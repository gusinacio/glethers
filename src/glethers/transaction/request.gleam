import gleam/option.{type Option}
import glethers/address
import glethers/primitives/bytes
import glethers/primitives/integer.{type Uint128, type Uint64, type Uint8}
import glethers/primitives/integer/uint256.{type Uint256}
import glethers/transaction/accesslist
import glethers/transaction/sidecar
import glethers/transaction/txkind.{type TxKind}

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

pub fn tx_type_id(tx_type: TxType) -> Int {
  case tx_type {
    Legacy -> 0
    Eip2930 -> 1
    Eip1559 -> 2
    Eip4844 -> 3
  }
}

pub type TransactionInput {
  TransactionInput(input: Option(BitArray), data: Option(BitArray))
}

pub fn into_input(tx: TransactionInput) -> Option(BitArray) {
  option.or(tx.input, tx.data)
}

pub type TransactionRequest {
  TransactionRequest(
    from: Option(address.Address),
    to: Option(TxKind),
    gas_price: Option(Uint128),
    max_fee_per_gas: Option(Uint128),
    max_priority_fee_per_gas: Option(Uint128),
    max_fee_per_blob_gas: Option(Uint128),
    gas: Option(Uint64),
    value: Option(Uint256),
    input: TransactionInput,
    nonce: Option(Uint64),
    chain_id: Option(Uint64),
    access_list: Option(accesslist.AccessList),
    transaction_type: Option(Uint8),
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
