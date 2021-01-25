using Test

include("./a_star.jl")

##
## Helpers
##

function prep_ug₁(T1::DataType, T2::DataType)
  ug = UnGraph{T1, T2}(11)

  add_edge!(ug::UnGraph{T1, T2}, 1, 2, 5)
  add_edge!(ug::UnGraph{T1, T2}, 1, 3, 9)
  add_edge!(ug::UnGraph{T1, T2}, 1, 5, 6)

  add_edge!(ug::UnGraph{T1, T2}, 2, 8, 9)
  add_edge!(ug::UnGraph{T1, T2}, 2, 3, 3)

  add_edge!(ug::UnGraph{T1, T2}, 3, 2, 2)
  add_edge!(ug::UnGraph{T1, T2}, 3, 4, 4)

  add_edge!(ug::UnGraph{T1, T2}, 4, 1, 6)
  add_edge!(ug::UnGraph{T1, T2}, 4, 9, 5)
  add_edge!(ug::UnGraph{T1, T2}, 4, 6, 7)

  add_edge!(ug::UnGraph{T1, T2}, 5, 1, 1)
  add_edge!(ug::UnGraph{T1, T2}, 5, 4, 2)
  add_edge!(ug::UnGraph{T1, T2}, 5, 6, 2)

  add_edge!(ug::UnGraph{T1, T2}, 6, 10, 7)

  add_edge!(ug::UnGraph{T1, T2}, 7, 6, 2)
  add_edge!(ug::UnGraph{T1, T2}, 7, 10, 8)

  ug
end

function prep_ug₂(T1::DataType, T2::DataType)
  ug = UnGraph{T1, T2}(10)

  add_edge!(ug::UnGraph{T1, T2}, 1, 2, 6)
  add_edge!(ug::UnGraph{T1, T2}, 1, 6, 3)

  add_edge!(ug::UnGraph{T1, T2}, 2, 3, 3)
  add_edge!(ug::UnGraph{T1, T2}, 2, 4, 2)

  add_edge!(ug::UnGraph{T1, T2}, 3, 4, 1)
  add_edge!(ug::UnGraph{T1, T2}, 3, 5, 5)

  add_edge!(ug::UnGraph{T1, T2}, 5, 4, 8)
  add_edge!(ug::UnGraph{T1, T2}, 5, 9, 5)
  add_edge!(ug::UnGraph{T1, T2}, 5, 10, 5)

  add_edge!(ug::UnGraph{T1, T2}, 6, 7, 1)
  add_edge!(ug::UnGraph{T1, T2}, 6, 8, 7)

  add_edge!(ug::UnGraph{T1, T2}, 7, 9, 3)
  add_edge!(ug::UnGraph{T1, T2}, 7, 9, 3)

  add_edge!(ug::UnGraph{T1, T2}, 8, 9, 2)

  add_edge!(ug::UnGraph{T1, T2}, 9, 10, 3)
  ug
end

function prep_ug₃(T1::DataType, T2::DataType)
  ug = UnGraph{T1, T2}(7)

  add_edge!(ug::UnGraph{T1, T2}, 1, 2, T2(2.0))
  add_edge!(ug::UnGraph{T1, T2}, 1, 3, T2(1.5))
  add_edge!(ug::UnGraph{T1, T2}, 3, 4, T2(2.0))
  add_edge!(ug::UnGraph{T1, T2}, 4, 5, T2(3.0))
  add_edge!(ug::UnGraph{T1, T2}, 2, 6, T2(2.0))

  ug
end

##
## Tests
##

@testset "simple undirected graph" begin
  ## Prep.
  T1, T2 = Int, Int
  ug = prep_ug₁(T1, T2)

  ## Heuristic
  h_heur = Dict{T1, T2}(1 => 5, 2 => 7, 3 => 3, 4 => 4, 5 => 6,
                        6 => 5, 7 => 6, 8 => 0, 9 => 0, 10 => 0)

  h = function(n::T1) # ::T2
    get(h_heur, n, typemax(T2))
  end

  ## Test
  path = a_star(ug, 1, 9, h)
  @test path == [1, 5, 4, 9]

  path = a_star(ug, 1, 10, h)
  @test path == [1, 5, 6, 10]
end

@testset "another simple undirected graph" begin
  ## Prep.
  T1, T2 = Int, Int
  ug = prep_ug₂(T1, T2)

  ## Heuristic
  h_heur = Dict{T1, T2}(1 => 10, 2 => 8, 3 => 5, 4 => 7, 5 => 3,
                        6 => 6, 7 => 5, 8 => 3, 9 => 1, 10 => 0)

  h = function(n::T1) # ::T2
    get(h_heur, n, typemax(T2))
  end

  ## Test
  path = a_star(ug, 1, 10, h)
  @test path == [1, 6, 7, 9, 10]
end


@testset "undirected graph - no path to goal" begin
  T1, T2 = Int, Float32
  ug = prep_ug₃(T1, T2)

  ## Heuristic
  h_heur = Dict{T1, T2}(1 => T2(1.5), 2 => T2(4.5), 3 => T2(4.0), 4 => T2(2.0), 5 => Inf32,
                        6 => Inf32, 7 => zero(T2))

  h = function(n::T1) # ::T2
    get(h_heur, n, Inf32)
  end

  ## Test
  @test a_star(ug, 1, 7, h) == nothing
end
