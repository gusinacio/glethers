import gleam/bit_array
import gleam/int
import gleam/string
import keccak_gleam

const message_prefix = "\u{0019}Ethereum Signed Message:\n"

// 32 bytes bit array
pub opaque type Hash {
  Hash(BitArray)
}

pub fn from_bit_array(hash: BitArray) -> Result(Hash, String) {
  case bit_array.byte_size(hash) == 32 {
    True -> Ok(Hash(hash))
    False -> Error("Invalid bit array length")
  }
}

pub fn to_bit_array(hash: Hash) -> BitArray {
  let Hash(hash) = hash
  hash
}

pub fn hash_message(message: String) -> Hash {
  let message_prefix_bit_array = message_prefix |> bit_array.from_string
  let message_length =
    string.length(message) |> int.to_string() |> bit_array.from_string
  let utf8_message = message |> bit_array.from_string

  // we just assume that the message is 32 bytes
  Hash(
    keccak_gleam.hash(
      bit_array.concat([message_prefix_bit_array, message_length, utf8_message]),
    ),
  )
}
