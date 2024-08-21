import gleam/http/response
import glethers/rpc/calls
import glethers/rpc/methods

// import gleam/dynamic
import gleam/http.{Post}
import gleam/http/request

// import gleam/httpc
import gleam/json

pub type Provider {
  Rpc(endpoint: String)
}

pub type ProviderError {
  DecodeError(json.DecodeError)
}

pub fn to_request(
  provider: Provider,
  method: methods.RpcMethod,
) -> request.Request(String) {
  request.new()
  |> request.set_method(Post)
  |> request.set_host(provider.endpoint)
  |> request.set_body(method)
  |> request.set_path("/")
  |> request.prepend_header("Content-Type", "application/json")
  |> request.map(methods.convert_to_body)
}

pub fn decode_response(
  body: response.Response(String),
) -> Result(calls.JsonRpcResponse, json.DecodeError) {
  body.body
  |> calls.decode
}
