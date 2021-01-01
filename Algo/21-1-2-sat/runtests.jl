using Test

include("scc_2sat.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)
  s = open(ifile) do f
    readlines(f)
  end[1]

  return parse(Int, strip(s))
end


for file in filter((fs) -> occursin(r"\Ainput_2sat_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile)")

  @testset "2SAT for $(file)" begin
    @time (act_val, _assign) = solve_2sat("$(TF_DIR)/$(file)", Int32)

    @test Integer(act_val) == exp_val
  end
end
