using Test

include("./ug_prim_pq.jl")

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
  ug = from_file("$(TF_DIR)/$(file)", UnGraph{Int, Int}; T1=Int, T2=Int)

  @testset "(PQ/heap based) prim MST on: $(file)" begin
    @test mst(ug)[1] == exp_value
  end
end

## Challenge / Princeton files
for file in filter((fs) -> occursin(r".+_ewg-challenge.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ug = from_file("$(TF_DIR)/$(file)", UnGraph{Int, Int}; T1=Int, T2=Int)
  exp_value = occursin(r"large_ewg-challenge.txt", file) ? 64_766_236_568 : 1_046_336

  @testset "(PQ/heap based) prim MST on: $(file)" begin
    @time @test mst(ug)[1] == exp_value
  end
end

#  julia runtests_prim_pq.jl

# 64766236568
#   6.592195 seconds (12.94 M allocations: 540.118 MiB, 0.54% gc time)
# Test Summary:                                        |
# (PQ/heap based) prim MST on: large_ewg-challenge.txt | No tests

# 1046336
#   0.000558 seconds (2.20 k allocations: 124.016 KiB)
# Test Summary:                                         |
# (PQ/heap based) prim MST on: medium_ewg-challenge.txt | No tests
