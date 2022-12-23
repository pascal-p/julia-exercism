using Base: default_color_error
using Test

include("rational-numbers.jl")

# import Base: ℯ

@test RationalNumber <: Real
@test_throws ArgumentError RationalNumber(0, 0)

@testset "One- & Zero-elements" begin
  @test zero(RationalNumber{Int}) == RationalNumber(0, 1)
  @test one(RationalNumber{Int})  == RationalNumber(1, 1)

  @test abs(one(RationalNumber{UInt})) === one(RationalNumber{UInt})
  @test abs(one(RationalNumber{Int})) === one(RationalNumber{Int})
  @test abs(-one(RationalNumber{Int})) === one(RationalNumber{Int})
end

@testset "Contructor on limit" begin
  @test RationalNumber(typemax(Int64), typemin(Int64)) == RationalNumber(Int128(typemax(Int64)) * -1, Int128(typemin(Int64)) * -1)

  @test RationalNumber(typemax(Int64), typemax(Int64)) == RationalNumber(1, 1)
  @test RationalNumber(typemax(Int128), typemax(Int128)) == RationalNumber(1, 1)
end

@testset "RationalNumber methods" begin
  rand_int = rand(Int8)

  for T in [Int8, Int16, Int32, Int128, BigInt]
    @test numerator(convert(T, rand_int)) == rand_int
    @test denominator(convert(T, rand_int)) == 1

    T == BigInt && continue  # BigInt typemin, typemax are NOT defined - Should I define them? side-effect of doing so?
    @test typemin(RationalNumber{T}) == RationalNumber(typemin(T), one(T))  # -one(T)//zero(T)
    @test typemax(RationalNumber{T}) == RationalNumber(typemax(T), one(T))  # one(T)//zero(T)
  end

  @test iszero(typemin(RationalNumber{UInt}))

  # @test RationalNumber(Float32(rand_int)) == RationalNumber(rand_int)
  @test RationalNumber(RationalNumber(rand_int)) == RationalNumber(rand_int)

  # @test begin
  #   var = -RationalNumber(UInt32(0))
  #   var == UInt32(0)
  # end

  # @test RationalNumber(rand_int, 3)/Complex(3, 2) == Complex(RationalNumber(rand_int, 13), -RationalNumber(rand_int*2, 39))
  # @test Complex(rand_int, 0) == RationalNumber(rand_int)
  # @test RationalNumber(rand_int) == Complex(rand_int, 0)

  # @test (Complex(rand_int, 4) == RationalNumber(rand_int)) == false
  # @test (RationalNumber(rand_int) == Complex(rand_int, 4)) == false

  # @test trunc(RationalNumber(BigInt(rand_int), BigInt(3))) == RationalNumber(trunc(BigInt, RationalNumber(BigInt(rand_int),BigInt(3))))
  # @test  ceil(RationalNumber(BigInt(rand_int), BigInt(3))) == RationalNumber( ceil(BigInt, RationalNumber(BigInt(rand_int),BigInt(3))))
  # @test round(RationalNumber(BigInt(rand_int), BigInt(3))) == RationalNumber(round(BigInt, RationalNumber(BigInt(rand_int),BigInt(3))))

  for a = -3:3
    # @test RationalNumber(Float32(a)) == RationalNumber(a)
    @test RationalNumber(a)//2 == a//2
    @test a//RationalNumber(2) == a//2 # RationalNumber(a, 2)
    @test a.//[-2, -1, 1, 2] == [-a//2, -a//1, a//1, a//2]
    # for b=-3:3, c=1:3
    #   @test b//(a+c*im) == b*a//(a^2+c^2)-(b*c//(a^2+c^2))*im
    #   for d=-3:3
    #     @test (a+b*im)//(c+d*im) == (a*c+b*d+(b*c-a*d)*im)//(c^2+d^2)
    #     @test Complex(RationalNumber(a)+b*im)//Complex(RationalNumber(c)+d*im) == Complex(a+b*im)//Complex(c+d*im)
    #   end
    # end
  end
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
    @testset "Exponentiation of a rational number with integer" begin
      @test RationalNumber( 1, 2)^3 == RationalNumber( 1, 8)
      @test RationalNumber(-1, 2)^3 == RationalNumber(-1, 8)
      @test RationalNumber( 0, 1)^5 == RationalNumber( 0, 1)
      @test RationalNumber( 1, 1)^4 == RationalNumber( 1, 1)
      @test RationalNumber( 1, 2)^0 == RationalNumber( 1, 1)
      @test RationalNumber(-1, 2)^0 == RationalNumber( 1, 1)

      @test_throws ArgumentError RationalNumber( 0, 10)^0
    end

    @testset "Exponentiation of a rational number with real" begin
      @test RationalNumber( 1, 2)^0.0 ≈ 1.0
      @test RationalNumber( 2, 3)^2.0 ≈ 0.4444444444444444
      @test RationalNumber( 2, 3)^2.1 ≈ 0.4267842225743191
      @test RationalNumber( 1, 10)^100.0 ≈ 1.0e-100

      @test_throws ArgumentError RationalNumber( 0, 1)^0.0 # undefined form
    end

    @testset "Exponentiation of a integer number to a rational number" begin
      @test 8^RationalNumber( 4, 3) ≈ 15.999999999999998
      @test 9^RationalNumber(-1, 2) ≈ 0.3333333333333333
      @test 2^RationalNumber( 0, 1) ≈ 1.0
      @test 2^RationalNumber( 1, 1) ≈ 2.0
      @test 100^RationalNumber( 2, 2) ≈ 100.0

      @test_throws ArgumentError 0^RationalNumber( 0, 1)
    end

    @testset "Exponentiation of a real number to a rational number" begin
      @test 8.0^RationalNumber( 4, 3) ≈ 15.999999999999998
      @test 9.0^RationalNumber(-1, 2) ≈ 0.3333333333333333
      @test 2.5^RationalNumber( 0, 1) ≈ 1.0
      @test 2.0^RationalNumber( 1, 1) ≈ 2.0
      @test 100.0^RationalNumber( 2, 2) ≈ 100.0
      @test 2.0^RationalNumber( -100, 3) ≈ 9.239890216664653e-11

      @test_throws ArgumentError 0.0^RationalNumber( 0, 1)
    end

    @testset "Exponentiation of an irrational to a rational number" begin
      @test ℯ^RationalNumber( 0, 1) ≈ 1.0
      @test (√2)^RationalNumber( 0, 1) ≈ 1.0
      @test (π)^RationalNumber( 0, 1) ≈ 1.0
      @test ℯ^RationalNumber( 1, 1) ≈ ℯ
      @test ℯ^RationalNumber( 2, 1) ≈ ℯ * ℯ

  # Test threw exception
  # Expression: ℯ ^ RationalNumber(0, 1) ≈ 1.0
  # MethodError: ^(::Irrational{:ℯ}, ::RationalNumber{Int64}) is ambiguous. Candidates:
  #   ^(x::Union{AbstractIrrational, AbstractFloat, Integer}, r::RationalNumber{T}) where T<:Integer in Main at /home/pascal/Projects/Exercism/julia/rational-numbers/rational-numbers.jl:266
  #   ^(::Irrational{:ℯ}, x::Number) in Base.MathConstants at mathconstants.jl:119
  # Possible fix, define
  #   ^(::Irrational{:ℯ}, ::RationalNumber{T}) where T<:Integer
    end
  end

  @testset "Division" begin
    @test RationalNumber( 1, 2) / RationalNumber( 2, 3) == RationalNumber( 3, 4)
    @test RationalNumber( 1, 2) / RationalNumber(-2, 3) == RationalNumber(-3, 4)
    @test RationalNumber(-1, 2) / RationalNumber(-2, 3) == RationalNumber( 3, 4)
    @test RationalNumber( 1, 2) / RationalNumber( 1, 1) == RationalNumber( 1, 2)

    @test_throws ArgumentError RationalNumber(1, 2) / RationalNumber(0, 3)


    @test RationalNumber( 1, 2) // RationalNumber( 2, 3) == RationalNumber( 3, 4)
    @test 3 // 4 == RationalNumber( 3, 4)

    @test 3 // RationalNumber( 3, 4) == RationalNumber(4, 1)
    @test RationalNumber( 3, 4) // 3 == RationalNumber(1, 4)
    @test RationalNumber( 0, 4) // 3 == RationalNumber(0, 1)

    @test_throws ArgumentError 3 // RationalNumber(0, 3)
  end
