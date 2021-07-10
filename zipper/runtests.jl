using Test

include("zipper.jl")

# abstract type TreeType end
const DATATYPE = Union{<: Integer, Nothing, TreeNode}
const DICTTYPE = Dict{Symbol, DATATYPE}

function set_initial_dict()
  Dict(
    :value => 1,
    :left => Dict(
      :value => 2,
      :left => nothing,
      :right => Dict(:value => 3, :left => nothing, :right => nothing),
    ),
    :right => Dict(:value => 4, :left => nothing, :right => nothing),
  )
end


@testset "data is retained/1" begin
  initial = TreeNode(
    1,
    left=TreeNode(
      2;
      left=nothing,
      right=TreeNode(3; left=nothing, right=nothing),
    ),
    right=TreeNode(4; left=nothing, right=nothing),
  )

  expected = TreeNode(
    1,
    left=TreeNode(
      2;
      left=nothing,
      right=TreeNode(3; left=nothing, right=nothing),
    ),
    right=TreeNode(4; left=nothing, right=nothing),
  )

  zipper = from_tree(initial)
  actual = to_tree(zipper)
  @test actual == expected
end

@testset "data is retained/2" begin
  initial = set_initial_dict()

  expected = TreeNode(
    1,
    left=TreeNode(
      2;
      left=nothing,
      right=TreeNode(3; left=nothing, right=nothing),
    ),
    right=TreeNode(4; left=nothing, right=nothing),
  )

  zipper = from_tree(initial)
  actual = to_tree(zipper)
  @test actual == expected
end

@testset "data is retained/3" begin
  initial = set_initial_dict()

  expected = Dict(
    :value => 1,
    :left => Dict(
      :value => 2,
      :left => nothing,
      :right => Dict(:value => 3, :left => nothing, :right => nothing),
    ),
    :right => Dict(:value => 4, :left => nothing, :right => nothing),
  )

  zipper = from_tree(initial)
  actual = to_dict(zipper)
  @test actual == expected
end

@testset "left/right and value" begin
  initial = TreeNode(
    1,
    left=TreeNode(
      2;
      left=nothing,
      right=TreeNode(3; left=nothing, right=nothing),
    ),
    right=TreeNode(4; left=nothing, right=nothing),
   )

  zipper = from_tree(initial)
  actual = left!(zipper) |> right! |> value
  @test actual == 3
end

@testset "dead end" begin
  initial = TreeNode(
    1,
    left=TreeNode(
      2;
      left=nothing,
      right=TreeNode(3; left=nothing, right=nothing),
    ),
    right=TreeNode(4; left=nothing, right=nothing),
   )

  zipper = from_tree(initial)
  actual = left!(zipper) |> left!
  @test actual === nothing
end

@testset "tree from deep focus" begin
  initial = set_initial_dict()

  expected = Dict(
    :value => 1,
    :left => Dict(
      :value => 2,
      :left => nothing,
      :right => Dict(:value => 3, :left => nothing, :right => nothing),
    ),
    :right => Dict(:value => 4, :left => nothing, :right => nothing),
  )

  zipper = from_tree(initial)
  actual = left!(zipper) |> right! |> to_dict
  @test actual == expected
end

@testset "tree from deep and reset focus" begin
  initial = set_initial_dict()

  expected = 1
  zipper = from_tree(initial)
  actual = left!(zipper) |> right! |> reset! |> value
  @test actual == expected
end

@testset "traversing up from to" begin
  initial = set_initial_dict()

  zipper = from_tree(initial)
  actual = up!(zipper)
  @test actual === nothing
end

@testset "traversing up from top reset" begin
  initial = set_initial_dict()
  expected = 1

  zipper = from_tree(initial)
  @test up!(zipper) === nothing

  actual = reset!(zipper) |> value
  @test actual == expected
end

@testset "left up right up left right" begin
  initial = set_initial_dict()
  zipper = from_tree(initial)

  actual = left!(zipper) |> up! |> right! |> up! |> left! |> right! |> value
  @test actual == 3
end

@testset "set value" begin
  initial = set_initial_dict()
  new_value = 5
  expected = Dict(
    :value => 1,
    :left => Dict(
      :value => new_value,
      :left => nothing,
      :right => Dict(:value => 3, :left => nothing, :right => nothing),
    ),
    :right => Dict(:value => 4, :left => nothing, :right => nothing),
  )

  zipper = from_tree(initial)
  actual = left!(zipper) |> z -> set_value(z, new_value) |> to_dict
  @test actual == expected
end

@testset "set value after traversing up" begin
  initial = set_initial_dict()
  new_value = 5
  expected = Dict(
    :value => 1,
    :left => Dict(
      :value => new_value,
      :left => nothing,
      :right => Dict(:value => 3, :left => nothing, :right => nothing),
    ),
    :right => Dict(:value => 4, :left => nothing, :right => nothing),
  )

  zipper = from_tree(initial)
  actual = left!(zipper) |> right! |> up! |> z -> set_value(z, new_value) |> to_dict
  @test actual == expected
end

@testset "set left with leaf" begin
  initial = set_initial_dict()
  new_value = Dict(:value => 5, :left => nothing, :right => nothing)
  expected = Dict(
    :value => 1,
    :left => Dict(
      :value => 2,
      :left => new_value,
      :right => Dict(:value => 3, :left => nothing, :right => nothing),
    ),
    :right => Dict(:value => 4, :left => nothing, :right => nothing),
  )

  zipper = from_tree(initial)
  tn = TreeNode(new_value[:value])
  actual = left!(zipper) |> z -> set_left!(z, tn) |> to_dict
  @test actual == expected
end

@testset "set right with null" begin
  initial = set_initial_dict()
  expected = Dict(
    :value => 1,
    :left => Dict(:value => 2, :left => nothing, :right => nothing),
    :right => Dict(:value => 4, :left => nothing, :right => nothing),
  )

  zipper = from_tree(initial)
  actual = left!(zipper) |> z -> set_right!(z, nothing) |> to_dict
  @test actual == expected
end

@testset "set right with subtree" begin
  initial = set_initial_dict()
  d = Dict(
    :value => 6,
    :left => Dict(:value => 7, :left => nothing, :right => nothing),
    :right => Dict(:value => 8, :left => nothing, :right => nothing)
  )

  expected = Dict(
    :value => 1,
    :left => Dict(
      :value => 2,
      :left => nothing,
      :right => Dict(:value => 3, :left => nothing, :right => nothing),
    ),
    :right => d
  )

  zipper = from_tree(initial)
  tn = TreeNode(d)
  actual = set_right!(zipper, tn) |> to_dict
  @test actual == expected
end

@testset "set value on deep focus" begin
  initial = set_initial_dict()
  new_value = 5
  expected = Dict(
    :value => 1,
    :left => Dict(
      :value => 2,
      :left => nothing,
      :right => Dict(:value => new_value, :left => nothing, :right => nothing),
    ),
    :right => Dict(:value => 4, :left => nothing, :right => nothing),
  )

  zipper = from_tree(initial)
  actual = left!(zipper) |> right! |> z -> set_value(z, new_value) |> to_dict
  @test actual == expected
end

@testset "different paths to same zipper" begin
  initial = set_initial_dict()

  actual = from_tree(initial) |> left! |> up! |> right! |> to_dict
  final = set_initial_dict()

  expected = from_tree(initial) |> right! |> to_dict
  @test actual == expected
end
