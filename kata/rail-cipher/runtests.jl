using Test

include("rail-cipher.jl")

@testset "encode" begin
  @test encode("WEAREDISCOVEREDFLEEATONCE") == "WECRLTEERDSOEEFEAOCAIVDEN"

  @test encode("WEAREDISCOVEREDFLEEATONCE"; n=5) == "WCLEESOFECAIVDENRDEEAOERT"
  @test encode("THEDEVILISINTHEDETAILS"; n=5) == "TIEHLSDTEIIEADVNHISETL"

  @test encode("XOXOXOXOXOXOXOXOXO"; n=2) == "XXXXXXXXXOOOOOOOOO"

  @test encode("") == ""

  @test encode("WE ARE DISCOVERED FLEE AT ONCE!") == "WRIVDETCEAEDSOEE LEA NE  CRF O!"
  @test encode("The devil is in the details...", n=4) == "Tv eiheisih al.edlintdts.   e."
end

@testset "more cases" begin
  @test decode("WECRLTEERDSOEEFEAOCAIVDEN") == "WEAREDISCOVEREDFLEEATONCE"

  @test decode("WCLEESOFECAIVDENRDEEAOERT"; n=5) == "WEAREDISCOVEREDFLEEATONCE"
  @test decode("TIEHLSDTEIIEADVNHISETL"; n=5) == "THEDEVILISINTHEDETAILS"

  @test decode("XXXXXXXXXOOOOOOOOO"; n=2) == "XOXOXOXOXOXOXOXOXO"

  @test decode("WRIVDETCEAEDSOEE LEA NE  CRF O!") == "WE ARE DISCOVERED FLEE AT ONCE!"
  @test decode("Tv eiheisih al.edlintdts.   e.", n=4) == "The devil is in the details..."
end

@testset "decode ∘ encode ≡ id" begin
  @test (decode ∘ encode)("WEAREDISCOVEREDFLEEATONCE") == "WEAREDISCOVEREDFLEEATONCE"
  @test decode(encode("WEAREDISCOVEREDFLEEATONCE"; n=5); n=5) == "WEAREDISCOVEREDFLEEATONCE"
  @test decode(encode("XOXOXOXOXOXOXOXOXO"; n=2); n=2) == "XOXOXOXOXOXOXOXOXO"

  @test decode("133714114238148966225439541018335470986172518171757571896261", n=6) == "112358132134558914423337761098715972584418167651094617711286"
end

@testset "encode with less letters than rails" begin
  @test encode("More rails than letters"; n=24) == "More rails than letters"
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
