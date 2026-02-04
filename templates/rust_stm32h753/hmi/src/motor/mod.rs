pub mod controller;
pub mod knife;
pub mod rotation;
pub mod translation;

use core::fmt;
use tb6600::Direction;
use uom::si::f32::Velocity;
use uom::si::velocity::millimeter_per_second;

/// Operational states a motor can be in
#[derive(Debug, Clone, Default, defmt::Format)]
pub enum MotorState {
    Enabled,
    Braking,
    #[default]
    Coasting,
}

#[derive(Debug, Clone, Default, defmt::Format, PartialEq)]
pub enum MotorDirection {
    #[default]
    Forward,
    Backward,
}

impl MotorDirection {
    pub fn reverse(&mut self) {
        use MotorDirection::*;
        *self = match self {
            Forward => Backward,
            Backward => Forward,
        };
    }
}

impl Into<Direction> for MotorDirection {
    fn into(self) -> Direction {
        match self {
            Self::Forward => Direction::Forward,
            Self::Backward => Direction::Reverse,
        }
    }
}

/// Commands all motors can accept
#[derive(Debug, Clone, Default)]
pub struct MotorCommand {
    /// Operational state of the motor, i.e. is it enabled? Is it braking?
    pub state: MotorState,
    /// Direction of axis rotation
    pub dir: MotorDirection,
    /// Speed of the motor
    pub speed: Velocity,
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
                write!(f, "{:.2} mm/s", self.speed.get::<millimeter_per_second>(),)
            }
            _ => write!(f, "DISABLED"),
        }
    }
}
