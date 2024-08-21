import ethers_gleam/address
import ethers_gleam/hash/message
import ethers_gleam/hash/typed_data.{Primitive, Struct}
import ethers_gleam/primitives
import ethers_gleam/primitives/integer
import ethers_gleam/signer
import ethers_gleam/signer/signing_key
import gleam/bit_array
import gleam/option
import gleam/string
import gleeunit/should
import secp256k1_gleam

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

pub fn encode_data_test() {
  let assert Ok(wallet) =
    address.from_string("0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826")

  let person = Person(name: "Cow", wallet: wallet)
  let typed_data = person_encoder(person)
  let hash = typed_data.hash_struct(typed_data)

  let assert Ok(expected) =
    "297900373bdec7367389f7e73ef4de05ccf64d18cf102258201c4cffb3f64e1e"
    |> bit_array.base16_decode

  hash |> should.equal(expected)
}

pub fn hash_message_test() {
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

  let assert Ok(wallet) =
    address.from_string("0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826")

  let person = Person(name: "Cow", wallet: wallet)
  let hash = typed_data.hash_message(domain, person, person_encoder)

  let assert Ok(expected) =
    "3ea4256e79a7b13bb5f3764a71bd58e5565f03031014be3c11da03a201c436a0"
    |> bit_array.base16_decode

  hash |> message.to_bit_array |> should.equal(expected)
}

pub fn sign_typed_data_test() {
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

  let assert Ok(wallet) =
    address.from_string("0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826")

  let person = Person(name: "Cow", wallet: wallet)
  let assert Ok(private_key) =
    signing_key.from_string(
      "0x314af9517df1fa5ab83ade9505d5d8b368d85833b4e39d7316daccba26e8e756",
    )
  let signature =
    private_key |> signer.sign_typed_data(domain, person, person_encoder)

  let expected =
    "0x67214bc6b9c398536dd440bf2fb7e9e9300a414b1d6d7efad681739b3632f3b4702485610bcd79ea1e9ba25511143ba9a0d5d341dc5eddd35dd3daf70d56d7861b"
  signature
  |> secp256k1_gleam.to_string
  |> string.lowercase()
  |> should.equal(expected)
}
