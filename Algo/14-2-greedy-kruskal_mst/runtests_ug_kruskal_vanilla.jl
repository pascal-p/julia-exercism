using Test

include("./ug_kruskal-vanilla.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)
  open(ifile) do f
    readlines(f)
  end |> a -> parse(Int, a[1])
end


@testset "basics" begin
  ug = UnGraph{Int, Int}("$(TF_DIR)/input_random_1_10.txt")

  @test v(ug) == 10
  @test e(ug) == 9 # self-loop edge ignore

  @test length(adj(ug, 1)) == 1
  @test length(adj(ug, 2)) == 2 # self-loop edge ignore
  @test length(adj(ug, 3)) == 2
end

for file in filter((fs) -> occursin(r"\Ainput_random_\d+_\d+", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")
  ug = from_file("$(TF_DIR)/$(file)", UnGraph{Int, Int}; T1=Int, T2=Int, cache_edges=true)

  @testset "(vanilla) kruskal MST on: $(file)" begin
    @test mst(ug)[1] == exp_value
  end
end
