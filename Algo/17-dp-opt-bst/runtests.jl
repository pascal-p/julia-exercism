using Test

include("./opt_bst_dp.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)
  s = open(ifile) do f
    readlines(f)
  end[1]
  T = occursin(r"\.", s) ? Float32 : Int
  parse(T, strip(s))
end


@testset "basics / 1" begin
  freq = [0, 34, 8, 50]
  n = length(freq) - 1
  exp_val = 142

  @test opt_bst(n, freq)[2] == exp_val
end

@testset "basics / 2" begin
  freq = [0, .05, .4, .08, .04, .1, .1, .23]
  n = length(freq) - 1
  exp_val = 2.18

  @test opt_bst(n, freq)[2] == exp_val
end

for file in filter((fs) -> occursin(r"\Ainput_problem.+.txt", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile)")

  @testset "for $(file)" begin
    n, freq = from_file("$(TF_DIR)/$(file)")

    @test opt_bst(n, freq)[2] == exp_val
  end
end
