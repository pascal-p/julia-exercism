using Test

push!(LOAD_PATH, "./src")
using YAUG

const TF_DIR = "./testfiles"

# input_un_3cc.txt define an undirected graph with 3 connected components
const n_cc = 3

@testset "basics on undirected graph connected componenets" begin
  ug = from_file("$(TF_DIR)/input_un_$(n_cc)cc.txt",
                 UnGraph{Int, Int}; T1=Int, T2=Int, cache_edges=true)

  @test v(ug) == 13
  @test e(ug) == 13

  uncc = UnCC{Int}(ug)
  @test count(uncc) == n_cc
end
