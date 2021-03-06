using Test
using Random

push!(LOAD_PATH, "./src")
using YAH


function check_inv(mheap)
  n = (mheap.last - 1) ÷ 2
  for ix in 1:n
    jx = ix << 1
    @assert mheap.h[ix].key ≤  mheap.h[jx].key "- HEAP Error(1) at ix:$(ix)  key:$(mheap.h[ix]) ≤ $(mheap.h[jx]) at jx:$(jx)\n$(mheap.h[1:(mheap.last-1)])"

    if jx + 1 < (mheap.last - 1)
      @assert mheap.h[ix].key ≤  mheap.h[jx + 1].key "- HEAP Error(2) at ix:$(ix)  key:$(mheap.h[ix]) ≤ $(mheap.h[jx + 1]) at jx:$(jx+1)\n$(mheap.h[1:(mheap.last-1)])"
    end
  end
end

function make_heap()
  n = 32
  mheap = Heap{Int, Nothing}(n)

  # manufacture specific heap
  mheap.h = [(key=10, value=nothing), (key=70, value=nothing), (key=30, value=nothing), (key=80, value=nothing), (key=100, value=nothing), (key=40, value=nothing), (key=51, value=nothing), (key=90, value=nothing), (key=85, value=nothing), (key=110, value=nothing), (key=120, value=nothing), (key=50, value=nothing), (key=55, value=nothing), (key=71, value=nothing), (key=77, value=nothing), (key=200, value=nothing), (key=300, value=nothing), (key=91, value=nothing), (key=94, value=nothing), (key=117, value=nothing), (key=118, value=nothing), (key=122, value=nothing), (key=124, value=nothing), (key=92, value=nothing)]

  mheap.last = length(mheap.h) + 1

  mheap.map_ix = Dict{NamedTuple{(:key, :value),Tuple{Int64,Nothing}},Int64}((key=10, value=nothing) => 1, (key=70, value=nothing) => 2, (key=30, value=nothing) => 3, (key=80, value=nothing) => 4, (key=100, value=nothing) => 5, (key=40, value=nothing) => 6, (key=51, value=nothing) => 7, (key=90, value=nothing) => 8, (key=85, value=nothing) => 9, (key=110, value=nothing) => 10, (key=120, value=nothing) => 11, (key=50, value=nothing) => 12, (key=55, value=nothing) => 13, (key=71, value=nothing) => 14, (key=77, value=nothing) => 15, (key=200, value=nothing) => 16, (key=300, value=nothing) => 17, (key=91, value=nothing) => 18, (key=94, value=nothing) => 19, (key=117, value=nothing) => 20, (key=118, value=nothing) => 21, (key=122, value=nothing) => 22, (key=124, value=nothing) => 23, (key=92, value=nothing) => 24)

  return mheap
end



@testset "min heap basics" begin
  n = 10
  mheap = Heap{Int, Float64}(n) ## MinHeap default

  @test size(mheap) == n
  @test isempty(mheap)

  insert!(mheap, (key=21, value=1.1))
  @test mheap.last == 2         ## next free position
end

@testset "min heap - deletions at any pos." begin
  ## OK 1:
  mheap = make_heap()
  check_inv(mheap)

  delete!(mheap, 2) # == 70
  check_inv(mheap)
  @test mheap.h[2].key == 80
  @test mheap.h[4].key == 85
  @test mheap.h[9].key == 91
  @test mheap.h[18].key == 92

  ## OK 2:
  mheap = make_heap()
  check_inv(mheap)

  delete!(mheap, 10) # == 110
  check_inv(mheap)
  @test mheap.h[5].key == 92
  @test mheap.h[10].key == 100

  ## OK 3:
  mheap = make_heap()
  check_inv(mheap)
  delete!(mheap, 4)  # == 80
  check_inv(mheap)
  @test mheap.h[4].key == 85
  @test mheap.h[9].key == 91
  @test mheap.h[18].key == 92

  ## OK 4: delete the root
  mheap = make_heap()
  check_inv(mheap)
  delete!(mheap, 1)  # == 10
  check_inv(mheap)
  @test mheap.h[1].key == 30
  @test mheap.h[3].key == 40
  @test mheap.h[6].key == 50
  @test mheap.h[12].key == 92

  # OK: 5
  mheap = make_heap()
  check_inv(mheap)
  delete!(mheap, 11)  # == 120
  check_inv(mheap)
  @test mheap.h[11].key == 100
  @test mheap.h[5].key == 92

  # OK 6:
  mheap = make_heap()
  check_inv(mheap)
  delete!(mheap, 22)  # == 122
  check_inv(mheap)
  @test mheap.h[22].key == 120
  @test mheap.h[11].key == 100
  @test mheap.h[5].key == 92
