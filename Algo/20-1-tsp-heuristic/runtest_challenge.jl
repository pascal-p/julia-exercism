using Test

include("nn_tsp.jl")

const TF_DIR = "./testfiles"

@testset "nn-tsp challenge for $(TF_DIR)/nn.txt" begin
  @time @test tsp("$(TF_DIR)/nn.txt", Float64;
                  x_sorted=true, no_index=true)[1] == 1_203_406
end
