using Test

include("./ug_kruskal-uf.jl")

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

  @testset "(uf) kruskal MST on: $(file)" begin
    @test mst(ug)[1] == exp_value
  end
end

## Challenge / Princeton files
for file in filter((fs) -> occursin(r".+_ewg-challenge.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ug = from_file("$(TF_DIR)/$(file)", UnGraph{Int, Int}; T1=Int, T2=Int, cache_edges=true)
  exp_value = occursin(r"large_ewg-challenge.txt", file) ? 64_766_236_568 : 1_046_336

  @testset "(uf) kruskal MST on: $(file)" begin
    @time @test mst(ug)[1] == exp_value
  end
end

# julia runtests_ug_kruskal_uf.jl

#   1.738447 seconds (2.00 M allocations: 461.425 MiB, 1.59% gc time)
# Test Summary:                                | Pass  Total
# (uf) kruskal MST on: large_ewg-challenge.txt |    1      1

# 0.000128 seconds (532 allocations: 103.562 KiB)
# Test Summary:                                 | Pass  Total
# (uf) kruskal MST on: medium_ewg-challenge.txt |    1      1