end

@testset "min heap insert" begin
  n = 2
  mheap = Heap{Int, Float64}(n)

  for x in [(key=14, value=2.0), (key=12, value=π/2), (key=10, value=ℯ/2)]
    insert!(mheap, x)
    @test peek(mheap) == x
  end

  @test size(mheap) == 2n       ## should have double
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

@testset "min heapify with index map checks" begin
  xs = [(key=35, value=2.0), (key=33, value=1.1), (key=10, value=√2), (key=45, value=√3), (key=30, value=ℯ/2), (key=49, value=ℯ/3),
        (key=48, value=π/4), (key=34, value=π/2), (key=12, value=√5), (key=5, value=-√5), (key=14, value=π/12), (key=43, value=log(2.1)),
        (key=16, value=5.0), (key=24, value=11.3), (key=31, value=√2/2)]
  mheap = Heap{Int, Float64}(15)
  heapify!(mheap, xs)

  @test map(t -> t.key,         ## or t[1]
            mheap.h) == [5, 12, 10, 34, 14, 16, 24, 35, 45, 30, 33, 43, 49, 48, 31]

  @test map(t -> mheap.map_ix[t], xs) == [8, 11, 3, 9, 10, 13, 14, 4, 2, 1, 5, 12, 6, 7, 15]
end

@testset "max heapify" begin
  xs = [(key=35, value=2.0), (key=33, value=1.1), (key=10, value=√2), (key=45, value=√3), (key=30, value=ℯ/2), (key=49, value=ℯ/3),
        (key=48, value=π/4), (key=34, value=π/2), (key=12, value=√5), (key=5, value=-√5), (key=14, value=π/12), (key=43, value=log(2.1)),
        (key=16, value=5.0), (key=24, value=11.3), (key=31, value=√2/2)]
  mheap = Heap{Int, Float64}(15; klass=MaxHeap)
  heapify!(mheap, xs)

  @test map(t -> t[1], mheap.h) == [49, 45, 48, 34, 30, 43, 35, 33, 12, 5, 14, 10, 16, 24, 31]
end

@testset "max heapify with index map" begin
  xs = [(key=35, value=2.0), (key=33, value=1.1), (key=10, value=√2), (key=45, value=√3), (key=30, value=ℯ/2), (key=49, value=ℯ/3),
        (key=48, value=π/4), (key=34, value=π/2), (key=12, value=√5), (key=5, value=-√5), (key=14, value=π/12), (key=43, value=log(2.1)),
        (key=16, value=5.0), (key=24, value=11.3), (key=31, value=√2/2)]
  mheap = Heap{Int, Float64}(15; klass=MaxHeap)
  heapify!(mheap, xs)

  @test map(t -> t[1], mheap.h) == [49, 45, 48, 34, 30, 43, 35, 33, 12, 5, 14, 10, 16, 24, 31]

  @test map(t -> mheap.map_ix[t], xs) == [7, 8, 12, 2, 5, 1, 3, 4, 9, 10, 11, 6, 13, 14, 15]
end

@testset "max heap insert" begin
  n = 2
  mheap = Heap{Int, Float64}(n; klass=MaxHeap)

  for x in [(key=10, value=ℯ/2), (key=12, value=π/3), (key=14, value=2.0)]    ## contrived example
    insert!(mheap, x)
    @test peek(mheap)[1] == x[1]
  end

  @test size(mheap) == 2n   ## should have double
  @test mheap.last == 4

end

@testset "max heap insert, with index map check" begin
  n = 2
  mheap = Heap{Int, Float64}(n; klass=MaxHeap)

  xs = [(key=10, value=ℯ/2), (key=12, value=π/3), (key=14, value=2.0)]    ## contrived example
  for x in xs
    insert!(mheap, x)
    @test peek(mheap)[1] == x.key # or x[1]
  end

  @test size(mheap) == 2n   ## should have double
  @test mheap.last == 4

  @test map(t -> mheap.map_ix[t], xs) == [2, 3, 1]
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

