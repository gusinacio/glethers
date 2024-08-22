import gleam/bit_array
import gleam/bool
import gleam/dynamic
import gleam/result

pub opaque type Bytes32 {
  Bytes32(BitArray)
}

pub type Bytes48 {
  Bytes48(BitArray)
}

pub fn decoder(
  value: dynamic.Dynamic,
) -> Result(Bytes32, List(dynamic.DecodeError)) {
  use str <- result.try(dynamic.bit_array(value))
  from_bit_array(str) |> result.map_error(fn(_) { [] })
}

pub fn from_bit_array(bytes32: BitArray) -> Result(Bytes32, String) {
  use <- bool.guard(
    when: bytes32 |> bit_array.byte_size != 32,
    return: Error("Incorrect length"),
  )
  Ok(Bytes32(bytes32))
}

pub fn to_bit_array(bytes32: Bytes32) -> BitArray {
  let Bytes32(bytes32) = bytes32
  bytes32
}
