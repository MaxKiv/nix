use defmt::*;
use embassy_executor::Spawner;
use embassy_futures::select::{Either3, select3};
use embassy_stm32::peripherals::*;
use embassy_stm32::timer::simple_pwm::SimplePwm;
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::watch::{self, Watch};
use embassy_time::Delay;
use l9110::{CUT_MAX_SPEED_MS_PS, Direction, L9110};
use uom::si::f32::Velocity;
use uom::si::velocity::millimeter_per_second;

use crate::button::{BUTTON_WATCH_SIZE, ButtonPeripherals, DebouncedButton};
use crate::pot::WATCH_POT;

static MOTOR_ENABLED: Watch<CriticalSectionRawMutex, bool, BUTTON_WATCH_SIZE> = Watch::new();
static MOTOR_DIRECTION: Watch<CriticalSectionRawMutex, bool, BUTTON_WATCH_SIZE> = Watch::new();

pub struct KnifeMotorPeripherals {
    /// PWM driver to control L9110, requires minimum 2 channels
    pub pwm: SimplePwm<'static, TIM1>,
    /// Button input to toggle knife motor operation
    pub enable_button: ButtonPeripherals<PC8>,
    /// Button input to toggle knife motor direction
    pub direction_button: ButtonPeripherals<PC9>,
}

pub fn setup(p: KnifeMotorPeripherals, spawner: &Spawner) {
    info!("Setting up knife motor");

    // Set up buttons
    let enable_rx = DebouncedButton::run(p.enable_button, &MOTOR_ENABLED, "Knife enable", spawner);
    let direction_rx = DebouncedButton::run(
        p.direction_button,
        &MOTOR_DIRECTION,
        "Knife direction",
        spawner,
    );

    // Set up L9110 driver
    let l9110 = L9110::try_new("Knife", p.pwm, embassy_time::Delay).unwrap();

    // spawner.spawn(latch_motor_movement(l9110)).unwrap();
    spawner
        .spawn(manage_knife_motor(l9110, enable_rx, direction_rx))
        .unwrap();
}

#[embassy_executor::task]
pub async fn manage_knife_motor(
    mut l9110: L9110<TIM1, Delay>,
    mut enable_rx: watch::Receiver<'static, CriticalSectionRawMutex, bool, BUTTON_WATCH_SIZE>,
    mut direction_rx: watch::Receiver<'static, CriticalSectionRawMutex, bool, BUTTON_WATCH_SIZE>,
) {
    info!("Starting to manage knife motor");

    // start disabled
    l9110.coast();

    let mut rx_pot = WATCH_POT.receiver().expect("increase WATCH_POT N");

    let mut enabled = false;
    let mut speed = Velocity::new::<millimeter_per_second>(0.0);
    let mut direction = Direction::Forward;

    loop {
        // Run knife motor at given setpoints
        if enabled {
            l9110.run(speed, &direction);
        } else {
            l9110.coast();
        }

        // Toggle L9110 enable and direction if their corresponding buttons are pressed
        match select3(
            enable_rx.changed(),
            direction_rx.changed(),
            rx_pot.changed(),
        )
        .await
        {
            Either3::First(_) => {
                info!("L9110 ENABLE changed");
                enabled = !enabled;
            }
            Either3::Second(_) => {
                info!("L9110 DIR changed");
                direction.flip();
            }
            Either3::Third(pot_value) => {
                speed = pot_to_speed(pot_value);
            }
        }
    }
}

fn pot_to_speed(pot: u16) -> Velocity {
    const MAX_POT: u16 = u16::MAX;

    let val = (pot as f32 / MAX_POT as f32) * CUT_MAX_SPEED_MS_PS;
    trace!("Converted pot value {} to speed {}mm/s", pot, val);

    Velocity::new::<millimeter_per_second>(val)
}
