using Test

include("./ug_prim.jl")

const challenge = "./testfiles/edges.txt"
const exp_val = -3_612_829


@testset "vanilla prim MST on: $(challenge)" begin
  @time @test mst_vanilla(challenge; T1=Int, T2=Int)[1] == exp_val
end

@testset "heap based prim MST on: $(challenge)" begin
  @time @test mst(challenge; T1=Int, T2=Int)[1] == exp_val
end

include("./ug_prim_pq.jl") # Overwrite mst

@testset "PQ/heap based prim MST on: $(challenge)" begin
  @time @test mst(challenge; T1=Int, T2=Int)[1] == exp_val
end
