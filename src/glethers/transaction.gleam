import gleam/option.{type Option}
import glethers/primitives/integer.{type Uint128, type Uint64}
import glethers/primitives/integer/uint256.{type Uint256}
import glethers/transaction/accesslist.{type AccessList}
import glethers/transaction/txkind.{type TxKind}

pub type Transaction {
  TxLegacy(
    chain_id: Option(Uint64),
    nonce: Uint64,
    gas_price: Uint64,
    gas_limit: Uint64,
    to: TxKind,
    value: Uint256,
    input: BitArray,
  )
  TxEip1559(
    chain_id: Option(Uint64),
    nonce: Uint64,
    gas_limit: Uint64,
    max_fee_per_gas: Uint128,
    max_priority_fee_per_gas: Uint128,
    to: txkind.TxKind,
    value: Uint256,
    access_list: AccessList,
    input: BitArray,
  )
}
