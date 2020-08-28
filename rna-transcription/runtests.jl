using Test

include("rna-transcription.jl")

@testset "basic transformations" begin
  @testset "rna complement of cytosine is guanine" begin
    @test to_rna("C") == "G"
    @test to_rna("c") == "G"
  end

  @testset "rna complement of guanine is cytosine" begin
    @test to_rna("G") == "C"
    @test to_rna("g") == "C"
  end

  @testset "rna complement of thymine is adenine" begin
    @test to_rna("T") == "A"
    @test to_rna("t") == "A"
  end

  @testset "rna complement of adenine is uracil" begin
    @test to_rna("A") == "U"
    @test to_rna("a") == "U"
  end
end


@testset "rna complement" begin
  @test to_rna("ACGTGGTCTTAA") == "UGCACCAGAAUU"

  @test to_rna("AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC") == "UCGAAAAGUAAGACUGACGUUGCCCGUUAUACAGAGACACACCUAAUUUUUUUCUCACAGACUAUCGUCG"
end

@testset "error handling" begin
  @testset "dna correctly handles invalid input" begin
    @test_throws ErrorException to_rna("U")
  end

  @testset "dna correctly handles completely invalid input" begin
    @test_throws ErrorException to_rna("XXX")
  end

  @testset "dna correctly handles partially invalid input" begin
    @test_throws ErrorException to_rna("ACGTXXXCTTAA")
  end
end
