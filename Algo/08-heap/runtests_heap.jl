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
  xs = [(key=35, value=2.0), (key=33, value=1.1), (key=10, value=√2), (key=45, value=√3), (key=30, value=ℯ/2), (key=49, value=ℯ/3),
        (key=48, value=π/4), (key=34, value=π/2), (key=12, value=√5), (key=5, value=-√5), (key=14, value=π/12), (key=43, value=log(2.1)),
        (key=16, value=5.0), (key=24, value=11.3), (key=31, value=√2/2)]
  mheap = Heap{Int, Float64}(15)
  heapify!(mheap, xs)

  @test map(t -> t[1],
            mheap.h) == [5, 12, 10, 34, 14, 16, 24, 35, 45, 30, 33, 43, 49, 48, 31]
end

@testset "min heapify with index map" begin
  xs = [(key=35, value=2.0), (key=33, value=1.1), (key=10, value=√2), (key=45, value=√3), (key=30, value=ℯ/2), (key=49, value=ℯ/3),
        (key=48, value=π/4), (key=34, value=π/2), (key=12, value=√5), (key=5, value=-√5), (key=14, value=π/12), (key=43, value=log(2.1)),
        (key=16, value=5.0), (key=24, value=11.3), (key=31, value=√2/2)]
  mheap = Heap{Int, Float64}(15; with_map=true)
  heapify!(mheap, xs)

  @test map(t -> t.key, # or t[1]
            mheap.h) == [5, 12, 10, 34, 14, 16, 24, 35, 45, 30, 33, 43, 49, 48, 31]

  @test map(t -> mheap.map_ix[t.value], xs) == [8, 11, 3, 9, 10, 13, 14, 4, 2, 1, 5, 12, 6, 7, 15]
end

@testset "max heapify" begin
  xs = [(key=35, value=2.0), (key=33, value=1.1), (key=10, value=√2), (key=45, value=√3), (key=30, value=ℯ/2), (key=49, value=ℯ/3),
        (key=48, value=π/4), (key=34, value=π/2), (key=12, value=√5), (key=5, value=-√5), (key=14, value=π/12), (key=43, value=log(2.1)),
        (key=16, value=5.0), (key=24, value=11.3), (key=31, value=√2/2)]
  mheap = Heap{Int, Float64}(15; klass=MaxHeap)
  heapify!(mheap, xs)

  @test map(t -> t[1],
            mheap.h) == [49, 45, 48, 34, 30, 43, 35, 33, 12, 5, 14, 10, 16, 24, 31]
end

@testset "max heapify with index map" begin
  xs = [(key=35, value=2.0), (key=33, value=1.1), (key=10, value=√2), (key=45, value=√3), (key=30, value=ℯ/2), (key=49, value=ℯ/3),
        (key=48, value=π/4), (key=34, value=π/2), (key=12, value=√5), (key=5, value=-√5), (key=14, value=π/12), (key=43, value=log(2.1)),
        (key=16, value=5.0), (key=24, value=11.3), (key=31, value=√2/2)]
  mheap = Heap{Int, Float64}(15; klass=MaxHeap, with_map=true)
  heapify!(mheap, xs)

  @test map(t -> t[1],
            mheap.h) == [49, 45, 48, 34, 30, 43, 35, 33, 12, 5, 14, 10, 16, 24, 31]

  @test map(t -> mheap.map_ix[t.value], xs) == [7, 8, 12, 2, 5, 1, 3, 4, 9, 10, 11, 6, 13, 14, 15]
  # Dict(0.7853981633974483 => 3,2.0 => 7,2.23606797749979 => 9,0.7419373447293773 => 6,1.5707963267948966 => 4,1.7320508075688772 => 2,0.7071067811865476 => 15,5.0 => 13,1.4142135623730951 => 12,11.3 => 14,1.1 => 8,0.9060939428196817 => 1,0.2617993877991494 => 11,1.3591409142295225 => 5,-2.23606797749979 => 10)
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

@testset "max heap insert, with index map" begin
  n = 2
  mheap = Heap{Int, Float64}(n; klass=MaxHeap, with_map=true)

  xs = [(key=10, value=ℯ/2), (key=12, value=π/3), (key=14, value=2.0)]    ## contrived example
  for x in xs
    insert!(mheap, x)
    @test peek(mheap)[1] == x.key # or x[1]
  end

  @test size(mheap) == 2n   ## should have double
  @test mheap.last == 4

  @test map(t -> mheap.map_ix[t.value], xs) == [2, 3, 1]
  # Dict(1.0471975511965976 => 3, 2.0 => 1, 1.3591409142295225 => 2))
end

