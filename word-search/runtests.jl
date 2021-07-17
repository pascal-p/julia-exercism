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
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(1, 1), _end=(1, 7))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure"]) == expected
  end

  @testset "can locate a left to right word in a different position" begin
    grid = ["mtclojurer"]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(1, 3), _end=(1, 9))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure"]) == expected
  end

  @testset "can locate a different left to right word" begin
    grid = ["coffeelplx"]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :coffee => (_start=(1, 1), _end=(1, 6))
    )
    ws = WordSearch(grid)

    @test find(ws, ["coffee"]) == expected
  end

  @testset "can locate that different left to right word in a different position" begin
    grid = ["xcoffeezlp"]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :coffee => (_start=(1, 2), _end=(1, 7))
    )
    ws = WordSearch(grid)

    @test find(ws, ["coffee"]) == expected
  end
end

@testset "multiline grids" begin
  @testset "can locate a left to right word in a two line grid" begin
    grid = ["jefblpepre", "clojurermt"]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(2, 1), _end=(2, 7))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure"]) == expected
  end

  @testset "can locate a left to right word in a different position in a two line grid" begin
    grid = ["jefblpepre", "tclojurerm"]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(2, 2), _end=(2, 8))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure"]) == expected
  end

  @testset "can locate a left to right word in a three line grid" begin
    grid = ["camdcimgtc", "jefblpepre", "clojurermt"]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(3, 1), _end=(3, 7))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure"]) == expected
  end

  # TODO: 'can locate a left to right word in a ten line grid'...
end
