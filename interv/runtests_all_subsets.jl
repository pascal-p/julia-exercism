using Test

include("./all_subsets.jl")


@testset "all subsets of a set of length 1 - Set impl" begin
  T = Char
  s = ST{T}(['a'])
  @test all_subset(s) == SST{T}([
                                 Set(['a']),
                                 Set{T}()
                                ])
end

@testset "all subsets of a set of length 1 - Array impl" begin
  T = Char
  s = VT{T}(['a'])
  @test all_subset(s) == VVT{T}([
                                 T[],
                                 ['a'],
                                ])
end

@testset "all subsets of a set of length 2 - Set impl" begin
  T = String
  s = ST{T}(["a", "b"])
  @test all_subset(s) == SST{T}([
                                 Set(["a"]),
                                 Set{T}(),
                                 Set(["b", "a"]),
                                 Set(["b"])
                                ])
end

@testset "all subsets of a set of length 2 - Array impl" begin
  T = String
  s = VT{T}(["a", "b"])
  @test all_subset(s) == VVT{T}([
                                 T[],
                                 ["a"],
                                 ["b"],
                                 ["a", "b"]
                                ])
end

@testset "all subsets of a set of length 5 - Set impl" begin
  T = Int
  s = ST{T}([10, 20, 30, 40, 50])
  @test all_subset(s) == SST{T}([
     Set([40]),
     Set([50, 40]),
     Set{T}(),
     Set([20, 40, 30]),
     Set([20, 10, 30]),
     Set([10, 50, 40, 30]),
     Set([50, 20]),
     Set([10, 40, 20]),
     Set([10, 40, 30]),
     Set([20, 10, 50, 40, 30]),
     Set([30]),
     Set([10, 50, 30]),
     Set([40, 30]),
     Set([20, 30]),
     Set([50, 40, 30]),
     Set([10, 30]),
     Set([10, 40]),
     Set([10, 50, 20]),
     Set([50, 30]),
     Set([50, 40, 20]),
     Set([10, 20]),
     Set([20, 10, 40, 30]),
     Set([40, 20]),
     Set([10]),
     Set([20, 50, 30]),
     Set([20, 50, 40, 30]),
     Set([20]),
     Set([10, 50, 40, 20]),
     Set([20, 10, 50, 30]),
     Set([10, 50]),
     Set([10, 50, 40]),
     Set([50])
  ])
end

@testset "all subset of a set of length 5 - Array impl" begin
  T = Int
  s = VT{T}([10, 20, 30, 40, 50])
  @test all_subset(s) == VVT{T}([
     [],
     [10],
     [20],
     [30],
     [40],
     [50],
     [10, 20],
     [10, 30],
     [10, 40],
     [10, 50],
     [20, 30],
     [20, 40],
     [20, 50],
     [30, 40],
     [30, 50],
     [40, 50],
     [10, 20, 30],
     [10, 20, 40],
     [10, 20, 50],
     [10, 30, 40],
     [10, 30, 50],
     [10, 40, 50],
     [20, 30, 40],
     [20, 30, 50],
     [20, 40, 50],
     [30, 40, 50],
     [10, 20, 30, 40],
     [10, 20, 30, 50],
     [10, 20, 40, 50],
     [10, 30, 40, 50],
     [20, 30, 40, 50],
     [10, 20, 30, 40, 50]
  ])
end


for k ∈ [4, 8, 10, 12]
  @testset "all subsets of a set of length $(k) - Set impl" begin
    T = Int
    s = ST{T}(collect(1:k))

    @time @test length(all_subset(s)) == 2^k
  end

  @testset "all subsets of a set of length $(k) - Set impl" begin
    T = Int
    s = VT{T}(collect(1:k))

    @time @test length(all_subset(s)) == 2^k
  end
end
