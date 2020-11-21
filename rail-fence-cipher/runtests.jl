using Test

include("rail_fence_cipher.jl")

@testset "encode/decode/fill_rails basics" begin
  @test encode("message to encode!", 4) == "meoegtcdsaonese"

  @test decode("meoegtcdsaonese", 4) == "messagetoencode"

  ary = fill_rails("messagetoencode", 4)
  @test ary[1] == ['m', '.', '.', '.', '.', '.', 'e', '.', '.', '.', '.', '.', 'o', '.', '.']
  @test ary[2] == ['.', 'e', '.', '.', '.', 'g', '.', 't', '.', '.', '.', 'c', '.', 'd', '.']
  @test ary[3] == ['.', '.', 's', '.', 'a', '.', '.', '.', 'o', '.', 'n', '.', '.', '.', 'e']
  @test ary[4] == ['.', '.', '.', 's', '.', '.', '.', '.', '.', 'e', '.', '.', '.', '.', '.']
end

@testset "encode with one rail" begin
  @test encode("One rail, only one rail", 1) == "One rail, only one rail"
end

@testset "encode with two rails" begin
  @test encode("XOXOXOXOXOXOXOXOXO", 2) == "XXXXXXXXXOOOOOOOOO"
end

@testset "encode with three rails" begin
  @test encode("WE ARE DISCOVERED FLEE AT ONCE!", 3) == "WECRLTEERDSOEEFEAOCAIVDEN"
end

@testset "encode with five rails" begin
  @test encode("The Devil, Is In The Details...", 5) == "TIehlsDteiIeaDvnhiseTl"
end

@testset "encode empty message" begin
  @test encode("", 5) == ""
end

@testset "encode with less letters than rails" begin
  @test encode("More rails than letters", 24) == "More rails than letters"
end

@testset "decode empty message" begin
  @test decode("", 5) == ""
end

@testset "decode with one rail" begin
  @test decode("One rail, only one rail", 1) == "One rail, only one rail"
end

@testset "decode with two rails" begin
  @test decode("XXXXXXXXXOOOOOOOOO", 2) == "XOXOXOXOXOXOXOXOXO"
end

@testset "decode with three rails" begin
  @test decode("TEITELHDVLSNHDTISEIIEA", 3) == "THEDEVILISINTHEDETAILS"
end

@testset "decode with six rails" begin
  @test decode("133714114238148966225439541018335470986172518171757571896261", 6) == "112358132134558914423337761098715972584418167651094617711286"
end

@testset "encode/decode identity" begin
  for (msg, rails) in [
                       ("XOXOXOXOXOXOXOXOXO", 2),
                       ("WEAREDISCOVEREDFLEEATONCE", 3),
                       ("THEDEVILISINTHEDETAILS", 3),
                       ("THEDEVILISINTHEDETAILS", 5),
                       ("133714114238148966225439541018335470986172518171757571896261", 6)
                       ]
    @test decode(encode(msg, rails), rails) == msg
  end
end