end

@testset "Absolute value" begin
  @test abs(RationalNumber( 1,  2)) == RationalNumber(1, 2)
  @test abs(RationalNumber(-1,  2)) == RationalNumber(1, 2)
  @test abs(RationalNumber( 0,  1)) == RationalNumber(0, 1)
  @test abs(RationalNumber( 1, -2)) == RationalNumber(1, 2)

  @test abs(RationalNumber(typemin(Int), 2)) == RationalNumber(div(typemax(Int), 2) + 1, 1)  # == RationalNumber(Int128(typemax(Int)) + 1, 2)
  @test abs(RationalNumber(typemin(Int), 1)) == RationalNumber(Int128(typemax(Int)) + 1, 1)

  @test abs(RationalNumber(mul_checked(2, typemin(Int)), 1)) == RationalNumber(mul_checked(add_checked(1, typemax(Int)), 2))
  # == 18446744073709551616//1
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

@testset "Relational Operators" begin
  @test RationalNumber(1, 6) ≠ RationalNumber(2, 3)
  @test RationalNumber(1, 6) < RationalNumber(2, 3)
  @test RationalNumber(2, 3) ≤ RationalNumber(2, 3)

  @test RationalNumber(2, 3) > RationalNumber(1, 6)
  @test RationalNumber(2, 3) ≥ RationalNumber(2, 3)
  @test RationalNumber(2, 3) == RationalNumber(2, 3)

  @test RationalNumber(Int128(typemax(Int)), typemin(Int)) == RationalNumber(Int128(typemax(Int)) << 1, Int128(typemin(Int)) << 1)
  # NOTE: typemin(Int) << 1 == 0!

  @test 1//1 == 1
  @test 2//2 == 1
  @test 1//1 == 1//1
  @test 2//2 == 1//1
  @test 2//4 == 3//6
  @test 1//2 + 1//2 == 1
  @test (-1)//3 == -(1//3)
  @test 1//2 + 3//4 == 5//4
  @test 1//3 * 3//4 == 1//4
  @test 1//2 / 3//4 == 2//3
  @test  (-1//2) // (-2//5) == 5//4
  @test (3 // 5) // (2 // 1) == 3//10

  @test_throws ArgumentError 1//0
  @test_throws ArgumentError 5//0
  @test_throws ArgumentError -1//0
  @test_throws ArgumentError -7//0
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

@testset "show and RationalNumbers" begin
  io = IOBuffer()
  r₁ = RationalNumber(1465, 8593)
  r₂ = RationalNumber(-4500, 9000)

  @test sprint(show, r₁) == "1465//8593"
  @test sprint(show, r₂) == "-1//2"

  let
    io1 = IOBuffer()
    write(io1, r₁)
    io1.ptr = 1
    @test read(io1, typeof(r₁)) == r₁

    io2 = IOBuffer()
    write(io2, r₂)
    io2.ptr = 1
    @test read(io2, typeof(r₂)) == r₂
  end

end
