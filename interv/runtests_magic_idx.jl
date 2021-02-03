using Test
using Random

include("./magic_idx.jl")

@testset "trival case with magic index" begin
  a = collect(Int, 1:2:20)  # sorted sequence

  @test magic_idx(a) == 1
end

@testset "trival case with no magic index" begin
  a = collect(Int, 0:10)

  @test magic_idx(a) == nothing
end

@testset "with negative integers - magic index" begin
  a = [collect(Int, -10:2:-1)..., collect(Int, 1:2:20)...]

  @test magic_idx(a) == 11
end

@testset "with negative integers - no magic index" begin
  a = [collect(Int, -10:2:-1)..., collect(Int, 3:3:20)...]

  @test magic_idx(a) == nothing
end

@testset "positive integers - no magic index" begin
  a = collect(Int, 5:3:100)

  @test magic_idx(a) == nothing
end

@testset "negative integers - no magic index" begin
  a = collect(Int, -100:3:-1)

  @test magic_idx(a) == nothing
end

@testset "random sequence of  integers - no magic index" begin
  # Random.seed!(5432);
  # a = unique(sort(rand(-100:100, 20)))
  a = [-20, -18, -17, -16, -13, -10, -8, -7, -6, -5, -4,
       1, 4, 8, 23, 24, 27, 36, 38]

  @test magic_idx(a) == nothing
end

@testset "random sequence of integers - with magic index" begin
  # Random.seed!(5432);
  # a = unique(sort(rand(-20:30, 20))
  a = [-20, -18, -15, -14, -2, -1, 5, 7, 8, 9, 10, 12, 15, 17, 29, 32, 36, 37]

  @test magic_idx(a) == 12
end

@testset "random sequence of integers with duplicate - with magic index" begin
  a = [-5, -3, -1, 0, 6, 7, 8, 8, 9, 9, 9, 9, 13, 14, 15, 16, 20, 20, 20, 23]
  #     1   2   3  4  5  6  7  8, 9 10 11 12  13  14  15  16  17  18  19  20

  @test magic_idx(a; no_dup=false) ∈ [8, 9, 15, 16]
end

@testset "random sequence of integers with duplicate - with magic indexes" begin
  a = [-5, -3, -1, 0, 6, 7, 8, 8, 9, 9, 9, 9, 13, 14, 15, 16, 20, 20, 20, 23]
  #     1   2   3  4  5  6  7  8  9 10 11 12  13  14  15  16  17  18  19  20

  @test magic_idx(a; first_only=false, no_dup=false) == [8, 9, 13, 14, 15, 16]
  @test magic_idx(a; first_only=true, no_dup=false) ∈ [8, 9, 13, 14, 15, 16]
end

@testset "integers  with duplicates - magic index" begin
  a = sort([collect(Int, 1:20)..., collect(Int, 2:2:20)...])

  @test magic_idx(a; first_only=false, no_dup=false) == [1, 2]
  @test magic_idx(a; no_dup=false) ∈ [1, 2]
end

@testset "large integers array with no duplicates - magic index" begin
  a = collect(-10000:2:40000);

  @test magic_idx(a) == 10002
  @test magic_idx(a; first_only=false) == [10002]
end

@testset "larger integers array with no duplicates - magic index / perf - binary search" begin
  a = collect(-100000000:2:400000000);

  @time @test magic_idx(a; first_only=false) == [100000002]
  # 0.000039 seconds (239 allocations: 4.359 KiB)
end

@testset "larger integers array with no duplicates - magic index / perf - seq. search" begin
  a = collect(-100000000:2:400000000);
  
  @time @test magic_idx_bf(a; first_only=false) == [100000002]
  # 0.103253 seconds (11 allocations: 704 bytes)
end
