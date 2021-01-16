using Test

include("./nth_prime_alt.jl")


function prime_range(n)
  """Returns a list of the first n primes"""
  [prime(i) for i ∈ 1:n]
end


@testset "basic" begin

  @test prime(1) ≡ 2

  @test prime(2) ≡ 3

  @test prime(3) ≡ 5

  @test prime(4) ≡ 7

  @test prime(6) ≡ 13

  @test prime(16) ≡ 53

  @test prime(1049) ≡ 8377

  @test prime(10001) ≡ 104743

  @test_throws ArgumentError prime(100_001)

  @test prime(20_001; lim=1_000_000) ≡ 224_743

  @test @time prime_range(20) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]
end

@testset "bigger value" begin
  @test prime(50_001; lim=1_000_000) ≡ 611_957

  @test @time prime(100_001; lim=2_000_000) ≡ 1_299_721

  @test @time prime(500_001; lim=10_000_000) ≡ 7_368_791
end
