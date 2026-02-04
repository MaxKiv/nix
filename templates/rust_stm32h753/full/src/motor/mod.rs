pub mod knife;
pub mod linear;
pub mod rotation;

use core::fmt;
use uom::si::f32::Velocity;
use uom::si::velocity::millimeter_per_second;

/// Operational states a motor can be in
#[derive(Debug, Clone, Default)]
pub enum MotorState {
    Enabled,
    Braking,
    #[default]
    Coasting,
}

/// Commands all motors can accept
#[derive(Debug, Clone, Default)]
pub struct MotorCommand {
    /// Speed of the motor
    pub speed: Velocity,
    /// Operational state of the motor, i.e. is it enabled? Is it braking?
    pub state: MotorState,
}

impl core::fmt::Display for MotorState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            MotorState::Enabled => f.write_str("EN"),
            MotorState::Braking => f.write_str("BR"),
            MotorState::Coasting => f.write_str("CO"),
        }
    }
}

impl fmt::Display for MotorCommand {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self.state {
            MotorState::Enabled => {
                write!(
                    f,
                    "EN {:.2} mm/s",
                    self.speed.get::<millimeter_per_second>(),
                )
            }
            _ => write!(f, "DISABLED"),
        }
    }
}
