using Test

include("./minimax.jl")

function tree1()
  T = Int64
  [
    [[NT{T}[8, 5], NT{T}[6, -4]], [NT{T}[3, 8], NT{T}[4, -6]]],
    [[NT{T}[1, 10], NT{T}[5, 2]], [NT{T}[100, 100], NT{T}[55, 65]]],
  ]
end

function tree2()
  T = Int64
  [
    [[NT{T}[8, 7], NT{T}[3, 9]], [NT{T}[9, 8], NT{T}[2, 4]]],
    [[NT{T}[1, 8], NT{T}[8, 9]], [NT{T}[9, 9], NT{T}[3, 4]]],
  ]
end

function tree3()
  # like tree1 with missing value => that don't need to be eval'ed when
  # using α-β pruning
  T = Int64
  [
    [[NT{T}[8, 5], NT{T}[6, -4]], [NT{T}[3, 8], NT{T}[4, -6]]],
    [[NT{T}[1, nothing], NT{T}[5, 2]], [NT{T}[nothing, nothing], NT{T}[nothing, nothing]]],
  ]
end

function tree4()
  T = Int64
  [
   [NT{T}[-1, 3], NT{T}[5, nothing]],
   [NT{T}[-6, -4], NT{T}[nothing, nothing]]
  ]
end

@testset "pure minimax" begin
  tree = Node{Int}(tree1())

  @test minimax(tree, 4, true, Float32) == Float32(3.0)
end

@testset "pure minimax/2" begin
  tree = Node{Int}(tree2())

  @test minimax(tree, 4, true, Float32) == Float32(8.0)
end

@testset "minimax α-β /1" begin
  tree = Node{Int}(tree1())

  @test minimax(tree, 4, true; α=-Inf32, β=Inf32) == Float32(3.0)
end

@testset "minimax α-β /2" begin
  tree = Node{Int}(tree2())

  @test minimax(tree, 4, true; α=-Inf32, β=Inf32) == Float32(8.0)
end

@testset "minimax α-β /3" begin
  tree = Node{Int}(tree3())

  @test minimax(tree, 4, true; α=-Inf32, β=Inf32) == Float32(3.0)
end

@testset "minimax α-β /4" begin
  tree = Node{Int}(tree4())

  @test minimax(tree, 3, true; α=-Inf32, β=Inf32) == Float32(3.0)
end
