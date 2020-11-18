using Test
using Random

include("quicksort.jl")

@testset "qsort basics" begin
  @test quick_sort!([]) == []
  @test quick_sort!([10]) == [10]
  @test quick_sort!(["b", "a"]) == ["a", "b"]
end

@testset "qsort on small samples w/o repetition" begin
  ## 4 elements
  x, sorted_x = [-3, 5, 2, -2], [-3, -2, 2, 5]
  @test quick_sort!(x) == sorted_x

  ## 10 elements
  x, sorted_x = [-3, 4, -5, 8, -1, 7, 2, 5, -6, 0],
    [-6,  -5, -3,  -1, 0, 2, 4, 5, 7, 8 ]
  @test quick_sort!(x) == sorted_x

  ## 15 elements
  x = [35, 33, 10, 45, 30, 49, 48, 34, 12, 5, 14, 43, 16, 24, 31]
    sorted_x = [ 5, 10, 12, 14, 16, 24, 30, 31, 33, 34, 35, 43, 45, 48, 49]

  @test quick_sort!(x; shuffle=true, pivot="median-3") == sorted_x
end

@testset "1_000 random-sample with repeated values" begin
  x = rand(-50:50, 1_000)
  sorted_x = sort(x)

  @test quick_sort!(x) == sorted_x
end

@testset "10_000 random-sample with no repeated values" begin
  sorted_x = collect(1:10_000)
  x = Random.shuffle(collect(1:10_000))

  @test quick_sort!(x; shuffle=false, pivot="median-3") == sorted_x
end

@testset "100_000 random-sample with no repeated values" begin
  sorted_x = collect(1:100_000)

  for _ in 1:3
    x = Random.shuffle(collect(1:100_000))
    @test quick_sort!(x; shuffle=false, pivot="median-3") == sorted_x
  end
end

@testset "1_000_000 random-sample with no repeated values" begin
  sorted_x = collect(1:1_000_000)

  for _ in 1:3
    x = Random.shuffle(collect(1:1_000_000))
    @test quick_sort!(x; shuffle=false, pivot="median-3") == sorted_x
  end
end

@testset "10_000_000 random-sample with no repeated values" begin
  sorted_x = collect(1:10_000_000)
  x = Random.shuffle(collect(1:10_000_000))

  @test quick_sort!(x; shuffle=false, pivot="median-3") == sorted_x
end
