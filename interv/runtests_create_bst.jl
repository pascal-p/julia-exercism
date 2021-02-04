using Test

include("./create_bst.jl")

@testset "bst with 1 node" begin
  T = Int
  bst = create_bst(T[1]) # BST{Int64}(<key: 2, data: nothing, size: 1, parent: <>, left: <>, right: <>)

  @test key(bst) == 1
  @test size(bst) == 1
  @test height(bst) == 1
end

@testset "bst with 2 nodes" begin
  T = Int
  bst = create_bst(T[1, 2])

  @test key(bst) == 1
  @test size(bst) == 2
  @test height(bst) == 2
end

@testset "bst with 3 nodes (complete bst)" begin
  T = Int
  bst = create_bst(T[1, 2, 3])

  @test key(bst) == 2
  @test size(bst) == 3
  @test height(bst) == 2
end

@testset "bst with 8 nodes" begin
  T = Int
  bst = create_bst(T[1, 2, 5, 7, 9, 13, 15, 17])

  @test key(bst) == 7
  @test size(bst) == 8
  @test height(bst) == 4
end

for p in (8, 10, 16, 20, 24, 25, 26)
  @testset "bst with $(2^p) nodes" begin
    @time bst = create_bst(collect(1:2^p))

    @test key(bst) == 2^(p - 1)
    @test size(bst) == 2^p
    @test height(bst) == p + 1
  end
end


#   0.000091 seconds (519 allocations: 26.281 KiB)
# Test Summary:      | Pass  Total
# bst with 256 nodes |    3      3

#   0.000345 seconds (4.63 k allocations: 144.500 KiB)
# Test Summary:       | Pass  Total
# bst with 1024 nodes |    3      3

#   0.020419 seconds (456.59 k allocations: 11.467 MiB)
# Test Summary:        | Pass  Total
# bst with 65536 nodes |    3      3

#   0.382403 seconds (7.34 M allocations: 184.055 MiB, 13.54% gc time)
# Test Summary:          | Pass  Total
# bst with 1048576 nodes |    3      3

#   6.909275 seconds (117.54 M allocations: 2.876 GiB, 22.09% gc time)
# Test Summary:           | Pass  Total
# bst with 16777216 nodes |    3      3

# 20.159819 seconds (235.08 M allocations: 5.753 GiB, 47.26% gc time)
# Test Summary:           | Pass  Total
# bst with 33554432 nodes |    3      3
# ≈ 3 × 2^24 nodes

#  55.770026 seconds (470.15 M allocations: 11.506 GiB, 62.87% gc time)
# Test Summary:           | Pass  Total
# bst with 67108864 nodes |    3      3
# ≈ 3 × 2^25 nodes
