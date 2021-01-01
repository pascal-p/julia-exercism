using Test

include("scc_2sat.jl")

const TF_DIR = "./testfiles"
const expected = Vector{Bool}([true, false, true, true, false, false]) # 101100

for (ix, file) in enumerate(filter((fs) -> occursin(r"\A2sat\d\.txt\z", fs),
                                   cd(readdir, "$(TF_DIR)")))

  @testset "Challenge 2SAT for $(file)" begin
    @time (act_val, _assign) = solve_2sat("$(TF_DIR)/$(file)", Int32)

    @test act_val == expected[ix]
  end
end
