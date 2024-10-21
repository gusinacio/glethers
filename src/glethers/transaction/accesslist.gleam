import glethers/address.{type Address}
import glethers/primitives/bytes.{type Bytes32}

pub type AccessList

pub type AccessListItem {
  AccessListItem(address: Address, storage_keys: List(Bytes32))
}
