import gleam/option.{type Option}
import glethers/address
import glethers/hash/message
import glethers/primitives/bytes
import glethers/primitives/integer
import glethers/transaction/eip2930
import glethers/transaction/sidecar

pub type ChainId =
  integer.Uint64


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
    sidecar: Option(sidecard.BlobTransactionSidecar),
  )
}

pub type TransactionInput {
  TransactionInput(data: List(integer.Uint8))
}

pub type Transaction {
  Transaction(to: address.Address)
}

pub fn new_transaction(req: TransactionRequest) -> Transaction {
  Transaction(req.to)
}

pub fn hash(_transaction: Transaction) -> message.Hash {
  todo
}

//_parseLegacy
//_parseEip2930
//_parseEip1559
//_parseEip4844

/// Check this builder's preferred type, based on the fields that are set.
///
/// Types are preferred as follows:
/// - EIP-4844 if sidecar or max_blob_fee_per_gas is set
/// - EIP-2930 if access_list is set
/// - Legacy if gas_price is set and access_list is unset
/// - EIP-1559 in all other cases
// pub const fn preferred_type(&self) -> TxType {
//     if self.sidecar.is_some() || self.max_fee_per_blob_gas.is_some() {
//         TxType::Eip4844
//     } else if self.access_list.is_some() && self.gas_price.is_some() {
//         TxType::Eip2930
//     } else if self.gas_price.is_some() {
//         TxType::Legacy
//     } else {
//         TxType::Eip1559
//     }
// }
