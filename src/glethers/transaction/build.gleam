import gleam/option
import glethers/transaction/eip1559
import glethers/transaction/eip2930
import glethers/transaction/eip4844
import glethers/transaction/legacy
import glethers/transaction/request.{
  type TransactionRequest, type TxType, Eip1559, Eip2930, Eip4844, Legacy,
}

/// Check this builder's preferred type, based on the fields that are set.
///
/// Types are preferred as follows:
/// - EIP-4844 if sidecar or max_blob_fee_per_gas is set
/// - EIP-2930 if access_list is set
/// - Legacy if gas_price is set and access_list is unset
/// - EIP-1559 in all other cases
fn preferred_type(tx: request.TransactionRequest) -> TxType {
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

pub fn build(tx: TransactionRequest) {
  let build = case preferred_type(tx) {
    Eip1559 -> eip1559.build
    Eip2930 -> eip2930.build
    Eip4844 -> eip4844.build
    Legacy -> legacy.build
  }
  build(tx)
}
