import envoy
import gleam/httpc
import gleam/result
import gleeunit/should
import glethers/address
import glethers/block
import glethers/primitives/integer/uint256
import glethers/provider
import glethers/rpc/calls
import glethers/rpc/methods
import glethers/rpc/response
import glethers/wei

pub fn rpc_methods_test() {
  let provider =
    envoy.get("RPC_ENDPOINT") |> result.unwrap("http://127.0.0.1:8545")
  let assert Ok(provider) = provider.new_rpc_provider(provider)
  let assert Ok(address) =
    address.from_string("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")

  let method = methods.GetBalance(address:, block: block.Latest)
  let response_decoder = response.decode_response(method)

  let req =
    provider
    |> provider.to_request(method)

  let assert Ok(resp) = httpc.send(req)
  let resp = resp |> provider.decode_response

  resp
  |> should.be_ok
  let assert Ok(calls.Result(_, _, data)) = resp
  let assert Ok(response.GetBalance(data)) = response_decoder(data)
  data
  |> should.equal(uint256.new_unchecked(10_000) |> uint256.multiply(wei.ether))
}
