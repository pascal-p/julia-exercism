using Test

push!(LOAD_PATH, "./src")
using YAUG

const TF_DIR = "./testfiles"


@testset "basics on undirected graph + bfs" begin
  ug = from_file("$(TF_DIR)/input_random_4_10.txt",
                 UnGraph{Int, Int}; T1=Int, T2=Int, cache_edges=true)

  @testset "undirected graph" begin
    @test v(ug) == 10
    @test e(ug) == 11

    @test is_edge(ug, 2, 7)
    @test is_edge(ug, 1, 10)

    @test !is_edge(ug, 2, 10)

    @test adj(ug, 2) == [(1, -8737), (3, -6040), (7, 2119)]
    @test adj(ug, 3) == [(2, -6040), (4, -2771)]

    @test edges(ug) == [(1, 2, -8737), (2, 3, -6040), (3, 4, -2771),
                        (4, 5, 7075), (5, 6, -7925), (6, 7, -9442),
                        (7, 8, 9877), (8, 9, -7664), (9, 10, 555),
                        (1, 10, -5950), (7, 2, 2119)]
  end

  @testset "bfs - mono source" begin
    bfs = UnBFS{Int}(ug, 2)

    @test has_path_to(bfs, 10)  # there is a path from 2 to 10
    @test has_path_to(bfs, 7)   # there is a path from 2 to 7
    @test has_path_to(bfs, 5)   # there is a path from 2 to 5

    @test path_builder(bfs, 7) == "2-7"      # show path 2~7 as a string
    @test path_builder(bfs, 6) == "2-7-6"    # show path 2~6 as a string
    @test path_builder(bfs, 5) == "2-3-4-5"  # show path 2~5 as a string
  end

end
