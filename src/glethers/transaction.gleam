import gleam/option.{type Option}
import gleam/result
import glethers/address
import glethers/hash/message
import glethers/primitives/bytes
import glethers/primitives/integer
import glethers/primitives/integer/uint256
import glethers/provider
import glethers/transaction/eip2930
import glethers/transaction/sidecar

pub type TxType {
  /// Legacy transaction type.
  Legacy
  /// EIP-2930 transaction type.
  Eip2930
  /// EIP-1559 transaction type.
  Eip1559
  /// EIP-4844 transaction type.
  Eip4844
}

fn tx_type_id(tx_type: TxType) -> Int {
  case tx_type {
    Legacy -> 0
    Eip2930 -> 1
    Eip1559 -> 2
    Eip4844 -> 3
  }
}

pub opaque type TransactionRequest {
  TransactionRequest(
    from: Option(address.Address),
    to: Option(TxKind),
    gas_price: Option(integer.Uint128),
    max_fee_per_gas: Option(integer.Uint128),
    max_priority_fee_per_gas: Option(integer.Uint128),
    max_fee_per_blob_gas: Option(integer.Uint128),
    gas: Option(integer.Uint64),
    value: Option(uint256.Uint256),
    input: TransactionInput,
    nonce: Option(integer.Uint64),
    chain_id: Option(integer.Uint64),
    access_list: Option(eip2930.AccessList),
    transaction_type: Option(integer.Uint8),
    blob_versioned_hashes: Option(List(bytes.Bytes32)),
    sidecar: Option(sidecar.BlobTransactionSidecar),
  )
}

pub fn new() -> TransactionRequest {
  TransactionRequest(
    from: option.None,
    to: option.None,
    gas_price: option.None,
    max_fee_per_gas: option.None,
    max_priority_fee_per_gas: option.None,
    max_fee_per_blob_gas: option.None,
    gas: option.None,
    value: option.None,
    input: TransactionInput(input: option.None, data: option.None),
    nonce: option.None,
    chain_id: option.None,
    access_list: option.None,
    transaction_type: option.None,
    blob_versioned_hashes: option.None,
    sidecar: option.None,
  )
}

pub fn build(_request: TransactionRequest) -> Result(TypedTransaction, String) {
  // let assert option.Some(tx_type) = buildable_type(request)
  Ok(TypedTransaction)
}

// fn buildable_type(_request: TransactionRequest) -> Option(TxType) {
//   option.None
// }

pub type TypedTransaction {
  TypedTransaction
}

pub type TransactionInput {
  TransactionInput(input: Option(BitArray), data: Option(BitArray))
}

fn into_input(tx: TransactionInput) -> Option(BitArray) {
  option.or(tx.input, tx.data)
}

pub type Transaction {
  TxLegacy(
    chain_id: Option(integer.Uint64),
    nonce: integer.Uint64,
    gas_price: integer.Uint64,
    gas_limit: integer.Uint64,
    to: TxKind,
    value: uint256.Uint256,
    input: BitArray,
  )
  TxEip1559(
    chain_id: Option(integer.Uint64),
    nonce: integer.Uint64,
    gas_limit: integer.Uint64,
    max_fee_per_gas: integer.Uint128,
    max_priority_fee_per_gas: integer.Uint128,
    to: TxKind,
    value: uint256.Uint256,
    access_list: eip2930.AccessList,
    input: BitArray,
  )
}

pub type TxKind {
  Create
  Call(address.Address)
}

pub fn hash(_transaction: Transaction) -> message.Hash {
  todo
}

/// Check this builder's preferred type, based on the fields that are set.
///
/// Types are preferred as follows:
/// - EIP-4844 if sidecar or max_blob_fee_per_gas is set
/// - EIP-2930 if access_list is set
/// - Legacy if gas_price is set and access_list is unset
/// - EIP-1559 in all other cases
fn preferred_type(tx: TransactionRequest) -> TxType {
  let sidecar = tx.sidecar |> option.is_some
  let max_fee_per_blob_gas = tx.max_fee_per_blob_gas |> option.is_some
  let access_list = tx.access_list |> option.is_some
  let gas_price = tx.gas_price |> option.is_some
  let sidecard_or_max_blob_fee = sidecar || max_fee_per_blob_gas
  let access_list_and_gas_price = access_list && gas_price
  case sidecard_or_max_blob_fee, access_list_and_gas_price, gas_price {
    True, _, _ -> Eip4844
    _, True, _ -> Eip2930
    _, _, True -> Legacy
    _, _, _ -> Eip1559
  }
}

pub fn parse(tx: TransactionRequest) {
  let parse = case preferred_type(tx) {
    Eip1559 -> build_eip1559
    Eip2930 -> parse_eip2930
    Eip4844 -> parse_eip4844
    Legacy -> parse_legacy
  }
  parse(tx)
}

fn build_eip1559(tx: TransactionRequest) -> Result(Transaction, String) {
  use to <- result.try(
    tx.to
    |> option.to_result("Missing 'to' field for Eip1559 transaction."),
  )
  use nonce <- result.try(
    tx.nonce
    |> option.to_result("Missing 'nonce' field for Eip1559 transaction."),
  )
  use gas_limit <- result.try(
    tx.gas
    |> option.to_result("Missing 'gas_limit' field for Eip1559 transaction."),
  )

  use max_fee_per_gas <- result.try(
    tx.max_fee_per_gas
    |> option.to_result(
      "Missing 'max_fee_per_gas' field for Eip1559 transaction.",
    ),
  )

  use max_priority_fee_per_gas <- result.try(
    tx.max_priority_fee_per_gas
    |> option.to_result(
      "Missing 'max_priority_fee_per_gas' field for Eip1559 transaction.",
    ),
  )

  use value <- result.try(
    tx.value
    |> option.to_result("Missing 'value' field for Eip1559 transaction."),
  )

  use access_list <- result.try(
    tx.access_list
    |> option.to_result("Missing 'access_list' field for Eip1559 transaction."),
  )

  use input <- result.try(
    tx.input
    |> into_input
    |> option.to_result("Missing 'input' field for Eip1559 transaction."),
  )
  Ok(TxEip1559(
    chain_id: tx.chain_id,
    nonce:,
    gas_limit:,
    max_fee_per_gas:,
    max_priority_fee_per_gas:,
    to:,
    value:,
    access_list:,
    input:,
  ))
}

//_parseLegacy
fn parse_legacy(_tx: TransactionRequest) {
  todo as "Legacy not implemented yet"
}

fn parse_eip2930(_tx: TransactionRequest) {
  todo as "Eip2930 not implemented yet"
}

fn parse_eip4844(_tx: TransactionRequest) {
  todo as "Eip4844 not implemented yet"
}
