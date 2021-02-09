using Test

include("./staircase.jl")

@testset "base cases / counting only" begin

  @test count_staircase(0) == 0
  @test count_staircase(1) == 1
  @test count_staircase(2) == 2
  @test count_staircase(3) == 4

end

@testset "non trivial cases / counting only" begin
  @test count_staircase(4) == 7
  @test count_staircase(5) == 13
  @test count_staircase(10) == 274
  @test count_staircase(20) == 121415
end

@testset "DP counting only - timing, n = 30" begin
  @time @test count_staircase(30) == 53_798_080
end

@testset "DP counting only - timing, n = 40" begin
  @time @test count_staircase(40) == 23_837_527_729
end

@testset "DP counting only - timing, n = 41" begin
  @time @test count_staircase(41) == 43_844_049_029
end

@testset "DP counting only - timing, n = 42" begin
  @time @test count_staircase(42) == 80_641_778_674
end

@testset "DP counting only - timing, n = 50" begin
  @time @test count_staircase(50) == 10_562_230_626_642
end

@testset "DP counting only - timing, n = 70" begin
  @time @test count_staircase(70) == 2_073_693_258_389_777_176
end

@testset "DP counting only - timing, n = 100" begin
  @time @test count_staircase(100) == 7_367_864_567_128_947_527
end

@testset "DP counting only - timing, n = 1000" begin
  @time @test count_staircase(1000) == 4_581_582_011_488_623_345
end


@testset "counting and progression n=4" begin
  @test staircase(4) == (7, [[1, 1, 1, 1], [1, 1, 2], [1, 2, 1], [1, 3], [2, 1, 1], [2, 2], [3, 1]])
end

@testset "counting and progression n=5" begin
  @test staircase(5) == (13,
                         [[1, 1, 1, 1, 1], [1, 1, 1, 2], [1, 1, 2, 1], [1, 1, 3],
                          [1, 2, 1, 1], [1, 2, 2], [1, 3, 1], [2, 1, 1, 1], [2, 1, 2],
                          [2, 2, 1], [2, 3], [3, 1, 1], [3, 2]])
end

