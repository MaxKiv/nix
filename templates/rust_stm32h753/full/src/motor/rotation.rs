use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::gpio::{Level, Output, Speed};
use embassy_stm32::timer::simple_pwm::SimplePwm;
use embassy_stm32::{Peri, peripherals::*};
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::watch::{self, Watch};
use embassy_time::Delay;
use tb6600::{Direction, Tb6600};
use uom::si::velocity::millimeter_per_second;

use crate::hmi::button::BUTTON_WATCH_SIZE;
use crate::motor::{MotorCommand, MotorState};

pub static ROTATION_SETPOINT: Watch<CriticalSectionRawMutex, MotorCommand, 2> = Watch::new();

static MOTOR_ENABLED: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> = Watch::new();
static MOTOR_DIRECTION: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> = Watch::new();

const SECOND_PER_ROTATION_AT_2500_HZ: f32 = 12.63;
const STEPS_PER_ROTATION: u32 = SECOND_PER_ROTATION_AT_2500_HZ as u32 * 2500u32;

pub struct RotationMotorPeripherals {
    pub pwm: SimplePwm<'static, TIM4>,
    pub dir: Peri<'static, PF9>,
}

pub fn setup(p: RotationMotorPeripherals, spawner: &Spawner) {
    info!("Setting up rotational motor");

    // Set up TB6600 Direction pin
    let dir = Output::new(p.dir, Level::Low, Speed::VeryHigh);
    // Set up TB6600 motordriver
    let tb = Tb6600::new("Rotational", p.pwm, dir, embassy_time::Delay);

    spawner.spawn(manage_rotational_motor(tb)).unwrap();
}

#[embassy_executor::task]
pub async fn manage_rotational_motor(mut tb: Tb6600<TIM4, Output<'static>, Delay>) {
    info!("Starting to manage rotational motor");

    // start disabled
    tb.stop();
    let mut rx = ROTATION_SETPOINT
        .receiver()
        .expect("increase ROTATION_WATCH N");

    loop {
        let cmd = rx.changed().await;

        match &cmd.state {
            MotorState::Enabled => {
                if let Err(_) = tb.run(cmd.speed).await {
                    error!("unable to run Rotational motor");
                }
            }
            _ => tb.stop(),
        };
    }
}
