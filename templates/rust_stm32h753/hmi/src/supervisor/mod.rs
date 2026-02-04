use crate::motor::MotorDirection;

pub mod appstate;
pub mod cmd;
pub mod task;

/// Different motors used in the project
#[derive(Debug, Clone, Default, defmt::Format)]
pub enum SelectedMotor {
    #[default]
    Translation,
    Rotation,
    Cut,
}

/// Setpoint for a single motor
#[derive(Debug, Clone, Default)]
pub struct MotorSetpoint {
    pub enabled: bool,
    pub speed_percentage: f32,
    pub dir: MotorDirection,
}

impl MotorSetpoint {
    pub fn safe() -> Self {
        Self {
            enabled: false,
            speed_percentage: 0.0,
            dir: MotorDirection::Forward,
        }
    }
}
