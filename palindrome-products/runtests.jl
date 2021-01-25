using Test

include("./palindrome_products.jl")

@testset "smallest palindrome from single digit factors" begin
  (value, factors) = smallest(;min_factor=1, max_factor=9)

  @test value == 1
  @test factors == [(1, 1)]
end

@testset "largest palindrome from single digit factors" begin
  (value, factors) = largest(;min_factor=1, max_factor=9)

  @test value == 9
  @test factors == [(1, 9), (3, 3)]
end

@testset "smallest palindrome from double digit factors" begin
  (value, factors) = smallest(;min_factor=10, max_factor=99)

  @test value == 121
  @test factors == [(11, 11)]
end

@testset "largest palindrome from double digit factors" begin
  (value, factors) = largest(;min_factor=10, max_factor=99)

  @test value == 9009
  @test factors == [(91, 99)]
end

@testset "smallest palindrome from three digit factors" begin
  (value, factors) = smallest(;min_factor=100, max_factor=999)

  @test value == 10201
  @test factors == [(101, 101)]
end

@testset "largest palindrome from three digit factors" begin
  (value, factors) = largest(;min_factor=100, max_factor=999)

  @test value == 906609
  @test factors == [(913, 993)]
end


@testset "smallest palindrome from four digit factors" begin
  (value, factors) = smallest(;min_factor=1000, max_factor=9999)

  @test value == 1002001
  @test factors == [(1001, 1001)]
end

@testset "largest palindrome from four digit factors" begin
  (value, factors) = largest(;min_factor=1000, max_factor=9999)

  @test value == 99000099
  @test factors == [(9901, 9999)]
end

@testset "smallest if no palindrome in the range" begin
  @test smallest(;min_factor=1002, max_factor=1003) == nothing
end

@testset "largest_if_no_palindrome_in_the_range" begin
  @test largest(;min_factor=15, max_factor=15) == nothing
end

@testset "error result for smallest if min > max" begin
  @test_throws ArgumentError smallest(;min_factor=10_000, max_factor=1)
end

@testset "error result for largest if min > max" begin
  @test_throws ArgumentError largest(;min_factor=10_000, max_factor=1)
end
