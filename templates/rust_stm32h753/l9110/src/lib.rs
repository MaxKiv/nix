#![no_std]

use defmt::*;
use embassy_stm32::{
    time::Hertz,
    timer::{
        GeneralInstance4Channel,
        simple_pwm::{SimplePwm, SimplePwmChannel, SimplePwmChannels},
    },
};
use embedded_hal::digital::PinState;
use embedded_hal_async::delay::DelayNs;
use thiserror::Error;
use uom::si::{f32::Velocity, velocity::millimeter_per_second};

pub const PWM_FREQUENCY: Hertz = Hertz(20_000); // 1-20kHz, low means audible noise, high = increased switching loss
pub const DEFAULT_DIR_STATE: PinState = PinState::Low;
pub const DEFAULT_DIRECTION: Direction = Direction::Forward;
pub const DEAD_TIME_US: u8 = 1; // TODO: validate
pub const DEFAULT_SPEED_MS_PS: f32 = 1.0;
pub const CUT_MAX_SPEED_MS_PS: f32 = 2.0;
/// Duration to break by shorting.
/// Increasing this increase heat release due to large ampererage in L9110 H-bridge short, potentially killing the device
pub const BREAK_DURATION_MS: u32 = 1;

pub struct L9110<Timer, Delay>
where
    Timer: GeneralInstance4Channel, // General-purpose 16-bit timer with 4 channels instance
{
    name: &'static str,
    a: SimplePwmChannel<'static, Timer>,
    b: SimplePwmChannel<'static, Timer>,
    delay: Delay,
    speed: Velocity,
    direction: Direction,
}

#[derive(Error, Debug, defmt::Format)]
pub enum L9110Error {
    #[error("Enable pin ging op zn gat")]
    EnablePin,
    #[error("Direction pin ging op zn gat")]
    DirectionPin,
    #[error("Step pin ging op zn gat")]
    StepPin,
}

#[derive(Clone, Debug, defmt::Format)]
pub enum Direction {
    Forward,
    Reverse,
}

impl Direction {
    pub fn flip(&mut self) {
        *self = match self {
            Direction::Forward => Direction::Reverse,
            Direction::Reverse => Direction::Forward,
        }
    }
}

impl<Timer, Delay> L9110<Timer, Delay>
where
    Delay: DelayNs,                 // Nanosecond capable delay
    Timer: GeneralInstance4Channel, // General-purpose 16-bit timer with 4 channels instance to back the pwm impl
{
    pub fn try_new(
        name: &'static str,
        mut pwm: SimplePwm<'static, Timer>,
        delay: Delay,
    ) -> Result<Self, L9110Error> {
        pwm.set_frequency(PWM_FREQUENCY); // set default pwm frequency

        // Split off pwm channels
        let SimplePwmChannels {
            mut ch1, mut ch2, ..
        } = pwm.split();

        // Disable PWM output at start
        ch1.set_duty_cycle_fully_off();
        ch2.set_duty_cycle_fully_off();

        // The L9110 driver requires the PWM channels to be enabled after construction, do that now
        ch1.enable();
        ch2.enable();

        // Construct Driver
        let mut out = Self {
            name,
            delay,
            speed: Velocity::new::<millimeter_per_second>(DEFAULT_SPEED_MS_PS),
            direction: DEFAULT_DIRECTION,
            a: ch1,
            b: ch2,
        };

        // Default driver state
        out.coast();

        Ok(out)
    }

    pub fn forward(&mut self, speed: Velocity) {
        let dc = Self::speed_to_duty_cycle_percent(speed);

        info!(
            "{} moving forward with {}mm/s ({}%dc)",
            self.name,
            speed.get::<millimeter_per_second>(),
            dc
        );

        self.a.set_duty_cycle_percent(dc);
        self.b.set_duty_cycle_fully_off();
    }

    pub fn reverse(&mut self, speed: Velocity) {
        let dc = Self::speed_to_duty_cycle_percent(speed);
        info!(
            "{} moving reverse with {}mm/s ({}%dc)",
            self.name,
            speed.get::<millimeter_per_second>(),
            dc
        );

        self.a.set_duty_cycle_fully_off();
        self.b.set_duty_cycle_percent(dc);
    }

    pub fn run(&mut self, mut speed: Velocity) {
        let mm_ps = speed.get::<millimeter_per_second>();
        if mm_ps.abs() > CUT_MAX_SPEED_MS_PS {
            warn!(
                "{} attempting to set speed to {}mm/s, exceeding max speed ({}mm/s) - clipping to max",
                self.name, mm_ps, CUT_MAX_SPEED_MS_PS
            );
            speed = Velocity::new::<millimeter_per_second>(CUT_MAX_SPEED_MS_PS);
        }

        if mm_ps > 0.0 {
            self.forward(speed);
        } else {
            self.reverse(speed);
        }
    }

    pub fn coast(&mut self) {
        info!("{} coasting", self.name);
        self.a.set_duty_cycle_fully_off();
        self.b.set_duty_cycle_fully_off();
    }

    /// Break by shorting, coast after
    pub async fn short_break(&mut self) {
        info!("{} breaking!", self.name);
        // Break by shorting motor
        self.a.set_duty_cycle_fully_on();
        self.b.set_duty_cycle_fully_on();

        // avoid shorting h bridge high side transistors for too long
        self.delay.delay_ms(BREAK_DURATION_MS).await;
        self.coast();
    }

    fn speed_to_duty_cycle_percent(speed: Velocity) -> u8 {
        let speed_abs = speed.get::<millimeter_per_second>().abs();

        let out = ((100.0 * speed_abs / CUT_MAX_SPEED_MS_PS) as u8).clamp(0, 100);

        trace!(
            "Converted speed {}mm/s to {}% dc",
            speed.get::<millimeter_per_second>(),
            out,
        );

        out
    }
}
