import glethers/hash/message
import glethers/hash/typed_data
import glethers/provider
import glethers/signer/signing_key.{type PrivateKey}
import secp256k1_gleam

pub type Signature =
  secp256k1_gleam.Signature

pub type Signer {
  Signer(provider: provider.Provider, private_key: PrivateKey)
}

pub fn sign_hash(private_key: PrivateKey, hash: message.Hash) -> Signature {
  let private_key = private_key |> signing_key.to_bit_array
  let message = hash |> message.to_bit_array
  let assert Ok(signature) = secp256k1_gleam.sign(message, private_key)
  signature
}

pub fn sign_typed_data(
  private_key: PrivateKey,
  domain: typed_data.TypedDataDomain,
  struct: a,
  encoder: fn(a) -> typed_data.TypedData,
) -> Signature {
  let hash = typed_data.hash_message(domain, struct, encoder)
  sign_hash(private_key, hash)
}

pub fn sign_message(private_key: PrivateKey, message: String) -> Signature {
  let hash = message.hash_message(message)
  sign_hash(private_key, hash)
}

pub fn verify_signature(
  private_key: PrivateKey,
  message: String,
  signature: Signature,
) -> Bool {
  let private_key = private_key |> signing_key.to_bit_array
  let assert Ok(public_key) = secp256k1_gleam.create_public_key(private_key)
  let hash = message.hash_message(message) |> message.to_bit_array
  case secp256k1_gleam.verify(hash, signature, public_key) {
    Ok(_) -> True
    Error(_) -> False
  }
}
