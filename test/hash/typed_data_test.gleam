import ethers_gleam/address
import ethers_gleam/hash/typed_data.{Primitive, Struct}
import ethers_gleam/primitives
import ethers_gleam/primitives/integer
import gleam/bit_array
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
  Person(wallet: address.Address, name: String)
}

type Transaction {
  Transaction(from: Person, to: Person, tx: Asset)
}

type Asset {
  Asset(token: address.Address, amount: integer.Uint256)
}

fn asset_encoder(asset: Asset) -> typed_data.TypedData {
  let value = [
    #("token", Primitive(primitives.from_address(asset.token))),
    #("amount", Primitive(primitives.from_uint256(asset.amount))),
  ]
  #("Asset", value)
}

fn transaction_encoder(transaction: Transaction) -> typed_data.TypedData {
  let value = [
    #("from", Struct(person_encoder(transaction.from))),
    #("to", Struct(person_encoder(transaction.to))),
    #("tx", Struct(asset_encoder(transaction.tx))),
  ]
  #("Transaction", value)
}

fn person_encoder(person: Person) -> typed_data.TypedData {
  let value = [
    #("wallet", Primitive(primitives.from_address(person.wallet))),
    #("name", Primitive(primitives.from_string(person.name))),
  ]
  #("Person", value)
}

pub fn hash_structure_test() {
  let assert Ok(wallet_1) =
    address.from_string("0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826")
  let assert Ok(wallet_2) =
    address.from_string("0xB0B0b0b0b0b0B000000000000000000000000002")
  let assert Ok(wallet_3) =
    address.from_string("0xB0B0b0b0b0b0B000000000000000000000000003")

  let person_1 = Person(name: "Cow", wallet: wallet_1)
  let person_2 = Person(name: "Dog", wallet: wallet_2)
  let asset = Asset(token: wallet_3, amount: integer.Uint256(0x1))

  let transaction = Transaction(from: person_1, to: person_2, tx: asset)
  let typed_data = transaction_encoder(transaction)

  typed_data.encode_type(typed_data)
  |> should.equal(
    "Transaction(Person from,Person to,Asset tx)Asset(address token,uint256 amount)Person(address wallet,string name)",
  )
}
