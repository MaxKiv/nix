use embassy_executor::Spawner;
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::watch::{Receiver, Sender, Watch};

use crate::hmi::pot::WATCH_POT;

const NUM_AVG: u32 = 10;

pub static LP_POT: Watch<CriticalSectionRawMutex, u16, 2> = Watch::new();

pub fn setup_low_pass_for_pot(spawner: &Spawner) {
    let rx = WATCH_POT.receiver().expect("Increase WATCH_POT N");
    let tx = LP_POT.sender();

    spawner.spawn(lowpass_filter_pot(rx, tx)).unwrap();
}

#[embassy_executor::task]
pub async fn lowpass_filter_pot(
    mut rx: Receiver<'static, CriticalSectionRawMutex, u16, 1>,
    tx: Sender<'static, CriticalSectionRawMutex, u16, 2>,
) {
    let mut avg = 0u32;

    loop {
        let new = rx.changed().await;
        avg = ((avg * (NUM_AVG - 1)) + new as u32) / NUM_AVG;
        tx.send(
            avg.try_into()
                .expect("Lowpass filter average does not fit u32, indicates logic error"),
        );
    }
}
