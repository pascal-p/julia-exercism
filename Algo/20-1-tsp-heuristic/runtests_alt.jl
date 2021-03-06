using Test

include("nn_tsp_alt.jl")

const TF_DIR = "./testfiles"


function read_sol(ifile)
  s = open(ifile) do f
    readlines(f)
  end[1]

  return parse(Int, strip(s))
end


for file in filter((fs) -> occursin(r"\Ainput_simple_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile)")

  for tsp_fn ∈ (tsp, tsp_bf)
    @testset "$(tsp) for $(file)" begin
      @time @test tsp_fn("$(TF_DIR)/$(file)", Float64)[1] == exp_val
    end
  end
end
