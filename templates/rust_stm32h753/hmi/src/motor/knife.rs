use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::timer::simple_pwm::SimplePwm;
use embassy_stm32::{peripherals::*, timer::complementary_pwm::ComplementaryPwm};
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::watch::Watch;
use embassy_time::Delay;
use l9110::L9110;

use crate::motor::{MotorCommand, MotorDirection, MotorState};

pub static CUT_SETPOINT: Watch<CriticalSectionRawMutex, MotorCommand, 2> = Watch::new();

pub struct CutMotorPeripherals {
    /// PWM driver to control L9110, requires minimum 2 channels
    pub pwm: SimplePwm<'static, TIM1>,
}

pub fn setup(p: CutMotorPeripherals, spawner: &Spawner) {
    info!("Setting up cutting motor");

    // Set up L9110 motor driver
    let l9110 = L9110::try_new("Cut", p.pwm, embassy_time::Delay).unwrap();

    spawner.spawn(manage_cutting_motor(l9110)).unwrap();
}

#[embassy_executor::task]
pub async fn manage_cutting_motor(mut l9110: L9110<TIM1, Delay>) {
    info!("Starting to manage cut motor");

    // start disabled
    l9110.coast();
    let mut rx = CUT_SETPOINT.receiver().expect("increase CUT_SETPOINT N");

    loop {
        let cmd = rx.changed().await;

        match &cmd.state {
            MotorState::Braking => l9110.short_break().await,
            MotorState::Coasting => l9110.coast(),
            MotorState::Enabled => {
                if cmd.dir == MotorDirection::Forward {
                    l9110.forward(cmd.speed)
                } else {
                    l9110.reverse(cmd.speed)
                }
            }
        };
    }
}
