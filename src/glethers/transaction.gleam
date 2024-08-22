import gleam/option.{type Option}
import glethers/address
import glethers/hash/message
import glethers/primitives/bytes
import glethers/primitives/integer
import glethers/transaction/eip2930
import glethers/transaction/sidecar

pub type ChainId =
  integer.Uint64

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

pub type TransactionRequest {
  TransactionRequest(
    from: Option(address.Address),
    to: Option(address.Address),
    gas_price: Option(integer.Uint128),
    max_fee_per_gas: Option(integer.Uint128),
    max_priority_fee_per_gas: Option(integer.Uint128),
    max_fee_per_blob_gas: Option(integer.Uint128),
    gas: Option(integer.Uint128),
    value: Option(integer.Uint256),
    input: TransactionInput,
    nonce: Option(integer.Uint64),
    chain_id: Option(ChainId),
    access_list: Option(eip2930.AccessList),
    transaction_type: Option(integer.Uint8),
    blob_versioned_hashes: Option(List(bytes.Bytes32)),
    sidecar: Option(sidecar.BlobTransactionSidecar),
  )
}

pub type TransactionInput {
  TransactionInput(data: List(integer.Uint8))
}

pub type Transaction {
  Transaction(to: address.Address)
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
//_parseLegacy
//_parseEip2930
//_parseEip1559
//_parseEip4844
