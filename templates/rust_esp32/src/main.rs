pub mod blinky;
pub mod control;
pub mod espcam;
pub mod request;
mod server;
pub mod wifi;

use std::{ffi::CStr, sync::Arc};

use anyhow::Result;
use embassy_executor::Spawner;
use embassy_time::{Duration, Ticker};
use esp_idf_hal::{
    ledc::{config::TimerConfig, LedcDriver, LedcTimerDriver, TIMER0},
    prelude::Peripherals,
};
use esp_idf_svc::{
    eventloop::EspSystemEventLoop, nvs::EspDefaultNvsPartition, timer::EspTaskTimerService,
};

use crate::{control::setpoint::Setpoint, espcam::Camera, wifi::WifiState};
use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex as Cs, watch::Watch};
use static_cell::StaticCell;

static WIFI_STATE: Watch<Cs, WifiState, 1> = Watch::new();
static SETPOINT: Watch<Cs, Setpoint, 1> = Watch::new();

static TIMER: StaticCell<LedcTimerDriver<'_, TIMER0>> = StaticCell::new();

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    if let Err(err) = main_fallible(&spawner).await {
        log::error!("MAIN: {err}");
    }
}

async fn main_fallible(spawner: &Spawner) -> Result<()> {
    let _ = spawner;
    esp_idf_svc::sys::link_patches();
    esp_idf_svc::log::EspLogger::initialize_default();

    let version = unsafe { esp_idf_sys::esp_get_idf_version() };
    let version = unsafe { CStr::from_ptr(version) };
    let version = version.to_str()?;
    log::info!("ESP-IDF version: {version}");

    log::info!("Setting up peripherals, esp event loop, nvs partition and timer service");
    let peripherals = Peripherals::take()?;
    let sys_loop = EspSystemEventLoop::take()?;
    let nvs = EspDefaultNvsPartition::take()?;
    let timer_service = EspTaskTimerService::new()?;

    // let timer = TIMER.init(
    //     LedcTimerDriver::new(peripherals.ledc.timer0, &TimerConfig::default())
    //         .expect("Unable to construct LedcTimerDriver"),
    // );

    let timer = LedcTimerDriver::new(peripherals.ledc.timer0, &TimerConfig::default())?;
    let mut pwm_a = LedcDriver::new(peripherals.ledc.channel0, &timer, peripherals.pins.gpio12)?;
    let mut pwm_b = LedcDriver::new(peripherals.ledc.channel1, &timer, peripherals.pins.gpio13)?;

    // Duty: 0..=255 by default
    pwm_a.set_duty(128)?;
    pwm_b.set_duty(200)?;

    // log::info!("Initialize LED task");
    // spawner.spawn(blinky::blink_led(
    //     timer,
    //     peripherals.ledc.channel0,
    //     peripherals.pins.gpio33,
    // ))?;

    log::info!("Initialize Wifi task");
    spawner.spawn(wifi::wifi_task(
        peripherals.modem,
        sys_loop,
        nvs,
        timer_service,
        WIFI_STATE.sender(),
    ))?;

    log::info!("Setting up camera");
    let camera = Camera::new(
        peripherals.pins.gpio32,
        peripherals.pins.gpio0,
        peripherals.pins.gpio5,
        peripherals.pins.gpio18,
        peripherals.pins.gpio19,
        peripherals.pins.gpio21,
        peripherals.pins.gpio36,
        peripherals.pins.gpio39,
        peripherals.pins.gpio34,
        peripherals.pins.gpio35,
        peripherals.pins.gpio25,
        peripherals.pins.gpio23,
        peripherals.pins.gpio22,
        peripherals.pins.gpio26,
        peripherals.pins.gpio27,
        esp_idf_sys::camera::pixformat_t_PIXFORMAT_JPEG,
        // Set quality here
        esp_idf_sys::camera::framesize_t_FRAMESIZE_SVGA,
    )?;
    let cam_arc = Arc::new(camera);

    log::info!("Initialize Webserver task");
    spawner.spawn(server::server_task(
        cam_arc,
        WIFI_STATE
            .receiver()
            .expect("Max wifi_state receivers reached"),
        SETPOINT.sender(),
    ))?;

    // log::info!("Initialize Controller task");
    // spawner.spawn(control::controller::control_loop(
    //     SETPOINT.receiver().expect("Max setpoint receivers reached"),
    //     timer,
    //     peripherals.ledc.channel1,
    //     peripherals.pins.gpio12,
    //     peripherals.ledc.channel2,
    //     peripherals.pins.gpio13,
    // ))?;

    let mut ticker = Ticker::every(Duration::from_millis(1000));
    let mut dc_a = 0;
    let mut dc_b = 255;
    loop {
        pwm_a.set_duty(dc_a)?;
        pwm_b.set_duty(dc_b)?;

        dc_a = (dc_a + 10) % 255;
        dc_b = (dc_b + 10) % 255;

        ticker.next().await;
    }

    core::future::pending::<()>().await;

    Ok(())
}
