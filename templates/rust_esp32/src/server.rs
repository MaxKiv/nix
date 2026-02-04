use std::sync::Arc;

use embassy_sync::{
    blocking_mutex::raw::CriticalSectionRawMutex as Cs,
    watch::{Receiver, Sender},
};
use esp_idf_hal::io::Write;
use esp_idf_svc::http::{
    server::{EspHttpConnection, EspHttpServer, Request},
    Method,
};
use log::*;

use crate::{espcam::Camera, request::ReadableRequest, wifi::WifiState, Setpoint};

#[embassy_executor::task]
pub async fn server_task(
    camera: Arc<Camera<'static>>,
    mut wifi_state_receiver: Receiver<'static, Cs, WifiState, 1>,
    setpoint_sender: Sender<'static, Cs, Setpoint, 1>,
) {
    loop {
        // Set up a HTTP server when wifi is connected
        match wifi_state_receiver.try_get() {
            Some(WifiState::Connected) => {
                match EspHttpServer::new(&esp_idf_svc::http::server::Configuration::default()) {
                    Ok(mut server) => {
                        // Set up HTTP server handlers
                        if let Err(err) = server.fn_handler("/", Method::Get, handle_root) {
                            error!("Unable to set up HTTP Server root handler: {err}, retrying...");
                        }
                        let camera = camera.clone();
                        if let Err(err) =
                            server.fn_handler("/camera", Method::Get, move |request| {
                                handle_camera(request, &camera)
                            })
                        {
                            error!("Unable to set up HTTP Server root handler: {err}, retrying...");
                        }

                        let sender = setpoint_sender.clone();
                        if let Err(err) =
                            server.fn_handler("/setpoint", Method::Post, move |request| {
                                handle_setpoint(request, &sender)
                            })
                        {
                            error!("Unable to set up HTTP Server root handler: {err}, retrying...");
                        }

                        // Keep server alive untill wifi connection drops
                        loop {
                            if let WifiState::Disconnected = wifi_state_receiver.changed().await {
                                warn!("WiFi disconnected, shutting down HTTP server...");
                                break; // drops server -> EspHttpServer::drop stops it
                            }
                        }

                        core::future::pending::<()>().await;
                    }
                    Err(err) => {
                        error!("Unable to set up HTTP Server: {err}, retrying...");
                    }
                }
            }
            _ => {
                warn!("Wifi is not yet connected -> Can't set up webserver, retrying soon...");
                embassy_time::Timer::after_millis(500).await;
            }
        }
    }
}

fn handle_root(request: Request<&mut EspHttpConnection<'_>>) -> anyhow::Result<()> {
    // A cursed html + javascript static webpage
    let data = r#"
        <html>
          <body>
            <input type="number" id="depth" placeholder="0">
            <button onclick="sendSetpoint()">Send Setpoint</button>

            <script>
              function sendSetpoint() {
                console.log("MAX triggered sendsetpoint")
                const depth = document.getElementById("depth").value;
                fetch("/setpoint", {
                  method: "POST",
                  headers: {
                    "Content-Type": "application/json",
                    "Connection": "close" // force a new request/connection
                  },
                  body: JSON.stringify({ depth: parseFloat(depth) })
                }).then(resp => resp.text())
                  .then(txt => alert("Response: " + txt))
                  .catch(err => alert("Error: " + err));
              }
            </script>
          </body>
        </html>
    "#;

    let headers = [
        ("Content-Type", "text/html"),
        ("Content-Length", &data.len().to_string()),
    ];

    let mut response = request.into_response(200, Some("OK"), &headers)?;
    response.write_all(data.as_bytes())?;
    response.flush()?;
    Ok(())
}

fn handle_camera(
    request: Request<&mut EspHttpConnection<'_>>,
    camera: &Arc<Camera>,
) -> anyhow::Result<()> {
    let part_boundary = "123456789000000000000987654321";
    let frame_boundary = format!("\r\n--{part_boundary}\r\n");

    let content_type = format!("multipart/x-mixed-replace;boundary={part_boundary}");
    let headers = [("Content-Type", content_type.as_str())];
    let mut response = request.into_response(200, Some("OK"), &headers)?;
    loop {
        if let Some(fb) = camera.get_framebuffer() {
            let data = fb.data();
            let frame_part = format!(
                "Content-Type: image/jpeg\r\nContent-Length: {}\r\n\r\n",
                data.len()
            );
            response.write_all(frame_part.as_bytes())?;
            response.write_all(data)?;
            response.write_all(frame_boundary.as_bytes())?;
            response.flush()?;
        }
    }
}

fn handle_setpoint(
    mut request: Request<&mut EspHttpConnection<'_>>,
    sender: &Sender<'static, Cs, Setpoint, 1>,
) -> anyhow::Result<()> {
    log::info!("Received setpoint");

    // Try to deserialize received data into setpoint
    let readable_request = ReadableRequest(&mut request);
    let setpoint: Setpoint = match readable_request.deserialize_into() {
        Ok(r) => r,
        Err(err) => {
            log::warn!("Unable to deserialize get request into setpoint: {err}",);
            let mut response = request.into_response(
                400,
                Some("Bad Request"),
                &[("Content-Type", "text/plain")],
            )?;
            response.write_all(format!("Invalid JSON: {err}").as_bytes())?;
            response.flush()?;
            return Ok(());
        }
    };
    log::info!("Deserialisation success! {setpoint:?}");

    sender.send(setpoint);

    // Success response
    let mut response = request.into_response(200, Some("OK"), &[("Content-Type", "text/plain")])?;
    response.write_all(b"Depth setpoint updated")?;
    response.flush()?;
    Ok(())
}
