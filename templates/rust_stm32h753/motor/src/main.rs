#![no_std]
#![no_main]

pub mod button;
pub mod lcd;
pub mod motor;

use crate::{button::ButtonPeripherals, lcd::LcdPeripherals, motor::MotorPeripherals};
use defmt::*;
use embassy_executor::Spawner;

use {defmt_rtt as _, panic_probe as _};

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let p = embassy_stm32::init(Default::default());
    info!("Hello World!");

    let button_peri = ButtonPeripherals {
        b1: (p.PC13, p.EXTI13),
        b2: (p.PD7, p.EXTI7),
        b3: (p.PD6, p.EXTI6),
        b4: (p.PD5, p.EXTI5),
        b5: (p.PD4, p.EXTI4),
    };

    let lcd_peri = LcdPeripherals {
        sda: p.PF0,
        scl: p.PF1,
        i2c: p.I2C2,
        tx_dma: p.DMA1_CH4,
        rx_dma: p.DMA1_CH5,
    };

    let motor_peri = MotorPeripherals {
        motor_step: p.PE3,
        motor_dir: p.PF8,
    };

    button::setup(button_peri, &spawner);
    lcd::setup(lcd_peri, &spawner);
    motor::setup(motor_peri, &spawner);
}
