import ethers_gleam/signer
import ethers_gleam/signer/signing_key
import gleam/string
import gleeunit/should
import secp256k1_gleam

pub fn message_hash_test() {
  let assert Ok(private_key) =
    signing_key.from_string(
      "0x314af9517df1fa5ab83ade9505d5d8b368d85833b4e39d7316daccba26e8e756",
    )
  let signature =
    private_key
    |> signer.sign_message("hello world")
    |> secp256k1_gleam.to_string
    |> string.lowercase
  should.equal(
    signature,
    "0xf1e4fea67aec3b36ab92db67734912cdbb3f7b003f3364fe78fde185caad375a1142636559004645948596bc8793e4c8d5f15d2717535087a52d278e44dedd181b",
  )
}
