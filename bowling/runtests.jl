using Test

include("bowling.jl")

function roll_new_game(rolls::Vector{<: Integer})
  # roll!.(game, rolls)
  game = BowlingGame()
  for roll ∈ rolls
    roll!(game, roll)
  end
  game
end

function roll_new_game(rolls::Vector)
  @assert length(rolls) == 0
  BowlingGame()
end

@testset "roll" begin
  @testset "two rolls in a frame cannot score > 10 points" begin
    game = roll_new_game([5])
    @test_throws ArgumentError roll!(game, 6)
  end

  @testset "the second bonus rolls after a strike in the last frame cannot be a strike if the first one is not a strike" begin
    game = roll_new_game([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 6])
    @test_throws ArgumentError roll!(game, 10)
  end

  @testset "test second bonus roll after a strike in the last frame cannot score more than 10 points" begin
    game = roll_new_game([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10])
    @test_throws ArgumentError roll!(game, 11)
  end

  @testset "test two bonus rolls after a strike in the last frame cannot score more than 10 points" begin
    game = roll_new_game([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 5])
    @test_throws ArgumentError roll!(game, 6)
  end

  @testset "cannot roll if game already has ten frames" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    game = roll_new_game(rolls)
    @test_throws ArgumentError roll!(game, 0)
  end

  @testset "cannot roll after bonus roll for spare" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 3, 2]
    game = roll_new_game(rolls)
    @test_throws ArgumentError roll!(game, 2)
  end

  @testset "cannot_roll_after_bonus_rolls_for_strike(" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 3, 2]
    game = roll_new_game(rolls)
    @test_throws ArgumentError roll!(game, 2)
  end
end

@testset "score" begin
  @testset "should be able to score a game with all zeros" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    game = roll_new_game(rolls)
    @test score(game) == zero(SType)
  end

  @testset "should be able to score a game with no strikes or spares" begin
    rolls = [3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6]
    game = roll_new_game(rolls)
    @test score(game) == SType(90)
  end

  @testset "points scored in the roll after a spare are counted twice" begin
    rolls = [6, 4, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    game = roll_new_game(rolls)
    @test score(game) == SType(16)
  end

  @testset "test consecutive spares each get a one roll bonus" begin
    rolls = [5, 5, 3, 7, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    game = roll_new_game(rolls)
    #println(game)
    @test score(game) == SType(31)
  end

  @testset "a spare in the last frame gets a one roll bonus that is counted once" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 3, 7]
    game = roll_new_game(rolls)
    @test score(game) == SType(17)
  end

  @testset "points scored in the two rolls after a strike are counted twice as a bonus" begin
    rolls = [10, 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    game = roll_new_game(rolls)
    @test score(game) == SType(26)
  end

  @testset "points scored in the two rolls after a strike are counted twice as a bonus" begin
    rolls = [10, 10, 10, 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    game = roll_new_game(rolls)
    @test score(game) == SType(81)
  end

  @testset "a strike in the last frame gets a two roll bonus that is counted once" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 7, 1]
    game = roll_new_game(rolls)
    @test score(game) == SType(18)
   end

  @testset "rolling a spare with the two roll bonus does not get a bonus roll" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 7, 3]
    game = roll_new_game(rolls)
    @test score(game) == SType(20)
  end

  @testset "a strike with the one roll bonus after a spare in the last frame does not get a bonus" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 3, 10]
    game = roll_new_game(rolls)
    @test score(game) == SType(20)
  end

  @testset "strikes_with_the_two_roll_bonus_do_not_get_bonus_roll" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10, 10]
    game = roll_new_game(rolls)
    @test score(game) == SType(30)
  end

  @testset "all strikes is a perfect game" begin
    rolls = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]
    game = roll_new_game(rolls)
    @test score(game) == SType(300)
  end

  @testset "test last two strikes followed by only last bonus with non strike points" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10, 0, 1]
    game = roll_new_game(rolls)
    @test score(game) == SType(31)
  end
end


@testset "Exception" begin
  @testset "an unstarted game cannot be scored" begin
    rolls = []
    game = roll_new_game(rolls)
    @test_throws ArgumentError score(game)
  end

  @testset "an incomplete game cannot be scored" begin
    rolls = [0, 0]
    game = roll_new_game(rolls)
    @test_throws ArgumentError score(game)
  end

  @testset "bonus rolls for a strike in the last frame must be rolled before score can be calculated" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10]
    game = roll_new_game(rolls)
    @test_throws ArgumentError score(game)
  end

  @testset "both bonus rolls for a strike in the last frame must be rolled before score can be calculated" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10] # missing fill
    game = roll_new_game(rolls)
    @test_throws ArgumentError score(game)
  end

  @testset "bonus roll for a spare in the last frame must be rolled before score can be calculated" begin
    rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 3]
    game = roll_new_game(rolls)
    @test_throws ArgumentError score(game)
  end
end
