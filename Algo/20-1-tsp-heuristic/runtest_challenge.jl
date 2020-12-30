using Test

include("nn_tsp.jl")

const TF_DIR = "./testfiles"

@testset "nn-tsp challenge for $(TF_DIR)/nn.txt" begin
  @time @test tsp("$(TF_DIR)/nn.txt", Float64;
                  x_sorted=true, no_index=true, algo=calc_tsp_f)[1] == 1_203_406
end

## using: calc_tsp_f
#  1.245713 seconds (1.50 M allocations: 72.630 MiB, 0.77% gc time)
# Test Summary:                           | Pass  Total
# nn-tsp challenge for ./testfiles/nn.txt |    1      1
#
