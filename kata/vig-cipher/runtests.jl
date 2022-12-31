using Test

include("vig-cipher.jl")

@testset "encode" begin
  @test encode("HELLOWORLD", "ABCXYZ") == "HFNIMVOSNA"

end

@testset "more cases" begin
end

@testset "decode" begin
  @test decode("HFNIMVOSNA", "ABCXYZ") == "HELLOWORLD"

end

@testset "decode ∘ encode ≡ id" begin
  # @test (decode ∘ encode)("WEAREDISCOVEREDFLEEATONCE") == "WEAREDISCOVEREDFLEEATONCE"
end

@testset "complement" begin
  @test complement("FOO", 7, 3) == "FOOFOOFOOF"
  @test complement("FOOBAR", 4, 6) == "FOOBARFOOB"
  @test complement("ABRACADA", 2, 8) == "ABRACADAAB"
  @test complement("ABRACADAB", 1, 9) == "ABRACADABA"
end
