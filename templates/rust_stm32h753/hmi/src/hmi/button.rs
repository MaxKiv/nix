use defmt::*;
use embassy_executor::Spawner;
use embassy_stm32::exti::ExtiInput;
use embassy_stm32::gpio::{Pin, Pull};
use embassy_stm32::Peri;
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex as Cs;
use embassy_sync::watch::{self, Watch};
use embassy_time::{Duration, Timer};

/// Max Number of receivers for a single button
/// Hacky, but I'm not spending 10 more hours on the mental masturbation effort
/// of dealing with generic task parameters, see https://github.com/embassy-rs/embassy/issues/2454
pub const BUTTON_WATCH_SIZE: usize = 2;

const MINIMUM_DETECTION_DURATION: Duration = Duration::from_millis(50);

pub enum ButtonMode {
    RisingEdge,
    FallingEdge,
}

pub struct ButtonPeripherals<T>
where
    T: Pin,
{
    pub pin: Peri<'static, T>,
    pub ch: Peri<'static, T::ExtiChannel>,
}

pub struct DebouncedButton {
    pub input: ExtiInput<'static>,
    tx: watch::Sender<'static, Cs, bool, BUTTON_WATCH_SIZE>,
    pub name: &'static str,
    pub mode: ButtonMode,
}

impl DebouncedButton {
    /// Spawns a task to manage button debouncing, stable presses are sent to the watch
    pub fn run<T>(
        p: ButtonPeripherals<T>,
        watch: &'static Watch<Cs, bool, BUTTON_WATCH_SIZE>,
        name: &'static str,
        mode: ButtonMode,
        spawner: &Spawner,
    ) -> watch::Receiver<'static, Cs, bool, BUTTON_WATCH_SIZE>
    where
        T: Pin,
    {
        let input = ExtiInput::new(p.pin, p.ch, Pull::Up);

        let button = Self {
            input,
            tx: watch.sender(),
            mode,
            name,
        };

        spawner.spawn(debounce_button(button)).unwrap();

        watch.receiver().unwrap()
    }
}

#[embassy_executor::task(pool_size = 10)]
async fn debounce_button(mut button: DebouncedButton) {
    loop {
        // Wait for initial transition
        match button.mode {
            ButtonMode::RisingEdge => button.input.wait_for_rising_edge().await,
            ButtonMode::FallingEdge => button.input.wait_for_falling_edge().await,
        };

        // Debounce the press
        Timer::after(MINIMUM_DETECTION_DURATION).await;
        match button.mode {
            ButtonMode::RisingEdge => {
                if !button.input.is_high() {
                    continue; // false trigger / bounce
                }
            }
            ButtonMode::FallingEdge => {
                if !button.input.is_low() {
                    continue; // false trigger / bounce 
                }
            }
        };

        // Stable input: Notify listeners
        button.tx.send(true);
        info!("Button {} clicked", button.name);

        // Debounce release
        match button.mode {
            ButtonMode::RisingEdge => button.input.wait_for_falling_edge().await,
            ButtonMode::FallingEdge => button.input.wait_for_rising_edge().await,
        };
        Timer::after(MINIMUM_DETECTION_DURATION).await;
    }
}
