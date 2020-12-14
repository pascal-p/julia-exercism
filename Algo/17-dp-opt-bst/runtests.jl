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

@testset "basics / 3" begin
  freq = [0, .2, .05, .17, .1, .2, .03, .25]
  n = length(freq) - 1
  exp_val = 2.23

  @test opt_bst(n, freq)[2] == exp_val
end

@testset "Problem 17.4" begin
  freq = [0, 20, 5, 17, 10, 20, 3, 25]
  n = length(freq) - 1
  exp_val = 223

  m, act_val = opt_bst(n, freq)

  @test act_val == exp_val
  @test m == [0 0 0 0 0 0 0 0;
              0 20 30 69 92 142 151 223;
              0 0 5 27 47 97 105 158;
              0 0 0 17 37 84 90 143;
              0 0 0 0 10 40 46 99;
              0 0 0 0 0 20 26 74;
              0 0 0 0 0 0 3 31;
              0 0 0 0 0 0 0 25;
              0 0 0 0 0 0 0 0]
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
