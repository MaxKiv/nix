use embassy_futures::select::select;
use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex as Cs, watch::Receiver};
use embassy_time::{Duration, Ticker};
use esp_idf_hal::ledc::LedcDriver;
use log::*;

use crate::Setpoint;

/// Period at which this task is ticked
const TASK_DURATION: Duration = Duration::from_millis(1000);

#[embassy_executor::task]
pub async fn control_loop(
    mut setpoint_receiver: Receiver<'static, Cs, Setpoint, 1>,
    timer: &'static esp_idf_hal::ledc::LedcTimerDriver<'static, esp_idf_hal::ledc::TIMER0>,
    channel_a: esp_idf_hal::ledc::CHANNEL1,
    pwm_pin_a: esp_idf_hal::gpio::Gpio12,
    channel_b: esp_idf_hal::ledc::CHANNEL2,
    pwm_pin_b: esp_idf_hal::gpio::Gpio13,
    // mut pwm_a: LedcDriver<'static>,
) {
    info!("starting control task");

    // Task timekeeper
    let mut ticker = Ticker::every(TASK_DURATION);

    // Construct pwms
    let mut pwm_a =
        LedcDriver::new(channel_a, timer, pwm_pin_a).expect("unable to construct pwm a driver");
    let mut pwm_b =
        LedcDriver::new(channel_b, timer, pwm_pin_b).expect("unable to construct pwm a driver");

    // Reset duty cycles
    if let Err(err) = pwm_a.set_duty(0) {
        warn!("Control: {err}");
    }
    if let Err(err) = pwm_b.set_duty(0) {
        warn!("Control: {err}");
    }

    loop {
        match select(ticker.next(), setpoint_receiver.changed()).await {
            embassy_futures::select::Either::First(_) => {
                // Timer passed, wait for next tick
                log::info!("Control task tick");
            }
            embassy_futures::select::Either::Second(setpoint) => {
                let dc = setpoint.get_depth_dutycycle();

                log::info!("Control task received new setpoint: {setpoint:?} - setting dc: {dc}");

                if let Err(err) = pwm_a.set_duty(setpoint.get_depth_dutycycle()) {
                    error!("Control: {err}");
                }
            }
        }
    }
}
