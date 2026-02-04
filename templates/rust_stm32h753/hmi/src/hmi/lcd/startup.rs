use defmt::*;
use display_interface_i2c::I2CInterface;
use embassy_stm32::{
    i2c::{I2c, Master},
    mode::Async,
};
use embassy_time::{Duration, Timer};
use embedded_graphics::{
    Drawable,
    image::{Image, ImageRawLE},
};
use embedded_graphics::{pixelcolor::BinaryColor, prelude::Point};
use oled_async::{displays::ssd1309::Ssd1309_128_64, mode::GraphicsMode};

use crate::hmi::lcd::setup::SSD1309_FRAMEBUFFER_SIZE;

pub async fn startup_display(
    display: &mut GraphicsMode<
        Ssd1309_128_64,
        I2CInterface<I2c<'static, Async, Master>>,
        { SSD1309_FRAMEBUFFER_SIZE },
    >,
) {
    // Initialise display
    while display.init().await.is_err() {
        error!("Unable to initialise display, is it connected?");
        Timer::after(Duration::from_millis(1000)).await;
    }
    display.clear();
    display.flush().await.unwrap();

    // Load image data
    let joris_im: ImageRawLE<BinaryColor> = ImageRawLE::new(
        include_bytes!("/home/max/git/saxion/peeler_mouse/data/joris.raw"),
        128,
    );
    let joris = Image::new(&joris_im, Point::new(0, 0));

    // let rene_im: ImageRawLE<BinaryColor> = ImageRawLE::new(
    //     include_bytes!("/home/max/git/saxion/peeler_mouse/data/rene.raw"),
    //     128,
    // );
    // let rene = Image::new(&rene_im, Point::new(0, 0));
    //
    // let lex_im: ImageRawLE<BinaryColor> = ImageRawLE::new(
    //     include_bytes!("/home/max/git/saxion/peeler_mouse/data/lex.raw"),
    //     128,
    // )
    // let lex = Image::new(&lex_im, Point::new(0, 0));

    joris.draw(display).unwrap();
    if display.flush().await.is_err() {
        error!("Unable to flush display");
    }

    // Give people time to appreciate the beautiful splash screen
    Timer::after_millis(350).await;
}
