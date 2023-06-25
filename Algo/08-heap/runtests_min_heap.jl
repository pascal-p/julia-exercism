using Test

include("min_heap.jl")

@testset "min heap basics" begin
  n = 10
  mheap = MinHeap{Int}(n)

  @test size(mheap) == n
  @test isempty(mheap)

  insert!(mheap, 21)
  @test mheap.last_ix == 2  ## next free position
end

@testset "min heap insert" begin
  n = 2
  mheap = MinHeap{Int}(n)

  for x in [14, 12, 10]
    insert!(mheap, x)
    @test peek(mheap) == x
  end

  @test size(mheap) == 2n   ## should have double
  @test mheap.last_ix == 4

end

@testset "min heap extract_min" begin
  n = 4
  ary = [14, 16, 10, 12, 15]
  mheap = MinHeap{Int}(n)

  for x in ary
    insert!(mheap, x)
  end

  @test peek(mheap) == minimum(ary)
  @test size(mheap) == 2n   ## should have double

  x = extract_min!(mheap)
  @test x == minimum(ary) # == 10
  @test peek(mheap) == 12

  x = extract_min!(mheap)
  @test x == 12
  @test peek(mheap) == 14

  x = extract_min!(mheap)
  @test x == 14
  @test peek(mheap) == 15

  x = extract_min!(mheap)
  @test x == 15
  @test peek(mheap) == 16

  @test size(mheap) == floor(Int, 2n * 0.75)  ## should have shrinked
end

@testset "delete" begin
  n = 10; mheap = MinHeap{Int}(n)
  for x in [21, 10, 14, 14, 13, 12, 15]
    insert!(mheap, x)
  end

  @test delete!(mheap, 2) == 13

  @test peek(mheap) == 10
  @test mheap.last_ix - 1 == 6

  # under the hood
  @test mheap.h[1:(mheap.last_ix - 1)] == [10, 14, 12, 21, 15, 14]
end

@testset "exceptions" begin
  n = 2
  mheap = MinHeap{Int}(n)

  @test_throws ArgumentError peek(mheap)          ## empty heap!
  @test_throws ArgumentError extract_min!(mheap)  ## empty heap!
end
