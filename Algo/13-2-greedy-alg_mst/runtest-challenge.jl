using Test

include("./ug_prim.jl")

const challenge = "./testfiles/edges.txt"

@testset "prim MST on: $(challenge)" begin
  @test mst(challenge; T1=Int, T2=Int)[1] == -3612829
end


