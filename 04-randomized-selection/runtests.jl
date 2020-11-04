using Test
using Random

include("rselect.jl")

@testset "rselect basics" begin
  @test rselect([], 2) == nothing
  @test rselect([2, 1], 3) == nothing

  @test rselect([30, 10, 40, 20], -2) == nothing
  @test rselect([30, 10, 40, 20], 5) == nothing
end

@testset "rselect on small samples w/o repetition" begin
  ## 10 elements
  x = [31, 42, 73, 81, 10, 72, 28, 67, 94, 5]
  # sorted [ 5, 10, 28, 31, 42, 67, 72, 73, 81, 94 ]
  @test rselect(x, 4) == 31
  @test rselect(x, 6) == 67
  @test rselect(x, 7) == 72
  @test rselect(x, 10) == 94
  @test rselect(x, 1) == 5


  ## 15 elements
  x = [35, 33, 10, 45, 30, 49, 48, 34, 12, 5, 14, 43, 16, 24, 31]
  # sorted [ 5, 10, 12, 14, 16, 24, 30, 31, 33, 34, 35, 43, 45, 48, 49]
  @test rselect(x, 1) == 5
  @test rselect(x, 15) == 49
  @test rselect(x, 7) == 30
end

@testset "10_000 random-sample with no repeated values" begin
  x = Random.shuffle(collect(1:10_000))

  for ith in 1000:1000:10_000
    @test rselect(x, ith) == ith
  end
end

@testset "100_000 random-sample with no repeated values" begin
  x = Random.shuffle(collect(1:100_000))

  for ith in 10000:5000:100_000
    @test rselect(x, ith) == ith
  end
end
