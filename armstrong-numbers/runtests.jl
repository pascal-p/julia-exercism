# canonical data version: 1.0.0

using Test
using Random

include("armstrong-numbers.jl")

ARY = [1, 2, 3, 4, 5, 6, 7, 8, 9, 153, 370, 371, 407, 1634, 8208, 9474, 54748, 92727, 93084,
       548834, 1741725, 4210818, 9800817, 9926315, 24678050, 24678051, 88593477, 146511208,
       472335975, 534494836, 912985153, 4679307774, 32164049650, 32164049651,
       # BigInt, actually Int128
       3706907995955475988644381, 19008174136254279995012734741, 186709961001538790100634132976991,
       115132219018763992565095597973971522401]

@testset "armstrong numbers" begin
  # @test  isarmstrong(5)
  # @test  isarmstrong(9474)
  # @test  isarmstrong(9926315)

  for ix in randperm(length(ARY))
    @test isarmstrong(ARY[ix])
  end
end

@testset "NON- armstrong numbers" begin
  @test !isarmstrong(10)
  @test !isarmstrong(100)
  @test !isarmstrong(9475)
  @test !isarmstrong(9926314)
  @test !isarmstrong(147808829414345923316083210206383297601)
  @test !isarmstrong(147808829414345923316083210206383297601001)
end
