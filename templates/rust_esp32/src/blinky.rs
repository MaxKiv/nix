use embassy_time::{Duration, Ticker};
use esp_idf_hal::ledc::{config::TimerConfig, LedcDriver, LedcTimerDriver};
use log::*;

/// Period at which this task is ticked
const LED_DURATION: Duration = Duration::from_millis(500);

const DUTY_CYCLES_PERCENT: [f32; 6] = [0.0, 5.0, 10.0, 25.0, 10.0, 5.0];

#[embassy_executor::task]
pub async fn blink_led(
    timer: &'static esp_idf_hal::ledc::LedcTimerDriver<'static, esp_idf_hal::ledc::TIMER0>,
    channel: esp_idf_hal::ledc::CHANNEL0,
    led_pin: esp_idf_hal::gpio::Gpio33,
    // mut led: PinDriver<'static, AnyOutputPin, Output>, // mut led: LedcDriver<'static>,
) {
    info!("starting LED task");

    let mut led = LedcDriver::new(channel, timer, led_pin).expect("unable to construct LedcDriver");

    if let Err(err) = led.set_duty(0) {
        warn!("Blinky: {err}");
    }

    let mut ticker = Ticker::every(LED_DURATION / 2);
    let mut id = 0;
    let max_dc = led.get_max_duty();

    loop {
        let dc = ((DUTY_CYCLES_PERCENT[id] / 100.0) * max_dc as f32) as u32;

        if let Err(err) = led.set_duty(dc) {
            warn!("Blinky: {err}");
        }

        id += 1;
        if id > 5 {
            id = 0;
        }

        ticker.next().await;
    }
}
