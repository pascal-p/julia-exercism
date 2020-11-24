using Test

push!(LOAD_PATH, "./src")
using YAH


@testset "min heap basics" begin
  n = 10
  mheap = Heap{Int}(n)  # MinHeap default

  @test size(mheap) == n
  @test isempty(mheap)

  insert!(mheap, 21)
  @test mheap.last == 2  ## next free position
end

@testset "min heap insert" begin
  n = 2
  mheap = Heap{Int}(n)

  for x in [14, 12, 10]
    insert!(mheap, x)
    @test peek(mheap) == x
  end

  @test size(mheap) == 2n   ## should have double
  @test mheap.last == 4

end

@testset "min heapify" begin
  x = [35, 33, 10, 45, 30, 49, 48, 34, 12, 5, 14, 43, 16, 24, 31]
  mheap = Heap{Int}(15)
  heapify!(mheap, x)

  @test mheap.h == [5, 12, 10, 34, 14, 16, 24, 35, 45, 30, 33, 43, 49, 48, 31]
end

@testset "max heapify" begin
  x = [35, 33, 10, 45, 30, 49, 48, 34, 12, 5, 14, 43, 16, 24, 31]
  mheap = Heap{Int}(15; klass=MaxHeap)
  heapify!(mheap, x)

  @test mheap.h == [49, 45, 48, 34, 30, 43, 35, 33, 12, 5, 14, 10, 16, 24, 31]
end

@testset "max heap insert" begin
  n = 2
  mheap = Heap{Int}(n; klass=MaxHeap) # :maxheap)

  for x in [10, 12, 14,]    ## contrived example
    insert!(mheap, x)
    @test peek(mheap) == x
  end

  @test size(mheap) == 2n   ## should have double
  @test mheap.last == 4

end

@testset "min heap extract_min" begin
  n = 4
  ary = [14, 16, 10, 12, 15]
  mheap = Heap{Int}(n)

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

@testset "max heap extract_max" begin
  n = 4
  ary = [14, 16, 10, 12, 15]
  mheap = Heap{Int}(n, klass=MaxHeap) # :maxheap)

  for x in ary
    insert!(mheap, x)
  end

  @test peek(mheap) == maximum(ary)
  @test size(mheap) == 2n   ## should have double

  x = extract_max!(mheap)
  @test x == maximum(ary) # == 16
  @test peek(mheap) == 15

  x = extract_max!(mheap)
  @test x == 15
  @test peek(mheap) == 14

  x = extract_max!(mheap)
  @test x == 14
  @test peek(mheap) == 12

  x = extract_max!(mheap)
  @test x == 12
  @test peek(mheap) == 10

  @test size(mheap) == floor(Int, 2n * 0.75)  ## should have shrinked
end

@testset "min heap deletion" begin
  n = 10; mheap = Heap{Int}(n)
  for x in [21, 10, 14, 14, 13, 12, 15]
    insert!(mheap, x)
  end

  @test delete!(mheap, 2) == 13

  @test peek(mheap) == 10
  @test mheap.last - 1 == 6

  # under the hood
  @test mheap.h[1:(mheap.last - 1)] == [10, 14, 12, 21, 15, 14]
end

@testset "max heap deletion" begin
  n = 10; mheap = Heap{Int}(n; klass=MaxHeap) # :maxheap)
  for x in [21, 10, 14, 14, 13, 12, 15]
    insert!(mheap, x)
  end
  # == Heap{Int64}([21, 14, 15, 10, 13, 12, 14, 0, 0, 0], 8, :maxheap)

  @test delete!(mheap, 2) == 14

  @test peek(mheap) == 21
  @test mheap.last - 1 == 6

  # under the hood
  @test mheap.h[1:(mheap.last - 1)] == [21, 14, 15, 10, 13, 12]
end


@testset "exceptions" begin
  n = 2
  mheap = Heap{Int}(n)

  @test_throws ArgumentError peek(mheap)          ## empty heap!
  @test_throws ArgumentError extract_min!(mheap)  ## empty heap!

  @test_throws AssertionError Heap{Int}(n; klass=:fooheap)
end
