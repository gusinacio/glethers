import gleam/bit_array
import gleam/dict
import gleam/list
import gleam/option.{type Option}
import gleam/string
import gleam/string_builder
import glethers/address.{type Address}
import glethers/hash/message
import glethers/primitives
import glethers/primitives/bytes
import glethers/primitives/integer/uint256
import keccak_gleam

// domain should define its own fields
// unused fields should be left out of the struct
pub type TypedDataDomain {
  TypedDataDomain(
    name: Option(String),
    version: Option(String),
    chain_id: Option(uint256.Uint256),
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

type EncodeField {
  Name
  Version
  ChainId
  VerifyingContract
  Salt
}

fn do_domain_to_typed_data(
  domain: TypedDataDomain,
  field: EncodeField,
) -> TypedDataValues {
  case field {
    Name ->
      case domain.name {
        option.Some(name) -> [
          #("name", Primitive(primitives.from_string(name))),
          ..do_domain_to_typed_data(domain, Version)
        ]
        option.None -> do_domain_to_typed_data(domain, Version)
      }
    Version ->
      case domain.version {
        option.Some(version) -> [
          #("version", Primitive(primitives.from_string(version))),
          ..do_domain_to_typed_data(domain, ChainId)
        ]
        option.None -> do_domain_to_typed_data(domain, ChainId)
      }
    ChainId ->
      case domain.chain_id {
        option.Some(chain_id) -> [
          #("chainId", Primitive(primitives.from_uint256(chain_id))),
          ..do_domain_to_typed_data(domain, VerifyingContract)
        ]
        option.None -> do_domain_to_typed_data(domain, VerifyingContract)
      }
    VerifyingContract ->
      case domain.verifying_contract {
        option.Some(verifying_contract) -> [
          #(
            "verifyingContract",
            Primitive(primitives.from_address(verifying_contract)),
          ),
          ..do_domain_to_typed_data(domain, Salt)
        ]
        option.None -> do_domain_to_typed_data(domain, Salt)
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

fn domain_to_typed_data(domain: TypedDataDomain) -> TypedData {
  let typed_values = domain |> do_domain_to_typed_data(Name)
  #("EIP712Domain", typed_values)
}

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

fn do_encode_data(values: TypedDataValues) -> BitArray {
  case values {
    [] -> <<>>
    [#(_, value), ..rest] -> {
      let encoded_value = case value {
        Primitive(prim) -> {
          prim |> primitives.eip712_encode
        }
        Struct(struct) -> {
          struct |> hash_struct
        }
      }
      <<encoded_value:bits, do_encode_data(rest):bits>>
    }
  }
}

pub fn encode_data(values: TypedData) -> BitArray {
  do_encode_data(values.1)
}

pub fn hash_domain(domain: TypedDataDomain) -> BitArray {
  domain |> domain_to_typed_data |> hash_struct
}

pub fn hash_struct(data: TypedData) -> BitArray {
  let encoded_type = encode_type(data) |> bit_array.from_string
  let encoded_type_hash = keccak_gleam.hash(encoded_type)
  let encoded_data = encode_data(data)
  keccak_gleam.hash(bit_array.concat([encoded_type_hash, encoded_data]))
}

fn encode(domain: TypedDataDomain, values: TypedData) -> BitArray {
  bit_array.concat([<<0x19, 0x01>>, hash_domain(domain), hash_struct(values)])
}

pub fn hash_message(
  domain: TypedDataDomain,
  struct: a,
  encoder: fn(a) -> TypedData,
) -> message.Hash {
  let typed_data = encoder(struct)
  let assert Ok(hash) =
    message.from_bit_array(keccak_gleam.hash(encode(domain, typed_data)))
  hash
}
