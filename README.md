# ethers_gleam

[![Package Version](https://img.shields.io/hexpm/v/ethers_gleam)](https://hex.pm/packages/ethers_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/ethers_gleam/)

```sh
gleam add ethers_gleam@1
```
```gleam
import ethers_gleam

pub fn main() {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/ethers_gleam>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Planned Features

- [ ] Wallet and Signer with mnemonic
- [x] Private key parsing
- [x] Signing and verifying messages
- [x] Crypto functions: keccak256, sha256, etc
- [ ] Blockchain primitives: 
    - [x] Address
    - [ ] Transaction
    - [x] Block
    - [ ] Signature
- [ ] signed and unsigned numbers: u32, u64, u128, u256, i32, i64, i128, i256
- [ ] RPC methods
- [ ] ABI parser
- [ ] Eip712 signed typed message
- [ ] Contract interaction
- [ ] Websocket connection
- [ ] Etherscan API

Use big int for js: https://gitlab.com/Nicd/bigi