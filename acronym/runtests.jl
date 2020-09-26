# canonical data version: 1.7.0

using Test

include("acronym.jl")


@testset "basic1" begin
  @test acronym("") == ""
end

@testset "basic2" begin
  for (s, exp) in [
                   ("Portable Network Graphics", "PNG"),
                   ("Looks good to me", "LGTM"),
                   ("Sounds 'good' to me", "SGTM"),
                   ("Isn't it good", "IIG"),
                   ("If and only if...", "IAOI"),
                   ("Yet Another Funny Acronym", "YAFA"),
                   ("Sometimes, it is necessary to raise an exception.", "SIINTRAE"),
                   ("Last-in, first-out", "LIFO"),
                   ("Oh my \"Gosh!\"", "OMG"),
                   ("Functional Programming", "FP"),
                   ("Imperative Programming", "IP"),
                   ("Object oriented Programming", "OOP"),
                   ("Differentiable Programming", "DP")]
    @test acronym(s) == exp
  end
end

@testset "lowercase words" begin
    @test acronym("Ruby on Rails") == "ROR"
end

@testset "punctuation" begin
    @test acronym("First In, First Out") == "FIFO"
end

@testset "all caps word" begin
    @test acronym("GNU Image Manipulation Program") == "GIMP"
end

@testset "punctuation without whitespace" begin
    @test acronym("Complementary metal-oxide semiconductor") == "CMOS"
end

@testset "very long abbreviation" begin
    @test acronym("Rolling On The Floor Laughing So Hard That My Dogs Came Over And Licked Me") == "ROTFLSHTMDCOALM"
end

@testset "consecutive delimiters" begin
    @test acronym("Something - I made up from thin air") == "SIMUFTA"
end

@testset "apostrophes" begin
    @test acronym("Halley's Comet") == "HC"
end

@testset "underscore emphasis" begin
    @test acronym("The Road _Not_ Taken") == "TRNT"
end
