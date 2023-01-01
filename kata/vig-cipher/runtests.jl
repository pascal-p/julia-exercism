using Test

include("vig-cipher.jl")

@testset "encode" begin
  @test encode("HELLOWORLD", "ABCXYZ") == "HFNIMVOSNA"

  @test encode("THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG", "LION") == "EPSDFQQXMZCJYNCKUCACDWJRCBVRWINLOWU"
  @test encode("ATTACKATDAWN", "GO") == "GHZOIYGHJOCB"
end

@testset "more cases" begin
end

@testset "decode" begin
  @test decode("HFNIMVOSNA", "ABCXYZ") == "HELLOWORLD"

  @test decode("EPSDFQQXMZCJYNCKUCACDWJRCBVRWINLOWU", "LION") == "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG"
  @test decode("GHZOIYGHJOCB", "GO") == "ATTACKATDAWN"
end

@testset "decode ∘ encode ≡ id" begin
  @test decode(encode("WEAREDISCOVEREDFLEEATONCE", "FOOBAR"), "FOOBAR") == "WEAREDISCOVEREDFLEEATONCE"
end

@testset "complement" begin
  @test complement("FOO", 7) == "FOOFOOFOOF"
  @test complement("FOOBAR", 4) == "FOOBARFOOB"
  @test complement("ABRACADA", 2) == "ABRACADAAB"
  @test complement("ABRACADAB", 1) == "ABRACADABA"
end
