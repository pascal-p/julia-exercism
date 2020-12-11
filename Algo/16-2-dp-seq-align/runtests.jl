using Test

include("./nw_dp.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)::Int
  open(ifile) do f
    readlines(f)
  end[1] |> s -> parse(Int, strip(s))
end


@testset "basic / 1" begin
  x, y = "AGGGCT", "AGGCA"

  (len, (nx, ny))  = nw(x, y; αg=1, αm=2)

  @test len == 3
  @test nx == "AGGGCT"
  @test ny == "A_GGCA"
end

@testset "basic / 2" begin
  x, y = "AGTACG", "ACATAG"

  (len, (nx, ny))  = nw(x, y; αg=1, αm=2)

  @test len == 4
  @test nx == "A_GTACG"
  @test ny == "ACATA_G"
end

for file in filter((fs) -> occursin(r"\Ainput_problem.+.txt", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")

  @testset "on file: $(file)" begin
    (x, y, αg, αm) = from_file("$(TF_DIR)/$(file)")

    @test nw(x, y; αg, αm)[1] == exp_value
  end
end
