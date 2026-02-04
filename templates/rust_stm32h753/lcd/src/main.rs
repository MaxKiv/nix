#![no_std]
#![no_main]

pub mod button;
pub mod lcd;

use crate::{
    button::{Button, ButtonPeripherals},
    lcd::LcdPeripherals,
};
use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::exti::ExtiInput;
use embassy_stm32::gpio::Pull;

use {defmt_rtt as _, panic_probe as _};

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let mut p = embassy_stm32::init(Default::default());
    info!("Hello World!");

    let button_peri = ButtonPeripherals {
        b1: (p.PE2, p.EXTI2),
        b2: (p.PE3, p.EXTI3),
        b3: (p.PE4, p.EXTI4),
        b4: (p.PE5, p.EXTI5),
        b5: (p.PE6, p.EXTI6),
    };

    let lcd_peri = LcdPeripherals {
        sda: p.PF0,
        scl: p.PF1,
        i2c: p.I2C2,
        tx_dma: p.DMA1_CH4,
        rx_dma: p.DMA1_CH5,
    };

    button::setup(button_peri, &spawner);
    lcd::setup(lcd_peri, &spawner);
}
