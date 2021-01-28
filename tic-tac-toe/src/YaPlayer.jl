module YaPlayer
  import Base: repr, ==

  export APlayer, HPlayer, RPlayer, CPlayer, get_move, repr,
    Player_Symbols, ==

  include("./player.jl")
end
