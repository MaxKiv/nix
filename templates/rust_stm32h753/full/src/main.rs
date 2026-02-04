#![no_std]
#![no_main]

pub mod clocks;
// pub mod encoder;
pub mod hmi;
pub mod motor;
pub mod supervisor;

use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::{
    Config,
    gpio::OutputType,
    time::{hz, khz},
    timer::simple_pwm::{PwmPin, SimplePwm},
};

use crate::{
    hmi::{
        button::{ButtonMode, ButtonPeripherals},
        lcd::{self, LcdPeripherals},
        pot::PotPeripherals,
    },
    motor::{
        knife::{self, KnifeMotorPeripherals},
        linear::LinearMotorPeripherals,
        rotation::RotationMotorPeripherals,
    },
};

use {defmt_rtt as _, panic_probe as _};

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let config = Config::default();
    let config = clocks::setup_clocks(config);
    let p = embassy_stm32::init(config);
    info!("Clocks configured - Hello World!");

    // ---- Motor Peripheral declarations -----
    let linear_step_pwm_pin = p.PA6;
    let linear_step_pwm = PwmPin::new(linear_step_pwm_pin, OutputType::PushPull);
    let linear_step_timer = p.TIM3;
    let linear_pwm = SimplePwm::new(
        linear_step_timer,
        Some(linear_step_pwm),
        None,
        None,
        None,
        khz(10),
        Default::default(),
    );
    let linear_peri = LinearMotorPeripherals {
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

    let knife_left_pwm_pin = p.PE9;
    let knife_left_pwm = PwmPin::new(knife_left_pwm_pin, OutputType::PushPull);
    let knife_right_pwm_pin = p.PE11;
    let knife_right_pwm = PwmPin::new(knife_right_pwm_pin, OutputType::PushPull);
    let knife_step_timer = p.TIM1;
    let knife_pwm = SimplePwm::new(
        knife_step_timer,
        Some(knife_left_pwm),
        Some(knife_right_pwm),
        None,
        None,
        hz(l9110::PWM_FREQUENCY.0),
        Default::default(),
    );
    let knife_peri = KnifeMotorPeripherals { pwm: knife_pwm };

    // ---- HMI Peripheral declarations -----

    // Potentiometer
    let pot_peri = PotPeripherals {
        pin: p.PA3,
        adc: p.ADC1,
        dma: *p.DMA1_CH1,
    };

    // I2C LCD screen
    let lcd_peri = LcdPeripherals {
        sda: p.PF0,
        scl: p.PF1,
        i2c: p.I2C2,
        tx_dma: p.DMA1_CH4,
        rx_dma: p.DMA1_CH5,
    };

    // LCD input
    let blue_button = ButtonPeripherals {
        pin: p.PC10,
        ch: p.EXTI10,
    };

    // Knife enable
    let yellow_button = ButtonPeripherals {
        pin: p.PC8,
        ch: p.EXTI8,
    };
    // Knife direction
    let green_button = ButtonPeripherals {
        pin: p.PC9,
        ch: p.EXTI9,
    };

    // Top button with LED
    let button_1 = ButtonPeripherals {
        pin: p.PD7,
        ch: p.EXTI7,
    };
    let button_2 = ButtonPeripherals {
        pin: p.PD6,
        ch: p.EXTI6,
    };
    let button_3 = ButtonPeripherals {
        pin: p.PD5,
        ch: p.EXTI5,
    };
    let button_4 = ButtonPeripherals {
        pin: p.PD4,
        ch: p.EXTI4,
    };

    // ---- HMI Task Construction -----
    hmi::button::DebouncedButton::run(
        yellow_button,
        &supervisor::KNIFE_ENABLED,
        "Knife EN",
        ButtonMode::RisingEdge,
        &spawner,
    );
    hmi::button::DebouncedButton::run(
        green_button,
        &supervisor::KNIFE_DIRECTION,
        "Knife DIR",
        ButtonMode::RisingEdge,
        &spawner,
    );

    hmi::button::DebouncedButton::run(
        button_1,
        &supervisor::LINEAR_ENABLED,
        "Linear EN",
        ButtonMode::RisingEdge,
        &spawner,
    );
    hmi::button::DebouncedButton::run(
        button_2,
        &supervisor::LINEAR_DIRECTION,
        "Linear DIR",
        ButtonMode::RisingEdge,
        &spawner,
    );
    hmi::button::DebouncedButton::run(
        button_3,
        &supervisor::ROTATION_ENABLED,
        "Rotation EN",
        ButtonMode::RisingEdge,
        &spawner,
    );
    hmi::button::DebouncedButton::run(
        button_4,
        &supervisor::ROTATION_DIRECTION,
        "Rotation DIR",
        ButtonMode::RisingEdge,
        &spawner,
    );

    hmi::button::DebouncedButton::run(
        blue_button,
        &lcd::LCD_INPUT,
        "LCD Input",
        ButtonMode::RisingEdge,
        &spawner,
    );

    hmi::lcd::setup(lcd_peri, &spawner);

    // ---- Motor Task Construction -----
    motor::knife::setup(knife_peri, &spawner);
    motor::linear::setup(linear_peri, &spawner);
    motor::rotation::setup(rotation_peri, &spawner);

    // ---- Supervisor (routes HMI input to motor actions) -----
    supervisor::setup(&spawner);
}
