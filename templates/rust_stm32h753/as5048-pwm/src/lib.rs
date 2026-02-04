#![no_std]

use defmt::error;
use embassy_stm32::timer::GeneralInstance32bit4Channel;

/// AS5048 PWM driver backed by a zero interrupt hardware implementation using pwm input
pub struct AS5048Pwm<Timer>
where
    Timer: GeneralInstance32bit4Channel,
{
    timer: Timer,
}

impl<T> AS5048Pwm<T>
where
    T: GeneralInstance32bit4Channel,
{
    /// Construct a new AS5048 PWM driver
    pub fn new(timer: T) -> Self {
        // let regs = T::regs();
        let regs = self.regs_gp32_unchecked();
        // ---------------------------------------------
        // 1) Configure timer clock (PSC, ARR)
        // ---------------------------------------------
        // Example: 100 MHz timer clock / 100 = 1 MHz counter → 1 tick = 1 µs
        // Enough for AS5048 PWM (~1 kHz, ~1000 µs period)
        regs.psc().write(|w| w.psc().bits(100 - 1));
        regs.arr().write(|w| w.arr().bits(2000)); // 2 ms max period

        // ---------------------------------------------
        // 2) Configure CH1 and CH2 as PWM-input pair
        // ---------------------------------------------
        regs.ccmr1_input().write(|w| {
            w.cc1s().ti1(); // IC1 = TI1 input (direct)
            w.cc2s().ti1(); // IC2 = TI1 input (indirect)
            w.ic1psc().bits(0); // no prescaler
            w.ic2psc().bits(0)
        });

        // ---------------------------------------------
        // 3) Edge polarity
        // ---------------------------------------------
        // CH1: Rising edge capture → period reference
        // CH2: Falling edge capture → high-time measurement
        regs.ccer.write(|w| {
            w.cc1e().set_bit();
            w.cc1p().clear_bit(); // rising
            w.cc1np().clear_bit();

            w.cc2e().set_bit();
            w.cc2p().set_bit(); // falling (invert)
            w.cc2np().clear_bit()
        });

        // ---------------------------------------------
        // 4) Slave mode: reset counter on rising edge
        // ---------------------------------------------
        regs.smcr.write(|w| {
            w.ts().ti1fp1(); // Trigger = TI1 filtered
            w.sms().reset_mode() // On rising edge of TI1, CNT resets to 0
        });

        // ---------------------------------------------
        // 5) Enable timer
        // ---------------------------------------------
        regs.cr1.modify(|_, w| w.cen().set_bit());

        Self { timer }
    }

    pub fn angle_raw(&self) -> Option<u16> {
        let period = self.timer.ccr1().read().ccr().bits();
        let high = self.timer.ccr2().read().ccr().bits();

        if period == 0 {
            return None;
        }

        // Raw AS5048 formula
        let val = high as i32 - 16;
        if val < 0 || val > 4095 {
            return None;
        }

        Some(val)
    }

    pub fn angle_float(&self) -> Option<u16> {
        let period = self.timer.ccr1().read().ccr().bits();
        let high = self.timer.ccr2().read().ccr().bits();

        if period == 0 {
            return None;
        }

        // duty = (high) / (period)
        let duty = high as f32 / period as f32;

        // AS5048 formula:
        let val = duty * 4119.0 - 16.0;
        let angle = val.clamp(0.0, 4095.0) as u16;

        Some(angle)
    }
}
