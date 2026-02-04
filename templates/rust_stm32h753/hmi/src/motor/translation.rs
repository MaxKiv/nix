use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::gpio::{Level, Output, Speed};
use embassy_stm32::timer::simple_pwm::SimplePwm;
use embassy_stm32::{Peri, peripherals::*};
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::watch::Watch;
use embassy_time::Delay;
use tb6600::{Direction, Tb6600};

use crate::motor::{MotorCommand, MotorDirection, MotorState};

pub static TRANSLATION_SETPOINT: Watch<CriticalSectionRawMutex, MotorCommand, 2> = Watch::new();

const MEASURED_SECONDS: f32 = 1.305053;
const MEASURED_DISTANCE_MM: f32 = 14.2;
const MEASURED_FREQ: f32 = 10000.0;
const MEASURED_STEPS_P_MM: f32 = (MEASURED_SECONDS * MEASURED_FREQ) / MEASURED_DISTANCE_MM;

pub enum TranslationDirection {
    Outward,
    Inward,
}

impl From<TranslationDirection> for Direction {
    fn from(val: TranslationDirection) -> Self {
        match val {
            TranslationDirection::Outward => Direction::Forward,
            TranslationDirection::Inward => Direction::Reverse,
        }
    }
}

pub struct TranslationMotorPeripherals {
    pub pwm: SimplePwm<'static, TIM8>,
    pub dir: Peri<'static, PF8>,
}

pub fn setup(p: TranslationMotorPeripherals, spawner: &Spawner) {
    info!("Setting up translation motor");

    // Set up TB6600 Direction pin
    let dir = Output::new(p.dir, Level::Low, Speed::VeryHigh);
    // Set up TB6600 motordriver
    let tb = Tb6600::new("Tranlsation", p.pwm, dir, embassy_time::Delay);

    spawner.spawn(manage_translation_motor(tb)).unwrap();
}

#[embassy_executor::task]
pub async fn manage_translation_motor(mut tb: Tb6600<TIM8, Output<'static>, Delay>) {
    info!("Starting to manage translation motor");

    // start disabled
    tb.stop();
    let mut rx = TRANSLATION_SETPOINT
        .receiver()
        .expect("increase TRANSLATION_SETPOINT N");

    loop {
        let cmd = rx.changed().await;

        match &cmd.state {
            MotorState::Enabled => {
                if tb.run_with_dir(cmd.speed, cmd.dir.into()).await.is_err() {
                    error!("Unable to drive translation motor!");
                };
            }
            _ => tb.stop(),
        };
    }
}
