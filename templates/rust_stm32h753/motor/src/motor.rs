use defmt::*;
use display_interface_i2c::I2CInterface;
use embassy_executor::Spawner;
use embassy_stm32::{
    Peri, bind_interrupts,
    gpio::{Level, Output, OutputType, Speed},
    i2c::{self, I2c, Master},
    mode::Async,
    peripherals::*,
    timer::simple_pwm::PwmPin,
};
use embassy_time::{Delay, Duration, Ticker};
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
use tb6600::Tb6600;

use crate::button::{ButtonPressed, WATCH_BUTTON};

const MOTOR_PERIOD: Duration = Duration::from_millis(100);

pub struct MotorPeripherals {
    pub motor_step: Peri<'static, PE3>,
    pub motor_dir: Peri<'static, PF8>,
}

pub fn setup(p: MotorPeripherals, spawner: &Spawner) {
    info!("Setting up motors");
    // https://docs.embassy.dev/embassy-stm32/git/stm32h753zi/timer/simple_pwm/struct.SimplePwm.html
    // https://github.com/embassy-rs/embassy/blob/db8641740c1e4653ba3fad79744ca6f8a0a139ae/examples/stm32h7/src/bin/pwm.rs

    let step = Output::new(p.motor_step, Level::Low, Speed::VeryHigh);
    let dir = Output::new(p.motor_dir, Level::Low, Speed::VeryHigh);

    let tb = Tb6600::new(step, dir, embassy_time::Delay, 5);

    spawner.spawn(manage_motors(tb)).unwrap();
}

#[embassy_executor::task]
pub async fn manage_motors(mut tb: Tb6600<Output<'static>, Output<'static>, Delay>) {
    let mut rx = WATCH_BUTTON
        .receiver()
        .expect("Not enough watch button receivers");

    // let mut ticker = Ticker::every(MOTOR_PERIOD);

    info!("Starting to manage motors");

    loop {
        let button = rx.changed().await;

        use ButtonPressed::*;
        match button {
            b @ Button1 => {
                info!("Motor task received button press: {:?} - stepping once", b);
                if let Err(err) = tb.step_n(100).await {
                    error!("Err: {}", err);
                }
            }
            b @ Button2 => {
                info!(
                    "Motor task received button press: {:?} - stepping 10 times",
                    b
                );
                if let Err(err) = tb.step_n(1000).await {
                    error!("Err: {}", err);
                }
            }
            b => info!("Motor task ignoring button {:?}", b),
        }
    }
}
