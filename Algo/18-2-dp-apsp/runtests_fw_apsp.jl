using Test

push!(LOAD_PATH, "./src")
using YA_FWAPSP

const TF_DIR = "./testfiles"

@testset "APSP basics /1" begin
  g = EWDiGraph{Int, Int}(5)

  add_edge(g, 1, 2, 4; positive_weight=false)
  add_edge(g, 1, 3, 2; positive_weight=false)
  add_edge(g, 2, 4, 4; positive_weight=false)
  add_edge(g, 3, 5, 2; positive_weight=false)
  add_edge(g, 3, 2, -1; positive_weight=false)
  add_edge(g, 5, 4, 2; positive_weight=false)

  ## Calc,
  exp_mat = [0 1 2 5 4;
             infinity(Int) 0 infinity(Int) 4 infinity(Int);
             infinity(Int) -1 0 3 2;
             infinity(Int) infinity(Int) infinity(Int) 0 infinity(Int);
             infinity(Int) infinity(Int) infinity(Int) 2 0]

  # act_mat = shortest_path(g)
  # @test act_mat == exp_mat

  fw_apsp = FWAPSP{Int, Int}(g)

  println("==> fw_apsp.dist_to: ", fw_apsp.dist_to)
  println("==> fw_apsp.path_to: ", fw_apsp.path_to)

  @test fw_apsp.dist_to == exp_mat
  # @test path_to(fw_apsp, 1, 4) == [1, 3, 2, 4]
  @test dist_to(fw_apsp, 1, 4) == 5

  # @test min_dist(fw_apsp) == (-1, [3, 2])
end

# @testset "APSP basics /1" begin
#   g = EWDiGraph{Int, Int}(4)

#   add_edge(g, 1, 3, 1)
#   add_edge(g, 2, 3, 6)
#   add_edge(g, 3, 4, 5)
#   add_edge(g, 4, 2, 2)
#   add_edge(g, 2, 1, 7)


#   fw_apsp = FWAPSP{Int, Int}(g)

#   println("==> fw_apsp.g: ", fw_apsp.g)
#   println("==> fw_apsp.dist_to: ", fw_apsp.dist_to)
#   println("==> fw_apsp.path_to: ", fw_apsp.path_to)
# end
