import gleam/dynamic
import gleeunit/should
import glethers/address
import glethers/primitives/integer/uint256

pub fn uint256_decode_test() {
  let value = uint256.new_unchecked(123_456_789)
  let dynamic_v = dynamic.from(value)

  let primitive = uint256.decoder(dynamic_v)
  primitive |> should.be_ok
  let assert Ok(_) = primitive
}

pub fn uint256_to_bit_array_test() {
  let value = uint256.new_unchecked(0x123465789abcdef123456789abcdef123456)
  let expected = <<
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 52, 101, 120, 154, 188, 222,
    241, 35, 69, 103, 137, 171, 205, 239, 18, 52, 86,
  >>

  value |> uint256.to_bit_array |> should.equal(expected)
}

pub fn address_to_bit_array_test() {
  let assert Ok(value) =
    address.from_string("0x8D97689C9818892B700e27F316cc3E41e17fBeb9")

  let expected = <<
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 141, 151, 104, 156, 152, 24, 137, 43,
    112, 14, 39, 243, 22, 204, 62, 65, 225, 127, 190, 185,
  >>

  value |> address.to_bit_array |> should.equal(expected)
}
