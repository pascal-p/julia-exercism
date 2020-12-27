using Test

include("dp_tsp.jl")

const TF_DIR = "./testfiles"

for file in filter((fs) -> occursin(r"\Atsp.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))

  for tsp ∈ (tsp_m, tsp_h)
    @testset "$(tsp) challenge $(file) / heuristic" begin
      @time tsp_dist = distm_challenge("$(TF_DIR)/$(file)", Float32; tsp)
      @test round_dist(tsp_dist, Int) == 26442
    end

    @testset "$(tsp) challenge $(file) / baseline - hash" begin
      distm = init_distm("$(TF_DIR)/$(file)", Float32)
      @time @test floor(Int, tsp(distm)) == 26442
    end
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


#   0.523526 seconds (4.69 M allocations: 236.501 MiB, 3.53% gc time)
# Test Summary:                       | Pass  Total
# tsp_m challenge tsp.txt / heuristic |    1      1

# 647.152974 seconds (13.86 G allocations: 666.187 GiB, 10.22% gc time)
# Test Summary:                             | Pass  Total
# tsp_m challenge tsp.txt / baseline - hash |    1      1

#   0.418528 seconds (4.36 M allocations: 218.204 MiB)
# Test Summary:                       | Pass  Total
# tsp_h challenge tsp.txt / heuristic |    1      1

# 1005.755300 seconds (13.88 G allocations: 668.132 GiB, 33.25% gc time)
# Test Summary:                             | Pass  Total
# tsp_h challenge tsp.txt / baseline - hash |    1      1
