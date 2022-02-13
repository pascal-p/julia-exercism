using Test

include("high_scores.jl")

@testset "latest score" begin
  @test latest([100, 0, 90, 30]) == 30
  @test latest([40, 100, 70]) == 70

  @test_throws Exception latest([100, 0, -90, 30])
end

@testset "personal best" begin
  @test personal_best([40, 90, 70, 60, 50]) == 90
  @test personal_best( [10, 30, 90, 30, 100, 20, 10, 0, 30, 40, 40, 70, 70]) == 100

  @test_throws ArgumentError personal_best([])
  @test_throws ArgumentError personal_best(UInt[])
  @test_throws ArgumentError personal_best(Integer[])
end

@testset "personal top 3" begin
  @test personal_top_3([10, 30, 90, 30, 100, 20, 10, 0, 30, 40, 40, 70, 70]) == [100, 90, 70]
  @test personal_top_3([20, 10, 30]) == [30, 20, 10]
  @test personal_top_3([40, 20, 40, 30]) == [40, 40, 30]
  @test personal_top_3([30, 70]) == [70, 30]
  @test personal_top_3([40]) == [40]

  @test_throws ArgumentError personal_top_3([])
  @test_throws ArgumentError personal_top_3(UInt[])
end
