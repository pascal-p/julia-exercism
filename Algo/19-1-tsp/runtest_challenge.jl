using Test

include("dp_tsp.jl")

const TF_DIR = "./testfiles"

for file in filter((fs) -> occursin(r"\Atsp.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))

  @testset "challenge $(file)" begin
    distm = init_distm("$(TF_DIR)/$(file)", Float32)

    @time @test floor(Int, tsp(distm)) == 26442
  end
end

#
# 617.176269 seconds (14.28 G allocations: 684.369 GiB, 11.20% gc time)
# Found: 26442
#
