using Test

include("rail-cipher.jl")

@testset "encode" begin
  @test encode("WEAREDISCOVEREDFLEEATONCE") == "WECRLTEERDSOEEFEAOCAIVDEN"

  @test encode("WEAREDISCOVEREDFLEEATONCE"; n=5) == "WCLEESOFECAIVDENRDEEAOERT"
  @test encode("THEDEVILISINTHEDETAILS"; n=5) == "TIEHLSDTEIIEADVNHISETL"

  @test encode("XOXOXOXOXOXOXOXOXO"; n=2) == "XXXXXXXXXOOOOOOOOO"
end

@testset "more cases" begin
  @test decode("WECRLTEERDSOEEFEAOCAIVDEN") == "WEAREDISCOVEREDFLEEATONCE"

  @test decode("WCLEESOFECAIVDENRDEEAOERT"; n=5) == "WEAREDISCOVEREDFLEEATONCE"
  @test decode("TIEHLSDTEIIEADVNHISETL"; n=5) == "THEDEVILISINTHEDETAILS"

  @test decode("XXXXXXXXXOOOOOOOOO"; n=2) == "XOXOXOXOXOXOXOXOXO"
end

@testset "Exception" begin
  @test_throws AssertionError encode("One rail, only one rail"; n=1) == "One rail, only one rail"
end

@testset "sequences" begin
  @test sequences(n = 2) == [(2, 0), (0, 2)]

  @test sequences(n = 4) == [(6, 0), (4, 2), (2, 4), (0, 6)]

  @test sequences(n = 5) == [(8, 0), (6, 2), (4, 4), (2, 6), (0, 8)]

  @test sequences(n = 3) == [(4, 0), (2, 2), (0, 4)]
end
