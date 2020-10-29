using Test

include("counting_inversions.jl")

@testset "basic tests on inversions" begin
  @test counting_inversions([])[end] == 0                    # emtpy array, no inversions
  @test counting_inversions([1])[end] == 0                   # singleton array, no inversions
  @test counting_inversions([1, 2])[end] == 0                # sorted pair, no inversion
  @test counting_inversions([1, 2, 3])[end] == 0             # sorted pair, no inversion

  @test counting_inversions([1, 2, 3, 4, 5, 6, 7])[end] == 0 # sorted array, no inversions
  @test counting_inversions([0, 2, 4, 6, 8, 10])[end] == 0   # sorted array, no inversions

  @test counting_inversions([2, 1])[end] == 1                # inverted pair == 1 inversion
  @test counting_inversions([3, 2, 1])[end] == 3             # inverted triplet == 2 inversions
end


@testset "tests on inversions" begin

  @test counting_inversions([1, 3, 5, 2, 4, 6])[end] == 3
  @test counting_inversions([1, 5, 6, 4, 20])[end] == 2
  @test counting_inversions([1, 20, 6, 4, 5 ])[end] == 5
  @test counting_inversions([2, 4, 1, 3, 5])[end] == 3

  @test counting_inversions([1, 4, 3, 2, 5, 6, 10, 9, 7, 8])[end] == 8

  @test counting_inversions([14, 12, 10, 8, 6, 4, 2, 0])[end] == 28  # max. num of inversions with sorted array in decr. order
end
