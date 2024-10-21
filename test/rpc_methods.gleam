import gleam/dynamic
import gleam/httpc
import gleeunit/should
import glethers/address
import glethers/block
import glethers/primitives/integer/uint256
import glethers/provider
import glethers/rpc/calls.{Result}
import glethers/rpc/methods
import glethers/wei

pub fn rpc_methods_test() {
  let assert Ok(provider) = provider.new_rpc_provider("http://127.0.0.1:8545")
  let assert Ok(address) =
    address.from_string("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")

  let req =
    provider
    |> provider.to_request(methods.GetBalance(address:, block: block.Latest))

  let assert Ok(resp) = httpc.send(req)
  let resp = resp |> provider.decode_response

  resp
  |> should.be_ok
  let assert Ok(resp) = resp
  let assert Result(_, _, data) = resp
  let assert Ok(data) = data |> dynamic.string()
  let assert Ok(data) = data |> uint256.from_string()
  data
  |> should.equal(uint256.new_unchecked(10_000) |> uint256.multiply(wei.ether))
}