@testset "counting and progression n=10" begin
  @test staircase(10) == (274,
                          [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 2], [1, 1, 1, 1, 1, 1, 1, 2, 1], [1, 1, 1, 1, 1, 1, 1, 3], [1, 1, 1, 1, 1, 1, 2, 1, 1], [1, 1, 1, 1, 1, 1, 2, 2], [1, 1, 1, 1, 1, 1, 3, 1], [1, 1, 1, 1, 1, 2, 1, 1, 1], [1, 1, 1, 1, 1, 2, 1, 2], [1, 1, 1, 1, 1, 2, 2, 1], [1, 1, 1, 1, 1, 2, 3], [1, 1, 1, 1, 1, 3, 1, 1], [1, 1, 1, 1, 1, 3, 2], [1, 1, 1, 1, 2, 1, 1, 1, 1], [1, 1, 1, 1, 2, 1, 1, 2], [1, 1, 1, 1, 2, 1, 2, 1], [1, 1, 1, 1, 2, 1, 3], [1, 1, 1, 1, 2, 2, 1, 1], [1, 1, 1, 1, 2, 2, 2], [1, 1, 1, 1, 2, 3, 1], [1, 1, 1, 1, 3, 1, 1, 1], [1, 1, 1, 1, 3, 1, 2], [1, 1, 1, 1, 3, 2, 1], [1, 1, 1, 1, 3, 3], [1, 1, 1, 2, 1, 1, 1, 1, 1], [1, 1, 1, 2, 1, 1, 1, 2], [1, 1, 1, 2, 1, 1, 2, 1], [1, 1, 1, 2, 1, 1, 3], [1, 1, 1, 2, 1, 2, 1, 1], [1, 1, 1, 2, 1, 2, 2], [1, 1, 1, 2, 1, 3, 1], [1, 1, 1, 2, 2, 1, 1, 1], [1, 1, 1, 2, 2, 1, 2], [1, 1, 1, 2, 2, 2, 1], [1, 1, 1, 2, 2, 3], [1, 1, 1, 2, 3, 1, 1], [1, 1, 1, 2, 3, 2], [1, 1, 1, 3, 1, 1, 1, 1], [1, 1, 1, 3, 1, 1, 2], [1, 1, 1, 3, 1, 2, 1], [1, 1, 1, 3, 1, 3], [1, 1, 1, 3, 2, 1, 1], [1, 1, 1, 3, 2, 2], [1, 1, 1, 3, 3, 1], [1, 1, 2, 1, 1, 1, 1, 1, 1], [1, 1, 2, 1, 1, 1, 1, 2], [1, 1, 2, 1, 1, 1, 2, 1], [1, 1, 2, 1, 1, 1, 3], [1, 1, 2, 1, 1, 2, 1, 1], [1, 1, 2, 1, 1, 2, 2], [1, 1, 2, 1, 1, 3, 1], [1, 1, 2, 1, 2, 1, 1, 1], [1, 1, 2, 1, 2, 1, 2], [1, 1, 2, 1, 2, 2, 1], [1, 1, 2, 1, 2, 3], [1, 1, 2, 1, 3, 1, 1], [1, 1, 2, 1, 3, 2], [1, 1, 2, 2, 1, 1, 1, 1], [1, 1, 2, 2, 1, 1, 2], [1, 1, 2, 2, 1, 2, 1], [1, 1, 2, 2, 1, 3], [1, 1, 2, 2, 2, 1, 1], [1, 1, 2, 2, 2, 2], [1, 1, 2, 2, 3, 1], [1, 1, 2, 3, 1, 1, 1], [1, 1, 2, 3, 1, 2], [1, 1, 2, 3, 2, 1], [1, 1, 2, 3, 3], [1, 1, 3, 1, 1, 1, 1, 1], [1, 1, 3, 1, 1, 1, 2], [1, 1, 3, 1, 1, 2, 1], [1, 1, 3, 1, 1, 3], [1, 1, 3, 1, 2, 1, 1], [1, 1, 3, 1, 2, 2], [1, 1, 3, 1, 3, 1], [1, 1, 3, 2, 1, 1, 1], [1, 1, 3, 2, 1, 2], [1, 1, 3, 2, 2, 1], [1, 1, 3, 2, 3], [1, 1, 3, 3, 1, 1], [1, 1, 3, 3, 2], [1, 2, 1, 1, 1, 1, 1, 1, 1], [1, 2, 1, 1, 1, 1, 1, 2], [1, 2, 1, 1, 1, 1, 2, 1], [1, 2, 1, 1, 1, 1, 3], [1, 2, 1, 1, 1, 2, 1, 1], [1, 2, 1, 1, 1, 2, 2], [1, 2, 1, 1, 1, 3, 1], [1, 2, 1, 1, 2, 1, 1, 1], [1, 2, 1, 1, 2, 1, 2], [1, 2, 1, 1, 2, 2, 1], [1, 2, 1, 1, 2, 3], [1, 2, 1, 1, 3, 1, 1], [1, 2, 1, 1, 3, 2], [1, 2, 1, 2, 1, 1, 1, 1], [1, 2, 1, 2, 1, 1, 2], [1, 2, 1, 2, 1, 2, 1], [1, 2, 1, 2, 1, 3], [1, 2, 1, 2, 2, 1, 1], [1, 2, 1, 2, 2, 2], [1, 2, 1, 2, 3, 1], [1, 2, 1, 3, 1, 1, 1], [1, 2, 1, 3, 1, 2], [1, 2, 1, 3, 2, 1], [1, 2, 1, 3, 3], [1, 2, 2, 1, 1, 1, 1, 1], [1, 2, 2, 1, 1, 1, 2], [1, 2, 2, 1, 1, 2, 1], [1, 2, 2, 1, 1, 3], [1, 2, 2, 1, 2, 1, 1], [1, 2, 2, 1, 2, 2], [1, 2, 2, 1, 3, 1], [1, 2, 2, 2, 1, 1, 1], [1, 2, 2, 2, 1, 2], [1, 2, 2, 2, 2, 1], [1, 2, 2, 2, 3], [1, 2, 2, 3, 1, 1], [1, 2, 2, 3, 2], [1, 2, 3, 1, 1, 1, 1], [1, 2, 3, 1, 1, 2], [1, 2, 3, 1, 2, 1], [1, 2, 3, 1, 3], [1, 2, 3, 2, 1, 1], [1, 2, 3, 2, 2], [1, 2, 3, 3, 1], [1, 3, 1, 1, 1, 1, 1, 1], [1, 3, 1, 1, 1, 1, 2], [1, 3, 1, 1, 1, 2, 1], [1, 3, 1, 1, 1, 3], [1, 3, 1, 1, 2, 1, 1], [1, 3, 1, 1, 2, 2], [1, 3, 1, 1, 3, 1], [1, 3, 1, 2, 1, 1, 1], [1, 3, 1, 2, 1, 2], [1, 3, 1, 2, 2, 1], [1, 3, 1, 2, 3], [1, 3, 1, 3, 1, 1], [1, 3, 1, 3, 2], [1, 3, 2, 1, 1, 1, 1], [1, 3, 2, 1, 1, 2], [1, 3, 2, 1, 2, 1], [1, 3, 2, 1, 3], [1, 3, 2, 2, 1, 1], [1, 3, 2, 2, 2], [1, 3, 2, 3, 1], [1, 3, 3, 1, 1, 1], [1, 3, 3, 1, 2], [1, 3, 3, 2, 1], [1, 3, 3, 3], [2, 1, 1, 1, 1, 1, 1, 1, 1], [2, 1, 1, 1, 1, 1, 1, 2], [2, 1, 1, 1, 1, 1, 2, 1], [2, 1, 1, 1, 1, 1, 3], [2, 1, 1, 1, 1, 2, 1, 1], [2, 1, 1, 1, 1, 2, 2], [2, 1, 1, 1, 1, 3, 1], [2, 1, 1, 1, 2, 1, 1, 1], [2, 1, 1, 1, 2, 1, 2], [2, 1, 1, 1, 2, 2, 1], [2, 1, 1, 1, 2, 3], [2, 1, 1, 1, 3, 1, 1], [2, 1, 1, 1, 3, 2], [2, 1, 1, 2, 1, 1, 1, 1], [2, 1, 1, 2, 1, 1, 2], [2, 1, 1, 2, 1, 2, 1], [2, 1, 1, 2, 1, 3], [2, 1, 1, 2, 2, 1, 1], [2, 1, 1, 2, 2, 2], [2, 1, 1, 2, 3, 1], [2, 1, 1, 3, 1, 1, 1], [2, 1, 1, 3, 1, 2], [2, 1, 1, 3, 2, 1], [2, 1, 1, 3, 3], [2, 1, 2, 1, 1, 1, 1, 1], [2, 1, 2, 1, 1, 1, 2], [2, 1, 2, 1, 1, 2, 1], [2, 1, 2, 1, 1, 3], [2, 1, 2, 1, 2, 1, 1], [2, 1, 2, 1, 2, 2], [2, 1, 2, 1, 3, 1], [2, 1, 2, 2, 1, 1, 1], [2, 1, 2, 2, 1, 2], [2, 1, 2, 2, 2, 1], [2, 1, 2, 2, 3], [2, 1, 2, 3, 1, 1], [2, 1, 2, 3, 2], [2, 1, 3, 1, 1, 1, 1], [2, 1, 3, 1, 1, 2], [2, 1, 3, 1, 2, 1], [2, 1, 3, 1, 3], [2, 1, 3, 2, 1, 1], [2, 1, 3, 2, 2], [2, 1, 3, 3, 1], [2, 2, 1, 1, 1, 1, 1, 1], [2, 2, 1, 1, 1, 1, 2], [2, 2, 1, 1, 1, 2, 1], [2, 2, 1, 1, 1, 3], [2, 2, 1, 1, 2, 1, 1], [2, 2, 1, 1, 2, 2], [2, 2, 1, 1, 3, 1], [2, 2, 1, 2, 1, 1, 1], [2, 2, 1, 2, 1, 2], [2, 2, 1, 2, 2, 1], [2, 2, 1, 2, 3], [2, 2, 1, 3, 1, 1], [2, 2, 1, 3, 2], [2, 2, 2, 1, 1, 1, 1], [2, 2, 2, 1, 1, 2], [2, 2, 2, 1, 2, 1], [2, 2, 2, 1, 3], [2, 2, 2, 2, 1, 1], [2, 2, 2, 2, 2], [2, 2, 2, 3, 1], [2, 2, 3, 1, 1, 1], [2, 2, 3, 1, 2], [2, 2, 3, 2, 1], [2, 2, 3, 3], [2, 3, 1, 1, 1, 1, 1], [2, 3, 1, 1, 1, 2], [2, 3, 1, 1, 2, 1], [2, 3, 1, 1, 3], [2, 3, 1, 2, 1, 1], [2, 3, 1, 2, 2], [2, 3, 1, 3, 1], [2, 3, 2, 1, 1, 1], [2, 3, 2, 1, 2], [2, 3, 2, 2, 1], [2, 3, 2, 3], [2, 3, 3, 1, 1], [2, 3, 3, 2], [3, 1, 1, 1, 1, 1, 1, 1], [3, 1, 1, 1, 1, 1, 2], [3, 1, 1, 1, 1, 2, 1], [3, 1, 1, 1, 1, 3], [3, 1, 1, 1, 2, 1, 1], [3, 1, 1, 1, 2, 2], [3, 1, 1, 1, 3, 1], [3, 1, 1, 2, 1, 1, 1], [3, 1, 1, 2, 1, 2], [3, 1, 1, 2, 2, 1], [3, 1, 1, 2, 3], [3, 1, 1, 3, 1, 1], [3, 1, 1, 3, 2], [3, 1, 2, 1, 1, 1, 1], [3, 1, 2, 1, 1, 2], [3, 1, 2, 1, 2, 1], [3, 1, 2, 1, 3], [3, 1, 2, 2, 1, 1], [3, 1, 2, 2, 2], [3, 1, 2, 3, 1], [3, 1, 3, 1, 1, 1], [3, 1, 3, 1, 2], [3, 1, 3, 2, 1], [3, 1, 3, 3], [3, 2, 1, 1, 1, 1, 1], [3, 2, 1, 1, 1, 2], [3, 2, 1, 1, 2, 1], [3, 2, 1, 1, 3], [3, 2, 1, 2, 1, 1], [3, 2, 1, 2, 2], [3, 2, 1, 3, 1], [3, 2, 2, 1, 1, 1], [3, 2, 2, 1, 2], [3, 2, 2, 2, 1], [3, 2, 2, 3], [3, 2, 3, 1, 1], [3, 2, 3, 2], [3, 3, 1, 1, 1, 1], [3, 3, 1, 1, 2], [3, 3, 1, 2, 1], [3, 3, 1, 3], [3, 3, 2, 1, 1], [3, 3, 2, 2], [3, 3, 3, 1]])
end

#
# @time count_staircase_bf(20)
#   0.000215 seconds
# 121415

# @time count_staircase_bf(30)
#   0.097066 seconds
# 53798080

# @time count_staircase_bf(40)
# 450.867903 seconds (88.65 M allocations: 1.321 GiB, 0.00% gc time)
# 23837527729

# @time count_staircase_dp(40)
#   0.024467 seconds (48.73 k allocations: 2.453 MiB)
# 23837527729

# @time count_staircase_dp(50)
#   0.000033 seconds (279 allocations: 10.797 KiB)
# 10562230626642

# @time count_staircase_dp(70)
#   0.000036 seconds (419 allocations: 12.984 KiB)
# 2073693258389777176

# @time count_staircase_dp(100)
#   0.000052 seconds (629 allocations: 16.266 KiB)
# 7367864567128947527

# @time count_staircase_dp(1000)
#  0.001122 seconds (9.87 k allocations: 246.203 KiB)
# 4581582011488623345