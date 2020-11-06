using Test
using Random

include("rselect.jl")

function slurp(ifile) # :: vector of ints
  open(ifile) do f
    readlines(f)
  end |> a -> map(s -> parse(Int, s), a)
end


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

  x = [31, 42, 73, 81, 10, 72, 28, 67, 94, 5]
  @test rselect(x, 6) == 67

  x = [31, 42, 73, 81, 10, 72, 28, 67, 94, 5]
  @test rselect(x, 7) == 72

  x = [31, 42, 73, 81, 10, 72, 28, 67, 94, 5]
  @test rselect(x, 10) == 94

  x = [31, 42, 73, 81, 10, 72, 28, 67, 94, 5]
  @test rselect(x, 1) == 5


  # ## 15 elements
  x = [35, 33, 10, 45, 30, 49, 48, 34, 12, 5, 14, 43, 16, 24, 31]
  # sorted [ 5, 10, 12, 14, 16, 24, 30, 31, 33, 34, 35, 43, 45, 48, 49]
  @test rselect(x, 1) == 5

  x = [35, 33, 10, 45, 30, 49, 48, 34, 12, 5, 14, 43, 16, 24, 31]
  @test rselect(x, 15) == 49

  x = [35, 33, 10, 45, 30, 49, 48, 34, 12, 5, 14, 43, 16, 24, 31]
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

@testset "challenge 1 / 10 num" begin
  x = slurp("problem6.5test_10.txt")
  @test rselect(x, 5) == 5469
end

@testset "challenge 2 / 100 num" begin
  x = slurp("problem6.5test_100.txt")
  @test rselect(x, 50) == 4715
end

@testset "challenge 3 / π digits" begin
  str = open("pi_first_100000.txt") do f
    readlines(f)[1]
  end

  n = length(str)
  x = [ parse(Int, str[ix:ix + 10]) for ix in 3:10:(n - 10) ]

  n = length(x)
  @test rselect(x, n ÷ 2) == 50217159133
end
