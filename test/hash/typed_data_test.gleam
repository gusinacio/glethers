import ethers_gleam/address
import ethers_gleam/hash/typed_data.{Primitive, Struct}
import ethers_gleam/primitives
import ethers_gleam/primitives/integer
import gleam/bit_array
import gleam/dict
import gleam/option
import gleeunit/should

pub fn hash_domain_test() {
  let assert Ok(verifying_contract) =
    address.from_string("0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC")
  let domain =
    typed_data.TypedDataDomain(
      name: option.Some("Ether Mail"),
      version: option.Some("1"),
      chain_id: option.Some(integer.Uint256(0x1)),
      verifying_contract: option.Some(verifying_contract),
      salt: option.None,
    )
  let assert Ok(expected) =
    bit_array.base16_decode(
      "f2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f",
    )

  domain |> typed_data.hash_domain |> should.equal(expected)
}

type Person {
  Person(name: String, wallet: address.Address)
}

fn eip_712_encoder(person: Person) -> typed_data.TypedData {
  let value = [
    #("name", Primitive(primitives.from_string(person.name))),
    #("wallet", Primitive(primitives.from_address(person.wallet))),
  ]
  dict.from_list([#("Person", value)])
}

pub fn hash_structure_test() {
  let assert Ok(wallet) =
    address.from_string("0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826")
  let person = Person(name: "Cow", wallet: wallet)
  let typed_data = eip_712_encoder(person)
}
