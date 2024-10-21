import gleam/dynamic
import gleam/result
import glethers/primitives/integer
import glethers/primitives/integer/uint256
import glethers/rpc/methods

pub type RpcResponse {
  BlockNumber(uint256.Uint256)
  ChainId(integer.Uint64)
  GasPrice(uint256.Uint256)
  GetBalance(uint256.Uint256)
}

pub fn decode_response(
  method: methods.RpcMethod,
) -> fn(dynamic.Dynamic) -> Result(RpcResponse, String) {
  case method {
    methods.BlockNumber -> map_uint256_result(BlockNumber)
    methods.ChainId -> todo
    methods.GetBalance(_, _) -> map_uint256_result(GetBalance)
    methods.GasPrice -> map_uint256_result(GasPrice)
  }
}

fn map_uint256_result(
  func: fn(uint256.Uint256) -> RpcResponse,
) -> fn(dynamic.Dynamic) -> Result(RpcResponse, String) {
  fn(dyn) {
    use str <- result.try(
      dyn
      |> dynamic.string()
      |> result.replace_error("Could not convert into string"),
    )
    str
    |> uint256.from_string()
    |> result.map(func)
  }
}
