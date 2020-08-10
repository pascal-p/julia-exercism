using Test

include("rational-numbers.jl")

@test RationalNumber <: Real
@test_throws ArgumentError RationalNumber(0, 0)

@testset "One- & Zero-elements" begin
  @test zero(RationalNumber{Int}) == RationalNumber(0, 1)
  @test one(RationalNumber{Int})  == RationalNumber(1, 1)
end

@testset "Contructor on limit" begin
  @test RationalNumber(typemax(Int64), typemin(Int64)) == RationalNumber(Int128(typemax(Int64)) * -1, Int128(typemin(Int64)) * -1)

  @test RationalNumber(typemax(Int64), typemax(Int64)) == RationalNumber(1, 1)
  @test RationalNumber(typemax(Int128), typemax(Int128)) == RationalNumber(1, 1)
end

# julia> RationalNumber(Int128(typemax(Int64)) * 2 + 1, 2)
# 18446744073709551615//2

# julia> methods(RationalNumber)
# # 10 methods for type constructor:
# [1] (::Type{T})(z::Complex) where T<:Real in Base at complex.jl:37
# [2] (::Type{RationalNumber})(x::BigInt, y::Int128) in Main at /home/pascal/snap/exercism/5/exercism/julia/rational-numbers/rational-numbers.jl:43
# [3] (::Type{RationalNumber})(x::Int64, y::Int128) in Main at /home/pascal/snap/exercism/5/exercism/julia/rational-numbers/rational-numbers.jl:42
# [4] (::Type{RationalNumber})(x::Int128, y::Int64) in Main at /home/pascal/snap/exercism/5/exercism/julia/rational-numbers/rational-numbers.jl:43
# [5] (::Type{RationalNumber})(x::Int128, y::BigInt) in Main at /home/pascal/snap/exercism/5/exercism/julia/rational-numbers/rational-numbers.jl:42
# [6] (::Type{RationalNumber})(x::Integer) in Main at /home/pascal/snap/exercism/5/exercism/julia/rational-numbers/rational-numbers.jl:38
# [7] (::Type{RationalNumber})(num::T, den::T) where T<:Real in Main at /home/pascal/snap/exercism/5/exercism/julia/rational-numbers/rational-numbers.jl:11
# [8] (::Type{T})(x::T) where T<:Number in Core at boot.jl:716
# [9] (::Type{T})(x::Base.TwicePrecision) where T<:Number in Base at twiceprecision.jl:243
# [10] (::Type{T})(x::AbstractChar) where T<:Union{AbstractChar, Number} in Base at char.jl:50

