using Test

include("scrabble-score.jl")

@testset "lowercase letter" begin
    @test score("a") == 1
end

@testset "uppercase letter" begin
    @test score("A") == 1
end

@testset "valuable letter" begin
    @test score("f") == 4
end

@testset "short word" begin
    @test score("at") == 2
end

@testset "short, valuable word" begin
    @test score("zoo") == 12
end

@testset "medium word" begin
    @test score("street") == 6
end

@testset "medium, valuable word" begin
    @test score("quirky") == 22
end

@testset "long, mixed-case word" begin
    @test score("OxyphenButazone") == 41
end

@testset "english-like word" begin
    @test score("pinata") == 8
end

@testset "non-english letter is not scored" begin
    @test score("piñata") == 7
end

@testset "empty input" begin
    @test score("") == 0
end

@testset "entire alphabet available" begin
    @test score("abcdefghijklmnopqrstuvwxyz") == 87
end

## Addition

@testset "basic setup" begin
  @test score("a") == 1

  @test score("A") == 1

  @test score("x") == 8

  @test score("q") == 10
end


@testset "basic scores" begin
  @test score("") == 0

  @test score("quirky") == 22

  @test score("street") == 6

  @test score("at") == 2

  @test score("zoo") == 12

  @test score("pinata") == 8

  @test score("OxyphenButazone") == 41

  @test score("cabbage") == 14

  @test score("abcdefghijklmnopqrstuvwxyz") == 87
end

@testset "Error - non word" begin
  @test_throws ArgumentError score("#!@@!")

  @test_throws ArgumentError score("la petite souris, ...")

  @test_throws ArgumentError score("CelaCommenceBien mais cela finit mal!")

  @test_throws AssertionError score("Abracadabra"; double_letter=['A'], triple_letter=['B'])

  @test_throws AssertionError score("Abracadabra"; double_letter=['Z'])
end

@testset "Double letter" begin
  @test score("quirky"; double_letter=['k']) == 27

  @test score("quirky"; double_letter=['Q']) == 32

  @test score("zoo"; double_letter=['o']) == 13
end

@testset "Triple letter" begin
  @test score("quirky"; triple_letter=['k']) == 32

  @test score("quirky"; triple_letter=['Q']) == 42

  @test score("zoo"; triple_letter=['O']) == 14

  @test score("zoo"; triple_letter=['Z']) == 32
end
