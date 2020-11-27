using Test
using Random

include("./src/karger_mincut.jl")
include("./utils/file.jl")
include("./utils/runner.jl")

const TF_DIR = "./testfiles"

function gen_adj()
  a = slurp("$(TF_DIR)/karger_mincut.txt")
  Dict([x[1] => x[2:end] for x in a])
end

@testset "mincut file - 200 nodes" begin

  @testset "10_000 runs" begin
    adjl = gen_adj()
    gr = UnGraph{Int}(adjl)

    @time (k, ) = runner(gr; n=10_000)
    @test k == 17
  end

end
