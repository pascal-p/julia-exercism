using Test

include("isogram.jl")

@testset "empty string" begin
  @test isisogram("")
end

@testset "isogram with only lower case characters" begin
  @test isisogram("isogram")
end

@testset "word with one duplicated character" begin
  @test !isisogram("eleven")
end

@testset "longest reported english isogram" begin
  @test isisogram("subdermatoglyphic")
end

@testset "word with duplicated character in mixed case" begin
  for word in ("Heterograms", "Alphabet", "Salesman", "Sentimentalism",)
    @test !isisogram(word)
    end
end

@testset "hypothetical isogrammic word with hyphen" begin
  @test isisogram("thumbscrew-japingly")
end

@testset "isogram with duplicated non letter character" begin
  @test isisogram("Hjelmqvist-Gryb-Zock-Pfund-Wax")
end

@testset "made-up name that is an isogram" begin
  @test isisogram("Emily Jung Schwartzkopf")
end

## https://en.wikipedia.org/wiki/Heterogram_(literature)#Isograms

@testset "sentence isogram" begin
  for sentence in ("Nymphs beg for quick waltz.", "The big dwarf only jumps.",
                   "Lampez un fort whisky!", "Plombez vingt fuyards!",
                   """"Fix, Schwyz!", quäkt Jürgen blöd vom Paß.""",)
    @test isisogram(sentence)
  end
end

@testset "14-letters isogram" begin
  for word in ("ambidextrously", "computerizably", "croquet-playing", "dermatoglyphic", "hydromagnetics",
               "hydropneumatic", "pseudomythical",  "subformatively", "troublemakings", "undiscoverably",
               )
    @test isisogram(word)
  end
end
