import ethers_gleam/address.{type Address}
import ethers_gleam/primitives
import ethers_gleam/primitives/bytes
import ethers_gleam/primitives/integer
import gleam/bit_array
import gleam/dict
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
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
  List(#(String, ComplexField))

pub type TypedData =
  #(String, TypedDataValues)

fn do_encode_type(
  values: TypedDataValues,
) -> #(List(string_builder.StringBuilder), dict.Dict(String, String)) {
  case values {
    [] -> #([], dict.new())
    [#(key, value), ..rest] -> {
      let #(type_, new_types) = case value {
        Primitive(primitives.String(_)) -> #("string", option.None)
        Primitive(primitives.Address(_)) -> #("address", option.None)
        Primitive(primitives.Uint256(_)) -> #("uint256", option.None)
        Primitive(primitives.Bytes32(_)) -> #("bytes32", option.None)
        Struct(struct) -> {
          let struct_name = encode_type(struct)
          let #(name, _) = struct
          #(name, option.Some(struct_name))
        }
      }
      let #(rest, names) = do_encode_type(rest)
      let result_dict = case new_types {
        option.Some(name) -> names |> dict.insert(type_, name)
        option.None -> names
      }
      #([string_builder.from_string(type_ <> " " <> key), ..rest], result_dict)
    }
  }
}

type EncodeField {
  Name
  Version
  ChainId
  VerifyingContract
  Salt
}

fn domain_to_type(
  domain: TypedDataDomain,
  field: EncodeField,
) -> TypedDataValues {
  case field {
    Name ->
      case domain.name {
        option.Some(name) -> [
          #("name", Primitive(primitives.from_string(name))),
          ..domain_to_type(domain, Version)
        ]
        option.None -> domain_to_type(domain, Version)
      }
    Version ->
      case domain.version {
        option.Some(version) -> [
          #("version", Primitive(primitives.from_string(version))),
          ..domain_to_type(domain, ChainId)
        ]
        option.None -> domain_to_type(domain, ChainId)
      }
    ChainId ->
      case domain.chain_id {
        option.Some(chain_id) -> [
          #("chainId", Primitive(primitives.from_uint256(chain_id))),
          ..domain_to_type(domain, VerifyingContract)
        ]
        option.None -> domain_to_type(domain, VerifyingContract)
      }
    VerifyingContract ->
      case domain.verifying_contract {
        option.Some(verifying_contract) -> [
          #(
            "verifyingContract",
            Primitive(primitives.from_address(verifying_contract)),
          ),
          ..domain_to_type(domain, Salt)
        ]
        option.None -> domain_to_type(domain, Salt)
      }
    Salt ->
      case domain.salt {
        option.Some(salt) -> [
          #("salt", Primitive(primitives.from_bytes32(salt))),
        ]
        option.None -> []
      }
  }
}

pub fn encode_type(typed_data: TypedData) -> String {
  let #(types, result_dict) = do_encode_type(typed_data.1)
  let struct_types =
    result_dict
    |> dict.to_list
    |> list.map(fn(x) { x.1 })
    |> list.sort(string.compare)
    |> list.map(string_builder.from_string)
  let builder =
    string_builder.from_string(typed_data.0 <> "(")
    |> string_builder.append_builder(string_builder.join(types, ","))
    |> string_builder.append(")")

  string_builder.concat([builder, ..struct_types])
  |> string_builder.to_string
}

fn encode_domain_type(domain: TypedDataDomain) -> String {
  let types = domain |> domain_to_type(Name)
  #("EIP712Domain", types) |> encode_type
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
  let encoded_type = encode_domain_type(domain) |> bit_array.from_string
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
