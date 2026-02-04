use defmt::*;
use display_interface_i2c::I2CInterface;
use embassy_executor::Spawner;
use embassy_stm32::{
    Peri,
    i2c::{Config, I2c},
    peripherals::*,
};
use oled_async::{builder::Builder, mode::GraphicsMode, prelude::DisplayRotation};

use crate::{Irqs, hmi::lcd::manage_display};

/// Period at which this task is ticked
const ADDRESS: u8 = 0x3C;
const DATA_BYTE: u8 = 0x40;
pub const SSD1309_FRAMEBUFFER_SIZE: usize = 128 * 64 / 8;

pub struct LcdPeripherals {
    pub i2c: Peri<'static, I2C2>,
    pub sda: Peri<'static, PF0>,
    pub scl: Peri<'static, PF1>,
    pub tx_dma: Peri<'static, DMA1_CH4>,
    pub rx_dma: Peri<'static, DMA1_CH5>,
}

pub fn setup(p: LcdPeripherals, spawner: &Spawner) {
    info!("Setting up display");
    let i2c_cfg = {
        let mut cfg = Config::default();
        cfg.sda_pullup = true;
        cfg.scl_pullup = true;
        cfg
    };

    // Set up I2C
    let i2c = I2c::new(p.i2c, p.scl, p.sda, Irqs, p.tx_dma, p.rx_dma, i2c_cfg);
    let i2c_interface = I2CInterface::new(i2c, ADDRESS, DATA_BYTE);

    // Set up display
    type Display = oled_async::displays::ssd1309::Ssd1309_128_64;
    let raw_disp = Builder::new(Display {})
        .with_rotation(DisplayRotation::Rotate0)
        .connect(i2c_interface);
    let disp: GraphicsMode<_, _, { SSD1309_FRAMEBUFFER_SIZE }> = raw_disp.into();

    spawner.spawn(manage_display(disp)).unwrap();
}
