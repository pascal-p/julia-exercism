using Test

include("eval-arith-expr.jl")

@testset "arithmetic evaluation base cases" begin
  @test parseexpr(" 1 - 1 ") == 0
  @test parseexpr(" 2 - 1 ") == 1
  @test parseexpr(" 2 + 1 ") == 3
  @test parseexpr(" 2 * 1") == 2

  @test parseexpr(" 2* -1 + -3") == -5
  @test parseexpr(" 2* 1 + -3") == -1
  @test parseexpr(" -2* 1 + -3") == -5
  @test parseexpr(" -2* 1 + 3") == 1
  @test parseexpr(" -2* -1 + 3") == 5

  @test parseexpr("2 * 5 * -3 * 7 + -2") == -212

  @test parseexpr("2 + 3 * 4") == 20 # evaluation uses left associativity (of the operators)
  @test parseexpr("2 * 3 + 4") == 10 # evaluation uses left associativity (of the operators)
end

@testset "arithmetic evaluation with decimal" begin
  @test parseexpr(" -2.* -1. + 3.") == 5.0f0

  @test parseexpr(" -2.0* -1.0 + 3.0") == 5.0f0
  @test parseexpr(" 2.1* 1.2 + -3.1") ≈ -0.58f0
  @test parseexpr("2.00001* 1.00002 + -3.00001") ≈ -0.9999599998f0
  @test parseexpr("2.1* 1.5 + -3.4") ≈ -0.25f0
  @test parseexpr("2.1 * 1.5 + -3.4 + 7.1 - 2.89") ≈ 3.96f0
  @test parseexpr("   2.1 *       1.5  * -3.4 * 7.1 *  2.89 ") ≈ -219.7585f0
  @test parseexpr("   2.1 *       1.5  * -3.4 * 7.1 *  -2.89   ") ≈ 219.7585f0

  @test parseexpr(" 5 / 2") == 2.5f0
  @test parseexpr(" 5 / 2.") == 2.5f0
  @test parseexpr(" 5. / 2.") == 2.5f0
  @test parseexpr(" -5. / 2.") == -2.5f0
  @test parseexpr(" 5. / -2.") == -2.5f0
end

@testset "parenthesized arithmetic evaluation" begin
  @test parseexpr("2 * (1 + 3)") == 8
  @test parseexpr("( 1 - 1 )") == 0
  @test parseexpr("2 * (1 + 3 + -2)") == 4
  @test parseexpr("2 * (1 + 3 + -2) - 2") == 2
  @test parseexpr("2 * (1 + 3 + -2) - (2 + 2)") == 0

  @test parseexpr("2 * (1 + (3 * -2))") == -10
  @test parseexpr("2 * (1 + (3 * -2) + 2)") == -6
  @test parseexpr("2 * (1 + (3 * -2) + 2) + 6") == 0

  @test parseexpr("2. * (1 + (3. * -2) + 2) + 6") == 0.0f0
  @test parseexpr("2. * (1 + (3 * -2) + 2.)") == -6.0f0

  # associativity is left to right
  @test parseexpr("2 * (2 * -3 * 7 + -4)") == -92  # inside parentheses left to right rule applies (unless modified by another set of parentheses)

  @test parseexpr("2.1 * (1.5 * -3.4 * 7.1 + -2.89)") ≈ -82.11f0
  @test parseexpr("   2.1 *      ( 1.5  * -3.4 * 7.1 + -2.89 )  ") ≈ -82.11f0

  @test parseexpr("2 + (3 * 4)") == 14 # change default left to right assoc rules
  @test parseexpr("(2 + 3) * 4") == 20 # left to right assoc rule -> parentheses needless
end

@testset "exception" begin
  @test_throws ArgumentError parseexpr(" -2* - 1 + 3")
  @test_throws ArgumentError parseexpr(" -2* -1 + - 3")
  @test_throws ArgumentError parseexpr(" 1- - 1")
  @test_throws ArgumentError parseexpr("- 1- - 1 ")
  @test_throws ArgumentError parseexpr("- 6 + - (4)")
  @test_throws ArgumentError parseexpr("- 6 + -(- 4)")
  @test_throws DivideError parseexpr(" 1 / 0")
  @test_throws DivideError parseexpr(" 1 / 0.")
end
