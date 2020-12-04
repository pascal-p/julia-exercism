module YAFUF
  # Yet Another Faster Union Find ADT
  import Base: count, union

  export UnionFind

  export count, connected, find, union

  include("./faster-union-find.jl")
end
