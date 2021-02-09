using Test

include("./food_chain.jl")

@testset "first paragraph - fly" begin
  @test recite(1, 1) == String[
                               "I know an old lady who swallowed a fly.",
                               "I don't know why she swallowed the fly. Perhaps she'll die.",
  ]
end

@testset "2nd paragraph - spider/fly" begin
  @test recite(2, 2) == String[
                               "I know an old lady who swallowed a spider.",
                               "It wriggled and jiggled and tickled inside her.",
                               "She swallowed the spider to catch the fly.",
                               "I don't know why she swallowed the fly. Perhaps she'll die.",
  ]
end

@testset "3rd paragraph - bird/spider/fly" begin
  @test recite(3, 3) == String[
                               "I know an old lady who swallowed a bird.",

                               "How absurd to swallow a bird!",

                               "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                               "She swallowed the spider to catch the fly.",
                               "I don't know why she swallowed the fly. Perhaps she'll die.",
  ]
end

@testset "4th paragraph - cat/bird/spider/fly" begin
  @test recite(4, 4) == String[
                               "I know an old lady who swallowed a cat.",

                               "Imagine that, to swallow a cat!",

                               "She swallowed the cat to catch the bird.",

                               "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                               "She swallowed the spider to catch the fly.",
                               "I don't know why she swallowed the fly. Perhaps she'll die.",
  ]
end

@testset "5th paragraph - dog/cat/bird/spider/fly" begin
  @test recite(5, 5) == String[
                               "I know an old lady who swallowed a dog.",

                               "What a hog, to swallow a dog!",

                               "She swallowed the dog to catch the cat.",
                               "She swallowed the cat to catch the bird.",

                               "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                               "She swallowed the spider to catch the fly.",
                               "I don't know why she swallowed the fly. Perhaps she'll die.",
  ]
end

@testset "6th paragraph - goat/dog/cat/bird/spider/fly" begin
  @test recite(6, 6) == String[
                               "I know an old lady who swallowed a goat.",

                               "Just opened her throat and swallowed a goat!",

                               "She swallowed the goat to catch the dog.",
                               "She swallowed the dog to catch the cat.",
                               "She swallowed the cat to catch the bird.",

                               "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                               "She swallowed the spider to catch the fly.",
                               "I don't know why she swallowed the fly. Perhaps she'll die.",
  ]
end

@testset "7th paragraph - cow/goat/dog/cat/bird/spider/fly" begin
  @test recite(7, 7) == String[
                               "I know an old lady who swallowed a cow.",

                               "I don't know how she swallowed a cow!",

                               "She swallowed the cow to catch the goat.",
                               "She swallowed the goat to catch the dog.",
                               "She swallowed the dog to catch the cat.",
                               "She swallowed the cat to catch the bird.",

                               "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                               "She swallowed the spider to catch the fly.",
                               "I don't know why she swallowed the fly. Perhaps she'll die.",
  ]
end

@testset "8th paragraph - horse/ dead" begin
  @test recite(8, 8) == ["I know an old lady who swallowed a horse.", "She's dead, of course!"]
end

@testset "multiple verses 1-3" begin
  @test recite(1, 3) == String[
                "I know an old lady who swallowed a fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
                "",
                "I know an old lady who swallowed a spider.",
                "It wriggled and jiggled and tickled inside her.",
                "She swallowed the spider to catch the fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
                "",
                "I know an old lady who swallowed a bird.",
                "How absurd to swallow a bird!",
                "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                "She swallowed the spider to catch the fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
  ]
end

@testset "multiple verses 1-8" begin
  @test recite(1, 8) == String[
                "I know an old lady who swallowed a fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
                "",
                "I know an old lady who swallowed a spider.",
                "It wriggled and jiggled and tickled inside her.",
                "She swallowed the spider to catch the fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
                "",
                "I know an old lady who swallowed a bird.",
                "How absurd to swallow a bird!",
                "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                "She swallowed the spider to catch the fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
                "",
                "I know an old lady who swallowed a cat.",
                "Imagine that, to swallow a cat!",
                "She swallowed the cat to catch the bird.",
                "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                "She swallowed the spider to catch the fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
                "",
                "I know an old lady who swallowed a dog.",
                "What a hog, to swallow a dog!",
                "She swallowed the dog to catch the cat.",
                "She swallowed the cat to catch the bird.",
                "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                "She swallowed the spider to catch the fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
                "",
                "I know an old lady who swallowed a goat.",
                "Just opened her throat and swallowed a goat!",
                "She swallowed the goat to catch the dog.",
                "She swallowed the dog to catch the cat.",
                "She swallowed the cat to catch the bird.",
                "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                "She swallowed the spider to catch the fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
                "",
                "I know an old lady who swallowed a cow.",
                "I don't know how she swallowed a cow!",
                "She swallowed the cow to catch the goat.",
                "She swallowed the goat to catch the dog.",
                "She swallowed the dog to catch the cat.",
                "She swallowed the cat to catch the bird.",
                "She swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her.",
                "She swallowed the spider to catch the fly.",
                "I don't know why she swallowed the fly. Perhaps she'll die.",
                "",
                "I know an old lady who swallowed a horse.",
                "She's dead, of course!",
  ]
end
