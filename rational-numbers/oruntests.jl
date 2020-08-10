using Test

include("rational-numbers.jl")

@testset "add_checked - signed integers" begin

  @testset "x > 0, y > 0 - no overflow Int64" begin
    @test add_checked(2, 3) == 5
    @test add_checked(100_000, 5_234) == 105_234
    @test add_checked(120_000, 180_000) == 300_000

    @test add_checked(100, typemax(Int) - 100) == typemax(Int)
    @test add_checked(typemax(Int) - 1000, 1000) == typemax(Int)
    @test add_checked(typemax(Int), 0) == typemax(Int)
  end

  @testset "x > 0, y > 0 - no overflow Int128" begin
    @test add_checked(Int128(typemax(Int)), 1000) == Int128(typemax(Int)) + 1000
    @test add_checked(Int128(typemin(Int)), -1000) == Int128(typemin(Int)) - 1000
  end

  @testset "x > 0, y > 0 - no overflow BigInt" begin
    @test add_checked(BigInt(typemax(Int128)), 1_000_000) == BigInt(typemax(Int128)) + 1_000_000

    @test add_checked(-10_000_000, BigInt(typemin(Int128))) == -10_000_000 + BigInt(typemin(Int128))
  end

  @testset "x < 0, y ≥ 0  || x ≥ 0, y < 0 - no overflow Int64" begin
    @test add_checked(2, -100) == -98
    @test add_checked(-100_000, 5_234) == -94_766
    @test add_checked(-120_000, 180_000) == 60_000

    @test add_checked(typemax(Int) - 1000, typemin(Int) + 1000) == -1
    @test add_checked(typemax(Int), typemin(Int) + 1000) == 1000 - 1
    @test add_checked(typemax(Int) - 1000, typemin(Int)) == -1001
  end

  @testset "x < 0, y ≥ 0  || x ≥ 0, y < 0 - no overflow Int128" begin
    # TODO
  end

  @testset "x < 0, y ≥ 0  || x ≥ 0, y < 0 - no overflow BigInt" begin
    # TODO
  end

  @testset "x > 0, y > 0 - with overflow Int64 -> Int128" begin
    @test add_checked(typemax(Int), 10) == Int128(typemax(Int)) + 10
    @test add_checked(1_000_000, typemax(Int)) == 1_000_000 + Int128(typemax(Int))
    @test typeof(add_checked(1_000_000, typemax(Int))) == Int128
  end

  @testset "x > 0, y > 0 - with overflow Int128 -> BigInt" begin
    @test add_checked(typemax(Int128), 10) == BigInt(typemax(Int128)) + 10
    @test add_checked(10, typemax(Int128)) == 10 + BigInt(typemax(Int128))
  end

  @testset "x ≤ 0, y ≤ 0 - with overflow Int64 -> Int128" begin
    @test add_checked(-1_000_000, typemin(Int)) == -1_000_000 + Int128(typemin(Int))
    @test add_checked(typemin(Int), -1) == Int128(typemin(Int)) - 1
  end

end

