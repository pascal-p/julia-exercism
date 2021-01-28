using Test

include("matrix.jl")

@testset "extract row from one number matrix" begin
  shape_ = (1,)
  matrix = YaMatrix{UInt32}(shape_; seed=70)

  @test shape(matrix) == shape_
  @test row(matrix, 1) == UInt32[2947072849] # 0xafa8c351
end

@testset "can extract row" begin
  T = UInt32
  matrix = YaMatrix{T}("1 2\n3 4")

  @test row(matrix, 1) == T[1, 2]
end

@testset "extract row where numbers have ≠ widths" begin
  T = UInt16
  matrix = YaMatrix{T}("1 2\n10 20")

  @test row(matrix, 2) == T[10, 20]
end

@testset "can extract row from non square matrix with no corresponding column" begin
  T = UInt16
  matrix = YaMatrix{T}("1 2 3\n4 5 6\n7 8 9\n8 7 6")

  @test row(matrix, 4) == T[8, 7, 6]
end

@testset "extract column from one number matrix" begin
  T = UInt16
  matrix = YaMatrix{T}("1")

  @test row(matrix, 1) == T[1]
end

@testset "can extract column" begin
  T = UInt8
  matrix = YaMatrix{T}("1 2 3\n4 5 6\n7 8 9")

  @test column(matrix, 3) == T[3, 6, 9]
end

@testset "can extract column from non square matrix with no corresponding row" begin
  T = UInt32
  matrix = YaMatrix{T}("1 2 3 4\n5 6 7 8\n9 8 7 6")

  @test column(matrix, 4) == T[4, 8, 6]
end

@testset "extract column where numbers have ≠ widths" begin
  T = UInt32
  matrix = YaMatrix{T}("89 1903 3\n18 3 1\n9 4 800")

   @test column(matrix, 2) == T[1903, 3, 4]
end
