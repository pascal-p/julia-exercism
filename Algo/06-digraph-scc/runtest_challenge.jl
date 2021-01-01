using Test

include("di_graph_scc.jl")

const TF_DIR = "./testfiles/"

## Challenge
## bash: ulimit -s unlimited  for the stack
## 371762 SCC
@testset "SCC 875714v_5105043e" begin
  (scc_g, _g) = calc_scc("$(TF_DIR)/875714v_5105043e_tc.txt")

  @test count(scc_g) == 371762

  @test topn(scc_g) == [ 218472 => 434821, 214518 => 968, 213230 => 459, 363858 => 313, 188585 => 211 ] # 5-element Array{Pair{Int64,Int64},1}
end

# run with: ulimit -s unlimited && julia runtests.jl
