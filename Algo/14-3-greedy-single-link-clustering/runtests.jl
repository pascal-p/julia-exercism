using Test

include("./single_link_clustering.jl")

const TF_DIR = "./testfiles"

const K = 4     ## number of clusters


function read_sol(ifile)
  open(ifile) do f
    readlines(f)
  end |> a -> parse(Int, a[1])
end


@testset "basics" begin
  ug = UnGraph{Int, Int}("$(TF_DIR)/input_complete_random_1_8.txt")

  @test v(ug) == 8
  @test e(ug) == 28

  @test length(adj(ug, 1)) == 7
  @test length(adj(ug, 2)) == 7
  @test length(adj(ug, 3)) == 7
end

for file in filter((fs) -> occursin(r"\Ainput_complete_random_\d+_\d+", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")
  ug = from_file("$(TF_DIR)/$(file)", UnGraph{Int, Int}; T1=Int, T2=Int, cache_edges=true)

  @testset "(uf) kruskal MST on: $(file)" begin
    @test calc_clusters(ug, K) == exp_value
  end
end
