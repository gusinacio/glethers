import gleam/dynamic

pub type Uint256 {
  Uint256(Int)
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
