using Test

include("satellite.jl")

@testset "Empty tree" begin
  preorder = []
  inorder = []

  expected = nothing
  @test tree_from_traversals(preorder, inorder) == expected
end

@testset "Tree with one item" begin
  preorder = ["a"]
  inorder = ["a"]

  expected = Node{String}("a")
  @test tree_from_traversals(preorder, inorder) == expected
end

@testset "Tree with many items/1" begin
  preorder = ["a", "i", "x", "f", "r"]
  inorder = ["i", "a", "f", "x", "r"]

  expected = Node{String}("a",
                          l=Node{String}("i"),
                          r=Node{String}("x";
                                         l=Node{String}("f"),
                                         r=Node{String}("r")
                                         )
                          )
  @test tree_from_traversals(preorder, inorder) == expected
end

@testset "Tree with many items/2" begin
  preorder = ["f", "b", "a", "d", "c", "e", "g", "i", "h"]
  inorder = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]

  expected = Node{String}("f",
                          l=Node{String}("b";
                                         l=Node{String}("a"),
                                         r=Node{String}("d";
                                                        l=Node{String}("c"),
                                                        r=Node{String}("e")
                                                        )
                                         ),
                          r=Node{String}("g";
                                         l=nothing,
                                         r=Node{String}("i";
                                                        l=Node{String}("h"),
                                                        r=nothing
                                                        )
                                 )
  )
  @test tree_from_traversals(preorder, inorder) == expected
end



@testset "Tree with many items/3" begin
  preorder = ["+", "*", "a", "-", "b", "c", "/", "d", "e"]
  inorder = ["a", "*", "b",  "-", "c", "+",  "d", "/",  "e"]

  expected = Node{String}("+",
                          l=Node{String}("*";
                                         l=Node{String}("a"),
                                         r=Node{String}("-";
                                                        l=Node{String}("b"),
                                                        r=Node{String}("c")
                                                        )
                                         ),
                          r=Node{String}("/";
                                         l=Node{String}("d"),
                                         r=Node{String}("e")
                                         )
  )
  @test tree_from_traversals(preorder, inorder) == expected
end

@testset "reject traversals of different length" begin
  preorder = ["a", "b", "c", "d"]
  inorder = ["a", "b", "c"]

  @test_throws ArgumentError tree_from_traversals(preorder, inorder)
end

@testset "reject inconsistent traversals of same length" begin
  preorder = ["a", "b", "c", "d"]
  inorder = ["a", "x", "y", "z"]

  @test_throws ArgumentError tree_from_traversals(preorder, inorder)
end

@testset "reject traversals with repeated items" begin
  preorder = ["a", "b", "c", "d"]
  inorder = ["a", "b", "c", "a"]

  @test_throws ArgumentError tree_from_traversals(preorder, inorder)
end
