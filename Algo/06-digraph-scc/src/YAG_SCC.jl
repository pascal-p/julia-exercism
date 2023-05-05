module YAG_SCC
  import Base: reverse, count, size

  using YAQ
  using Printf

  export DiGraph  # Directed Graph
  export DFO
  export SCC

  export add_edge!, v, e
  export reverse
  export id, count, groupby, topn
  export pre, post, rev_post

  include("./di_graph.jl")
  # include("./di_dfs.jl")
  include("./di_dfo.jl")
  include("./di_scc.jl")
end
