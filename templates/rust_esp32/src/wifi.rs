use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex as Cs, watch::Sender};
use embassy_time::Timer;
use esp_idf_hal::modem::Modem;
use esp_idf_svc::{
    eventloop::{EspEventLoop, System},
    nvs::{EspNvsPartition, NvsDefault},
    timer::{EspTimerService, Task},
    wifi::{AccessPointConfiguration, AsyncWifi, ClientConfiguration, Configuration, EspWifi},
};

use dotenvy_macro::dotenv;
use log::*;

#[derive(Clone)]
pub enum WifiState {
    Disconnected,
    Connected,
}

#[embassy_executor::task]
pub async fn wifi_task(
    mut modem: Modem,
    sys_loop: EspEventLoop<System>,
    nvs: EspNvsPartition<NvsDefault>,
    timer_service: EspTimerService<Task>,
    wifi_state_sender: Sender<'static, Cs, WifiState, 1>,
) {
    log::info!("Setting up Wifi stack");

    loop {
        match try_connect(
            dotenv!("WIFI_SSID"),
            dotenv!("WIFI_PASSWORD"),
            &mut modem,
            sys_loop.clone(),
            nvs.clone(),
            timer_service.clone(),
        )
        .await
        {
            Ok(wifi) => {
                wifi_state_sender.send(WifiState::Connected);

                // Ghetto connectivity check
                // TODO: await EspEventLoop for wifi disconnected events
                loop {
                    if !wifi.is_connected().unwrap_or(false) {
                        warn!("Wifi connection dropped!");
                        break;
                    }

                    Timer::after_millis(1000).await;
                }
            }
            Err(err) => {
                warn!("Wifi unable to connect: {err}, retrying...");
            }
        }
    }
}

async fn try_connect<'a>(
    ssid: &'static str,
    password: &'static str,
    modem: &'a mut Modem,
    sys_loop: EspEventLoop<System>,
    nvs: EspNvsPartition<NvsDefault>,
    timer_service: EspTimerService<Task>,
) -> anyhow::Result<AsyncWifi<EspWifi<'a>>> {
    let mut wifi = AsyncWifi::wrap(
        EspWifi::new(modem, sys_loop.clone(), Some(nvs))?,
        sys_loop,
        timer_service,
    )?;

    // let client_cfg = ClientConfiguration {
    //         ssid: ssid
    //             .try_into()
    //             .map_err(|_| anyhow::anyhow!("unable to fit {ssid} into heapless string"))?,
    //         bssid: None,
    //         auth_method: AuthMethod::WPA2Personal,
    //         password: password
    //             .try_into()
    //             .map_err(|_| anyhow::anyhow!("unable to fit {password} into heapless string"))?,
    //         channel: None,
    //         ..Default::default()
    // }

    let configuration = Configuration::AccessPoint(AccessPointConfiguration::default());

    // let configuration = Configuration::Mixed(
    //     ClientConfiguration {
    //         ssid: ssid
    //             .try_into()
    //             .map_err(|_| anyhow::anyhow!("unable to fit {ssid} into heapless string"))?,
    //         bssid: None,
    //         auth_method: AuthMethod::WPA2Personal,
    //         password: password
    //             .try_into()
    //             .map_err(|_| anyhow::anyhow!("unable to fit {password} into heapless string"))?,
    //         channel: None,
    //         ..Default::default()
    //     },
    //     AccessPointConfiguration {
    //         ..Default::default()
    //     },
    // );

    wifi.set_configuration(&configuration)?;

    wifi.start().await?;
    log::info!("Wifi started");

    // wifi.connect().await?;
    // log::info!("Wifi connected");

    wifi.wait_netif_up().await?;
    log::info!("Wifi netif up");

    log::info!("Device ip: {}", wifi.wifi().ap_netif().get_ip_info()?.ip);
    Ok(wifi)
}
