use defmt::*;
use embassy_executor::Spawner;
use embassy_futures::select::{Either3, select3};
use embassy_stm32::peripherals::*;
use embassy_stm32::timer::simple_pwm::SimplePwm;
use embassy_stm32::{
    Peri,
    gpio::{Level, Output, Speed},
};
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::watch::Watch;
use embassy_time::{Delay, Duration, Ticker, Timer};
use tb6600::{Direction, Tb6600};

use crate::button::{ButtonPressed, WATCH_BUTTON};
use crate::pot::WATCH_POT;

static MOTOR_ENABLED: Watch<CriticalSectionRawMutex, bool, 1> = Watch::new();
static MOTOR_DIRECTION: Watch<CriticalSectionRawMutex, Direction, 1> = Watch::new();

pub struct LinearAxisMotorPeripherals {
    pub step: SimplePwm<'static, TIM3>,
    pub dir: Peri<'static, PF8>,
}

pub fn setup(p: LinearAxisMotorPeripherals, spawner: &Spawner) {
    info!("Setting up motors");

    let dir = Output::new(p.dir, Level::Low, Speed::VeryHigh);
    let tb = Tb6600::new("Translation", p.step, dir, embassy_time::Delay, 5);

    spawner.spawn(latch_motor_movement(tb)).unwrap();
    spawner.spawn(manage_linear_motor()).unwrap();
}

#[embassy_executor::task]
pub async fn manage_linear_motor() {
    let mut rx_enabled = WATCH_BUTTON
        .receiver()
        .expect("Not enough watch button receivers");

    let tx_enabled = MOTOR_ENABLED.sender();
    let tx_dir = MOTOR_DIRECTION.sender();

    info!("Starting to manage translation motor");

    let mut moving = false;
    let mut dir = Direction::Forward;
    loop {
        let button = rx_enabled.changed().await;

        use ButtonPressed::*;
        match button {
            b @ Button2 => {
                moving = !moving;
                info!(
                    "Motor task received button press: {:?} - {} motor",
                    b,
                    if moving { "moving" } else { "stopping" }
                );
                tx_enabled.send(moving);
            }
            b @ Button3 => {
                dir = match dir.clone() {
                    Direction::Forward => Direction::Reverse,
                    Direction::Reverse => Direction::Forward,
                };

                info!(
                    "Motor task received button press: {:?} - switched direction to {:?}",
                    b, dir
                );
                tx_dir.send(dir.clone())
            }

            b => info!("Motor task ignoring button {:?}", b),
        }
    }
}

#[embassy_executor::task]
async fn latch_motor_movement(mut tb: Tb6600<TIM3, Output<'static>, Delay>) {
    let mut ticker = Ticker::every(Duration::from_millis(100));
    let mut rx_enabled = MOTOR_ENABLED.receiver().expect("increase MOTOR_ENABLED N");
    let mut rx_direction = MOTOR_DIRECTION
        .receiver()
        .expect("increase MOTOR_DIRECTION N");
    let mut rx_speed = WATCH_POT.receiver().expect("increase WATCH_POT N");

    loop {
        let should_step = rx_enabled.get().await;
        let freq = rx_speed.get().await;
        tb.set_speed(freq.into());

        tb.control_stepping(should_step);

        // continue for 100ms or until a new enable or direction setpoint is received
        match select3(ticker.next(), rx_enabled.changed(), rx_direction.changed()).await {
            Either3::First(_) => {} // 100ms expired -> check for speed changes in next iteration
            Either3::Second(_) => {} // motor enabled/disabled -> next iteration
            Either3::Third(direction) => {
                // new direction, change direction and restart loop
                if let Err(err) = tb.set_direction(direction).await {
                    error!("Unable to change TB6600 direction: {:?}", err);
                }
            }
        }
    }
}
