use defmt::*;
use embassy_executor::Spawner;
use embassy_futures::select::Either6;
use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex as Cs, watch::Watch};
use uom::si::f32::Velocity;
use uom::si::velocity::millimeter_per_second;

use crate::hmi::button::BUTTON_WATCH_SIZE;
use crate::hmi::encoder::data::EncoderData;
use crate::supervisor::SelectedMotor;
use crate::supervisor::appstate::Appstate;

pub static APPSTATE_WATCH: Watch<Cs, Appstate, 2> = Watch::new();

pub static ROTATION_SELECTED: Watch<Cs, bool, { BUTTON_WATCH_SIZE }> = Watch::new();
pub static TRANSLATION_SELECTED: Watch<Cs, bool, { BUTTON_WATCH_SIZE }> = Watch::new();
pub static CUT_SELECTED: Watch<Cs, bool, { BUTTON_WATCH_SIZE }> = Watch::new();
pub static STOP_ALL_SELECTED: Watch<Cs, bool, { BUTTON_WATCH_SIZE }> = Watch::new();
pub static ENCODER_PRESSED: Watch<Cs, bool, { BUTTON_WATCH_SIZE }> = Watch::new();
pub static ENCODER_DATA: Watch<Cs, EncoderData, 2> = Watch::new();

pub const MOTOR_SPEED_STEPS: usize = 10;
pub const DEFAULT_ROTATION_VELOCITY_MM_PS: f32 = 0.0;
pub const DEFAULT_TRANSLATION_VELOCITY_MM_PS: f32 = 0.0;
pub const DEFAULT_CUT_VELOCITY_MM_PS: f32 = 0.0;
pub const MAX_ROTATION_VELOCITY_MM_PS: f32 = 10.0;
pub const MAX_TRANSLATION_VELOCITY_MM_PS: f32 = 1.0;
pub const MAX_CUT_VELOCITY_MM_PS: f32 = 1.4;

pub fn setup(spawner: &Spawner) {
    info!("Setting up Supervisor");

    spawner.spawn(supervise()).unwrap();
}

/// Main supervisor loop, manages appstate
#[embassy_executor::task]
async fn supervise() {
    let mut rotation_selected_rx = ROTATION_SELECTED
        .receiver()
        .expect("Increase rotation_selected N");
    let mut translation_selected_tx = TRANSLATION_SELECTED
        .receiver()
        .expect("Increase translation_selected N");
    let mut cut_selected_rx = CUT_SELECTED.receiver().expect("Increase cut_selected N");
    let mut stop_all_selected_rx = STOP_ALL_SELECTED
        .receiver()
        .expect("Increase stop_all_selected N");
    let mut encoder_pressed_rx = ENCODER_PRESSED
        .receiver()
        .expect("Increase encoder_pressed N");

    let mut encoder_data_rx = ENCODER_DATA.receiver().expect("Increase encoder_data N");

    let appstate_tx = APPSTATE_WATCH.sender();

    // Initialise appstate
    let mut app_state = Appstate::default();
    // Select cut motor by default
    CUT_SELECTED.sender().send(true);

    loop {
        // Wait for a HMI input that we need to process
        match embassy_futures::select::select6(
            rotation_selected_rx.changed(),
            translation_selected_tx.changed(),
            cut_selected_rx.changed(),
            stop_all_selected_rx.changed(),
            encoder_pressed_rx.changed(),
            encoder_data_rx.changed(),
        )
        .await
        {
            // Rotation Selected Pressed -> Select Rotation motor
            Either6::First(_) => {
                debug!("Supervisor - Select Rotation Motor");
                app_state.select_motor(SelectedMotor::Rotation);
            }
            // Translation Selected Pressed -> Select Translation motor
            Either6::Second(_) => {
                debug!("Supervisor - Select Translation Motor");
                app_state.select_motor(SelectedMotor::Translation);
            }
            // Cut Selected Pressed -> Select cut motor
            Either6::Third(_) => {
                debug!("Supervisor - Select Cut Motor");
                app_state.select_motor(SelectedMotor::Cut);
            }
            // Stop All Selected Pressed -> Stop all motors
            Either6::Fourth(_) => {
                debug!("Supervisor - STOP ALL");
                app_state.stop_all();
            }
            // Encoder button pressed -> Stop current motor + Reverse direction
            Either6::Fifth(_) => {
                let mut setpoint = app_state.get_current_motor_setpoint();
                setpoint.speed_percentage = 0.0;
                setpoint.dir.reverse();
                setpoint.enabled = false;

                debug!(
                    "Supervisor - Reversing {:?}",
                    app_state.get_selected_motor()
                );

                app_state.set_current_motor_setpoint(setpoint);
            }
            // Encoder count change -> Change current motor speed
            Either6::Sixth(encoder_data) => {
                // Calculate new speed
                let selected_motor = app_state.get_selected_motor();
                let mut setpoint = app_state.get_current_motor_setpoint();
                let encoder_delta = encoder_data.pos.saturating_sub(app_state.last_encoder_pos);

                setpoint.speed_percentage = calculate_new_motor_speed_percentage(
                    selected_motor,
                    setpoint.speed_percentage,
                    encoder_delta,
                );

                if setpoint.speed_percentage > 0.0 {
                    debug!("Supervisor - speed {} > 0.0", setpoint.speed_percentage);
                    setpoint.enabled = true;
                } else {
                    debug!("Supervisor - speed {} = 0.0", setpoint.speed_percentage);
                    setpoint.enabled = false;
                }

                // Log change in speed
                debug!(
                    "Supervisor - Setting {} state {} speed {}%",
                    app_state.selected_motor, setpoint.enabled, setpoint.speed_percentage
                );

                app_state.last_encoder_pos = encoder_data.pos;
                app_state.set_current_motor_setpoint(setpoint);
            }
        }

        // Application state has changed, update downstream actuators & Display
        appstate_tx.send(app_state.clone());
    }
}

/// Calculates the new motor speed after a new encoder delta is received
/// This depends on the previous and maximum motor speed.
fn calculate_new_motor_speed_percentage(
    selected_motor: SelectedMotor,
    current_speed_percentage: f32,
    encoder_delta: i16,
) -> f32 {
    const STEP: f32 = 2.5;

    (current_speed_percentage + (STEP * encoder_delta as f32)).clamp(0.0, 100.0)
}
