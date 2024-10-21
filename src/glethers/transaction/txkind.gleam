import glethers/address.{type Address}

pub type TxKind {
  Create
  Call(Address)
}
