using Test
using Random

include("karger_mincut.jl")
include("file_utils.jl")

function runner(gr; n=100)
  res = Dict{Integer, Real}()

  for _ in 1:n
    c_gr = copy(gr)
    mc = mincut!(c_gr)
    res[mc] = mc ∈ keys(res) ? res[mc] + 1. : 1.
  end

  for k ∈ keys(res)
    res[k] /= Real(n)
  end

  return (min(keys(res)...), res)
end


@testset "100 samples on a simple graph" begin
  gr = UnGraph{Int}(Dict(1 => [2, 3], 2 => [1, 3, 4], 3 => [1, 2, 4], 4 => [2, 3]))
  (k, ) = runner(gr)

  @test k == 2  # min == 2
end

@testset "100 samples on a simple graph" begin
  gr = UnGraph{Int}(Dict(1 => [2, 3, 4], 2 => [1, 3, 4, 5], 3 => [1, 2, 4, 5, 6],
                         4 => [1, 2, 3, 5, 6], 5 => [2, 3, 4, 6], 6 => [3, 4, 5]))
  (k, ) = runner(gr; n=100)

  @test k == 3  # min == 3
end

@testset "100 samples on another simple graph" begin
  gr = UnGraph{Int}(Dict(1 => [2, 3], 2 => [1, 3, 4, 5], 3 => [1, 2], 4 => [2, 5, 6],
                         5 => [2, 4, 6], 6 => [4, 5]))
  (k, ) = runner(gr; n=100)

  @test k == 2  # min == 2
end

@testset "1000 samples on another simple graph" begin
  gr = UnGraph{Int}(Dict(1 => [3, 5, 7, 8], 2 => [3, 4, 8, 6], 3 => [1, 8, 2, 4, 7], 4 => [2, 3, 7],
                         5 => [1, 7, 8, 6], 6 => [2, 8, 5], 7 => [1, 3, 4, 5], 8 => [1, 3, 2, 6, 5]))

  (k, ) = runner(gr; n=1_000)

  @test k == 3  # min == 3
end

@testset "1000 samples on another simple graph" begin
  gr = UnGraph{Int}(Dict(1 => [3, 5, 8], 2 => [3, 4, 8, 6], 3 => [1, 8, 2, 4, 7], 4 => [2, 3, 7],
                         5 => [1, 8, 6], 6 => [2, 8, 5], 7 => [3, 4], 8 => [1, 3, 2, 6, 5]))

  (k, ) = runner(gr; n=1_000)

  @test k == 2  # min == 2
end

## can take a while
@testset "mincut file - 200 nodes / 1000 samples" begin
  a = slurp("./karger_mincut.txt")
  adjl = Dict([x[1] => x[2:end] for x in a])

  gr = UnGraph{Int}(adjl)
  @time (k, ) = runner(gr; n=100)

  @test k == 20  # min == 20 / 17 minutes run?
end

#  10 runs => 9s
#  20 runs => 19s
#  30 runs => 29s
#
#  50 runs => 51s
#
# 100 runs => 98.828102 seconds (414.21 M allocations: 59.193 GiB, 2.25% gc time)
# Test Summary:                          | Pass  Total
# mincut file - 200 nodes / 1000 samples |    1      1

# graph = UnGraph{Int}(4)
# add_adjl(graph, Dict(1 => [2, 3], 2 => [1, 3, 4], 3 => [1, 2, 4], 4 => [2, 3]))

# # 1st iter
# v, k, vv = graph.n, 1, 5
# (eo, ed) = graph.edges[k]
# adjl_o, adjl_e = graph.adjl[eo], graph.adjl[ed]
# graph.adjl[vv] = sort([adjl_o..., adjl_e...])

# graph.adjl[vv] = filter(x -> x ∉ (eo, ed), graph.adjl[vv])

# delete!(graph.adjl, eo)
# delete!(graph.adjl, ed)
# graph.n -= 1

# for n in 1:v
#   n ∈ (eo, ed) && continue
#   graph.adjl[n] = map(x -> x ∈ (eo, ed) ? vv : x, graph.adjl[n])
# end
# graph.m, graph.edges = update_edges(graph.adjl)

# # 2nd iter
# v, k, vv = graph.n, 2, 6  # pick edgee (3, 5)
# (eo, ed) = graph.edges[k]


# adjl_o, adjl_e = graph.adjl[eo], graph.adjl[ed]
# graph.adjl[vv] = sort([adjl_o..., adjl_e...])
# graph.adjl[vv] = filter(x -> x ∉ (eo, ed), graph.adjl[vv])
# delete!(graph.adjl, eo)
# delete!(graph.adjl, ed)
# graph.n -= 1

# for n in keys(graph.adjl)
#   n ∈ (eo, ed) && continue
#   graph.adjl[n] = map(x -> x ∈ (eo, ed) ? vv : x, graph.adjl[n])
# end
# graph.m, graph.edges = update_edges(graph.adjl)


# a = [[1, 3], [3, 4], [2, 4], [1, 2], [2, 3]]
# sort(a, by=t -> (t[1], t[2]))
