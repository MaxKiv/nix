use defmt::info;
use embassy_executor::Spawner;
use embassy_stm32::exti::ExtiInput;
use embassy_stm32::gpio::Pull;
use embassy_stm32::{Peri, peripherals::*};

pub struct Button<'a> {
    pub input: ExtiInput<'a>,
    pub name: &'static str,
}

pub struct ButtonPeripherals {
    pub b1: (Peri<'static, PE2>, Peri<'static, EXTI2>),
    pub b2: (Peri<'static, PE3>, Peri<'static, EXTI3>),
    pub b3: (Peri<'static, PE4>, Peri<'static, EXTI4>),
    pub b4: (Peri<'static, PE5>, Peri<'static, EXTI5>),
    pub b5: (Peri<'static, PE6>, Peri<'static, EXTI6>),
}

pub fn setup(p: ButtonPeripherals, spawner: &Spawner) {
    spawner.spawn(manage_button(p)).unwrap();
}

#[embassy_executor::task]
pub async fn manage_button(p: ButtonPeripherals) {
    let button_1 = Button {
        input: ExtiInput::new(p.b1.0, p.b1.1, Pull::Down),
        name: "1",
    };
    let button_2 = Button {
        input: ExtiInput::new(p.b2.0, p.b2.1, Pull::Down),
        name: "2",
    };
    let button_3 = Button {
        input: ExtiInput::new(p.b3.0, p.b3.1, Pull::Down),
        name: "3",
    };
    let button_4 = Button {
        input: ExtiInput::new(p.b4.0, p.b4.1, Pull::Down),
        name: "4",
    };
    let button_5 = Button {
        input: ExtiInput::new(p.b5.0, p.b5.1, Pull::Down),
        name: "5",
    };

    let handle_2 = handle_button(button_2);
    let handle_1 = handle_button(button_1);
    let handle_3 = handle_button(button_3);
    let handle_4 = handle_button(button_4);
    let handle_5 = handle_button(button_5);

    info!("Press a button...");

    embassy_futures::select::select5(handle_1, handle_2, handle_3, handle_4, handle_5).await;
}

async fn handle_button(mut button: Button<'_>) {
    loop {
        button.input.wait_for_rising_edge().await;
        info!("button {} pressed", button.name);
        button.input.wait_for_falling_edge().await;
        info!("Released!");
    }
}
