use defmt::*;
use embassy_executor::Spawner;
use embassy_futures::select::{Either, select};
use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex, watch::Watch};
use uom::si::{f32::Velocity, velocity::millimeter_per_second};

use crate::{
    hmi::button::BUTTON_WATCH_SIZE,
    motor::{MotorCommand, MotorState, knife, linear, rotation},
};

pub static KNIFE_ENABLED: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> =
    Watch::new();
pub static KNIFE_DIRECTION: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> =
    Watch::new();

pub static LINEAR_ENABLED: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> =
    Watch::new();
pub static LINEAR_DIRECTION: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> =
    Watch::new();

pub static ROTATION_ENABLED: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> =
    Watch::new();
pub static ROTATION_DIRECTION: Watch<CriticalSectionRawMutex, bool, { BUTTON_WATCH_SIZE }> =
    Watch::new();

pub const DEFAULT_ROTATION_VELOCITY_MM_PS: f32 = 0.1;
pub const DEFAULT_LINEAR_VELOCITY_MM_PS: f32 = 1.0;
pub const DEFAULT_KNIFE_VELOCITY_MM_PS: f32 = 1.4;

pub fn setup(spawner: &Spawner) {
    info!("Setting up Supervisor");

    spawner.spawn(supervise_knife()).unwrap();
    spawner.spawn(supervise_linear()).unwrap();
    spawner.spawn(supervise_rotation()).unwrap();
}

#[embassy_executor::task]
async fn supervise_knife() {
    let mut knife_enabled = KNIFE_ENABLED.receiver().expect("Increase Knife Enabled N");
    let mut knife_direction = KNIFE_DIRECTION
        .receiver()
        .expect("Increase Knife Direction N");

    let knife_out = knife::KNIFE_SETPOINT.sender();

    let mut knife_setpoint = MotorCommand {
        speed: Velocity::new::<millimeter_per_second>(DEFAULT_KNIFE_VELOCITY_MM_PS),
        state: MotorState::Coasting,
    };

    info!("Starting to supervise knife motor");

    loop {
        match select(knife_enabled.changed(), knife_direction.changed()).await {
            // Knife ENABLE pressed
            Either::First(_) => {
                knife_setpoint.state = match knife_setpoint.state {
                    MotorState::Enabled => MotorState::Coasting,
                    _ => MotorState::Enabled,
                };
            }
            // Knife DIR pressed, swap speed
            Either::Second(_) => {
                knife_setpoint.speed = -knife_setpoint.speed;
            }
        }

        knife_out.send(knife_setpoint.clone());
    }
}

#[embassy_executor::task]
async fn supervise_linear() {
    let mut linear_enabled = LINEAR_ENABLED
        .receiver()
        .expect("Increase Linear Enabled N");
    let mut linear_direction = LINEAR_DIRECTION
        .receiver()
        .expect("Increase Linear Direction N");

    let linear_out = linear::LINEAR_SETPOINT.sender();

    let mut linear_setpoint = MotorCommand {
        speed: Velocity::new::<millimeter_per_second>(DEFAULT_LINEAR_VELOCITY_MM_PS),
        state: MotorState::Coasting,
    };

    info!("Starting to supervise linear motor");

    loop {
        match select(linear_enabled.changed(), linear_direction.changed()).await {
            // Linear ENABLE pressed
            Either::First(_) => {
                linear_setpoint.state = match linear_setpoint.state {
                    MotorState::Enabled => MotorState::Coasting,
                    _ => MotorState::Enabled,
                };
            }
            // Linear DIR pressed, swap speed
            Either::Second(_) => {
                linear_setpoint.speed = -linear_setpoint.speed;
            }
        }

        linear_out.send(linear_setpoint.clone());
    }
}

#[embassy_executor::task]
async fn supervise_rotation() {
    let mut rotation_enabled = ROTATION_ENABLED
        .receiver()
        .expect("Increase Rotation Enabled N");
    let mut rotation_direction = ROTATION_DIRECTION
        .receiver()
        .expect("Increase Rotation Direction N");

    let rotation_out = rotation::ROTATION_SETPOINT.sender();

    let mut rotation_setpoint = MotorCommand {
        speed: Velocity::new::<millimeter_per_second>(DEFAULT_ROTATION_VELOCITY_MM_PS),
        state: MotorState::Coasting,
    };

    info!("Starting to supervise rotation motor");

    loop {
        match select(rotation_enabled.changed(), rotation_direction.changed()).await {
            // Rotation ENABLE pressed
            Either::First(_) => {
                rotation_setpoint.state = match rotation_setpoint.state {
                    MotorState::Enabled => MotorState::Coasting,
                    _ => MotorState::Enabled,
                };
            }
            // Rotation DIR pressed, swap speed
            Either::Second(_) => {
                rotation_setpoint.speed = -rotation_setpoint.speed;
            }
        }

        rotation_out.send(rotation_setpoint.clone());
    }
}
