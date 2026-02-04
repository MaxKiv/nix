#![no_std]
#![no_main]

use defmt::*;
use embassy_executor::Spawner;
use embassy_futures::select::select5;
use embassy_stm32::exti::ExtiInput;
use embassy_stm32::gpio::Pull;
use {defmt_rtt as _, panic_probe as _};

struct Button<'a> {
    input: ExtiInput<'a>,
    name: &'static str,
}

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    let p = embassy_stm32::init(Default::default());
    info!("Hello World!");

    let mut button_1 = Button {
        input: ExtiInput::new(p.PE2, p.EXTI2, Pull::Down),
        name: "1",
    };
    let handle_1 = handle_button(button_1);
    let mut button_2 = Button {
        input: ExtiInput::new(p.PE4, p.EXTI4, Pull::Down),
        name: "2",
    };
    let handle_2 = handle_button(button_2);
    let mut button_3 = Button {
        input: ExtiInput::new(p.PE5, p.EXTI5, Pull::Down),
        name: "3",
    };
    let handle_3 = handle_button(button_3);
    let mut button_4 = Button {
        input: ExtiInput::new(p.PE6, p.EXTI6, Pull::Down),
        name: "4",
    };
    let handle_4 = handle_button(button_4);
    let mut button_5 = Button {
        input: ExtiInput::new(p.PE3, p.EXTI3, Pull::Down),
        name: "5",
    };
    let handle_5 = handle_button(button_5);

    info!("Press a button...");

    select5(handle_1, handle_2, handle_3, handle_4, handle_5).await;
}

async fn handle_button(mut button: Button<'_>) {
    loop {
        button.input.wait_for_rising_edge().await;
        info!("button {} pressed", button.name);
        button.input.wait_for_falling_edge().await;
        info!("Released!");
    }
}
