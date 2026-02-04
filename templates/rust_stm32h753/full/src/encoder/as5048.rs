use as5048_pwm::AS5048Pwm;
use defmt::info;
use embassy_executor::Spawner;
use embassy_stm32::adc::{AdcChannel, SampleTime};
use embassy_stm32::{Peri, adc::Adc, peripherals::*};
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::watch::Watch;
use embassy_time::{Duration, Timer};

const AS5048_ENCODER_PERIOD: Duration = Duration::from_millis(1);

pub static WATCH_AS5048_ENCODER: Watch<Cs, f32, 1> = Watch::new();

pub struct AS5048EncoderPeripherals {
    pub timer: TIM5,
}

pub fn setup(p: AS5048EncoderPeripherals, spawner: &Spawner) {
    let encoder = AS5048Pwm::new(p.timer);

    spawner.spawn(manage_as5048_encoder(pot)).unwrap();
}

pub struct PotAdc {
    pub pin: Peri<'static, PA3>,
    pub dma: DMA1_CH1,
    pub adc: Adc<'static, ADC1>,
}

#[embassy_executor::task]
pub async fn manage_as5048_encoder(mut encoder: AS5048Pwm<TIM5>) {
    let mut ticker = Ticker::every(AS5048_ENCODER_PERIOD);

    let tx = WATCH_AS5048_ENCODER.sender();

    // continously measure encoder and send to interested parties
    loop {
        let angle = encoder.angle_float();

        info!("encoder angle: {}", angle);

        tx.send(measured);

        ticker.next().await;
    }
}
