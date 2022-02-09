using Test

include("bowling.jl")

function roll_new_game!(game::BowlingGame, rolls::Vector{<: Integer})
  # roll!.(game, rolls)
  for roll ∈ rolls
    roll!(game, roll)
  end
  game
end

@testset "roll" begin
  @testset "two rolls in a frame cannot score > 10 points" begin
    game = BowlingGame()
    roll_new_game!(game, [5])

    @test_throws ArgumentError roll!(game, 6)
  end

  @testset "the second bonus rolls after a strike in the last frame cannot be a strike if the first one is not a strike" begin
    game = BowlingGame()
    roll_new_game!(game, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 6])

    @test_throws ArgumentError roll!(game, 10)
  end

  @testset "test second bonus roll after a strike in the last frame cannot score more than 10 points" begin
    game = BowlingGame()
    roll_new_game!(game, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10])

    @test_throws ArgumentError roll!(game, 11)
  end

  @testset "test two bonus rolls after a strike in the last frame cannot score more than 10 points" begin
    game = BowlingGame()
    roll_new_game!(game, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 5])

     @test_throws ArgumentError roll!(game, 6)
  end
end
