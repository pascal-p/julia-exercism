using Test

include("hangman.jl")

@testset "hangman game" begin

  @testset "9 failures are allowed" begin
    game = Hangman("foo")

    @test get_status(game) == ONGOING::States
    @test get_remaining_guesses(game) == NUM_GUESSES
  end

  @testset "after 10 failures game is over" begin
    game = Hangman("foo")

    @test get_masked_word(game) == "___"
    for ix ∈ 1:NUM_GUESSES
      guess(game, 'x')
    end

    guess(game, 'x')
    @test get_status(game) == LOSE::States
  end

  @testset "feeding a correct letter removes underscores" begin
    game = Hangman("foobar")

    guess(game, 'b')
    @test get_masked_word(game) == "___b__"
    @test get_remaining_guesses(game) == NUM_GUESSES

    guess(game, 'o')
    @test get_masked_word(game) == "_oob__"
    @test get_remaining_guesses(game) == NUM_GUESSES
  end

  @testset "feeding a correct letter twice counts as a failure" begin
    game = Hangman("foobar")

    guess(game, 'b')
    @test get_masked_word(game) == "___b__"
    @test get_remaining_guesses(game) == NUM_GUESSES

    guess(game, 'b')
    @test get_masked_word(game) == "___b__"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    @test get_status(game) == ONGOING::States
  end

  @testset "getting all the letters right makes for a win" begin
    game = Hangman("hello")

    guess(game, 'b')
    @test get_masked_word(game) == "_____"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    guess(game, 'e')
    @test get_masked_word(game) == "_e___"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    guess(game, 'l')
    @test get_masked_word(game) == "_ell_"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    guess(game, 'h')
    @test get_masked_word(game) == "hell_"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    guess(game, 'o')
    @test get_masked_word(game) == "hello"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    @test get_status(game) == WIN::States
  end

  @testset "winning on last guess still counts as a win" begin
    game = Hangman("aaa")
    for ch ∈ "bcdefghija"
      guess(game, ch)
    end

    @test get_masked_word(game) == "aaa"
    @test get_remaining_guesses(game) == 0
    @test get_status(game) == WIN::States
  end

  @testset "game is case insensitive" begin
    game = Hangman("Hello")

    guess(game, 'b')
    @test get_masked_word(game) == "_____"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    guess(game, 'E')
    @test get_masked_word(game) == "_e___"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    guess(game, 'L')
    @test get_masked_word(game) == "_ell_"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    guess(game, 'h')
    @test get_masked_word(game) == "hell_"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    guess(game, 'O')
    @test get_masked_word(game) == "hello"
    @test get_remaining_guesses(game) == NUM_GUESSES - 1

    @test get_status(game) == WIN::States
  end
end

@testset "exception/1" begin
  game = Hangman("foo")
  for ix ∈ 0:NUM_GUESSES
    guess(game, 'x')
  end

  @test_throws DomainError guess(game, 'x')
end

@testset "exception/2" begin
  @test_throws ArgumentError HangmanStateInit(-1)
  @test_throws ArgumentError HangmanStateInit("foo")
end
