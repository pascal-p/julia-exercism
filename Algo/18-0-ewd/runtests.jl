using Test

push!(LOAD_PATH, "./src")
using YA_EWD


function edges(T::DataType, T1::DataType)
  Vector{Tuple{T, T, T1}}([
    (1, 2, 4), (1, 3, 2), (2, 4, 4), (3, 5, 2),
    (3, 2, -1), (5, 4, 2), (5, 1, 0)
  ])
end

function build_ewd_graph(T::DataType, T1::DataType, nv::Int)
  g = EWDiGraph{T, T1}(nv)
  build_graph!(g, edges(T, T1))
  g
end


@testset "basics /1" begin
  nv, T, T1 = 5, Int, Int
  g = build_ewd_graph(T, T1, nv)

  @test v(g) == nv
  @test e(g) == 7
end

@testset " basics /2" begin
  nv, T, T1 = 5, Int, Int
  g = build_ewd_graph(T, T1, nv)
  ng = EEWDiGraph{T, T1}(g)

  @test v(ng) == nv + 1
  @test e(ng) == 7 + 5
end
