using Test

include("./ug_prim.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)
  open(ifile) do f
    readlines(f)
  end |> a -> parse(Int, a[1])
end


@testset "basics" begin
  g = UnGraph{Int, Int}("$(TF_DIR)/input_random_1_10.txt")

  @test v(g) == 10
  @test e(g) == 9 # self-loop edge ignore

  @test length(g.adj[1]) == 1
  @test length(g.adj[2]) == 2 # self-loop edge ignore
  @test length(g.adj[3]) == 2
end

for file in filter((fs) -> occursin(r"\Ainput_random_1[89]_100", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")
  ug = from_file("$(TF_DIR)/$(file)", UnGraph{Int, Int}; T1=Int, T2=Int)

  @testset "(vanilla) prim MST on: $(file)" begin
    @test mst_vanilla(ug)[1] == exp_value
  end
end
