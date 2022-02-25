using Test

include("go_counting.jl")

@testset "territory" begin
  board = GoBoard(["  B  ", " B B ", "B W B", " W W ", "  W  "])

  @test territory(board, 3, 1) == (NONE, Set())
  @test territory(board, 3, 4) == (WHITE, Set([Point(3, 4)]))
  @test territory(board, 1, 2) == (BLACK, Set([Point(1, 1), Point(1, 2), Point(2, 1)]))
  @test territory(board, 3, 4) == (WHITE, Set([Point(3, 4)]))
  @test territory(board, 2, 5) == (NONE, Set([Point(1, 4), Point(1, 5), Point(2, 5)]))
  @test territory(board, 5, 5) == (NONE, Set([Point(5, 4), Point(4, 5), Point(5, 5)]))
  @test territory(board, 3, 3) == (NONE, Set())
end

@testset "territory exception" begin
  board = GoBoard(["  B  ", " B B ", "B W B", " W W ", "  W  "])

  @test_throws ArgumentError territory(board, -1, 1)
  @test_throws ArgumentError territory(board, 6, 1)
  @test_throws ArgumentError territory(board, 0, -1)
  @test_throws ArgumentError territory(board, 1, 10)
end


@testset "territories" begin
  @testset "1 cell board" begin
    board = GoBoard([" "])
    hres = territories(board)

    @test hres[BLACK] == Set{Point}()
    @test hres[WHITE] == Set{Point}()
    @test hres[NONE] == Set{Point}([Point(TT(1), TT(1))])
  end
end
