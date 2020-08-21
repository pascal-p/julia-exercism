# canonical data version 1.1.0
using Test

include("prime-factors.jl")

for algo in (pf_trial, pf_wheel,)
  println("\n+++ method $(algo)\n")

  @testset "no factors" begin
    @test prime_factors(1; algo) == []
  end

  @testset "prime number" begin
    for n in FIRST_PRIMES
      @test prime_factors(n; algo) == [n]
    end

    for n in [2_345_678_917, ]
      @test prime_factors(n; algo) == [n]
    end
  end

  @testset "square of a prime" begin
    @test prime_factors(9; algo) == [3, 3]
    @test prime_factors(49; algo) == [7, 7]
    @test prime_factors(121; algo) == [11, 11]
    @test prime_factors(169; algo) == [13, 13]
    @test prime_factors(25; algo) == [5, 5]
    @test prime_factors(4; algo) == [2, 2]
  end

  @testset "cube of a prime" begin
    @test prime_factors(8; algo) == [2, 2, 2]
  end

  @testset "power of 2" begin
    @test prime_factors(1024; algo) == [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
  end

  @testset "product of primes and non-primes" begin
    @test prime_factors(12; algo) == [2, 2, 3]
  end

  @testset "product of primes" begin
    @test prime_factors(901255; algo) == [5, 17, 23, 461]
    @test prime_factors(5959; algo) == [59, 101]
    @test prime_factors(1000009; algo) == [293, 3413]
  end

  @testset "random integer" begin
    @test prime_factors(199_999_999; algo) == [89, 1447, 1553]
    @test prime_factors(199_999_999_998; algo) == [2, 3, 3, 21649, 513239]
    @test prime_factors(700_666_999_666; algo) == [2, 193, 257, 1453, 4861]
    @test prime_factors(1_099_511_627_775; algo) == [3, 5, 5, 11, 17, 31, 41, 61681]
  end

  @testset "factors include a large prime" begin
    @test prime_factors(93819012551; algo) == [11, 9539, 894119]
  end

  @testset "factors of a huge integer 2^64 - 1" begin
    @test prime_factors(UInt128(340282366920938463463374607431768211455); algo) == [3, 5, 17, 257, 641, 65537, 274177, 6_700_417, 672_804_213_107_21]
  end
end
