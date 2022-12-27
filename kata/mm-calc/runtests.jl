using Test

include("mm-calc.jl")

@testset "base cases" begin
  @test calc(1, 2, "+") == 3
  @test calc(0, 0, "-") === 0
  @test calc(6, 7, "*") === 42
  @test calc(5, 4, "%") === 1
  @test isnan(calc(9, 0, "/"))
end
