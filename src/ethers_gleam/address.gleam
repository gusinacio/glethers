import gleam/bit_array
import gleam/bool
import gleam/dynamic
import gleam/list
import gleam/result
import gleam/string

pub opaque type Address {
  Address(String)
}

pub fn decoder(
  value: dynamic.Dynamic,
) -> Result(Address, List(dynamic.DecodeError)) {
  use str <- result.try(dynamic.element(1, dynamic.string)(value))
  from_string(str) |> result.map_error(fn(_) { [] })
}

pub type DecodeError {
  NotEnoughBytes
  NonHexDecimal
  IncorrectLength
}

pub fn from_string(addr: String) -> Result(Address, DecodeError) {
  let address = case addr {
    "0x" <> value -> value
    other -> other
  }
  // check length
  use <- bool.guard(
    when: address |> string.length != 40,
    return: Error(IncorrectLength),
  )
  // check for non hex decimal

  use <- bool.guard(
    when: address
      |> string.to_graphemes
      |> list.map(is_hex_char)
      |> list.any(fn(is_hex) { !is_hex }),
    return: Error(NonHexDecimal),
  )

  Ok(Address(address))
}

fn is_hex_char(char: String) -> Bool {
  case char {
    "0"
    | "1"
    | "2"
    | "3"
    | "4"
    | "5"
    | "6"
    | "7"
    | "8"
    | "9"
    | "a"
    | "b"
    | "c"
    | "d"
    | "e"
    | "f"
    | "A"
    | "B"
    | "C"
    | "D"
    | "E"
    | "F" -> True
    _ -> False
  }
}

pub fn to_string(address: Address) -> String {
  let Address(addr) = address
  "0x" <> addr
}

pub fn to_bit_array(address: Address) -> BitArray {
  let Address(addr) = address
  let assert Ok(bytes) = addr |> bit_array.base16_decode
  <<0:size(96), bytes:bits>>
}
