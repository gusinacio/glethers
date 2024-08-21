import gleam/bit_array
import gleam/result

pub opaque type PrivateKey {
  PrivateKey(BitArray)
}

pub type PrivateKeyError {
  WrongLength
  FailedBase16Decode
}

pub fn from_string(private_key: String) -> Result(PrivateKey, PrivateKeyError) {
  let private_key = case private_key {
    "0x" <> value -> value
    other -> other
  }

  use private_key <- result.try(
    private_key
    |> bit_array.base16_decode
    |> result.map_error(fn(_) { FailedBase16Decode }),
  )

  case bit_array.byte_size(private_key) {
    32 -> Ok(PrivateKey(private_key))
    _ -> Error(WrongLength)
  }
}

pub fn to_bit_array(private_key: PrivateKey) -> BitArray {
  let PrivateKey(private_key) = private_key
  private_key
}
