#![no_std]

use defmt::{info, trace, warn};
use embassy_stm32::{
    time::Hertz,
    timer::{GeneralInstance4Channel, simple_pwm::SimplePwm},
};
use embedded_hal::digital::OutputPin;
use embedded_hal_async::delay::DelayNs;
use thiserror::Error;
use uom::si::{f32::Velocity, velocity::millimeter_per_second};

const BASE_DUTY_CYCLE_PERCENT: u8 = 50;
pub const BASE_STEP_FREQUENCY_HZ: Hertz = Hertz(10_000);
pub const MIN_STEP_FREQUENCY_HZ: Hertz = Hertz(1);
pub const MAX_STEP_FREQUENCY_HZ: Hertz = Hertz(25_000); // 100khz max theoretical (~5µs pulse width at 50% dc), but this cooks the Tb6600 already
pub const DEFAULT_SPEED_MS_PS: f32 = 1.0;

pub struct Tb6600<Timer, DirPin, Delay>
where
    Timer: GeneralInstance4Channel, // General-purpose 16-bit timer with 4 channels instance
{
    name: &'static str,
    step_pwm: SimplePwm<'static, Timer>,
    step_frequency: Hertz,
    dir_pin: DirPin,
    enabled: bool,
    delay: Delay,
    /// Fierce googling: min pulse width ~5µs, maybe?
    pub direction: Direction,
}

#[derive(Error, Debug, defmt::Format)]
pub enum TB6600Error {
    #[error("Direction pin ging op zn gat")]
    DirectionPin,
    #[error("Step pin ging op zn gat")]
    StepPin,
    #[error("Enable pin ging op zn gat")]
    EnablePin,
    #[error("Invalid input")]
    Input,
}

#[derive(Clone, Debug, defmt::Format)]
pub enum Direction {
    Forward,
    Reverse,
}

impl<Timer, DirPin, Delay> Tb6600<Timer, DirPin, Delay>
where
    DirPin: OutputPin,              // Any output pin
    Delay: DelayNs,                 // Nanosecond capable delay
    Timer: GeneralInstance4Channel, // General-purpose 16-bit timer with 4 channels instance to back the pwm impl
{
    pub fn new(
        name: &'static str,
        mut step_pwm: SimplePwm<'static, Timer>,
        dir_pin: DirPin,
        delay: Delay,
    ) -> Self {
        step_pwm.ch1().disable(); // start disabled

        let mut out = Self {
            name,
            step_pwm,
            step_frequency: BASE_STEP_FREQUENCY_HZ,
            dir_pin,
            delay,
            direction: Direction::Forward,
            enabled: false,
        };

        // start disabled
        out.stop();

        out
    }

    /// Run the stepper at given speed
    pub async fn run_with_dir(
        &mut self,
        speed: Velocity,
        dir: Direction,
    ) -> Result<(), TB6600Error> {
        match dir {
            Direction::Forward => self.run(speed).await,
            Direction::Reverse => self.run(-speed).await,
        }
    }

    /// Run the stepper at given speed
    pub async fn run(&mut self, speed: Velocity) -> Result<(), TB6600Error> {
        let mut speed = speed.get::<millimeter_per_second>();
        info!("{} motor RUNNING at {}mm/s", self.name, speed);

        // Check in which direction we should be running
        if speed > 0.0 {
            self.set_direction(Direction::Forward).await?;
        } else {
            self.set_direction(Direction::Reverse).await?;
            // make sure speed is positive from here
            speed = -speed;
        }

        // Set stepping frequency appropriate to the velocity setpoint
        // Validate setpoint
        if let Some(freq) = self.speed_to_frequency(speed) {
            self.step_pwm.set_frequency(freq);

            self.step_pwm
                .ch1()
                .set_duty_cycle_percent(BASE_DUTY_CYCLE_PERCENT); // set_frequency docs suggests I have to call this again

            self.start_stepping();

            self.step_frequency = freq;
        } else {
            // Setpoint invalid, stop motor
            self.stop();
        }

        Ok(())
    }

    /// Stop the stepper
    pub fn stop(&mut self) {
        info!("{} motor stopped stepping", self.name);
        self.step_pwm.ch1().disable();
        self.enabled = false;
    }

    /// Set step N times
    pub async fn do_steps(&mut self, num_steps: u32, speed: Velocity) {
        let us = ((num_steps as f32 / self.step_frequency.0 as f32) * 1_000_000.0) as u32;

        info!(
            "{} motor START stepping {} times -> {}us",
            self.name, num_steps, us
        );

        self.run(speed).await;
        self.delay.delay_us(us).await;

        info!(
            "{} motor DONE stepping {} times -> {}us",
            self.name, num_steps, us
        );
        self.stop();
    }

    /// Start stepping
    /// ENABLE LOW = ON + EN tied low -> Driver is always on
    /// Software enables the step pwm output
    fn start_stepping(&mut self) {
        info!(
            "{} motor started stepping at {}",
            self.name, self.step_frequency
        );
        self.step_pwm.ch1().enable();
        self.enabled = true;
    }

    /// Set step direction
    async fn set_direction(&mut self, direction: Direction) -> Result<(), TB6600Error> {
        self.direction = direction;

        match self.direction {
            Direction::Forward => self
                .dir_pin
                .set_high()
                .map_err(|_| TB6600Error::DirectionPin)?,
            Direction::Reverse => self
                .dir_pin
                .set_low()
                .map_err(|_| TB6600Error::DirectionPin)?,
        };

        // Chill out, catch some waves
        self.delay.delay_us(5).await;

        Ok(())
    }

    /// Flip step direction
    async fn flip_direction(&mut self) -> Result<(), TB6600Error> {
        let dir = match self.direction {
            Direction::Forward => Direction::Reverse,
            Direction::Reverse => Direction::Forward,
        };

        self.set_direction(dir).await?;

        Ok(())
    }

    /// Set step pwm dc
    /// Percentage [0-100]
    fn set_duty_cycle_percent(&mut self, percentage: u8) {
        trace!("{} motor set dc to {}%", self.name, percentage);
        self.step_pwm.ch1().set_duty_cycle_percent(percentage);
    }

    fn speed_to_frequency(&self, speed: f32) -> Option<Hertz> {
        /// Speed [mm/s] at maximum stepping frequency
        const MAX_SPEED_MS_PS: f32 = 10.0;

        let speed_percentage = (speed / MAX_SPEED_MS_PS).clamp(0.0, 1.0);
        let freq = (speed_percentage * MAX_STEP_FREQUENCY_HZ.0 as f32) as u32;
        if freq > 0 {
            info!(
                "converting {} motor speed setpoint of {}mm/s to {}% speed ({})",
                self.name,
                speed,
                speed_percentage * 100.0,
                freq
            );

            Some(Hertz(freq))
        } else {
            warn!(
                "INVALID SPEED: attempting to convert {} motor speed setpoint of {}mm/s to {}% speed ({})",
                self.name,
                speed,
                speed_percentage * 100.0,
                freq
            );

            None
        }
    }
}