@testset "min heap extract_min - with ties" begin
  n = 4
  xs = [(key=14, value=100), (key=12, value=200), (key=10, value=300), (key=12, value=110), (key=14, value=120), (key=10, value=120), (key=12, value=120)]

  mheap = Heap{Int, Int}(n)
  for x in xs; insert!(mheap, x); end
  # [(key = 10, value = 120), (key = 12, value = 110), (key = 10, value = 300), (key = 14, value = 100), (key = 14, value = 120), (key = 12, value = 200), (key = 12, value = 120), (key = 140048280156384, value = 0)], 8,
  # MinHeap, Dict(200 => 6,100 => 4,120 => 7,110 => 2,300 => 3))

  @test peek(mheap) == minimum(xs)

  x = extract_min!(mheap)
  @test x == minimum(xs) # == 10
  # new min:
  # [(key = 10, value = 300), (key = 12, value = 110), (key = 12, value = 120), (key = 14, value = 100), (key = 14, value = 120), (key = 12, value = 200), (key = 12, value = 120), (key = 0, value = 0)], 7, MinHeap,
  # Dict(200 => 6,100 => 4,120 => 3,110 => 2,300 => 1))

  @test peek(mheap) == (key = 10, value = 300)

  x = extract_min!(mheap)[1]
  @test x == 10
  @test peek(mheap) == (key = 12, value = 200)
  # [(key = 12, value = 200), (key = 12, value = 110), (key = 12, value = 120), (key = 14, value = 100), (key = 14, value = 120), (key = 12, value = 200), (key = 12, value = 120), (key = 139941379796368, value = 139941403780112)], 6, MinHeap,
  # Dict(200 => 1,100 => 4,120 => 3,110 => 2))

  @test delete!(mheap, 3) ==  (key = 12, value = 120) # remove (key = 12, value = 200)

  insert!(mheap, (key = 10, value = 9999))
  @test peek(mheap) == (key = 10, value = 9999)

  insert!(mheap, (key = 10, value = 9997))
  @test peek(mheap) == (key = 10, value = 9997)
  # [(key = 10, value = 9997), (key = 12, value = 200), (key = 10, value = 9999), (key = 14, value = 100), (key = 12, value = 110), (key = 14, value = 120), (key = 12, value = 120), (key = 1, value = 0)], 7, MinHeap, Dict(200 => 2,100 => 4,9997 => 1,120 => 6,9999 => 3,110 => 5))

  @test delete!(mheap, 3) == (key = 10, value = 9999)  # == (key = 10, value = 9999)
  # [(key = 10, value = 9997), (key = 12, value = 200), (key = 14, value = 120), (key = 14, value = 100), (key = 12, value = 110), (key = 14, value = 120), (key = 12, value = 120), (key = 1, value = 0)], 6, MinHeap, Dict(200 => 2,100 => 4,9997 => 1,120 => 3,110 => 5))

  @test delete!(mheap, 2) == (key = 12, value = 200)

  insert!(mheap, (key = 10, value = 200))  # new priority

  @test peek(mheap) == (key = 10, value = 200)
end

