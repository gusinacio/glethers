import glethers/address
import glethers/primitives/bytes

pub type AccessList

pub type AccessListItem {
  AccessListItem(address: address.Address, storage_keys: List(bytes.Bytes32))
}
