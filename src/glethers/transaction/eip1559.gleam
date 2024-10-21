import gleam/option
import gleam/result
import glethers/transaction.{type Transaction, TxEip1559}
import glethers/transaction/request.{type TransactionRequest}

pub fn build(tx: TransactionRequest) -> Result(Transaction, String) {
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
    |> request.into_input
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
