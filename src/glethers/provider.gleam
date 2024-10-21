import gleam/dynamic
import gleam/http/response
import gleam/result
import glethers/rpc/calls
import glethers/rpc/methods
import toy

// import gleam/dynamic
import gleam/http.{Post}
import gleam/http/request

// import gleam/httpc
import gleam/json

pub opaque type Provider {
  Rpc(endpoint: String)
}

pub fn new_rpc_provider(endpoint: String) -> Result(Provider, Nil) {
  use _ <- result.try(request.to(endpoint))
  Ok(Rpc(endpoint))
}

pub type ProviderError {
  JsonDecodeError(json.DecodeError)
  ToyDecodeError(List(toy.ToyError))
}

pub fn to_request(
  provider: Provider,
  method: methods.RpcMethod,
) -> request.Request(String) {
  let assert Ok(request) = request.to(provider.endpoint)
  request
  |> request.set_method(Post)
  |> request.set_body(method)
  |> request.set_path("/")
  |> request.prepend_header("Content-Type", "application/json")
  |> request.map(methods.convert_to_body)
}

pub fn decode_response(
  body: response.Response(String),
) -> Result(calls.JsonRpcResponse, ProviderError) {
  use data <- result.try(
    json.decode(body.body, dynamic.dynamic)
    |> result.map_error(fn(err) { JsonDecodeError(err) }),
  )
  data
  |> calls.decode
  |> result.map_error(fn(err) { ToyDecodeError(err) })
}
