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

  @testset "can locate a left to right word in a ten line grid" begin
    grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "jalaycalmp",
      "clojurermt",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(10, 1), _end=(10, 7))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure"]) == expected
  end

  @testset "can locate a left to right word in a different position in a ten line grid" begin
    grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "clojurermt",
      "jalaycalmp",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(9, 1), _end=(9, 7))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure"]) == expected
  end

  @testset "can locate a different left to right word in a ten line grid" begin
     grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "clojurermt",
      "jalaycalmp",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :scree => (_start=(7, 1), _end=(7, 5))
    )
    ws = WordSearch(grid)

    @test find(ws, ["scree"]) == expected
  end
end

@testset "can find multiple words" begin

  @testset "can find two words written left to right" begin
    grid = [
      "aefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "jalaycalmp",
      "clojurermt",
      "xjavamtzlp",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(10, 1), _end=(10, 7)),
      :java => (_start=(11, 2), _end=(11, 5)),
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure", "java"]) == expected
  end
end

@testset "different directions" begin

  @testset "should locate a single word written right to left" begin
    grid = ["rixilelhrs"]

    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :elixir => (_start=(1, 6), _end=(1, 1))
    )
    ws = WordSearch(grid)

    @test find(ws, ["elixir"]) == expected
  end

  @testset "should locate multiple words written in different horizontal directions" begin
    grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "jalaycalmp",
      "clojurermt",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(10, 1), _end=(10, 7)),
      :elixir => (_start=(5, 6), _end=(5, 1))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure", "elixir"]) == expected
  end
end

@testset "vertical directions" begin
  @testset "should locate words written top to bottom" begin
    grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "jalaycalmp",
      "clojurermt",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(10, 1), _end=(10, 7)),
      :elixir => (_start=(5, 6), _end=(5, 1)),
      :ecmascript => (_start=(1, 10), _end=(10, 10))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure", "elixir", "ecmascript"]) == expected
  end

  @testset "should locate words written bottom to top" begin
     grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "jalaycalmp",
      "clojurermt",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(10, 1), _end=(10, 7)),
      :elixir => (_start=(5, 6), _end=(5, 1)),
      :ecmascript => (_start=(1, 10), _end=(10, 10)),
      :rust => (_start=(5, 9), _end=(2, 9))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure", "elixir", "ecmascript", "rust"]) == expected
  end

  @testset "should locate words written top left to bottom right" begin
     grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "jalaycalmp",
      "clojurermt",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(10, 1), _end=(10, 7)),
      :elixir => (_start=(5, 6), _end=(5, 1)),
      :ecmascript => (_start=(1, 10), _end=(10, 10)),
      :rust => (_start=(5, 9), _end=(2, 9)),
      :java => (_start=(1, 1), _end=(4, 4))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure", "elixir", "ecmascript", "rust", "java"]) == expected
  end

  @testset "should locate words written bottom right to top left" begin
    grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "jalaycalmp",
      "clojurermt",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(10, 1), _end=(10, 7)),
      :elixir => (_start=(5, 6), _end=(5, 1)),
      :ecmascript => (_start=(1, 10), _end=(10, 10)),
      :rust => (_start=(5, 9), _end=(2, 9)),
      :java => (_start=(1, 1), _end=(4, 4)),
      :lua => (_start=(9, 8), _end=(7, 6))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure", "elixir", "ecmascript", "rust", "java", "lua"]) == expected
  end

  @testset "should locate words written bottom left to top right" begin
    grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "jalaycalmp",
      "clojurermt",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(10, 1), _end=(10, 7)),
      :elixir => (_start=(5, 6), _end=(5, 1)),
      :ecmascript => (_start=(1, 10), _end=(10, 10)),
      :rust => (_start=(5, 9), _end=(2, 9)),
      :java => (_start=(1, 1), _end=(4, 4)),
      :lua => (_start=(9, 8), _end=(7, 6)),
      :lisp => (_start=(6, 3), _end=(3, 6))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure", "elixir", "ecmascript", "rust", "java", "lua", "lisp"]) == expected
  end

  @testset "should locate words written top right to bottom left" begin
    grid = [
      "jefblpepre",
      "camdcimgtc",
      "oivokprjsm",
      "pbwasqroua",
      "rixilelhrs",
      "wolcqlirpc",
      "screeaumgr",
      "alxhpburyi",
      "jalaycalmp",
      "clojurermt",
    ]
    expected = Dict{Symbol, NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}}(
      :clojure => (_start=(10, 1), _end=(10, 7)),
      :elixir => (_start=(5, 6), _end=(5, 1)),
      :ecmascript => (_start=(1, 10), _end=(10, 10)),
      :rust => (_start=(5, 9), _end=(2, 9)),
      :java => (_start=(1, 1), _end=(4, 4)),
      :lua => (_start=(9, 8), _end=(7, 6)),
      :lisp => (_start=(6, 3), _end=(3, 6)),
      :ruby => (_start=(6, 8), _end=(9, 5))
    )
    ws = WordSearch(grid)

    @test find(ws, ["clojure", "elixir", "ecmascript", "rust", "java", "lua", "lisp", "ruby"]) == expected
  end
end