@testset "Arithmetic" begin
  @testset "Addition" begin
    @test RationalNumber( 1, 2) + RationalNumber( 2, 3) == RationalNumber( 7, 6)
    @test RationalNumber( 1, 2) + RationalNumber(-2, 3) == RationalNumber(-1, 6)
    @test RationalNumber(-1, 2) + RationalNumber(-2, 3) == RationalNumber(-7, 6)
    @test RationalNumber( 1, 2) + RationalNumber(-1, 2) == RationalNumber( 0, 1)

    @test RationalNumber(typemax(Int64), 1) + RationalNumber(1, 2) == RationalNumber(Int128(typemax(Int64)) * 2 + 1, 2)

    @test RationalNumber(typemax(Int64), typemax(Int64)) + RationalNumber(1, 2) == RationalNumber(3, 2)
    @test RationalNumber(typemax(Int64), 2) + RationalNumber(1, 2) == RationalNumber(Int128(typemax(Int64)) + 1, 2)
    @test RationalNumber(typemax(Int64), 4) + RationalNumber(1, 2) == RationalNumber(Int128(typemax(Int64)) + 2, 4)

    @test RationalNumber(typemin(Int128), typemin(Int128)) + RationalNumber(1, 2) == RationalNumber(3, 2)
  end


  @testset "Mixed Addition" begin
    @test RationalNumber( 1, 2) + 2  == RationalNumber( 5, 2)
    @test 2 +  RationalNumber( 1, 2) == RationalNumber(5, 2)
    @test RationalNumber(-1, 2) + 3  == RationalNumber(5, 2)
    @test 1 + RationalNumber( 5, 2)  == RationalNumber(7, 2)

    @test 1000 + RationalNumber( 1, 2)  == RationalNumber(2001, 2)
    @test typemax(Int64) + RationalNumber(1, 2) == RationalNumber(Int128(typemax(Int64)) * 2 + 1, 2)
  end

  @testset "Subtraction" begin
    @test RationalNumber( 1, 2) - RationalNumber( 2, 3) == RationalNumber(-1, 6)
    @test RationalNumber( 1, 2) - RationalNumber(-2, 3) == RationalNumber( 7, 6)
    @test RationalNumber(-1, 2) - RationalNumber(-2, 3) == RationalNumber( 1, 6)
    @test RationalNumber( 1, 2) - RationalNumber( 1, 2) == RationalNumber( 0, 1)

    @test RationalNumber(typemin(Int64), 2) - RationalNumber(1, 2) == RationalNumber(Int128(typemin(Int64)) - 1, 2)
    @test RationalNumber(typemin(Int64), 4) - RationalNumber(1, 2) == RationalNumber(Int128(typemin(Int64)) - 2, 4)

    @test RationalNumber(typemin(Int128), 2) - RationalNumber(1, 2) == RationalNumber(BigInt(typemin(Int128)) - 1, 2)
  end

  @testset "Mix Subtraction" begin
    @test RationalNumber(-1, 2) - 3 == RationalNumber(-7, 2)
    @test 3 - RationalNumber( 1, 2) == RationalNumber( 5, 2)
    @test RationalNumber(-1, 2) - 2 == RationalNumber(-5, 2)
    @test 4 - RationalNumber( 5, 2) == RationalNumber(3, 2)
    @test 1 - RationalNumber( 5, 2) == RationalNumber(-3, 2)

    @test typemin(Int64) - RationalNumber(5, 2) == RationalNumber(Int128(typemin(Int64)) * 2 - 5, 2)
  end

  @testset "Multiplication" begin
    @test RationalNumber( 1, 2) * RationalNumber( 2, 3) == RationalNumber( 1, 3)
    @test RationalNumber(-1, 2) * RationalNumber( 2, 3) == RationalNumber(-1, 3)
    @test RationalNumber(-1, 2) * RationalNumber(-2, 3) == RationalNumber( 1, 3)
    @test RationalNumber( 1, 2) * RationalNumber( 2, 1) == RationalNumber( 1, 1)
    @test RationalNumber( 1, 2) * RationalNumber( 1, 1) == RationalNumber( 1, 2)
    @test RationalNumber( 1, 2) * RationalNumber( 0, 1) == RationalNumber( 0, 1)

    @test RationalNumber(typemin(Int64), 2) * RationalNumber(typemax(Int64), 2) == RationalNumber(Int128(typemin(Int64)) * typemax(Int64), 4)
  end

  @testset "Exponentiation" begin
    @testset "Exponentiation of a rational number" begin
      @test RationalNumber( 1, 2)^3 == RationalNumber( 1, 8)
      @test RationalNumber(-1, 2)^3 == RationalNumber(-1, 8)
      @test RationalNumber( 0, 1)^5 == RationalNumber( 0, 1)
      @test RationalNumber( 1, 1)^4 == RationalNumber( 1, 1)
      @test RationalNumber( 1, 2)^0 == RationalNumber( 1, 1)
      @test RationalNumber(-1, 2)^0 == RationalNumber( 1, 1)
    end

    @testset "Exponentiation of a real number to a rational number" begin
      @test 8^RationalNumber( 4, 3) ≈ 15.999999999999998
      @test 9^RationalNumber(-1, 2) ≈ 0.3333333333333333
      @test 2^RationalNumber( 0, 1) ≈ 1.0
      @test 2^RationalNumber( 1, 1) ≈ 2.0

      @test_throws ArgumentError 0^RationalNumber( 0, 1)
    end
  end

  @testset "Division" begin
    @test RationalNumber( 1, 2) / RationalNumber( 2, 3) == RationalNumber( 3, 4)
    @test RationalNumber( 1, 2) / RationalNumber(-2, 3) == RationalNumber(-3, 4)
    @test RationalNumber(-1, 2) / RationalNumber(-2, 3) == RationalNumber( 3, 4)
    @test RationalNumber( 1, 2) / RationalNumber( 1, 1) == RationalNumber( 1, 2)

    @test_throws ArgumentError RationalNumber(1, 2) / RationalNumber(0, 3)
  end
