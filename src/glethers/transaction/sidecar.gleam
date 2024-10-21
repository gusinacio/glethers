// EIP-4844 sidecar type

import glethers/primitives/bytes.{type Bytes48}

pub type BlobTransactionSidecar {
  BlobTransactionSidecar(
    blobs: List(Blob),
    commitments: List(Bytes48),
    proofs: List(Bytes48),
  )
}

// pub const BYTES_PER_BLOB: usize = 131_072;
pub type Blob {
  Blob(BitArray)
}
