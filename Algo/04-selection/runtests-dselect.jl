using Test
using Random

include("./utils/file.jl")
include("./src/dselect.jl")

const TF_DIR = "./testfiles"


@testset "dselect basics" begin
  @test dselect([], 2) == nothing
  @test dselect([2, 1], 3) == nothing

  @test dselect([30, 10, 40, 20], -2) == nothing
  @test dselect([30, 10, 40, 20], 5) == nothing
end

@testset "dselect on small samples w/o repetition" begin
  ## 10 elements
  x = [31, 42, 73, 81, 10, 72, 28, 67, 94, 5]
  # sorted [ 5, 10, 28, 31, 42, 67, 72, 73, 81, 94 ]
  @test dselect(x, 4) == 31

  @test dselect(x, 6) == 67
  @test dselect(x, 7) == 72
  @test dselect(x, 10) == 94
  @test dselect(x, 1) == 5

  # ## 15 elements
  x = [35, 33, 10, 45, 30, 49, 48, 34, 12, 5, 14, 43, 16, 24, 31]
  # # sorted [ 5, 10, 12, 14, 16, 24, 30, 31, 33, 34, 35, 43, 45, 48, 49]
  @test dselect(x, 1) == 5
  @test dselect(x, 15) == 49
  @test dselect(x, 7) == 30
end

@testset "10_000 random-sample with no repeated values" begin
  x = Random.shuffle(collect(1:10_000))

  for ith in 1000:1000:10_000
    @test dselect(x, ith) == ith
  end
end

@testset "100_000 random-sample with no repeated values" begin
  x = Random.shuffle(collect(1:100_000))

  for ith ∈ 10000:5000:100_000
    @test dselect(x, ith) == ith
  end
end

@testset "challenge 1 / 10 num" begin
  x = slurp("$(TF_DIR)/problem6.5test_10.txt")
  @test dselect(x, 5) == 5469
end

@testset "challenge 2 / 100 num" begin
  x = slurp("$(TF_DIR)/problem6.5test_100.txt")
  @test dselect(x, 50) == 4715
end

@testset "challenge 3 / π digits" begin
  str = open("$(TF_DIR)/pi_first_100000.txt") do f
    readlines(f)[1]
  end

  n = length(str)
  x = [ parse(Int, str[ix:ix + 10]) for ix in 3:10:(n - 10) ]

  n = length(x)
  @test dselect(x, n ÷ 2) == 50217159133
end