@testset "min heap extract_min" begin
  n = 4
  xs = [(key=14, value=√2), (key=16, value=ℯ/2), (key=10, value=π/4), (key=12, value=√5), (key=15, value=π/12)]
  mheap = Heap{Int, Float64}(n)

  for x in xs; insert!(mheap, x); end

  @test peek(mheap) == minimum(xs)
  @test size(mheap) == 2n   ## should have double

  x = extract_min!(mheap)
  @test x == minimum(xs) # == 10
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

@testset "min heap extract_min, with index map" begin
  n = 4
  xs = [(key=14, value=√2), (key=16, value=ℯ/2), (key=10, value=π/4), (key=12, value=√5), (key=15, value=π/12)]
  mheap = Heap{Int, Float64}(n; with_map=true)
  for x in xs; insert!(mheap, x); end

  @test peek(mheap) == minimum(xs)
  @test size(mheap) == 2n   ## should have double
  # 1. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 10, value = 0.7853981633974483), (key = 12, value = 2.23606797749979), (key = 14, value = 1.4142135623730951), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140302084119120, value = 6.9318439803281e-310), (key = 140302084119360, value = 6.9318439803328e-310), (key = 140302084119456, value = 6.93184398033756e-310)], 6, MinHeap, Dict(0.7853981633974483 => 1, 1.4142135623730951 => 3, 0.2617993877991494 => 5, 1.3591409142295225 => 4, 2.23606797749979   => 2))

  x_min₁ = extract_min!(mheap)
  @test x_min₁ == minimum(xs) # == 10
  @test peek(mheap)[1] == 12

  @test map(t -> map_ix(mheap)[t.value],
            filter(x -> x.key != x_min₁.key, xs)) == [3, 4, 1, 2]
  # 2. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 12, value = 2.23606797749979), (key = 15, value = 0.2617993877991494), (key = 14, value = 1.4142135623730951), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140302084119120, value = 6.9318439803281e-310), (key = 140302084119360, value = 6.9318439803328e-310), (key = 140302084119456, value = 6.93184398033756e-310)], 5, MinHeap, Dict(1.4142135623730951 => 3, 0.2617993877991494 => 2, 1.3591409142295225 => 4, 2.23606797749979   => 1))

  x_min₂ = extract_min!(mheap)
  @test x_min₂.key == 12
  @test peek(mheap)[1] == 14
  @test map(t -> map_ix(mheap)[t.value],
            filter(x -> x.key ∉ [x_min₁.key, x_min₂.key], xs)) == [1, 3, 2]
  # 3. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 14, value = 1.4142135623730951), (key = 15, value = 0.2617993877991494), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140704516954480, value = 6.9517268043224e-310), (key = 140704516962432, value = 6.951726804588e-310), (key = 140704517262640, value = 6.95172681942577e-310)], 4, MinHeap, Dict(1.4142135623730951 => 1, 0.2617993877991494 => 2, 1.3591409142295225 => 3))

  x_min₃ = extract_min!(mheap)
  @test x_min₃.key == 14
  @test peek(mheap)[1] == 15
  @test map(t -> map_ix(mheap)[t.value],
            filter(x -> x.key ∉ [x_min₁.key, x_min₂.key, x_min₃.key], xs)) == [2, 1]
  # 4. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 15, value = 0.2617993877991494), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140264669813104, value = 6.92999546812485e-310), (key = 140264669821056, value = 6.92999546839046e-310), (key = 140264670121264, value = 6.92999548322824e-310)], 3, MinHeap, Dict(0.2617993877991494 => 1, 1.3591409142295225 => 2))

  x_min₄ = extract_min!(mheap)
  @test x_min₄.key == 15
  @test peek(mheap)[1] == 16
  @test map(t -> map_ix(mheap)[t.value],
            filter(x -> x.key ∉ [x_min₁.key, x_min₂.key, x_min₃.key, x_min₄.key], xs)) == [1]
  # 5. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140264669813104, value = 6.92999546812485e-310)], 2, MinHeap, Dict(1.3591409142295225 => 1))

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
  for x in [(key=21, value=√2), (key=10, value=√3), (key=14, value=√7), (key=14, value=√5), (key=13, value=√2/2), (key=12, value=π/2), (key=15, value=2π)]
    insert!(mheap, x)
  end

  @test delete!(mheap, 2)[1] == 13

  @test peek(mheap)[1] == 10
  @test mheap.last - 1 == 6

  # under the hood
  @test map(t -> t[1],
            mheap.h[1:(mheap.last - 1)]) == [10, 14, 12, 21, 15, 14]
end

