using Test

include("dijkstra_sp.jl")

const FILEDIR = "./tests"

function sum_w(g, path)
  ## summing weigths on path from path[1] to path[end] == dist_to(path[1], path[end])

  prev_p, sum_w = path[1], 0

  for p in path[2:end]
    ix = findfirst(t -> t[1] == p, g.adj[prev_p])
    (_, w) = g.adj[prev_p][ix]
    sum_w += w                  # sum_w is the distance!
    prev_p = p
  end

  sum_w
end

@testset "DSP 4v_5e" begin
  dsp, g = shortest_path("$(FILEDIR)/simple_4v_5e_digraph.txt", 1)

  @test has_path(dsp, g, 4) # true
  @test path_to(dsp, g, 4) == [1, 2, 3, 4]
  @test dist_to(dsp, g, 4) == 6
end

@testset "DSP 8v_13e" begin
  dsp, g = shortest_path("$(FILEDIR)/simple_8v_13e_digraph.txt", 6)

  @test has_path(dsp, g, 7) # true
  @test path_to(dsp, g, 7) == [6, 2, 4, 7]
  @test dist_to(dsp, g, 7) == 113

  @test has_path(dsp, g, 3) # true
  @test path_to(dsp, g, 3) == [6, 8, 3]
  @test dist_to(dsp, g, 3) == 62

  @test has_path(dsp, g, 1) # true
  @test path_to(dsp, g, 1) == [6, 5, 1]
  @test dist_to(dsp, g, 1) == 73
end


@testset "DSP 8e_16v" begin
  dsp, g = shortest_path("$(FILEDIR)/8v_16e.txt", 1)

  for (v, d) in [(1, 0), (2, 1), (3, 2), (4, 3), (5, 4), (6, 4), (7, 3), (8, 2) ]
    @test dist_to(dsp, g, v) == d
  end
end


@testset "DSP 200v_3734e challenge" begin
  dsp, g = shortest_path("$(FILEDIR)/200e_3734v.txt", 1)

  for (v, d) in [
                 (7, 2599), (37, 2610), (59, 2947), (82, 2052),
                 (99, 2367), (115, 2399), (133, 2029), (165, 2442),
                 (188, 2505), (197, 3068)
                 ]

    @test dist_to(dsp, g, v) == d
  end

  ## max. distance in this graph at index 161
  ix_max = argmax(dsp.dist_to)
  e = 161
  @test ix_max == e
  @test dist_to(dsp, g, e) == 4772

  exp_path = [1, 80, 19, 88, 161]
  @test path_to(dsp, g, e) == exp_path
  @test sum_w(g, exp_path) == dsp.dist_to[e]

  ## other path_to(1, 188)
  e = 188
  exp_path = [1, 92, 70, 9, 72, 157, 26, 95, 196, 188]
  @test path_to(dsp, g, e) == exp_path

  @test dist_to(dsp, g, e) == 2505
  @test sum_w(g, exp_path) == dsp.dist_to[e]

end


# julia> for x in [7,37,59,82,99,115,133,165,188,197]
#          println("==> distance to: $(x) is $(dist_to(dsp, g, x))")
#          end
# ==> distance to: 7 is 2599
# ==> distance to: 37 is 2610
# ==> distance to: 59 is 2947
# ==> distance to: 82 is 2052
# ==> distance to: 99 is 2367
# ==> distance to: 115 is 2399
# ==> distance to: 133 is 2029
# ==> distance to: 165 is 2442
# ==> distance to: 188 is 2505
# ==> distance to: 197 is 3068
# 2599,2610,2947,2052,2367,2399,2029,2442,2505,3068

# for x in [7,37,59,82,99,115,133,165,188,197]
#          println("==> path to: $(x) from 1 is $(path_to(dsp, g, x))")
#        end
# ==> path to: 7 from 1 is [1, 114, 129, 85, 53, 7]
# ==> path to: 37 from 1 is [1, 145, 108, 126, 155, 37]
# ==> path to: 59 from 1 is [1, 92, 194, 162, 59]
# ==> path to: 82 from 1 is [1, 92, 134, 135, 82]
# ==> path to: 99 from 1 is [1, 99]
# ==> path to: 115 from 1 is [1, 80, 115]
# ==> path to: 133 from 1 is [1, 114, 129, 85, 133]
# ==> path to: 165 from 1 is [1, 80, 19, 187, 165]
# ==> path to: 188 from 1 is [1, 92, 70, 9, 72, 157, 26, 95, 196, 188]
# ==> path to: 197 from 1 is [1, 114, 103, 110, 197]
#
