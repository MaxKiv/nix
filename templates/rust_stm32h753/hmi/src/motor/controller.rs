use crate::{
    motor::{
        MotorCommand, MotorState, knife::CUT_SETPOINT, rotation::ROTATION_SETPOINT,
        translation::TRANSLATION_SETPOINT,
    },
    supervisor::{
        MotorSetpoint, SelectedMotor,
        task::{
            APPSTATE_WATCH, MAX_CUT_VELOCITY_MM_PS, MAX_ROTATION_VELOCITY_MM_PS,
            MAX_TRANSLATION_VELOCITY_MM_PS,
        },
    },
};
use defmt::*;
use embassy_executor::Spawner;
use l9110::CUT_MAX_SPEED_MS_PS;
use uom::si::{f32::Velocity, velocity::millimeter_per_second};

pub fn setup(spawner: &Spawner) {
    info!("Setting up Motor Contoller");

    spawner.spawn(control_motors()).unwrap();
}

#[embassy_executor::task]
async fn control_motors() {
    let mut appstate_rx = APPSTATE_WATCH
        .receiver()
        .expect("Increase APPSTATE_WATCH N");

    let cut_tx = CUT_SETPOINT.sender();
    let rotation_tx = ROTATION_SETPOINT.sender();
    let translation_tx = TRANSLATION_SETPOINT.sender();

    loop {
        // Wait for a new application state to arive
        let appstate = appstate_rx.changed().await;

        let pairs = [
            (
                &appstate.rotation_setpoint,
                &rotation_tx,
                SelectedMotor::Rotation,
            ),
            (
                &appstate.translation_setpoint,
                &translation_tx,
                SelectedMotor::Translation,
            ),
            (&appstate.cut_setpoint, &cut_tx, SelectedMotor::Cut),
        ];

        for (setpoint, tx, motor_type) in pairs.iter() {
            // Construct the appropriate motor setpoint
            let MotorSetpoint {
                enabled,
                speed_percentage,
                dir,
            } = setpoint;

            // Map motor disabled -> coasting
            let state = match enabled {
                true => MotorState::Enabled,
                false => MotorState::Coasting,
            };

            let speed = speed_percentage_to_velocity(*speed_percentage, motor_type);
            let cmd = MotorCommand {
                speed,
                state,
                dir: dir.clone(),
            };

            // Send the command to the right motor
            debug!(
                "Controller - {} Sending {} {} {}mm/s",
                motor_type,
                cmd.state,
                cmd.dir,
                cmd.speed.get::<millimeter_per_second>()
            );
            tx.send(cmd)
        }
    }
}

fn speed_percentage_to_velocity(speed_percentage: f32, selected_motor: &SelectedMotor) -> Velocity {
    let max_velocity = match selected_motor {
        SelectedMotor::Translation => MAX_TRANSLATION_VELOCITY_MM_PS,
        SelectedMotor::Rotation => MAX_ROTATION_VELOCITY_MM_PS,
        SelectedMotor::Cut => CUT_MAX_SPEED_MS_PS,
    };

    let speed = speed_percentage * max_velocity / 100.0;

    debug!(
        "Controller - {} converted {}% speed to {}mm/s (max = {})",
        selected_motor, speed_percentage, speed, max_velocity
    );

    Velocity::new::<millimeter_per_second>(speed)
}