@testset "min heap deletion, with index map" begin
  n = 10; mheap = Heap{Int, Float64}(n; with_map=true)
  xs = [(key=21, value=√2), (key=10, value=√3), (key=14, value=√7), (key=14, value=√5), (key=13, value=√2/2), (key=12, value=π/2), (key=15, value=2π)]
  for x in xs; insert!(mheap, x); end

  # sanity check
  @test map(t -> mheap.map_ix[t.value], xs) == [4, 1, 6, 5, 2, 3, 7]
  @test length(mheap) == length(xs)

  k = 13                                      ## delete pair with key 13, which is located at index 2 of min_heap
  ix_in_xs = findall(x -> x.key == k, xs)[1]  ## which is located at ix_in_xs
  ix =  mheap.map_ix[xs[ix_in_xs].value]      ## which is located at ix in the heap...
  @test ix == 2                               ## which is expected to be at index 2 in the heap

  @test delete!(mheap, ix)[1] == k
  @test length(mheap) == length(xs) - 1       ## one less item
  @test peek(mheap)[1] == 10                  ## no change for the root (key)
  @test mheap.last - 1 == 6

  ## under the hood
  @test map(t -> t[1],
            mheap.h[1:(mheap.last - 1)]) == [10, 14, 12, 21, 15, 14]

  @test map(t -> mheap.map_ix[t.value],
            filter(x -> x.key != k, xs)) == [4, 1, 6, 2, 3, 5]

  ## Another deletion
  k, v = 14, √5   # for pair (key=14, value=√5)
  ix_in_xs = findall(x -> x.key == k &&x.value == v, xs)[1]
  @test ix_in_xs == 4                         ## expected at pos 4 in xs (by construction)

  @test xs[ix_in_xs].value ≈ √5               ## xs[ix_in_xs].value == √5
  ix =  mheap.map_ix[xs[ix_in_xs].value]
  @test ix == 2                               ## which is expected (again) to be at index 2 in the heap

  @test delete!(mheap, ix)[1] == k
  @test length(mheap) == length(xs) - 2       ## two less item
  @test peek(mheap)[1] == 10                  ## no change for the root (key)

  @test map(t -> mheap.map_ix[t.value],
            filter(x -> x ∉ [(key=13, value=√2/2), (key=k, value=v)], xs)) == [4, 1, 6, 3, 5]

  # 1. => Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 10, value = 1.7320508075688772), (key = 13, value = 0.7071067811865476), (key = 12, value = 1.5707963267948966), (key = 21, value = 1.4142135623730951), (key = 14, value = 2.23606797749979), (key = 14, value = 2.6457513110645907), (key = 15, value = 6.283185307179586), (key = 5, value = 2.5e-323), (key = 3, value = 1.5e-323), (key = 1, value = 5.0e-324)], 8, MinHeap,
  ## Dict(1.5707963267948966 => 3,
  ##      1.4142135623730951 => 4,
  ##      1.7320508075688772 => 1,
  ##      0.7071067811865476 => 2,  => (key=13, value=√2/2)
  ##      2.23606797749979 => 5,    => (key=14, value=√5)
  ##      2.6457513110645907 => 6,  => (key=14, value=√7)
  ##      6.283185307179586 => 7))

  # 2. => Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 10, value = 1.7320508075688772), (key = 14, value = 2.23606797749979), (key = 12, value = 1.5707963267948966), (key = 21, value = 1.4142135623730951), (key = 15, value = 6.283185307179586), (key = 14, value = 2.6457513110645907), (key = 15, value = 6.283185307179586), (key = 5, value = 2.5e-323), (key = 3, value = 1.5e-323), (key = 1, value = 5.0e-324)], 7, MinHeap,
  ## Dict(1.5707963267948966 => 3,
  ##      1.4142135623730951 => 4,
  ##      1.7320508075688772 => 1,
  ##      2.23606797749979 => 2,    => (key=14, value=√5)
  ##      2.6457513110645907 => 6,  => (key=14, value=√7)
  ##      6.283185307179586 => 5))

  # 3. => Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 10, value = 1.7320508075688772), (key = 14, value = 2.6457513110645907), (key = 12, value = 1.5707963267948966), (key = 21, value = 1.4142135623730951), (key = 15, value = 6.283185307179586), (key = 14, value = 2.6457513110645907), (key = 15, value = 6.283185307179586), (key = 5, value = 2.5e-323), (key = 3, value = 1.5e-323), (key = 1, value = 5.0e-324)], 6, MinHeap,
  ## Dict(1.5707963267948966 => 3,
  ##      1.4142135623730951 => 4,
  ##      1.7320508075688772 => 1,
  ##      2.6457513110645907 => 6,
  ##      6.283185307179586 => 5))
end


@testset "max heap deletion" begin
  n = 10; mheap = Heap{Int, Float64}(n; klass=MaxHeap) # :maxheap)
  for x in [(key=21, value=√2), (key=10, value=√3), (key=14, value=√7), (key=14, value=√5), (key=13, value=√2/2), (key=12, value=π/2), (key=15, value=2π)]
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
