#![no_std]
#![no_main]

pub mod button;
pub mod clocks;
pub mod knife_motor;
pub mod lcd;
pub mod linear_motor;
pub mod pot;
pub mod rotational_motor;

use crate::{
    button::ButtonPeripherals, knife_motor::KnifeMotorPeripherals, lcd::LcdPeripherals,
    linear_motor::LinearAxisMotorPeripherals, pot::PotPeripherals,
    rotational_motor::RotationalAxisMotorPeripherals,
};
use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::{
    Config,
    gpio::{Level, Output, OutputType, Speed},
    time::{hz, khz},
    timer::simple_pwm::{PwmPin, SimplePwm},
};

use {defmt_rtt as _, panic_probe as _};

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let mut config = Config::default();
    let config = clocks::setup_clocks(config);
    let p = embassy_stm32::init(config);
    info!("Hello World!");

    // let button_peri = ButtonPeripherals {
    //     b1: (p.PC13, p.EXTI13),
    //     b2: (p.PD7, p.EXTI7),
    //     b3: (p.PD6, p.EXTI6),
    //     b4: (p.PD5, p.EXTI5),
    //     b5: (p.PD4, p.EXTI4),
    // };

    // let linear_step_pwm_pin = p.PA6;
    // let linear_step_pwm = PwmPin::new(linear_step_pwm_pin, OutputType::PushPull);
    // let linear_step_timer = p.TIM3;
    // let linear_pwm = SimplePwm::new(
    //     linear_step_timer,
    //     Some(linear_step_pwm),
    //     None,
    //     None,
    //     None,
    //     khz(10),
    //     Default::default(),
    // );
    //
    // let linear_motor_peri = LinearAxisMotorPeripherals {
    //     step: linear_pwm,
    //     dir: p.PF8,
    // };

    let rotational_step_pwm_pin = p.PB6;
    let rotationalstep_pwm = PwmPin::new(rotational_step_pwm_pin, OutputType::PushPull);
    let rotational_step_timer = p.TIM4;
    let rotational_pwm = SimplePwm::new(
        rotational_step_timer,
        Some(rotationalstep_pwm),
        None,
        None,
        None,
        khz(10),
        Default::default(),
    );

    let rotational_motor_peri = RotationalAxisMotorPeripherals {
        step: rotational_pwm,
        dir: p.PF9,
    };

    let pot_peri = PotPeripherals {
        pin: p.PA3,
        adc: p.ADC1,
        dma: *p.DMA1_CH1,
    };

    let lcd_peri = LcdPeripherals {
        sda: p.PF0,
        scl: p.PF1,
        i2c: p.I2C2,
        tx_dma: p.DMA1_CH4,
        rx_dma: p.DMA1_CH5,
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
    let knife_enable_button = ButtonPeripherals {
        pin: p.PC8,
        ch: p.EXTI8,
    };
    let knife_dir_button = ButtonPeripherals {
        pin: p.PC9,
        ch: p.EXTI9,
    };
    let knife_peri = KnifeMotorPeripherals {
        pwm: knife_pwm,
        enable_button: knife_enable_button,
        direction_button: knife_dir_button,
    };

    pot::setup(pot_peri, &spawner);
    // button::setup(button_peri, &spawner);
    // linear_motor::setup(linear_motor_peri, &spawner);
    // rotational_motor::setup(rotational_motor_peri, &spawner);
    // lcd::setup(lcd_peri, &spawner);
    knife_motor::setup(knife_peri, &spawner);
}