@testset "min heap extract_min, with index map check" begin
  n = 4
  xs = [(key=14, value=√2), (key=16, value=ℯ/2), (key=10, value=π/4), (key=12, value=√5), (key=15, value=π/12)]
  mheap = Heap{Int, Float64}(n)
  for x in xs; insert!(mheap, x); end

  @test peek(mheap) == minimum(xs)
  @test size(mheap) == 2n   ## should have double
  # 1. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 10, value = 0.7853981633974483), (key = 12, value = 2.23606797749979), (key = 14, value = 1.4142135623730951), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140302084119120, value = 6.9318439803281e-310), (key = 140302084119360, value = 6.9318439803328e-310), (key = 140302084119456, value = 6.93184398033756e-310)], 6, MinHeap, Dict(0.7853981633974483 => 1, 1.4142135623730951 => 3, 0.2617993877991494 => 5, 1.3591409142295225 => 4, 2.23606797749979   => 2))

  x_min₁ = extract_min!(mheap)
  @test x_min₁ == minimum(xs) # == 10
  @test peek(mheap)[1] == 12

  @test map(t -> map_ix(mheap)[t], filter(x -> x.key != x_min₁.key, xs)) == [3, 4, 1, 2]
  # 2. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 12, value = 2.23606797749979), (key = 15, value = 0.2617993877991494), (key = 14, value = 1.4142135623730951), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140302084119120, value = 6.9318439803281e-310), (key = 140302084119360, value = 6.9318439803328e-310), (key = 140302084119456, value = 6.93184398033756e-310)], 5, MinHeap, Dict(1.4142135623730951 => 3, 0.2617993877991494 => 2, 1.3591409142295225 => 4, 2.23606797749979   => 1))

  x_min₂ = extract_min!(mheap)
  @test x_min₂.key == 12
  @test peek(mheap)[1] == 14
  @test map(t -> map_ix(mheap)[t], filter(x -> x.key ∉ [x_min₁.key, x_min₂.key], xs)) == [1, 3, 2]
  # 3. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 14, value = 1.4142135623730951), (key = 15, value = 0.2617993877991494), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140704516954480, value = 6.9517268043224e-310), (key = 140704516962432, value = 6.951726804588e-310), (key = 140704517262640, value = 6.95172681942577e-310)], 4, MinHeap, Dict(1.4142135623730951 => 1, 0.2617993877991494 => 2, 1.3591409142295225 => 3))

  x_min₃ = extract_min!(mheap)
  @test x_min₃.key == 14
  @test peek(mheap)[1] == 15
  @test map(t -> map_ix(mheap)[t], filter(x -> x.key ∉ [x_min₁.key, x_min₂.key, x_min₃.key], xs)) == [2, 1]
  # 4. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 15, value = 0.2617993877991494), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140264669813104, value = 6.92999546812485e-310), (key = 140264669821056, value = 6.92999546839046e-310), (key = 140264670121264, value = 6.92999548322824e-310)], 3, MinHeap, Dict(0.2617993877991494 => 1, 1.3591409142295225 => 2))

  x_min₄ = extract_min!(mheap)
  @test x_min₄.key == 15
  @test peek(mheap)[1] == 16
  @test map(t -> map_ix(mheap)[t], filter(x -> x.key ∉ [x_min₁.key, x_min₂.key, x_min₃.key, x_min₄.key], xs)) == [1]
  # 5. mheap:Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 16, value = 1.3591409142295225), (key = 15, value = 0.2617993877991494), (key = 140264669813104, value = 6.92999546812485e-310)], 2, MinHeap, Dict(1.3591409142295225 => 1))

  @test size(mheap) == floor(Int, 2n * 0.75)  ## should have shrinked
end


@testset "max heap extract_max" begin
  n = 4
  ary = [(key=14, value=√2), (key=16, value=ℯ/2), (key=10, value=π/4), (key=12, value=√5), (key=15, value=π/12)]
  mheap = Heap{Int, Float64}(n, klass=MaxHeap)

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

  ## under the hood - now using iterator
  # @test map(t -> t[1], mheap.h[1:(mheap.last - 1)]) == [10, 14, 12, 21, 15, 14]
  @test map(t -> t[1], collect(mheap)) == [10, 14, 12, 21, 15, 14]

end

@testset "min heap deletion, with index map check" begin
  n = 10; mheap = Heap{Int, Float64}(n)
  xs = [(key=21, value=√2), (key=10, value=√3), (key=14, value=√7), (key=14, value=√5), (key=13, value=√2/2), (key=12, value=π/2), (key=15, value=2π)]
  for x in xs; insert!(mheap, x); end

  # sanity check
  @test map(t -> mheap.map_ix[t], xs) == [4, 1, 6, 5, 2, 3, 7]
  @test length(mheap) == length(xs)

  k = 13                                      ## delete pair with key 13, which is located at index 2 of min_heap
  ix_in_xs = findall(x -> x.key == k, xs)[1]  ## which is located at ix_in_xs
  ix =  mheap.map_ix[xs[ix_in_xs]]            ## which is located at ix in the heap...
  @test ix == 2                               ## which is expected to be at index 2 in the heap

  @test delete!(mheap, ix)[1] == k
  @test length(mheap) == length(xs) - 1       ## one less item
  @test peek(mheap)[1] == 10                  ## no change for the root (key)
  @test mheap.last - 1 == 6

  ## under the hood
  @test map(t -> t[1], mheap.h[1:(mheap.last - 1)]) == [10, 14, 12, 21, 15, 14]

  @test map(t -> mheap.map_ix[t], filter(x -> x.key != k, xs)) == [4, 1, 6, 2, 3, 5]

  ## Another deletion
  k, v = 14, √5                               ## for pair (key=14, value=√5)
  ix_in_xs = findall(x -> x.key == k && x.value == v, xs)[1]
  @test ix_in_xs == 4                         ## expected at pos 4 in xs (by construction)

  @test xs[ix_in_xs].value ≈ √5               ## xs[ix_in_xs].value == √5
  ix =  mheap.map_ix[xs[ix_in_xs]]
  @test ix == 2                               ## which is expected (again) to be at index 2 in the heap

  @test delete!(mheap, ix)[1] == k
  @test length(mheap) == length(xs) - 2       ## two less item
  @test peek(mheap)[1] == 10                  ## no change for the root (key)

  # mheap.map_ix[t] returns an index
  @test map(t -> mheap.map_ix[t],
            filter(x -> x ∉ [(key=13, value=√2/2), (key=k, value=v)], xs)) == [4, 1, 2, 3, 5]