end

@testset "Absolute value" begin
  @test abs(RationalNumber( 1,  2)) == RationalNumber(1, 2)
  @test abs(RationalNumber(-1,  2)) == RationalNumber(1, 2)
  @test abs(RationalNumber( 0,  1)) == RationalNumber(0, 1)
  @test abs(RationalNumber( 1, -2)) == RationalNumber(1, 2)

  @test abs(RationalNumber(typemin(Int), 2)) == RationalNumber(div(typemax(Int), 2) + 1, 1)  # == RationalNumber(Int128(typemax(Int)) + 1, 2)
  @test abs(RationalNumber(typemin(Int), 1)) == RationalNumber(Int128(typemax(Int)) + 1, 1)
end

@testset "Reduction to lowest terms" begin
  r = RationalNumber(2, 4)
  @test numerator(r)   == 1
  @test denominator(r) == 2

  r = RationalNumber(-4, 6)
  @test numerator(r)   == -2
  @test denominator(r) ==  3

  r = RationalNumber(3, -9)
  @test numerator(r)   == -1
  @test denominator(r) ==  3

  r = RationalNumber(0, 6)
  @test numerator(r)   == 0
  @test denominator(r) == 1

  r = RationalNumber(-14, 7)
  @test numerator(r)   == -2
  @test denominator(r) ==  1

  r = RationalNumber(13, 13)
  @test numerator(r)   == 1
  @test denominator(r) == 1

  r = RationalNumber(1, -1)
  @test numerator(r)   == -1
  @test denominator(r) ==  1
end

# TODO add to problem spec
# The following testset is based on the tests for rational numbers in Julia Base (MIT license)
# https://github.com/JuliaLang/julia/blob/52bafeb981bac548afd2264edb518d8d86944dca/test/rational.jl
# https://github.com/JuliaLang/julia/blob/52bafeb981bac548afd2264edb518d8d86944dca/LICENSE.md
@testset "Ordering" begin
  for a in -5:5, b in -5:5, c in -5:5
    # a == b == 0 && continue
    b == 0 && continue

    r = RationalNumber(a, b)

    @test (r == c) == (a / b == c)
    @test (r != c) == (a / b != c)
    @test (r ≤ c) == (a / b ≤ c)
    @test (r < c) == (a / b < c)
    @test (r ≥ c) == (a / b ≥ c)
    @test (r > c) == (a / b > c)

    for d in -5:5
      # c == d == 0 && continue
      d == 0 && continue

      s = RationalNumber(c, d)

      @test (r == s) == (a / b == c / d)
      @test (r != s) == (a / b != c / d)
      @test (r <= s) == (a / b <= c / d)
      @test (r <  s) == (a / b <  c / d)
      @test (r >= s) == (a / b >= c / d)
      @test (r >  s) == (a / b >  c / d)
    end
  end
end

@testset "Showing RationalNumbers" begin
  @test sprint(show, RationalNumber(23, 42)) == "23//42"
  @test sprint(show, RationalNumber(-2500, 5000)) == "-1//2"
end
