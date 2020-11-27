using Test

include("./src/karger_mincut.jl")
include("./utils/file.jl")
include("./utils/runner.jl")

const TF_DIR = "./testfiles"

function gen_adj(ifile::String)
  a = slurp("$(TF_DIR)/$(ifile)")
  Dict([x[1] => x[2:end] for x in a])
end

for file in filter((fs) -> occursin(r"\Ainput_random_\d+_\d+", fs),
                   cd(readdir, "$(TF_DIR)"))

  m = match(r"\Ainput_random_(\d+)_(\d+)\.txt", file)
  _, n2 = map(s -> parse(Int, s), m.captures)

  @testset "mincut file: $(file)" begin
    ifile = replace(file, r"\Ainput_" => s"output_")
    exp_k = read_sol("$(TF_DIR)/$(ifile)")

    adjl = gen_adj(file)
    gr = UnGraph{Int}(adjl)

    n = if n2 ≤ 10
      50
    elseif n2 ≤ 25
      250
    elseif n2 ≤ 50
      500
    elseif n2 ≤ 75
      600
    elseif n2 ≤ 125
      900
    elseif n2 ≤ 175
      1200
    else
      1500
    end

    (k, ) = runner(gr; n=n, seed=42)
    @test k == exp_k
  end
end
