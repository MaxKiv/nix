use uom::si::f32::Velocity;

use crate::{motor::MotorDirection, supervisor::SelectedMotor};

#[derive(Clone)]
pub enum AppCmd {
    SelectMotor(SelectedMotor),
    StopAll,
    SetSpeed(Velocity),
    SetDirection(MotorDirection),
}
