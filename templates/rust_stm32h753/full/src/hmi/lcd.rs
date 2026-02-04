use defmt::*;
use display_interface_i2c::I2CInterface;
use embassy_executor::Spawner;
use embassy_stm32::{
    Peri, bind_interrupts,
    i2c::{self, I2c, Master},
    mode::Async,
    peripherals::*,
};
use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex, watch::Watch};
use embassy_time::{Duration, Ticker, Timer};
use embedded_graphics::{
    Drawable,
    image::{Image, ImageRawLE},
    mono_font::{MonoTextStyleBuilder, ascii::FONT_6X10},
    text::{Baseline, Text},
};
use embedded_graphics::{pixelcolor::BinaryColor, prelude::Point};
use heapless::format;
use oled_async::{
    builder::Builder, displays::ssd1309::Ssd1309_128_64, mode::GraphicsMode,
    prelude::DisplayRotation,
};

use crate::{
    hmi::button::BUTTON_WATCH_SIZE,
    motor::{knife::KNIFE_SETPOINT, linear::LINEAR_SETPOINT, rotation::ROTATION_SETPOINT},
};

pub static LCD_INPUT: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> = Watch::new();

/// Period at which this task is ticked
const LCD_PERIOD: Duration = Duration::from_millis(500);
const ADDRESS: u8 = 0x3C;
const DATA_BYTE: u8 = 0x40;
const SSD1309_FRAMEBUFFER_SIZE: usize = 128 * 64 / 8;
const TEXT_OFFSET_HEIGHT: i32 = 14;

bind_interrupts!(struct Irqs {
    I2C2_EV => i2c::EventInterruptHandler<I2C2>;
    I2C2_ER => i2c::ErrorInterruptHandler<I2C2>;
});

pub struct LcdPeripherals {
    pub i2c: Peri<'static, I2C2>,
    pub sda: Peri<'static, PF0>,
    pub scl: Peri<'static, PF1>,
    pub tx_dma: Peri<'static, DMA1_CH4>,
    pub rx_dma: Peri<'static, DMA1_CH5>,
}

pub fn setup(p: LcdPeripherals, spawner: &Spawner) {
    info!("Setting up display");

    // Set up I2C
    let i2c = I2c::new(
        p.i2c,
        p.scl,
        p.sda,
        Irqs,
        p.tx_dma,
        p.rx_dma,
        Default::default(),
    );
    let i2c_interface = I2CInterface::new(i2c, ADDRESS, DATA_BYTE);

    // Set up display
    type Display = oled_async::displays::ssd1309::Ssd1309_128_64;
    let raw_disp = Builder::new(Display {})
        .with_rotation(DisplayRotation::Rotate180)
        .connect(i2c_interface);
    let disp: GraphicsMode<_, _, { SSD1309_FRAMEBUFFER_SIZE }> = raw_disp.into();

    spawner.spawn(manage_display(disp)).unwrap();
}

#[embassy_executor::task]
pub async fn manage_display(
    mut display: GraphicsMode<
        Ssd1309_128_64,
        I2CInterface<I2c<'static, Async, Master>>,
        { SSD1309_FRAMEBUFFER_SIZE },
    >,
) {
    info!("Starting to manage display");

    let mut ticker = Ticker::every(LCD_PERIOD);

    // let mut rx = LCD_INPUT.receiver().expect("Increase LCD_INPUT N");
    let mut knife_rx = KNIFE_SETPOINT
        .receiver()
        .expect("increase KNIFE_SETPOINT N");
    let mut linear_rx = LINEAR_SETPOINT
        .receiver()
        .expect("increase LINEAR_SETPOINT N");
    let mut rotation_rx = ROTATION_SETPOINT
        .receiver()
        .expect("increase ROTATION_SETPOINT N");

    // Initialise display
    while display.init().await.is_err() {
        error!("Unable to initialise display, is it connected?");
        Timer::after(Duration::from_millis(1000)).await;
    }
    display.clear();
    display.flush().await.unwrap();

    // Load image data
    let joris_im: ImageRawLE<BinaryColor> = ImageRawLE::new(
        include_bytes!("/home/max/git/saxion/peeler_mouse/data/joris.raw"),
        128,
    );
    let joris = Image::new(&joris_im, Point::new(0, 0));

    // let rene_im: ImageRawLE<BinaryColor> = ImageRawLE::new(
    //     include_bytes!("/home/max/git/saxion/peeler_mouse/data/rene.raw"),
    //     128,
    // );
    // let rene = Image::new(&rene_im, Point::new(0, 0));
    //
    // let lex_im: ImageRawLE<BinaryColor> = ImageRawLE::new(
    //     include_bytes!("/home/max/git/saxion/peeler_mouse/data/lex.raw"),
    //     128,
    // )
    // let lex = Image::new(&lex_im, Point::new(0, 0));

    joris.draw(&mut display).unwrap();
    if display.flush().await.is_err() {
        error!("Unable to flush display");
    }

    let text_style = MonoTextStyleBuilder::new()
        .font(&FONT_6X10)
        .text_color(BinaryColor::On)
        .build();

    // Give people time to appreciate the beautifull splash screen
    Timer::after_millis(500).await;

    // Main Display loop
    loop {
        display.clear();

        // get latest setpoints
        let knife_cmd = knife_rx.try_get().unwrap_or_default();
        let linear_cmd = linear_rx.try_get().unwrap_or_default();
        let rotation_cmd = rotation_rx.try_get().unwrap_or_default();

        // Format data
        let knife_str = format!(128; "Cut: {}", knife_cmd)
            .expect("knife cmd string doesn't fit heapless string");
        let linear_str = format!(128; "Lin: {}", linear_cmd)
            .expect("linear cmd string doesn't fit heapless string");
        let rotation_str = format!(128; "Rot: {}", rotation_cmd)
            .expect("rotation cmd string doesn't fit heapless string");

        // Draw to display
        let to_plot = [&knife_str, &linear_str, &rotation_str];
        for (idx, data) in to_plot.iter().enumerate() {
            Text::with_baseline(
                data,
                Point::new(10, TEXT_OFFSET_HEIGHT * idx as i32),
                text_style,
                Baseline::Top,
            )
            .draw(&mut display)
            .unwrap();
        }
        if display.flush().await.is_err() {
            warn!("Unable to flush display");
            while display.init().await.is_err() {
                error!("Unable to initialise display, is it connected?");
                Timer::after(Duration::from_millis(1000)).await;
            }
        }

        ticker.next().await;
    }
}
