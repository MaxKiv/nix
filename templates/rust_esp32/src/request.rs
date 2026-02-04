/// Defines a ['ReadableRequest'] type that implments [std::io::Read] to easily deserialize http
/// requests using [serde_json::from_reader]
use std::io::ErrorKind;

use esp_idf_hal::io::EspIOError;
use esp_idf_svc::http::server::EspHttpConnection;
use serde::de::DeserializeOwned;

pub struct EspIOReaderError(EspIOError);

impl Into<std::io::Error> for EspIOReaderError {
    fn into(self) -> std::io::Error {
        std::io::Error::new(ErrorKind::Other, self.0)
    }
}

/// Create a request that implments [std::io::Read]
pub struct ReadableRequest<'a, 'r, 'c>(
    pub &'a mut esp_idf_svc::http::server::Request<&'r mut EspHttpConnection<'c>>,
);

impl<'a, 'r, 'c> std::io::Read for &mut ReadableRequest<'a, 'r, 'c> {
    fn read(&mut self, buf: &mut [u8]) -> std::io::Result<usize> {
        self.0.read(buf).map_err(|e| EspIOReaderError(e).into())
    }
}

impl<'a, 'r, 'c> ReadableRequest<'a, 'r, 'c> {
    /// Deserialize a ['ReadableRequest'] into a T
    pub fn deserialize_into<T>(mut self) -> anyhow::Result<T>
    where
        T: DeserializeOwned,
    {
        let val: T = serde_json::from_reader(&mut self)?;
        Ok(val)
    }
}
