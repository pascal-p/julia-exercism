using Test

include("luhn.jl")

@testset "invalid" begin
  @testset "single digit strings can not be valid" begin
    @test !luhn("1")
  end

  @testset "A single zero (or zero with space) is invalid" begin
    @test !luhn("0")

    @test !luhn(" 0")

    @test !luhn("0 ")
  end

  @testset "invalid Canadian SIN" begin
    @test !luhn("046 454 287")
  end

  @testset "invalid credit card" begin
    @test !luhn("8273 1232 7352 0569")
  end

  @testset "valid strings with a non-digit or punctuation added become invalid" begin
    @test !luhn("046a 454 286")

    @test !luhn("055-444-285")

    @test !luhn("055# 444\$ 285")

    @test !luhn("09:")
  end
end

@testset "valid" begin

  @testset "valid Canadian SIN" begin
    @test luhn("046 454 286")

    @test luhn("055 444 285")
  end

  @testset "valid Credit Card or Sequence" begin
    @test luhn("4539 3195 0343 6467")

    @test luhn("4539319503436467")

    @test luhn("8273 1232 7352 0869")

    @test luhn("234 567 891 234")

    @test luhn("059")

    @test luhn("59")

    @test luhn("091")

    @test luhn("0000 0")
  end

end
