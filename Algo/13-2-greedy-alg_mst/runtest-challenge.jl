using Test

include("./ug_prim.jl")

const challenge = "./testfiles/edges.txt"

@testset "vanilla prim MST on: $(challenge)" begin
  @time @test mst_vanilla(challenge; T1=Int, T2=Int)[1] == -3612829
end

@testset "heap based prim MST on: $(challenge)" begin
  @time @test mst(challenge; T1=Int, T2=Int)[1] == -3612829 # -3609489, -3610200, -3610999
end
