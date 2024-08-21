import gleam/int

pub type Block {
  Latest
  Number(Int)
}

pub fn to_string(block: Block) -> String {
  case block {
    Latest -> "latest"
    Number(n) -> int.to_string(n)
  }
}
