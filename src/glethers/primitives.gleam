import gleam/bit_array
import gleam/dynamic
import glethers/address.{type Address}
import glethers/primitives/bytes
import glethers/primitives/integer/uint256
import keccak_gleam

pub type Primitive {
  String(String)
  Uint256(uint256.Uint256)
  Bytes32(bytes.Bytes32)
  Address(Address)
}

pub fn from_string(value: String) -> Primitive {
  String(value)
}

pub fn from_uint256(value: uint256.Uint256) -> Primitive {
  Uint256(value)
}

pub fn from_bytes32(value: bytes.Bytes32) -> Primitive {
  Bytes32(value)
}

pub fn from_address(value: address.Address) -> Primitive {
  Address(value)
}

pub fn from(value: a) -> Result(Primitive, List(dynamic.DecodeError)) {
  let a = dynamic.from(value)
  let decoder =
    dynamic.any([
      dynamic.decode1(String, dynamic.string),
      dynamic.decode1(Uint256, uint256.decoder),
      dynamic.decode1(Bytes32, bytes.decoder),
      dynamic.decode1(Address, address.decoder),
    ])
  decoder(a)
}

// always encodes to 32 bytes
pub fn eip712_encode(value: Primitive) -> BitArray {
  case value {
    String(value) -> keccak_gleam.hash(value |> bit_array.from_string)
    Uint256(value) -> value |> uint256.to_bit_array
    Bytes32(value) -> value |> bytes.to_bit_array
    Address(value) -> value |> address.to_bit_array
  }
}
