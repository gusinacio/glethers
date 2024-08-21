import ethers_gleam/address
import ethers_gleam/block
import ethers_gleam/rpc/calls
import gleam/json

pub type RpcMethod {
  BlockNumber
  ChainId
  GasPrice
  GetAccount(address: address.Address, block: block.Block)
  GetBalance(address: address.Address, block: block.Block)
}

pub fn convert_to_body(method: RpcMethod) -> String {
  let #(call, params) = case method {
    BlockNumber -> #("eth_blockNumber", [])
    ChainId -> #("eth_chainId", [])
    GasPrice -> #("eth_gasPrice", [])
    GetAccount(address: address, block: block) -> #("eth_getAccount", [
      address |> address.to_string,
      block |> block.to_string,
    ])
    GetBalance(address: address, block: block) -> #("eth_getBalance", [
      address |> address.to_string,
      block |> block.to_string,
    ])
  }

  calls.RpcRequest(method: call, params: params, id: 1, jsonrpc: "2.0")
  |> calls.encode_rpc_call
  |> json.to_string
}
