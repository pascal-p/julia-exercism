module YaGame
  import Base: show

  export Game, reset!, move!, has_empty_cells, num_empty_cells,
    available_moves, show, show_num

  include("./game.jl")
end
