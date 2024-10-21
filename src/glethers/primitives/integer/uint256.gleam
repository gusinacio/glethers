import gleam/dynamic
import gleam/int
import gleam/result

pub opaque type Uint256 {
  Uint256(Int)
}

pub fn new(v: Int) -> Result(Uint256, String) {
  case v < 0 {
    True -> Error("Number is negative")
    False -> Ok(Uint256(v))
  }
}

pub fn new_unchecked(v: Int) -> Uint256 {
  let assert Ok(v) = new(v)
  v
}

pub fn decoder(
  value: dynamic.Dynamic,
) -> Result(Uint256, List(dynamic.DecodeError)) {
  let decoder = dynamic.decode1(Uint256, dynamic.element(1, dynamic.int))
  decoder(value)
}

pub fn to_bit_array(value: Uint256) -> BitArray {
  let Uint256(value) = value
  <<value:size(256)>>
}

pub fn from_string(value: String) -> Result(Uint256, String) {
  // remove any 0x prefix before parsing
  let value = case value {
    "0x" <> value -> value
    value -> value
  }
  value
  |> int.base_parse(16)
  |> result.map(fn(v) { Uint256(v) })
  |> result.replace_error("Could not parse hex string")
}

pub fn multiply(a: Uint256, b: Uint256) -> Uint256 {
  let Uint256(a) = a
  let Uint256(b) = b
  Uint256(a * b)
}

pub const ether = Uint256(1_000_000_000_000_000_000)
