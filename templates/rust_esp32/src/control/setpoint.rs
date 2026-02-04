use serde::de::Error;
use serde::Deserialize;
use serde::Deserializer;
use uom::si::{f32::Length, length::millimeter};

const MIN_DEPTH: f32 = 0.0;
const MAX_DEPTH: f32 = 30.0;

fn deserialize_and_validate_depth<'de, D>(deserializer: D) -> Result<Length, D::Error>
where
    D: Deserializer<'de>,
{
    let v = f32::deserialize(deserializer)?;
    if (MIN_DEPTH..=MAX_DEPTH).contains(&v) {
        Ok(Length::new::<millimeter>(v))
    } else {
        Err(<D::Error as Error>::custom(format!(
            "depth setpoint out of range [{MIN_DEPTH}, {MAX_DEPTH}]: {v}"
        )))
    }
}

#[derive(Deserialize, Copy, Clone, Debug)]
pub struct Setpoint {
    #[serde(deserialize_with = "deserialize_and_validate_depth")]
    depth: Length,
}

impl Setpoint {
    pub fn get_depth_dutycycle(&self) -> u32 {
        const MAX_DC: f32 = 255.0;

        let dc = self.depth.get::<millimeter>() / MAX_DEPTH * MAX_DC;
        dc as u32
    }
}
