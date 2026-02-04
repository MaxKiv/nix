use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::gpio::{Level, Output, Speed};
use embassy_stm32::timer::simple_pwm::SimplePwm;
use embassy_stm32::{Peri, peripherals::*};
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::watch::Watch;
use embassy_time::Delay;
use tb6600::{Direction, Tb6600};
use uom::si::f32::Velocity;
use uom::si::velocity::millimeter_per_second;

use crate::motor::{MotorCommand, MotorState};
use crate::supervisor::DEFAULT_LINEAR_VELOCITY_MM_PS;

pub static LINEAR_SETPOINT: Watch<CriticalSectionRawMutex, MotorCommand, 2> = Watch::new();

const MEASURED_SECONDS: f32 = 1.305053;
const MEASURED_DISTANCE_MM: f32 = 14.2;
const MEASURED_FREQ: f32 = 10000.0;
const MEASURED_STEPS_P_MM: f32 = (MEASURED_SECONDS * MEASURED_FREQ) / MEASURED_DISTANCE_MM;

pub enum LinearDirection {
    Outward,
    Inward,
}

impl From<LinearDirection> for Direction {
    fn from(val: LinearDirection) -> Self {
        match val {
            LinearDirection::Outward => Direction::Forward,
            LinearDirection::Inward => Direction::Reverse,
        }
    }
}

pub struct LinearMotorPeripherals {
    pub pwm: SimplePwm<'static, TIM3>,
    pub dir: Peri<'static, PF8>,
}

pub fn setup(p: LinearMotorPeripherals, spawner: &Spawner) {
    info!("Setting up linear motor");

    // Set up TB6600 Direction pin
    let dir = Output::new(p.dir, Level::Low, Speed::VeryHigh);
    // Set up TB6600 motordriver
    let tb = Tb6600::new("Linear", p.pwm, dir, embassy_time::Delay);

    spawner.spawn(manage_linear_motor(tb)).unwrap();
}

#[embassy_executor::task]
pub async fn manage_linear_motor(mut tb: Tb6600<TIM3, Output<'static>, Delay>) {
    info!("Starting to manage linear motor");

    // start disabled
    tb.stop();
    let mut rx = LINEAR_SETPOINT.receiver().expect("increase LINEAR_WATCH N");
    // let default_linear_velo = Velocity::new::<millimeter_per_second>(DEFAULT_LINEAR_VELOCITY_MM_PS);

    loop {
        let cmd = rx.changed().await;

        match &cmd.state {
            MotorState::Enabled => {
                if tb.run(cmd.speed).await.is_err() {
                    error!("Unable to run linear motor!");
                };
            }
            _ => tb.stop(),
        };
    }
}
