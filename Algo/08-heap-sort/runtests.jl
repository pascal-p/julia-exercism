using Test
using Random

include("heapsort.jl")

@testset "heap sort basics" begin
  @test heap_sort!([]) == []

  @test heap_sort([10]) == [10]
  @test heap_sort([21, 11]) == [11, 21]
end

@testset "qsort on small samples w/o repetition" begin
  ## 4 elements
  x, sorted_x = [-3, 5, 2, -2], [-3, -2, 2, 5]

  heap_sort!(x) # mutate x
  @test x == sorted_x

  ## 10 elements
  x, sorted_x = [-3, 4, -5, 8, -1, 7, 2, 5, -6, 0],
    [-6,  -5, -3,  -1, 0, 2, 4, 5, 7, 8 ]
  heap_sort!(x)
  @test x == sorted_x

  ## 15 elements - reversed
  x = [35, 33, 10, 45, 30, 49, 48, 34, 12, 5, 14, 43, 16, 24, 31]
    rev_sorted_x = [49, 48, 45, 43, 35, 34, 33, 31, 30, 24, 16, 14, 12, 10, 5]

  @test heap_sort(x; opt=:minheap) == rev_sorted_x
end

@testset "1_000 random-sample with repeated values" begin
  x = rand(-50:50, 1_000)
  sorted_x = sort(x)

  heap_sort!(x)
  @test x == sorted_x
end

@testset "10_000 random-sample with no repeated values" begin
  sorted_x = collect(1:10_000)
  x = Random.shuffle(collect(1:10_000))

  heap_sort!(x; opt=:maxheap)
  @test x == sorted_x
end

@testset "100_000 random-sample with no repeated values" begin
  sorted_x = collect(1:100_000)

  for _ in 1:3
    x = Random.shuffle(collect(1:100_000))
    heap_sort!(x; opt=:maxheap)
    @test x == sorted_x
  end
end

@testset "100_000 random-sample with no repeated values - reverse order" begin
  sorted_x = collect(100_000:-1:1)
  for _ in 1:3
    x = Random.shuffle(collect(1:100_000))
    heap_sort!(x; opt=:minheap)
    @test x == sorted_x
  end
end

@testset "1_000_000 random-sample with no repeated values" begin
  sorted_x = collect(1:1_000_000)
  for _ in 1:3
    x = Random.shuffle(collect(1:1_000_000))
    heap_sort!(x; opt=:maxheap)
    @test x == sorted_x
  end
end

@testset "10_000_000 random-sample with no repeated values" begin
  sorted_x = collect(1:10_000_000)
  x = Random.shuffle(collect(1:10_000_000))
  heap_sort!(x; opt=:maxheap)
  @test x == sorted_x
end

@testset "10_000_000 random-sample with no repeated values - reverse order" begin
  sorted_x = collect(10_000_000:-1:1)

  x = Random.shuffle(collect(1:10_000_000))
  heap_sort!(x; opt=:minheap)
  @test x == sorted_x
end
