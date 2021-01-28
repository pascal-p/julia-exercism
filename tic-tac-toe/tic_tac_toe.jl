push!(LOAD_PATH, "./src")

using YaGame
using YaPlayer

function play(game::Game, x_player::APlayer, o_player::APlayer;
              disp_game=true, tsleep=0.2)

  @assert x_player ≠ o_player && repr(x_player) == Player_Symbols[1] && repr(o_player) == Player_Symbols[2]

  disp_game && show_num(Base.stdout, game)
  symbol = repr(x_player)

  while has_empty_cells(game)
    cell = symbol == repr(x_player) ? get_move(x_player, game) : get_move(o_player, game)

    if move!(game, cell, symbol)
      if disp_game
        println("$(symbol) plays move to cell $(cell)")
        show(Base.stdout, game)
        println()
      end

      if game.current_winner[1] != nothing
        disp_game && println("$(symbol) wins!")
        return symbol
      end

      symbol = symbol == repr(x_player) ? repr(o_player) : repr(x_player)
    end

    disp_game && sleep(tsleep)
  end

  disp_game && println("Tie!")
  return nothing
end

function interactive_play(n::Int=3)
  x_player, o_player = RPlayer(Player_Symbols[1]), CPlayer(Player_Symbols[2])
  game = Game(n)

  play(game, x_player, o_player)
end

function simulation(;m=1000, n=3)
  o_nwin, x_nwin, n_tie = 0, 0, 0
  x_player, o_player = RPlayer(Player_Symbols[1]), CPlayer(Player_Symbols[2])

  for _ix ∈ 1:m
    # ix % 100 == 0 && println("played $(ix) / $(m) games")
    game = Game(n)
    outcome = play(game, x_player, o_player; disp_game=false)

    if outcome == nothing
      n_tie += 1
    elseif outcome == :O
      o_nwin += 1
    else
      x_nwin += 1
    end
  end

  println("o_wins: $(o_nwin), x_wins: $(x_nwin), n_ties: $(n_tie)")
  (o_nwin, x_nwin, n_tie)
end


# simulation()

#
# usage:
# include("./tic_tac_toe.jl")
# interactive_play()
# ...

#
# julia tic_tac_toe.jl
# o_wins: 808, x_wins: 0, n_ties: 192

# julia> @time simulation()
# o_wins: 783, x_wins: 0, n_ties: 217
#  81.815410 seconds (1.82 G allocations: 105.440 GiB, 6.96% gc time)
# (783, 0, 217)
