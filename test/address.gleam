import gleeunit/should
import glethers/address

// gleeunit test functions end in `_test`
pub fn parse_address_test() {
  // with 0x prefix
  let address = "0x1234567890abcdef1234567890abcdef12345678"
  let address = address |> address.from_string
  address
  |> should.be_ok

  // without 0x prefix
  let address = "1234567890abcdef1234567890abcdef12345678"
  let address = address |> address.from_string
  address
  |> should.be_ok

  // invalid address
  let address = "1234567890abcdef1234567890ABCDEF123mnopq"

  let address = address |> address.from_string
  address
  |> should.equal(Error(address.NonHexDecimal))

  // invalid length
  let address = "1234567890abcdef1234567890abcdef123m"

  let address = address |> address.from_string
  address
  |> should.equal(Error(address.IncorrectLength))
}
