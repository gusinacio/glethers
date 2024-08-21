import gleam/httpc
import gleeunit/should
import glethers/address
import glethers/block
import glethers/provider
import glethers/rpc/methods

pub fn rpc_methods_test() {
  let provider = provider.Rpc("eth.llamarpc.com")
  let assert Ok(address) =
    address.from_string("0x8D97689C9818892B700e27F316cc3E41e17fBeb9")

  let req =
    provider
    |> provider.to_request(methods.GetBalance(address:, block: block.Latest))

  let assert Ok(resp) = httpc.send(req)
  let resp = resp |> provider.decode_response

  resp
  |> should.be_ok
}
