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


@testset "grouping" begin
  act, exp = grouping("HFNIMVOSNA", 6), ByteMatrix([['H', 'O'], ['F', 'S'], ['N', 'N'], ['I', 'A'], ['M'], ['V']], 0x0000000000000006)
  @test act.matrix == exp.matrix && act.size == exp.size

  act, exp = grouping("GHZOIYGHJOCB", 2), ByteMatrix([['G', 'Z', 'I', 'G', 'J', 'C'], ['H', 'O', 'Y', 'H', 'O', 'B']], 0x0000000000000002)
  @test act.matrix == exp.matrix && act.size == exp.size

  act, exp = grouping("EPSDFQQXMZCJYNCKUCACDWJRCBVRWINLOWU", 4), ByteMatrix([['E', 'F', 'M', 'Y', 'U', 'D', 'C', 'W', 'O'], ['P', 'Q', 'Z', 'N', 'C', 'W', 'B', 'I', 'W'], ['S', 'Q', 'C', 'C', 'A', 'J', 'V', 'N', 'U'], ['D', 'X', 'J', 'K', 'C', 'R', 'R', 'L']], 0x0000000000000004)
  @test act.matrix == exp.matrix && act.size == exp.size
end
