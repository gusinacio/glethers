import ethers_gleam/address.{type Address}
import ethers_gleam/primitives
import ethers_gleam/primitives/bytes
import ethers_gleam/primitives/integer
import gleam/bit_array
import gleam/dict
import gleam/option.{type Option}
import gleam/result
import gleam/string_builder
import keccak_gleam

// domain should define its own fields
// unused fields should be left out of the struct
pub type TypedDataDomain {
  TypedDataDomain(
    name: Option(String),
    version: Option(String),
    chain_id: Option(integer.Uint256),
    verifying_contract: Option(Address),
    salt: Option(bytes.Bytes32),
  )
}

pub type ComplexField {
  Primitive(primitives.Primitive)
  Struct(TypedData)
}

pub type TypedDataValues =
  dict.Dict(String, ComplexField)

pub type TypedData =
  dict.Dict(String, TypedDataValues)

type EncodeField {
  Name
  Version
  ChainId
  VerifyingContract
  Salt
}

fn do_encode_type(
  domain: TypedDataDomain,
  field: EncodeField,
) -> List(string_builder.StringBuilder) {
  case field {
    Name ->
      case option.is_some(domain.name) {
        True -> [
          string_builder.from_string("string name"),
          ..do_encode_type(domain, Version)
        ]
        False -> do_encode_type(domain, Version)
      }
    Version ->
      case option.is_some(domain.version) {
        True -> [
          string_builder.from_string("string version"),
          ..do_encode_type(domain, ChainId)
        ]
        False -> do_encode_type(domain, ChainId)
      }
    ChainId ->
      case option.is_some(domain.chain_id) {
        True -> [
          string_builder.from_string("uint256 chainId"),
          ..do_encode_type(domain, VerifyingContract)
        ]
        False -> do_encode_type(domain, Salt)
      }
    VerifyingContract ->
      case option.is_some(domain.verifying_contract) {
        True -> [
          string_builder.from_string("address verifyingContract"),
          ..do_encode_type(domain, Salt)
        ]
        False -> do_encode_type(domain, Salt)
      }
    Salt ->
      case option.is_some(domain.salt) {
        True -> [string_builder.from_string("bytes32 salt")]
        False -> []
      }
  }
}

fn encode_type(domain: TypedDataDomain) -> String {
  let types = do_encode_type(domain, Name)
  string_builder.from_string("EIP712Domain(")
  |> string_builder.append_builder(string_builder.join(types, ","))
  |> string_builder.append(")")
  |> string_builder.to_string
}

fn do_encode_data(domain: TypedDataDomain, field: EncodeField) -> BitArray {
  case field {
    Name ->
      case domain.name {
        option.Some(name) -> {
          let assert Ok(name) =
            primitives.from(name) |> result.map(primitives.eip712_encode)
          bit_array.concat([name, do_encode_data(domain, Version)])
        }
        option.None -> do_encode_data(domain, Version)
      }
    Version ->
      case domain.version {
        option.Some(version) -> {
          let assert Ok(version) =
            primitives.from(version) |> result.map(primitives.eip712_encode)
          bit_array.concat([version, do_encode_data(domain, ChainId)])
        }
        option.None -> do_encode_data(domain, ChainId)
      }
    ChainId ->
      case domain.chain_id {
        option.Some(chain_id) -> {
          let assert Ok(chain_id) =
            primitives.from(chain_id) |> result.map(primitives.eip712_encode)
          bit_array.concat([chain_id, do_encode_data(domain, VerifyingContract)])
        }
        option.None -> do_encode_data(domain, VerifyingContract)
      }
    VerifyingContract ->
      case domain.verifying_contract {
        option.Some(verifying_contract) -> {
          let assert Ok(verifying_contract) =
            primitives.from(verifying_contract)
            |> result.map(primitives.eip712_encode)
          bit_array.concat([verifying_contract, do_encode_data(domain, Salt)])
        }
        option.None -> do_encode_data(domain, Salt)
      }
    Salt ->
      case domain.salt {
        option.Some(salt) -> {
          let assert Ok(salt) =
            primitives.from(salt) |> result.map(primitives.eip712_encode)
          bit_array.concat([salt])
        }
        option.None -> <<>>
      }
  }
}

fn encode_data(domain: TypedDataDomain) -> BitArray {
  do_encode_data(domain, Name)
}

pub fn hash_domain(domain: TypedDataDomain) -> BitArray {
  let encoded_type = encode_type(domain) |> bit_array.from_string
  let encoded_type_hash = keccak_gleam.hash(encoded_type)
  let encoded_data = encode_data(domain)
  keccak_gleam.hash(bit_array.concat([encoded_type_hash, encoded_data]))
}

pub fn encode_types_and_values(_values: TypedData) -> BitArray {
  <<>>
}

pub fn encode(domain: TypedDataDomain, values: TypedData) -> BitArray {
  bit_array.concat([
    <<0x19, 0x01>>,
    hash_domain(domain),
    encode_types_and_values(values),
  ])
}

pub fn hash_structure(domain: TypedDataDomain, values: TypedData) -> BitArray {
  keccak_gleam.hash(encode(domain, values))
}
