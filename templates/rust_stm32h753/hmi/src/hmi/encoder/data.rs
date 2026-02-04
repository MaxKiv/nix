use core::fmt;
use embassy_stm32::timer::qei;

#[derive(Clone, Debug, defmt::Format)]
pub enum Direction {
    Increased,
    Decreased,
}

impl From<qei::Direction> for Direction {
    fn from(val: qei::Direction) -> Self {
        match val {
            qei::Direction::Upcounting => Self::Increased,
            qei::Direction::Downcounting => Self::Decreased,
        }
    }
}

impl core::fmt::Display for EncoderData {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self.dir {
            Direction::Increased => f.write_str("CW "),
            Direction::Decreased => f.write_str("CCW"),
        }?;
        f.write_fmt(format_args!(" {}", self.pos))
    }
}

impl Default for EncoderData {
    fn default() -> Self {
        Self {
            dir: Direction::Increased,
            pos: 0,
        }
    }
}

#[derive(Clone, Debug, defmt::Format)]
pub struct EncoderData {
    pub dir: Direction,
    pub pos: i16,
}
