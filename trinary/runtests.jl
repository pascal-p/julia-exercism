using Test

include("trinary.jl")

@testset "trinary 0, 1, 2 is decimal 0, 1, 2" begin
  @test trinary_to_decimal("0") == 0
  @test trinary_to_decimal("1") == 1
  @test trinary_to_decimal("2") == 2

  @test trinary_to_decimal("00") == 0
  @test trinary_to_decimal("01") == 1
  @test trinary_to_decimal("02") == 2

  @test trinary_to_decimal("000") == 0
  @test trinary_to_decimal("001") == 1
  @test trinary_to_decimal("002") == 2
end

@testset "trinary empty string or string reducible to empty string is 0" begin
  @test trinary_to_decimal("000000000") == 0
  @test trinary_to_decimal("") == 0

  # @test trinary_to_decimal('') == 0  # ERROR: syntax: invalid empty character literal
  @test trinary_to_decimal('0') == 0
end

# TODO...

@testset "trinary 10, 20 is decimal 3, 6" begin
  @test trinary_to_decimal("10") == 3
  @test trinary_to_decimal("20") == 6
end

@testset "trinary 11 is decimal 4" begin
  @test trinary_to_decimal("11") == 4
end

@testset "trinary 100 is decimal 9" begin
  @test trinary_to_decimal("100") == 9
end

@testset "trinary 112 is decimal 14" begin
  @test trinary_to_decimal("112") == 14
end

@testset "trinary 222 is decimal 26" begin
  @test trinary_to_decimal("222") == 26
  @test trinary_to_decimal("000222") == 26
end

@testset "trinary 1122000120 is decimal 32091" begin
  @test trinary_to_decimal("1122000120") == 32091
end

@testset "trinary 333333333333333 is decimal 0" begin
  @test trinary_to_decimal("333333333333333") == 0
end

@testset "trinary 222222222222222 is decimal 14348906" begin
  @test trinary_to_decimal("222222222222222") == 14348906
end

@testset "trinary 22222222222222200000111112222222222 is decimal 50031541619419283" begin
  @test trinary_to_decimal("22222222222222200000111112222222222") == 50031541619419283
end

@testset "invalid trinary digits returns 0" begin
  @test trinary_to_decimal("1234") == 0
end

@testset "invalid word as input returns 0" begin
  @test trinary_to_decimal("carrot") == 0
end

@testset "invalid numbers with letters/symbols as input returns 0" begin
  @test trinary_to_decimal("0a1b2c") == 0

  @test trinary_to_decimal("-112") == 0
end
