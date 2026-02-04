use crate::supervisor::{MotorSetpoint, SelectedMotor};

/// Application state, managed by the supervisor
/// Tracks the currently selected motor
/// And for each motor the previo
#[derive(Debug, Default, Clone)]
pub struct Appstate {
    pub selected_motor: SelectedMotor,
    pub translation_setpoint: MotorSetpoint,
    pub rotation_setpoint: MotorSetpoint,
    pub cut_setpoint: MotorSetpoint,
    pub last_encoder_pos: i16,
}

impl Appstate {
    pub fn select_motor(&mut self, to_select: SelectedMotor) {
        self.selected_motor = to_select;
    }

    pub fn get_selected_motor(&self) -> SelectedMotor {
        self.selected_motor.clone()
    }

    pub fn set_current_motor_setpoint(&mut self, setpoint: MotorSetpoint) {
        match self.selected_motor {
            SelectedMotor::Translation => self.translation_setpoint = setpoint,
            SelectedMotor::Rotation => self.rotation_setpoint = setpoint,
            SelectedMotor::Cut => self.cut_setpoint = setpoint,
        }
    }

    pub fn get_current_motor_setpoint(&self) -> MotorSetpoint {
        match self.selected_motor {
            SelectedMotor::Translation => self.translation_setpoint.clone(),
            SelectedMotor::Rotation => self.rotation_setpoint.clone(),
            SelectedMotor::Cut => self.cut_setpoint.clone(),
        }
    }

    pub fn stop_all(&mut self) {
        self.translation_setpoint = MotorSetpoint::safe();
        self.rotation_setpoint = MotorSetpoint::safe();
        self.cut_setpoint = MotorSetpoint::safe();
    }
}
