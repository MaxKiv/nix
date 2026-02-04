pub mod setup;
pub mod startup;

use defmt::*;
use display_interface_i2c::I2CInterface;
use embassy_stm32::{
    i2c::{I2c, Master},
    mode::Async,
};
use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex, watch::Watch};
use embassy_time::{Duration, Ticker, Timer};
use embedded_graphics::{
    Drawable,
    mono_font::{MonoTextStyleBuilder, ascii::FONT_6X10},
    text::{Baseline, Text},
};
use embedded_graphics::{pixelcolor::BinaryColor, prelude::Point};
use heapless::format;
use oled_async::{displays::ssd1309::Ssd1309_128_64, mode::GraphicsMode};
use uom::si::{f32::Velocity, velocity::millimeter_per_second};

use crate::{
    hmi::{
        button::BUTTON_WATCH_SIZE,
        lcd::{setup::SSD1309_FRAMEBUFFER_SIZE, startup::startup_display},
    },
    motor::MotorDirection,
    supervisor::{
        MotorSetpoint, SelectedMotor,
        appstate::{self, Appstate},
        task::APPSTATE_WATCH,
    },
};

pub static LCD_INPUT: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> = Watch::new();

const LCD_PERIOD: Duration = Duration::from_millis(100);

// UI related
const TEXT_OFFSET_HEIGHT: i32 = 14;
const NUM_SPEED_BARS: usize = 8;

struct FontStyles<'a> {
    width: usize,
    selected: embedded_graphics::mono_font::MonoTextStyle<'a, BinaryColor>,
    unselected: embedded_graphics::mono_font::MonoTextStyle<'a, BinaryColor>,
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
    let mut appstate_tx = APPSTATE_WATCH
        .receiver()
        .expect("increase APPSTATE_WATCH N");

    // Set up fonts
    let font = &FONT_6X10;
    let selected = MonoTextStyleBuilder::new()
        .font(&font)
        .text_color(BinaryColor::Off)
        .background_color(BinaryColor::On)
        .build();
    let unselected = MonoTextStyleBuilder::new()
        .font(&font)
        .text_color(BinaryColor::On)
        .build();
    let font_styles = FontStyles {
        width: 6,
        selected,
        unselected,
    };

    // Start display
    startup_display(&mut display).await;

    // Main Display loop
    loop {
        display.clear();

        // Get latest state
        let latest_state = appstate_tx.try_get().unwrap_or_default();

        // use appstate to draw display
        draw_ui(&mut display, latest_state, &font_styles);

        // Flush display
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

fn draw_ui(
    display: &mut GraphicsMode<
        Ssd1309_128_64,
        I2CInterface<I2c<'static, Async, Master>>,
        { SSD1309_FRAMEBUFFER_SIZE },
    >,
    latest_state: Appstate,
    font_styles: &FontStyles,
) {
    let cut_str =
        format!(128; "Cut | {} {:>5.1}%", get_dir_str(&latest_state.cut_setpoint), latest_state.cut_setpoint.speed_percentage)
            .expect("Cut cmd string doesn't fit heapless string");
    let rot_str = format!(128; "Rot | {} {:>5.1}%", get_dir_str(&latest_state.rotation_setpoint), latest_state.rotation_setpoint.speed_percentage)
        .expect("rot cmd string doesn't fit heapless string");
    let lin_str =
        format!(128; "Lin | {} {:>5.1}%", get_dir_str(&latest_state.translation_setpoint),latest_state.translation_setpoint.speed_percentage)
            .expect("lin cmd string doesn't fit heapless string");

    let to_plot = [&cut_str, &lin_str, &rot_str];
    let selected: usize = match latest_state.selected_motor {
        SelectedMotor::Cut => 0,
        SelectedMotor::Translation => 1,
        SelectedMotor::Rotation => 2,
    };

    for (idx, data) in to_plot.iter().enumerate() {
        Text::with_baseline(
            data,
            Point::new(10, TEXT_OFFSET_HEIGHT * idx as i32),
            if idx == selected {
                font_styles.selected
            } else {
                font_styles.unselected
            },
            Baseline::Top,
        )
        .draw(display)
        .unwrap();
    }
}

fn get_dir_str(setpoint: &MotorSetpoint) -> &'static str {
    use MotorDirection::*;

    match setpoint.dir {
        Forward => "->",
        Backward => "<-",
    }
}
