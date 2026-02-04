use defmt::*;
use display_interface_i2c::I2CInterface;
use embassy_executor::Spawner;
use embassy_stm32::{
    Peri, bind_interrupts,
    i2c::{self, I2c, Master},
    mode::Async,
    peripherals::*,
};
use embassy_time::{Delay, Duration, Ticker, Timer};
use embedded_graphics::{
    Drawable,
    image::{Image, ImageRawLE},
};
use embedded_graphics::{
    mono_font::{MonoTextStyleBuilder, ascii::FONT_6X10},
    pixelcolor::BinaryColor,
    prelude::Point,
    text::{Baseline, Text},
};
use ssd1309::{Builder, mode::GraphicsMode};

use crate::button::{ButtonPressed, WATCH_BUTTON};

/// Period at which this task is ticked
const LCD_PERIOD: Duration = Duration::from_millis(100);
const ADDRESS: u8 = 0x3C;
const DATA_BYTE: u8 = 0x40;

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

    let disp = Builder::new().connect(i2c_interface).into();
    spawner.spawn(manage_display(disp)).unwrap();
}

#[embassy_executor::task]
pub async fn manage_display(mut display: GraphicsMode<I2CInterface<I2c<'static, Async, Master>>>) {
    info!("Starting to manage display");

    let mut rx = WATCH_BUTTON
        .receiver()
        .expect("Not enough watch button receivers");

    let mut ticker = Ticker::every(LCD_PERIOD);

    while display.init().is_err() {
        error!("Unable to initialise display, is it connected?");
        Timer::after(Duration::from_millis(1000)).await;
    }
    display.clear();
    flush_logged(&mut display);

    let joris_im: ImageRawLE<BinaryColor> = ImageRawLE::new(
        include_bytes!("/home/max/git/saxion/peeler_mouse/data/joris.raw"),
        128,
    );
    let joris = Image::new(&joris_im, Point::new(0, 0));

    let rene_im: ImageRawLE<BinaryColor> = ImageRawLE::new(
        include_bytes!("/home/max/git/saxion/peeler_mouse/data/rene.raw"),
        128,
    );
    let rene = Image::new(&rene_im, Point::new(0, 0));

    let lex_im: ImageRawLE<BinaryColor> = ImageRawLE::new(
        include_bytes!("/home/max/git/saxion/peeler_mouse/data/lex.raw"),
        128,
    );
    let lex = Image::new(&lex_im, Point::new(0, 0));

    // let text_style = MonoTextStyleBuilder::new()
    //     .font(&FONT_6X10)
    //     .text_color(BinaryColor::On)
    //     .build();
    //
    // Text::with_baseline("Hello world!", Point::zero(), text_style, Baseline::Top)
    //     .draw(&mut display)
    //     .unwrap();

    loop {
        let button = rx.changed().await;

        use ButtonPressed::*;
        match button {
            b @ Button3 => {
                info!("LCD task received button press: {:?} - Drawing Joris", b);

                // TODO: move to async display https://201.rustiec.be/4_display_async.html
                joris.draw(&mut display).unwrap();
                flush_logged(&mut display);
            }
            b @ Button4 => {
                info!("LCD task received button press: {:?} - Drawing Rene", b);
                rene.draw(&mut display).unwrap();
                flush_logged(&mut display);
            }
            b @ Button5 => {
                info!("LCD task received button press: {:?} - Drawing Lex", b);
                lex.draw(&mut display).unwrap();
                flush_logged(&mut display);
            }
            b => info!("LCD task ignoring button {:?}", b),
        }
    }
}

fn flush_logged(display: &mut GraphicsMode<I2CInterface<I2c<'static, Async, Master>>>) {
    if display.flush().is_err() {
        error!("Unable to flush display, skipping...");
    }
}
