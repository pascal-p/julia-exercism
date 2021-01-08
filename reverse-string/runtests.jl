using Test

include("reverse-string.jl")

const TEST_GRAPHEMES = true

@testset "an empty string" begin
  @test yareverse("") == ""
end

@testset "a word" begin
  @test yareverse("robot") == "tobor"
end

@testset "a capitalized word" begin
  @test yareverse("Ramen") == "nemaR"
end

@testset "a sentence with punctuation" begin
  @test yareverse("I'm hungry!") == "!yrgnuh m'I"
end

@testset "a palindrome" begin
  @test yareverse("racecar") == "racecar"
end

@testset "an even-sized word" begin
  @test yareverse("drawer") == "reward"
end

@testset "reversing a string twice" begin
  @test yareverse(yareverse("gift")) == "gift"
end

@testset "emoji" begin
  @test yareverse("hi 🐱") == "🐱 ih"

  @test yareverse("my 🚴 is in 🗾 😉") == "😉 🗾 ni si 🚴 ym"
end

if @isdefined(TEST_GRAPHEMES)
  @eval @testset "graphemes" begin
    @test yareverse("as⃝df̅"; with_graphemes=true) == "f̅ds⃝a"
    @test yareverse("hi 👋🏾"; with_graphemes=true) == "👋🏾 ih"

    @test yareverse("my 🚴 is in 🗾 😉"; with_graphemes=true) == "😉 🗾 ni si 🚴 ym"
  end
end
