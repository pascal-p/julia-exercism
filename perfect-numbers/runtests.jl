# canonical data version 1.1.0
using Test

include("perfect-numbers.jl")

@testset "Perfect numbers" begin

  @testset "Smallest perfect number is classified correctly" begin
    @test isperfect(6)
  end

  @testset "Medium perfect number is classified correctly" begin
    @test isperfect(28)
  end

  @testset "Large perfect number is classified correctly" begin
    @test isperfect(33550336)
  end

  @testset "first 47 even perfect numbers" begin
    # https://en.wikipedia.org/wiki/Perfect_number
    for p in [2, 3, 5, 7, 13, 17, 19, 31, 61, 89, 107, 127, 521, 607, 1279, 2203, 2281, 3217, 4253, 4423,
              9689, 9941, 11213, 19937, 21701, 23209, 44497, 86243, 110503, 132049, 216091, 756839, 859433,
              1257787, 1398269, 2976221, 3021377, 6972593, 13466917, 20996011, 24036583, 25964951, 30402457,
              32582657, 37156667, 42643801, 43112609]
      n = UInt128(2^p-1 * (2^p - 1))
      @test isodd(n) && isperfect(n)
    end
  end
end

@testset "Abundant numbers" begin

  @testset "Smallest abundant number is classified correctly" begin
    @test isabundant(12)
  end

  @testset "Medium abundant number is classified correctly" begin
    @test isabundant(30)
  end

  @testset "Large abundant number is classified correctly" begin
    @test isabundant(33550335)
  end

  @testset "First abundant numbers..." begin
    # https://en.wikipedia.org/wiki/Abundant_number
    # https://oeis.org/A005101
    for n in [12, 18, 20, 24, 30, 36, 40, 42, 48, 54, 56, 60, 66, 70, 72, 78, 80, 84, 88, 90, 96, 100, 102, 104,
              108, 112, 114, 120, 126, 132, 138, 140, 144, 150, 156, 160, 162, 168, 174, 176, 180, 186, 192, 196,
              198, 200, 204, 208, 210, 216, 220, 222, 224, 228, 234, 240, 246, 252, 258, 260, 264, 270]
      @test isabundant(n)
    end
  end
end

@testset "Deficient numbers" begin

  @testset "Smallest prime deficient number is classified correctly" begin
    @test isdeficient(2)
  end

  @testset "Smallest non-prime deficient number is classified correctly" begin
    @test isdeficient(4)
  end

  @testset "Medium deficient number is classified correctly" begin
    @test isdeficient(32)
  end

  @testset "Large deficient number is classified correctly" begin
    @test isdeficient(33550337)
  end

  @testset "Edge case (no factors other than itself) is classified correctly" begin
    @test isdeficient(1)
  end

  @testset "First deficient numbers..." begin
    # https://en.wikipedia.org/wiki/Deficient_number
    # https://oeis.org/A005100
    for n in [1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 19, 21, 22, 23, 25, 26, 27, 29, 31,
               32, 33, 34, 35, 37, 38, 39, 41, 43, 44, 45, 46, 47, 49, 50, 51, 52, 53, 55, 57, 58, 59,
               61, 62, 63, 64, 65, 67, 68, 69, 71, 73, 74, 75, 76, 77, 79, 81, 82, 83, 85, 86]
      @test isdeficient(n)
    end
  end
end

@testset "Invalid inputs" begin

  @testset "Zero is rejected (not a natural number)" begin
    @test_throws DomainError isdeficient(0)
    @test_throws DomainError isperfect(0)
    @test_throws DomainError isabundant(0)
  end

  @testset "Negative integer is rejected (not a natural number)" begin
    @test_throws DomainError isdeficient(-1)
    @test_throws DomainError isperfect(-1)
    @test_throws DomainError isabundant(-1)
  end
end
