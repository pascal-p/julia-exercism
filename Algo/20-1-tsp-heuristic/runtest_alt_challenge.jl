using Test

include("nn_tsp_alt.jl")

const TF_DIR = "./testfiles"

@testset "nn-tsp (alt)  challenge for $(TF_DIR)/nn.txt" begin
  @time @test tsp("$(TF_DIR)/nn.txt", Float64;
                  x_sorted=true, no_index=true, algo=calc_tsp)[1] == 1_203_406
end

##
#  9.523268 seconds (1.47 M allocations: 71.626 MiB, 0.10% gc time)
# Test Summary:                                  | Pass  Total
# nn-tsp (alt)  challenge for ./testfiles/nn.txt |    1      1
