using Test

include("dp_tsp.jl")

const TF_DIR = "./testfiles"

for file in filter((fs) -> occursin(r"\Atsp.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))

  # @testset "challenge $(file) / heuristic" begin
  #   @time tsp_dist = distm_challenge("$(TF_DIR)/$(file)", Float32)
  #   @test round_dist(tsp_dist, Int) == 26442
  # end

  # @testset "challenge $(file) / baseline - hash" begin
  #   distm = init_distm("$(TF_DIR)/$(file)", Float32)
  #   @time @test floor(Int, tsp(distm)) == 26442
  # end

  @testset "challenge $(file) / baseline - matrix" begin
    distm = init_distm("$(TF_DIR)/$(file)", Float32)
    @time @test floor(Int, tsp_m(distm)) == 26442
  end

end

#
# 0.646848 seconds (5.16 M allocations: 257.902 MiB, 3.16% gc time)
# Test Summary:                 | Pass  Total
# challenge tsp.txt / heuristic |    1      1

# Using Hash
# 1431.506865 seconds (14.30 G allocations: 684.933 GiB, 52.34% gc time)
# Test Summary:                | Pass  Total
# challenge tsp.txt / baseline |    1      1

# Using Array
# 622.455368 seconds (14.28 G allocations: 684.417 GiB, 11.21% gc time)
# Test Summary:                         | Pass  Total
# challenge tsp.txt / baseline - matrix |    1      1
