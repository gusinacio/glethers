import gleam/json
import glethers/address
import glethers/block
import glethers/rpc/calls

pub type RpcMethod {
  BlockNumber
  ChainId
  GasPrice
  GetBalance(address: address.Address, block: block.Block)
}

pub fn convert_to_body(method: RpcMethod) -> String {
  let #(call, params) = case method {
    BlockNumber -> #("eth_blockNumber", [])
    ChainId -> #("eth_chainId", [])
    GasPrice -> #("eth_gasPrice", [])
    GetBalance(address: address, block: block) -> #("eth_getBalance", [
      address |> address.to_string,
      block |> block.to_string,
    ])
  }

  calls.RpcRequest(method: call, params: params, id: 1, jsonrpc: "2.0")
  |> calls.encode_rpc_call
  |> json.to_string
}
