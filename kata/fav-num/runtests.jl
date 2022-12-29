using Test

include("fav-num.jl")

@testset "base cases" begin
  @test decompose(34) ∈ [(0, 6, 28), (3, 10, 21), (0, 3, 7)]

  @test decompose(69) ∈ [(0, 2, 11)]
  @test decompose(68) ∈ [(2, 4, 10)]
  @test decompose(67) ∈ [(0, 1, 11)]
  @test decompose(66) ∈ [(1, 4, 10)]
  @test decompose(65) ∈ [(0, 4, 10)]

  @test decompose(10_000_0000) ∈ [(12, 133, 14141)]

  @test decompose(100_000_0000) ∈ [(18, 1332, 44701)]

  @test decompose(100_000_000_000) ∈ [(44, 2690, 447205)]
  @test decompose(1_000_000_000_000_000_000) ∈ [(1518, 1693417, 1414212548)]
end
