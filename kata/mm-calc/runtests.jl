using Base: end_base_include
using Test

include("mm-calc.jl")

@testset "base cases" begin
  @test calc(1, 2, "+") == 3
  @test calc(5000, 5000, "+") == 10000

  @test calc(0, 0, "-") == 0
  @test calc(6, 0, "-") == 6
  @test calc(7, 2, "-") == 5
  @test calc(2, 7, "-") == -5

  @test calc(6, 7, "*") == 42
  @test calc(5000, 5000, "*") == 25_000_000


  @test calc(7, 2, "/") ≈ 3.5
  @test calc(10, 3, "/") ≈ 3.33
  @test isnan(calc(9, 0, "/"))

  @test isnan(calc(9, 0, "%"))
  @test calc(5, 4, "%") == 1
  @test calc(5, 5, "%") == 0
  for i ∈ 0:7
    @test calc(8+i, 8, "%") |> Integer == i
  end
end

@testset "" begin
  @test calc(2, 3, "^") == 8
  @test calc(2, 10, "^") == 1024
  @test isnan(calc(0, 0, "^"))

  # exception:
  # @test calc(5000, 3, "^") == 9765625000000000000000000000000000000
  @test_throws ArgumentError calc(5000, 3, "^")
end

@testset "lesser" begin
  @test !lesser(5, 3)
  @test !lesser(5, 5)
  @test lesser(3, 5)
end

@testset "other exceptions" begin
  @test_throws AssertionError calc(-10, 1, "+")
  @test_throws AssertionError calc(-1, 10, "+")
  @test_throws AssertionError calc(-10, -2, "-")

  @test_throws AssertionError calc(5001, 2, "-")

  @test_throws ArgumentError calc(200, 12, "⋇")
end
