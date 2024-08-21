import gleam/dynamic.{field, int, string}
import gleam/json

pub type JsonRpcResponse {
  Result(id: Int, jsonrpc: String, result: dynamic.Dynamic)
  Error(id: Int, jsonrpc: String, error: JsonRpcError)
}

pub type JsonRpcError {
  JsonRpcError(code: Int, message: String)
}

fn error_decoder() {
  dynamic.decode2(
    JsonRpcError,
    field("code", of: int),
    field("message", of: string),
  )
}

fn response_decoder() {
  dynamic.any([
    dynamic.decode3(
      Result,
      field("id", of: int),
      field("jsonrpc", of: string),
      field("result", of: dynamic.dynamic),
    ),
    dynamic.decode3(
      Error,
      field("id", of: int),
      field("jsonrpc", of: string),
      field("error", error_decoder()),
    ),
  ])
}

pub fn decode(json_string: String) -> Result(JsonRpcResponse, json.DecodeError) {
  json.decode(from: json_string, using: response_decoder())
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