@testset "mul_checked - signed integers" begin

  @testset "x ≥ 0, y ≥ 0 || x ≤ 0 && y ≤ 0 - no overflow Int64" begin
    @test mul_checked(2, 3) == 6
    @test mul_checked(100_000, 5_234) == 523_400_000
    @test mul_checked(120_000, 180_000) == 216_00_000_000

    @test mul_checked(2, -3) == -6
    @test mul_checked(-100_000, 5_234) == -523_400_000

    @test mul_checked(-120_000, -180_000) == 216_00_000_000
  end

  @testset "x ≥ 0, y ≥ 0 || x ≤ 0 && y ≤ 0 - no overflow Int128" begin
    @test mul_checked(Int128(typemax(Int)), 1000) == Int128(typemax(Int)) * 1000
    @test mul_checked(Int128(typemin(Int)), -1000) == Int128(typemin(Int)) * -1000
  end

  @testset "x ≥ 0, y ≥ 0 || x ≤ 0 && y ≤ 0 - no overflow BigInt" begin
    @test mul_checked(BigInt(typemax(Int128)), 1_000_000) == BigInt(typemax(Int128)) * 1_000_000
    @test mul_checked(-10_000_000, BigInt(typemin(Int128))) == -10_000_000 * BigInt(typemin(Int128))
  end

  @testset "x ≥ 0, y ≥ 0 || x ≤ 0, y ≤ 0 - with overflow Int64 -> Int128" begin
    @test mul_checked(typemax(Int), 10) == Int128(typemax(Int)) * 10
    @test mul_checked(1_000, typemax(Int)) == 1_000 * Int128(typemax(Int))
    @test mul_checked(1_000_000_000, typemax(Int)) == 1_000_000_000 * Int128(typemax(Int))
    @test mul_checked(typemax(Int), 1_000_000_000) == Int128(typemax(Int)) * 1_000_000_000

    @test mul_checked(typemin(Int), typemax(Int)) == Int128(typemin(Int)) * Int128(typemax(Int))

    @test mul_checked(typemin(Int), typemin(Int)) == Int128(typemin(Int)) * Int128(typemin(Int))
    @test mul_checked(typemax(Int), typemax(Int)) == Int128(typemax(Int)) * Int128(typemax(Int))
    @test mul_checked(typemin(Int), typemin(Int)) > mul_checked(typemax(Int), typemax(Int))

    ## typemax = -(typemin + 1) ≡ typemax² = (-(typemin + 1))² ≡ typemax² = typemin² + 2 × typemin + 1
    @test mul_checked(typemax(Int), typemax(Int)) == add_checked(add_checked(mul_checked(typemin(Int), typemin(Int)), mul_checked(2, typemin(Int))), 1)

    @test typeof(mul_checked(1_000_000, typemax(Int))) == Int128
    @test typeof(mul_checked(typemax(Int), typemax(Int))) == Int128
  end

  @testset "x ≥ 0, y ≥ 0 || x ≤ 0, y ≤ 0 - with overflow Int128 -> BigInt" begin
    @test mul_checked(typemax(Int128), 10) == BigInt(typemax(Int128)) * 10
    @test mul_checked(1_000, typemax(Int128)) == 1_000 * BigInt(typemax(Int128))

    @test mul_checked(typemin(Int128), typemin(Int128)) == BigInt(typemin(Int128)) * BigInt(typemin(Int128))
    @test mul_checked(typemax(Int128), typemax(Int128)) == BigInt(typemax(Int128)) * BigInt(typemax(Int128))

    @test mul_checked(typemin(Int128), typemin(Int128)) > mul_checked(typemax(Int128), typemax(Int128))
    @test typeof(mul_checked(1_000, typemax(Int128))) == BigInt
  end

end

@testset "sub_checked - signed integers" begin

  @testset "x - y NO overflow Int64" begin
    @test sub_checked(-100, 10090) == -10190
    @test sub_checked(1000, 90) == 910

    @test sub_checked(typemin(Int), -1_000) == typemin(Int) + 1000
    @test sub_checked(typemin(Int), -1_000_000) == typemin(Int) + 1_000_000

    @test sub_checked(typemin(Int), -typemax(Int)) == -1

    @test sub_checked(typemin(Int128), -typemax(Int128)) == -1
  end


  @testset "x - y with overflow Int64" begin
    ##
    ## (-9223372036854775808 + 1000) - (9223372036854775807 - 1000) = 2001 => overflow, actual result:  -18446744073709549615
    ## Correct: Int128(-9223372036854775808 + 1000) - Int128(9223372036854775807 - 1000)
    ##          Int128(typemin(Int) + 1000) - Int128(typemax(Int) - 1000)
    @test sub_checked(-9223372036854774808, 9223372036854774807) == Int128(typemin(Int) + 1000) - Int128(typemax(Int) - 1000)
    @test sub_checked(typemin(Int) + 1000, typemax(Int) - 1000) == Int128(typemin(Int) + 1000) - Int128(typemax(Int) - 1000)

     @test sub_checked(typemin(Int) + 1000, (typemin(Int) + 1000) * -1) == 2 * Int128(typemin(Int) + 1000)

    ##
    ## (9223372036854775807 - 1000) - (-9223372036854775808 + 1000)  = 2001 => overflow, actual result: 18446744073709549615
    ## Correct: Int128(9223372036854775807 - 1000) - Int128(-9223372036854775808 + 1000)
    @test sub_checked(9223372036854774807, -9223372036854774808) == Int128(9223372036854775807) - Int128(-9223372036854775808) - 2000

    ## the same as above, note using - as no overflow expected!
    @test sub_checked(typemax(Int) - 1000, typemin(Int) + 1000) == Int128(typemax(Int)) - Int128(typemin(Int)) - 2000
  end

end
