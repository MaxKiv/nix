use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::peripherals::*;
use embassy_stm32::timer::simple_pwm::SimplePwm;
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::watch::Watch;
use embassy_time::Delay;
use l9110::L9110;

use crate::motor::{MotorCommand, MotorState};

pub static KNIFE_SETPOINT: Watch<CriticalSectionRawMutex, MotorCommand, 2> = Watch::new();

pub struct KnifeMotorPeripherals {
    /// PWM driver to control L9110, requires minimum 2 channels
    pub pwm: SimplePwm<'static, TIM1>,
}

pub fn setup(p: KnifeMotorPeripherals, spawner: &Spawner) {
    info!("Setting up knife motor");

    // Set up L9110 momtor driver
    let l9110 = L9110::try_new("Knife", p.pwm, embassy_time::Delay).unwrap();

    spawner.spawn(manage_knife_motor(l9110)).unwrap();
}

#[embassy_executor::task]
pub async fn manage_knife_motor(mut l9110: L9110<TIM1, Delay>) {
    info!("Starting to manage knife motor");

    // start disabled
    l9110.coast();
    let mut rx = KNIFE_SETPOINT
        .receiver()
        .expect("increase KNIFE_SETPOINT N");

    loop {
        let cmd = rx.changed().await;

        match &cmd.state {
            MotorState::Braking => l9110.short_break().await,
            MotorState::Coasting => l9110.coast(),
            MotorState::Enabled => l9110.run(cmd.speed),
        };
    }
}
