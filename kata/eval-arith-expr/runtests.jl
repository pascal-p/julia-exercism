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
end

@testset "arithmetic evaluation special casses" begin
end

@testset "exception" begin
  @test_throws ArgumentError parseexpr(" -2* - 1 + 3")
  @test_throws ArgumentError parseexpr(" -2* -1 + - 3")
  @test_throws ArgumentError parseexpr(" 1- - 1")
end
