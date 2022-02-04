using Test

include("arcade_game.jl")

@testset "Task 1" begin
  @test eat_ghost(true, true) ≡ true
  @test eat_ghost(false, true) ≡ false
  @test eat_ghost(true, false) ≡ false
  @test eat_ghost(false, false) ≡ false
end

@testset "Task 2" begin
  @test score(false, true) ≡ true
  @test score(true, false) ≡ true
  @test score(false, false) ≡ false
  @test score(true, true) ≡ true
end

@testset "Task 3" begin
  @test lose(true, false) ≡ false
  @test lose(true, true) ≡ false
  @test lose(false, true) ≡ true
  @test lose(true, false) ≡ false
end

@testset "Task 4" begin
  @test win(true, false, false) ≡ true
  @test win(true, false, true) ≡ false
  @test win(true, true, true) ≡ true

  @test win(false, true, true) ≡ false

  # if first boolean is false then so is win() (ensured by the use of && in win() function)
end
