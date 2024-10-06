import gleam/dynamic
import gleam/json
import toy

pub type JsonRpcResponse {
  Result(id: Int, jsonrpc: String, result: dynamic.Dynamic)
  Error(id: Int, jsonrpc: String, error: JsonRpcError)
}

pub type JsonRpcError {
  JsonRpcError(code: Int, message: String)
}

fn rpc_error_decoder() -> toy.Decoder(JsonRpcError) {
  use code <- toy.field("code", toy.int)
  use message <- toy.field("message", toy.string)
  toy.decoded(JsonRpcError(code:, message:))
}

fn result_decoder() {
  use id <- toy.field("id", toy.int)
  use jsonrpc <- toy.field("jsonrpc", toy.string)
  use result <- toy.field("result", toy.dynamic)
  toy.decoded(Result(id:, jsonrpc:, result:))
}

fn response_error_decoder() {
  use id <- toy.field("id", toy.int)
  use jsonrpc <- toy.field("jsonrpc", toy.string)
  use error <- toy.field("error", rpc_error_decoder())
  toy.decoded(Error(id:, jsonrpc:, error:))
}

fn response_decoder() {
  toy.one_of([result_decoder(), response_error_decoder()])
}

pub fn decode(
  data: dynamic.Dynamic,
) -> Result(JsonRpcResponse, List(toy.ToyError)) {
  data |> toy.decode(response_decoder())
}

pub type RpcRequest {
  RpcRequest(method: String, params: List(String), id: Int, jsonrpc: String)
}

pub fn encode_rpc_call(json_rpc_call: RpcRequest) {
  json.object([
    #("jsonrpc", json.string(json_rpc_call.jsonrpc)),
    #("method", json.string(json_rpc_call.method)),
    #("params", json.array(from: json_rpc_call.params, of: json.string)),
    #("id", json.int(json_rpc_call.id)),
  ])
}
