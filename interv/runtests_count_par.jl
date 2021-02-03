using Test

include("./count_par.jl")

@testset "count_parentheses 3" begin
  @test count_par(3) == 5
end

@testset "count_parentheses 3 with expr" begin
  @test count_par(3; count_only=false) == (5, ["((()))", "(()())", "(())()", "()(())", "()()()"])
end

@testset "count_parentheses 4" begin
  @test count_par(4) == 14
end

@testset "count_parentheses 4 with expr" begin
  @test count_par(4; count_only=false) == (14, ["(((())))", "((()()))", "((())())", "((()))()", "(()(()))", "(()()())", "(()())()", "(())(())", "(())()()", "()((()))", "()(()())", "()(())()", "()()(())", "()()()()"])
end

@testset "count_parentheses 4" begin
  @test count_par(5) == 42
end

@testset "count_parentheses 10" begin
  @test count_par(10) == 16796
  # 0.000292 seconds
end

@testset "count_parentheses 20" begin
  @test count_par(20) == 6_564_120_420
  # 0.000292 seconds

  ## @time count_par(13)
  ## 0.012796 seconds
  ## 742900

  ## @time count_par(15)
  ## 0.181031 seconds
  ## 9_694_845

  ## @time count_par(16)
  ## 0.656198 seconds
  ## 35_357_670

  ## @time count_par(17)
  ## 2.530178 seconds
  ## 129_644_790

  ## @time count_par(18)
  ##  8.900670 seconds
  ## 477_638_700

  ## rough estimate for  19:    33s (4×),            2_000_000_000
  ## rough estimate for  20:   132s (4×),            8_000_000_000
  ## rough estimate for  20:   132s (4×),            8_000_000_000
  ## rough estimate for  21:   528s (4×),           32_000_000_000
  ## rough estimate for  22:  2112s (4×),          128_000_000_000
  ## rough estimate for  23:  8448s (4×),          512_000_000_000
  ## rough estimate for  25: 33792s (4×),        1_024_000_000_000 > 9h
  
  ## @time count_par(19)
  ## 31.316739 seconds
  ##  1_767_263_190

  ## @time count_par(20)
  ## 122.574722 seconds
  ##  6_564_120_420
  
  ## @time count_par(21)
  ## 458.700420 seconds
  ## 24_466_267_020

  ## @time count_par(22)
  ## 1654.778212 seconds
  ## 91_482_563_640

end

# OOOppps 
#@testset "count_parentheses 100" begin
#  #
#  @test count_par(100) == 16796
#end
