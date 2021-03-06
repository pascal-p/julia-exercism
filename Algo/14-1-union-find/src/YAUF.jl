module YAUF
  # Yet Another Union Find ADT
  import Base: count, union

  export UnionFind

  export count, connected, find, union

  include("./union-find.jl")
end