end


@testset "max heap deletion" begin
  n = 10; mheap = Heap{Int, Float64}(n; klass=MaxHeap) # :maxheap)
  for x in [(key=21, value=√2), (key=10, value=√3), (key=14, value=√7), (key=14, value=√5), (key=13, value=√2/2), (key=12, value=π/2), (key=15, value=2π)]
    insert!(mheap, x)
  end

  @test delete!(mheap, 2)[1] == 14

  @test peek(mheap)[1] == 21
  @test mheap.last - 1 == 6

  # under the hood - using iterator
  @test collect(mheap) == [(key=21, value=√2), (key=14, value=√7), (key=15, value=2π), (key=10, value=√3), (key=13, value=√2/2), (key=12, value=π/2)]
end

@testset "max heap deletion - ignoring absence of item to delete" begin
  n = 10; mheap = Heap{Int, String}(n; klass=MaxHeap)
  for x in [(key=21, value="foo"), (key=10, value="bar"), (key=14, value="toto"), (key=14, value="titi"), (key=13, value="tutu"), (key=12, value="tata")]
    insert!(mheap, x)
  end

  @test delete!(mheap, 2) == (key=14, value="titi")  # because inserted after (key=14, value="toto")

  @test peek(mheap) == (key=21, value="foo")
  @test mheap.last - 1 == 5

  # under the hood - using iterator
  @test map(t -> t[1], collect(mheap)) == [21, 13, 14, 10, 12]

  ## delete non-existent pair - w/o raising exception
  @test delete!(mheap, (key=42, value="meaning of life"); ignore_absence=true) == nothing
  @test mheap.last - 1 == 5 ## no change
end

@testset "repeated insert!/delete! operations on heap" begin
  n = 10; mheap = Heap{Int, String}(n; klass=MinHeap)
  xs = [(key=21, value="bar"), (key=-10, value="boo"), (key=-14, value="foo"), (key=-14, value="moo"), (key=13, value="tar"), (key=-12, value="rar"), (key=15, value="xoo")]
  l = length(xs)

  for x in xs
    insert!(mheap, x)
    @test haskey(mheap.map_ix, x)

    ## Random delete
    ix = rand(1:l)
    delete!(mheap, xs[ix]; ignore_absence=true)

    for (k_val, v_jx) in map_ix(mheap)
      @test k_val == mheap.h[v_jx] # "AssertionError: k_val:$(k_val) at pos. $(v_jx) should match  mheap.h[v_jx:$(v_jx)]: $(mheap.h[v_jx])"
    end

    # re-insert deleted element with lower priority and delete again... and again
    (k, v) = xs[ix]
    for _ix in 1:10 # 10_000
      k -= 10
      insert!(mheap, (key=k, value=v); ignore_presence=true)
      delete!(mheap, (key=k+10, value=v); ignore_absence=true)
    end
  end

  ## delete last item
  n = mheap.last - 1
  delete!(mheap, mheap.last - 1)
  @test mheap.last - 1 == n - 1

  ## delete first
  n = mheap.last - 1
  delete!(mheap, 1)
  @test mheap.last - 1 == n - 1

  for _ix in 1:(mheap.last - 1)
    delete!(mheap, 1)
  end

  @test mheap.last == 1
  @test length(mheap.map_ix) == 0
end

@testset "exceptions" begin
  n = 2
  mheap = Heap{Int, Int}(n)

  @test_throws ArgumentError peek(mheap)          ## empty heap!
  @test_throws ArgumentError extract_min!(mheap)  ## empty heap!

  @test_throws AssertionError Heap{Int, Int}(n; klass=:fooheap)
end
