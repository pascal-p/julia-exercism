using Test

include("dp_floyd_warshall_apsp.jl")

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

  act_mat = shortest_path(g)
  @test act_mat == exp_mat
  
  #  [0 1 2 5 4;
  #   ∞ 0 ∞ 4 ∞;
  #   ∞ -1 0 3 2;
  #   ∞ ∞ ∞ 0 ∞;
  #   ∞ ∞ ∞ 2 0]
  println(" >> act_mat: ", act_mat)
end

# @testset "APSP basics /2" begin
#   g = EWDiGraph{Int, Int}(5)

#   add_edge(g, 1, 2, -1; positive_weight=false)
#   add_edge(g, 1, 3, 4; positive_weight=false)
#   add_edge(g, 2, 3, 3; positive_weight=false)
#   add_edge(g, 2, 5, 2; positive_weight=false)
#   add_edge(g, 2, 4, 2; positive_weight=false)
#   add_edge(g, 4, 2, 1; positive_weight=false)
#   add_edge(g, 4, 3, 5; positive_weight=false)
#   add_edge(g, 5, 4, -3; positive_weight=false)

#   exp_mat = [0 -1 2 -2 1;
#              infinity(Int) 0 3 -1 2;
#              infinity(Int) infinity(Int) 0 infinity(Int) infinity(Int);
#              infinity(Int) 1 4 0 3;
#              infinity(Int) -2 1 -3 0]

#   @test shortest_path(g) == exp_mat
# end

# @testset "APSP on tiny_ewd.txt" begin
#   act_mat, _g = shortest_path("$(TF_DIR)/tiny_ewd.txt"; VType=Int, WType=Float32)

#   exp_mat = [0.0 1.05 0.26 0.99 0.38 0.73 1.51 0.6;
#              1.3899999 0.0 1.2099999 0.29 1.74 1.8299999 0.80999994 1.55;
#              1.83 0.94000006 0.0 0.73 0.97 0.62 1.25 0.34;
#              1.0999999 1.86 0.91999996 0.0 1.45 1.54 0.52 1.26;
#              1.86 0.66999996 1.68 0.76 0.0 0.35 1.28 0.37;
#              1.71 0.32 1.53 0.61 0.35 0.0 1.13 0.28;
#              0.58 1.34 0.4 1.13 0.93 1.02 0.0 0.74;
#              1.49 0.6 1.31 0.39 0.63 0.28 0.90999997 0.0]

#   @test act_mat ≈ exp_mat
# end
