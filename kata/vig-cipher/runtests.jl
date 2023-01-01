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


@testset "split by group" begin
  act, exp = splitbygroup("HFNIMVOSNA", 6), CharMatrix([['H', 'O'], ['F', 'S'], ['N', 'N'], ['I', 'A'], ['M'], ['V']], 0x0000000000000006)
  @test act.matrix == exp.matrix && act.size == exp.size

  act, exp = splitbygroup("GHZOIYGHJOCB", 2), CharMatrix([['G', 'Z', 'I', 'G', 'J', 'C'], ['H', 'O', 'Y', 'H', 'O', 'B']], 0x0000000000000002)
  @test act.matrix == exp.matrix && act.size == exp.size

  act, exp = splitbygroup("EPSDFQQXMZCJYNCKUCACDWJRCBVRWINLOWU", 4), CharMatrix([['E', 'F', 'M', 'Y', 'U', 'D', 'C', 'W', 'O'], ['P', 'Q', 'Z', 'N', 'C', 'W', 'B', 'I', 'W'], ['S', 'Q', 'C', 'C', 'A', 'J', 'V', 'N', 'U'], ['D', 'X', 'J', 'K', 'C', 'R', 'R', 'L']], 0x0000000000000004)
  @test act.matrix == exp.matrix && act.size == exp.size
end

@testset "re-assemble" begin
  @test joinfromgroup(CharMatrix([['H', 'O'], ['F', 'S'], ['N', 'N'], ['I', 'A'], ['M'], ['V']], 0x0000000000000006)) == "HFNIMVOSNA"

  @test joinfromgroup(CharMatrix([['G', 'Z', 'I', 'G', 'J', 'C'], ['H', 'O', 'Y', 'H', 'O', 'B']], 0x0000000000000002)) == "GHZOIYGHJOCB"

  @test joinfromgroup(CharMatrix([['E', 'F', 'M', 'Y', 'U', 'D', 'C', 'W', 'O'], ['P', 'Q', 'Z', 'N', 'C', 'W', 'B', 'I', 'W'], ['S', 'Q', 'C', 'C', 'A', 'J', 'V', 'N', 'U'], ['D', 'X', 'J', 'K', 'C', 'R', 'R', 'L']], 0x0000000000000004)) == "EPSDFQQXMZCJYNCKUCACDWJRCBVRWINLOWU"
end
