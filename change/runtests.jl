using Test

include("change.jl")

@testset "Change..." begin
  @test find_fewest_coins([1, 5, 10, 25, 100], 1) == [1]
  @test find_fewest_coins([1, 5, 10, 25, 100], 15) == [5, 10]
  @test find_fewest_coins([1, 5, 10, 25, 100], 25) == [25]
  @test find_fewest_coins([1, 5, 10, 25, 100], 55) == [5, 25, 25]

  @test find_fewest_coins([1, 4, 15, 20, 50], 23) == [4, 4, 15]
  @test find_fewest_coins([1, 5, 10, 21, 25], 63) == [21, 21, 21]

  @test find_fewest_coins([1, 2, 5, 10, 20, 50, 100], 999) == [2, 2, 5, 20, 20, 50, 100, 100, 100, 100, 100, 100, 100, 100, 100]
  @test find_fewest_coins([1, 2, 5, 10, 20, 50, 100, 500], 1999) == [2, 2, 5, 20, 20, 50, 100, 100, 100, 100, 500, 500, 500]
  @test find_fewest_coins([1, 2, 5, 10, 20, 50, 100, 500], 10999) == [2, 2, 5, 20, 20, 50, 100, 100, 100, 100, [500 for _ in 1:21]...]
  @test find_fewest_coins([1, 2, 5, 10, 20, 50, 100, 500], 20999) == [2, 2, 5, 20, 20, 50, 100, 100, 100, 100, [500 for _ in 1:41]...]

  @test find_fewest_coins([1, 5, 10, 21, 25], 0) == []
  @test find_fewest_coins([2, 5, 10, 20, 50], 21) == [2, 2, 2, 5, 10]
  @test find_fewest_coins([4, 5], 27) == [4, 4, 4, 5, 5, 5]
end

@testset "Change - exceptions" begin
  @test_throws ArgumentError find_fewest_coins([1, 2, 5], -5)  # target < 0
  @test_throws ArgumentError find_fewest_coins([5, 10], 94)    # target not reachable
end
