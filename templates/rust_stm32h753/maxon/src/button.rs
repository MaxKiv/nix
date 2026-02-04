use defmt::info;
use embassy_executor::Spawner;
use embassy_stm32::exti::ExtiInput;
use embassy_stm32::gpio::{Pin, Pull};
use embassy_stm32::{Peri, peripherals::*};
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex as Cs;
use embassy_sync::watch::{self, Sender, Watch};
use embassy_time::{Duration, Timer};

/// Max Number of receivers for a single button
/// Hacky, but I'm not spending 10 more hours on the mental masturbation effort
/// of dealing with generic task parameters, see https://github.com/embassy-rs/embassy/issues/2454
pub const BUTTON_WATCH_SIZE: usize = 10;

pub static WATCH_BUTTON: Watch<Cs, ButtonPressed, 10> = Watch::new();

const MINIMUM_DETECTION_DURATION: Duration = Duration::from_millis(50);

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
}

impl DebouncedButton {
    /// Spawns a task to manage button debouncing, stable presses are sent to the watch
    pub fn run<T>(
        p: ButtonPeripherals<T>,
        watch: &'static Watch<Cs, bool, BUTTON_WATCH_SIZE>,
        name: &'static str,
        spawner: &Spawner,
    ) -> watch::Receiver<'static, Cs, bool, BUTTON_WATCH_SIZE>
    where
        T: Pin,
    {
        let input = ExtiInput::new(p.pin, p.ch, Pull::Up);

        let button = Self {
            input,
            tx: watch.sender(),
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
        button.input.wait_for_falling_edge().await;

        // Debounce the press
        Timer::after(MINIMUM_DETECTION_DURATION).await;
        if !button.input.is_low() {
            continue; // false trigger / bounce
        }

        // Stable input: Notify listeners
        button.tx.send(true);

        // Debounce release
        button.input.wait_for_rising_edge().await;
        Timer::after(MINIMUM_DETECTION_DURATION).await;
    }
}

#[derive(Clone, Debug, defmt::Format)]
pub enum ButtonPressed {
    Button1,
    Button2,
    Button3,
    Button4,
    Button5,
}

// pub struct ButtonPeripherals {
//     pub b1: (Peri<'static, PC13>, Peri<'static, EXTI13>),
//     pub b2: (Peri<'static, PD7>, Peri<'static, EXTI7>),
//     pub b3: (Peri<'static, PD6>, Peri<'static, EXTI6>),
//     pub b4: (Peri<'static, PD5>, Peri<'static, EXTI5>),
//     pub b5: (Peri<'static, PD4>, Peri<'static, EXTI4>),
// }
//
// pub fn setup(p: ButtonPeripherals, spawner: &Spawner) {
//     spawner.spawn(manage_button(p)).unwrap();
// }
//
// #[embassy_executor::task]
// pub async fn manage_button(p: ButtonPeripherals) {
//     use ButtonPressed::*;
//
//     let button_1 = DebouncedButton {
//         input: ExtiInput::new(p.b1.0, p.b1.1, Pull::Up),
//         number: Button1,
//     };
//     let button_2 = DebouncedButton {
//         input: ExtiInput::new(p.b2.0, p.b2.1, Pull::Up),
//         number: Button2,
//     };
//     let button_3 = DebouncedButton {
//         input: ExtiInput::new(p.b3.0, p.b3.1, Pull::Up),
//         number: Button3,
//     };
//     let button_4 = DebouncedButton {
//         input: ExtiInput::new(p.b4.0, p.b4.1, Pull::Up),
//         number: Button4,
//     };
//     let button_5 = DebouncedButton {
//         input: ExtiInput::new(p.b5.0, p.b5.1, Pull::Up),
//         number: Button5,
//     };
//
//     let handle_1 = handle_button(button_1);
//     let handle_2 = handle_button(button_2);
//     let handle_3 = handle_button(button_3);
//     let handle_4 = handle_button(button_4);
//     let handle_5 = handle_button(button_5);
//
//     embassy_futures::select::select5(handle_1, handle_2, handle_3, handle_4, handle_5).await;
// }
//
// async fn handle_button(mut button: DebouncedButton<'_>) {
//     let tx = WATCH_BUTTON.sender();
//     info!("Press a button...");
//
//     loop {
//         button.input.wait_for_rising_edge().await;
//
//         // Rising edge detected, wait a bit to check for stable input or noise
//         Timer::after(MINIMUM_DETECTION_DURATION).await;
//         if button.input.is_high() {
//             // Stable input detected, user pressed button
//             tx.send(button.number.clone());
//             info!("{:?} Pressed!", button.number);
//
//             // Wait a bit before accepting new buttonpresses to avoid spam
//             Timer::after(DEBOUNCE_DURATION).await;
//             while button.input.is_high() {
//                 Timer::after(DEBOUNCE_DURATION).await;
//             }
//         }
//     }
// }

// pub async fn debounce_button<M, const N: usize>(
//     mut button: DebouncedButton<'_>,
//     tx: Sender<'static, CriticalSectionRawMutex, bool, N>,
// ) {
//     loop {
//         info!("Ready to accept button press for {:?}", button.number);
//         button.input.wait_for_rising_edge().await;
//
//         // Rising edge detected, wait a bit to check for stable input or noise
//         Timer::after(MINIMUM_DETECTION_DURATION).await;
//         if button.input.is_high() {
//             // Stable input detected, user pressed button
//             tx.send(true);
//             info!("{:?} Pressed!", button.number);
//
//             // Wait a bit before accepting new buttonpresses to avoid spam
//             Timer::after(DEBOUNCE_DURATION).await;
//
//             // Avoid resending button presses while button is held down
//             while button.input.is_high() {
//                 Timer::after(DEBOUNCE_DURATION).await;
//             }
//         }
//     }
// }
