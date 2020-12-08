module YATRIE
  ## Yet Another Trie
  # import Base:

  export TrieNode, UCS

  export isleaf, left, right, key, freq,
    expand, build_code, encode

  include("./trie.jl")
end
