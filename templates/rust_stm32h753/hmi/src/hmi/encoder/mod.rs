pub mod data;

use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::{
    Peri,
    peripherals::TIM3,
    timer::{
        Ch1, Ch2, TimerPin,
        qei::{Qei, QeiPin},
    },
};
use embassy_time::{Duration, Ticker, Timer};

use crate::{
    hmi::encoder::data::{Direction, EncoderData},
    supervisor::task::ENCODER_DATA,
};

const TASK_PERIOD: Duration = Duration::from_millis(50);

const SINGLE_THRESHOLD: f32 = 0.8;
const MULTI_THRESHOLD: f32 = 2.3;

pub struct QuadratureEncoderPeripherals<P1, P2>
where
    P1: TimerPin<TIM3, Ch1>,
    P2: TimerPin<TIM3, Ch2>,
{
    pub ch1: Peri<'static, P1>,
    pub ch2: Peri<'static, P2>,
    pub timer: Peri<'static, TIM3>,
}

pub struct QuadratureEncoder {
    pub qei: Qei<'static, TIM3>,
    pub name: &'static str,
}

impl QuadratureEncoder {
    /// Spawns a task to manage button debouncing, stable presses are sent to the watch
    pub fn run<P1, P2>(p: QuadratureEncoderPeripherals<P1, P2>, spawner: &Spawner)
    where
        P1: embassy_stm32::timer::TimerPin<TIM3, Ch1>,
        P2: embassy_stm32::timer::TimerPin<TIM3, Ch2>,
    {
        info!("Setting up encoder");

        let qei_pin_1 = QeiPin::new(p.ch1);
        let qei_pin_2 = QeiPin::new(p.ch2);
        let qei = Qei::new(p.timer, qei_pin_1, qei_pin_2);
        let encoder = QuadratureEncoder { qei, name: "HMI" };

        spawner.spawn(manage_encoder(encoder)).unwrap();
    }
}

#[embassy_executor::task]
async fn manage_encoder(encoder: QuadratureEncoder) {
    let encoder_tx = ENCODER_DATA.sender();
    let mut ticker = Ticker::every(TASK_PERIOD);
    let mut pos: i16 = 0;
    let mut prev: u16 = 0;

    info!("Starting {} Encoder loop", encoder.name);
    loop {
        // Read out the encoder
        let count = encoder.qei.count();
        let dir: Direction = encoder.qei.read_direction().into();

        // Calculate delta
        let delta = count.wrapping_sub(prev) as i16;
        let abs_delta = delta.abs();

        // Map delta -> abstract encoder position
        let increase = match abs_delta {
            _ if abs_delta >= 4 => 2,
            _ if abs_delta >= 1 => 1,
            _ => 0,
        };
        // Make sure to in/decrement based on encoder direction
        pos += match dir {
            Direction::Increased => 1,
            Direction::Decreased => -1,
        } * increase;

        let state = EncoderData { dir, pos };
        trace!(
            "encoder - count: {} - delta: {} - pos: {}",
            count, delta, pos
        );

        // Send the new value along
        encoder_tx.send(state.clone());

        // Housekeeping
        prev = count;
        // Debounce knob if we increased this cycle
        if abs_delta > 1 {
            Timer::after_millis(100).await;
        }

        ticker.next().await;
    }
}
