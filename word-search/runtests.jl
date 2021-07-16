using Test

include("word-search.jl")

@testset "single line grids" begin

  @testset "Should accept an initial game grid" begin
    grid = ["jefblpepre"]
    ws = WordSearch(grid)

    @test typeof(ws) == WordSearch
  end

  @testset "can accept a target search word" begin
    grid = ["jefblpepre"]
    ws = WordSearch(grid)

    @test find(ws, ["glasnost"]) === nothing
  end

  @testset "should locate a word written left to right" begin
    grid = ["clojurermt"]
    expected = Dict{Symbol, NamedTuple}(
      :clojure => (_start=[1, 1], _end=[1, 7])
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure"]) == expected
  end

end
