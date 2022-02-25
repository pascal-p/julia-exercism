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

  @testset "rectangular board 2x4" begin
    board = GoBoard([" BW ", " BW "])
    hres = territories(board)

    @test hres[BLACK] == Set{Point}([Point(TT(1), TT(1)), Point(TT(1), TT(2))])
    @test hres[WHITE] == Set{Point}([Point(TT(4), TT(1)), Point(TT(4), TT(2))])
    @test hres[NONE] == Set{Point}()
  end

  @testset "rectangular board 1x3" begin
    board = GoBoard([" W "])
    hres = territories(board)

    @test hres[BLACK] == Set{Point}()
    @test hres[WHITE] == Set{Point}([Point(TT(1), TT(1)), Point(TT(3), TT(1))])
    @test hres[NONE] == Set{Point}()
  end

  @testset "multi territories on sqare board" begin
    board = GoBoard(["  B  ", " B B ", "B W B", " W W ", "  W  "])
    hres = territories(board)

    @test hres[BLACK] == Set{Point}([Point(TT(1), TT(1)), Point(TT(1), TT(2)), Point(TT(2), TT(1)),
                                     Point(TT(4), TT(1)), Point(TT(5), TT(1)), Point(TT(5), TT(2))])
    @test hres[WHITE] == Set{Point}([Point(TT(3), TT(4))])
    @test hres[NONE] == Set{Point}([Point(TT(1), TT(4)), Point(TT(1), TT(5)), Point(TT(2), TT(5)),
                                    Point(TT(4), TT(5)), Point(TT(5), TT(4)), Point(TT(5), TT(5))])
  end
end
