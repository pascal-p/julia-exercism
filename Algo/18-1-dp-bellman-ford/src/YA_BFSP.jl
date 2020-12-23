module YA_BFSP
  using YAQ     ## Client using this will have to either install package YAQ, or modify LOAD_PATH 
  using YA_EWD  ## ditto 

  export BFSP

  export dist_to, has_path_to, path_to, has_negative_cycle,
    negative_cycle, min_dist

  include("./bellman_ford_sp.jl")
end
