#![no_std]
#![no_main]

pub mod clocks;
pub mod hmi;
pub mod motor;
pub mod supervisor;

use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::gpio::OutputType;
use embassy_stm32::hrtim::ComplementaryPwmPin;
use embassy_stm32::peripherals::I2C2;
use embassy_stm32::time::{hz, khz};
use embassy_stm32::timer::complementary_pwm::ComplementaryPwm;
use embassy_stm32::timer::simple_pwm::{PwmPin, SimplePwm};
use embassy_stm32::{Config, bind_interrupts, i2c};
use embassy_time::{Duration, Timer};

use crate::hmi::lcd::setup::LcdPeripherals;
use crate::hmi::{
    button::{ButtonMode, ButtonPeripherals},
    encoder::QuadratureEncoderPeripherals,
};
use crate::motor::knife::CutMotorPeripherals;
use crate::motor::rotation::RotationMotorPeripherals;
use crate::motor::translation::TranslationMotorPeripherals;

bind_interrupts!(struct Irqs {
    I2C2_EV => i2c::EventInterruptHandler<I2C2>;
    I2C2_ER => i2c::ErrorInterruptHandler<I2C2>;
});

use {defmt_rtt as _, panic_probe as _};

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let config = Config::default();
    let config = clocks::setup_clocks(config);
    let p = embassy_stm32::init(config);
    info!("Clocks configured - Hello World!");

    // ---- Motor Peripheral declarations -----
    let linear_step_pwm_pin = p.PC6;
    let linear_step_pwm = PwmPin::new(linear_step_pwm_pin, OutputType::PushPull);
    let linear_step_timer = p.TIM8;
    let linear_pwm = SimplePwm::new(
        linear_step_timer,
        Some(linear_step_pwm),
        None,
        None,
        None,
        khz(10),
        Default::default(),
    );
    let translation_peri = TranslationMotorPeripherals {
        pwm: linear_pwm,
        dir: p.PF8,
    };

    let rotation_step_pwm_pin = p.PB6;
    let rotationstep_pwm = PwmPin::new(rotation_step_pwm_pin, OutputType::PushPull);
    let rotation_step_timer = p.TIM4;
    let rotation_pwm = SimplePwm::new(
        rotation_step_timer,
        Some(rotationstep_pwm),
        None,
        None,
        None,
        khz(10),
        Default::default(),
    );
    let rotation_peri = RotationMotorPeripherals {
        pwm: rotation_pwm,
        dir: p.PF9,
    };

    // let knife_left_pwm_pin = p.PE9;
    let knife_left_pwm_pin = p.PA8;
    let knife_left_pwm = PwmPin::new(knife_left_pwm_pin, OutputType::PushPull);
    // let knife_right_pwm_pin = p.PE11;
    let knife_right_pwm_pin = p.PA9;
    let knife_right_pwm = PwmPin::new(knife_right_pwm_pin, OutputType::PushPull);
    let knife_pwm = SimplePwm::new(
        p.TIM1,
        Some(knife_left_pwm),
        Some(knife_right_pwm),
        None,
        None,
        hz(l9110::PWM_FREQUENCY.0),
        Default::default(),
    );

    let knife_peri = CutMotorPeripherals { pwm: knife_pwm };

    // ---- HMI Peripheral declarations -----

    // I2C LCD screen
    let lcd_peri = LcdPeripherals {
        sda: p.PF0,
        scl: p.PF1,
        i2c: p.I2C2,
        tx_dma: p.DMA1_CH4,
        rx_dma: p.DMA1_CH5,
    };

    // LED buttons
    let green_button = ButtonPeripherals {
        pin: p.PD7,
        ch: p.EXTI7,
    };
    let blue_button = ButtonPeripherals {
        pin: p.PD6,
        ch: p.EXTI6,
    };
    let purple_button = ButtonPeripherals {
        pin: p.PD5,
        ch: p.EXTI5,
    };
    let gray_button = ButtonPeripherals {
        pin: p.PD4,
        ch: p.EXTI4,
    };

    // Encoder
    let encoder_button = ButtonPeripherals {
        pin: p.PD3,
        ch: p.EXTI3,
    };
    let encoder_peri = QuadratureEncoderPeripherals {
        ch1: p.PA6,
        ch2: p.PB5,
        timer: p.TIM3,
    };

    // ---- HMI Task Construction -----

    hmi::button::DebouncedButton::run(
        green_button,
        &supervisor::task::STOP_ALL_SELECTED,
        "green",
        ButtonMode::FallingEdge,
        &spawner,
    );

    hmi::button::DebouncedButton::run(
        blue_button,
        &supervisor::task::TRANSLATION_SELECTED,
        "blue",
        ButtonMode::FallingEdge,
        &spawner,
    );

    hmi::button::DebouncedButton::run(
        purple_button,
        &supervisor::task::CUT_SELECTED,
        "purple",
        ButtonMode::FallingEdge,
        &spawner,
    );

    hmi::button::DebouncedButton::run(
        gray_button,
        &supervisor::task::ROTATION_SELECTED,
        "gray",
        ButtonMode::FallingEdge,
        &spawner,
    );

    hmi::button::DebouncedButton::run(
        encoder_button,
        &supervisor::task::ENCODER_PRESSED,
        "encoder",
        ButtonMode::FallingEdge,
        &spawner,
    );

    hmi::encoder::QuadratureEncoder::run(encoder_peri, &spawner);

    hmi::lcd::setup::setup(lcd_peri, &spawner);

    // ---- Motor Task Construction -----
    motor::controller::setup(&spawner);
    motor::knife::setup(knife_peri, &spawner);
    motor::translation::setup(translation_peri, &spawner);
    motor::rotation::setup(rotation_peri, &spawner);

    // ---- Supervisor (routes HMI input to HMI & Motor output) -----
    supervisor::task::setup(&spawner);
}
