using Test

push!(LOAD_PATH, "./src")
using YAH


@testset "min heap basics" begin
  n = 10
  mheap = Heap{Int, Float64}(n)  # MinHeap default

  @test size(mheap) == n
  @test isempty(mheap)

  insert!(mheap, (key=21, value=1.1))
  @test mheap.last == 2  ## next free position
end

@testset "min heap insert" begin
  n = 2
  mheap = Heap{Int, Float64}(n)

  for x in [(key=14, value=2.0), (key=12, value=π/2), (key=10, value=ℯ/2)]
    insert!(mheap, x)
    @test peek(mheap) == x
  end

  @test size(mheap) == 2n   ## should have double
  @test mheap.last[1] == 4

end

@testset "min heapify" begin
  x = [(key=35, value=2.0), (key=33, value=1.1), (key=10, value=√2), (key=45, value=√3), (key=30, value=ℯ/2), (key=49, value=ℯ/3), (key=48, value=π/4), (key=34, value=π/2), (key=12, value=√5), (key=5, value=-√5), (key=14, value=π/12), (key=43, value=log(2.1)), (key=16, value=5.0), (key=24, value=11.3), (key=31, value=√2/2)]
  mheap = Heap{Int, Float64}(15)
  heapify!(mheap, x)

  @test map(t -> t[1],
            mheap.h) == [5, 12, 10, 34, 14, 16, 24, 35, 45, 30, 33, 43, 49, 48, 31]
end

@testset "max heapify" begin
  x = [(key=35, value=2.0), (key=33, value=1.1), (key=10, value=√2), (key=45, value=√3), (key=30, value=ℯ/2), (key=49, value=ℯ/3), (key=48, value=π/4), (key=34, value=π/2), (key=12, value=√5), (key=5, value=-√5), (key=14, value=π/12), (key=43, value=log(2.1)), (key=16, value=5.0), (key=24, value=11.3), (key=31, value=√2/2)]
  mheap = Heap{Int, Float64}(15; klass=MaxHeap)
  heapify!(mheap, x)

  @test map(t -> t[1],
            mheap.h) == [49, 45, 48, 34, 30, 43, 35, 33, 12, 5, 14, 10, 16, 24, 31]
end

@testset "max heap insert" begin
  n = 2
  mheap = Heap{Int, Float64}(n; klass=MaxHeap) # :maxheap)

  for x in [(key=10, value=ℯ/2), (key=12, value=π/3), (key=14, value=2.0)]    ## contrived example
    insert!(mheap, x)
    @test peek(mheap)[1] == x[1]
  end

  @test size(mheap) == 2n   ## should have double
  @test mheap.last == 4

end

@testset "min heap extract_min" begin
  n = 4
  ary = [(key=14, value=√2), (key=16, value=ℯ/2), (key=10, value=π/4), (key=12, value=√5), (key=15, value=π/12)]
  mheap = Heap{Int, Float64}(n)

  for x in ary
    insert!(mheap, x)
  end

  @test peek(mheap) == minimum(ary)
  @test size(mheap) == 2n   ## should have double

  x = extract_min!(mheap)
  @test x == minimum(ary) # == 10
  @test peek(mheap)[1] == 12

  x = extract_min!(mheap)[1]
  @test x == 12
  @test peek(mheap)[1] == 14

  x = extract_min!(mheap)[1]
  @test x == 14
  @test peek(mheap)[1] == 15

  x = extract_min!(mheap)[1]
  @test x == 15
  @test peek(mheap)[1] == 16

  @test size(mheap) == floor(Int, 2n * 0.75)  ## should have shrinked
end

@testset "max heap extract_max" begin
  n = 4
  ary = [(key=14, value=√2), (key=16, value=ℯ/2), (key=10, value=π/4), (key=12, value=√5), (key=15, value=π/12)]
  mheap = Heap{Int, Float64}(n, klass=MaxHeap) # :maxheap)

  for x in ary
    insert!(mheap, x)
  end

  @test peek(mheap) == maximum(ary)
  @test size(mheap) == 2n   ## should have double

  x = extract_max!(mheap)[1]
  @test x == maximum(ary)[1] # == 16
  @test peek(mheap)[1] == 15

  x = extract_max!(mheap)[1]
  @test x == 15
  @test peek(mheap)[1] == 14

  x = extract_max!(mheap)[1]
  @test x == 14
  @test peek(mheap)[1] == 12

  x = extract_max!(mheap)[1]
  @test x == 12
  @test peek(mheap)[1] == 10

  @test size(mheap) == floor(Int, 2n * 0.75)  ## should have shrinked
end

@testset "min heap deletion" begin
  n = 10; mheap = Heap{Int, Float64}(n)
  for x in [(key=21, value=√2), (key=10, value=√3), (key=14, value=√7), (key=14, value=√5), (key=13, value=√2), (key=12, value=π/2), (key=15, value=2π)]
    insert!(mheap, x)
  end

  @test delete!(mheap, 2)[1] == 13

  @test peek(mheap)[1] == 10
  @test mheap.last - 1 == 6

  # under the hood
  @test map(t -> t[1],
            mheap.h[1:(mheap.last - 1)]) == [10, 14, 12, 21, 15, 14]
end

@testset "max heap deletion" begin
  n = 10; mheap = Heap{Int, Float64}(n; klass=MaxHeap) # :maxheap)
  for x in [(key=21, value=√2), (key=10, value=√3), (key=14, value=√7), (key=14, value=√5), (key=13, value=√2), (key=12, value=π/2), (key=15, value=2π)]
    insert!(mheap, x)
  end
  # == Heap{Int64}([21, 14, 15, 10, 13, 12, 14, 0, 0, 0], 8, :maxheap)

  @test delete!(mheap, 2)[1] == 14

  @test peek(mheap)[1] == 21
  @test mheap.last - 1 == 6

  # under the hood
  @test map(t -> t[1],
            mheap.h[1:(mheap.last - 1)]) == [21, 14, 15, 10, 13, 12]
end


@testset "exceptions" begin
  n = 2
  mheap = Heap{Int, Int}(n)

  @test_throws ArgumentError peek(mheap)          ## empty heap!
  @test_throws ArgumentError extract_min!(mheap)  ## empty heap!

  @test_throws AssertionError Heap{Int, Int}(n; klass=:fooheap)
end
