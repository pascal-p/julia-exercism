using Test

push!(LOAD_PATH, "./lib")
using YAB

@testset "one node bst" begin
  k, data = 5, 5.0
  bst = BST{Int}((k, data))

  @test key(bst) == k
end

@testset "three node bst" begin
  bst = BST{Int}([(5, 5.), (3, 3.), (9, .9)])

  @test key(bst) == 5
  @test key(left(bst)) == 3
  @test key(right(bst)) == 9

  @test size(bst) == 3
end

@testset "four node bst with insert!" begin
  bst = BST{Int}([(5, 5.), (3, 3.), (9, .9)])
  @test size(bst) == 3

  insert!(bst, (1, 1.))
  @test size(bst) == length(bst) == 4

  @test key(bst) == 5
  @test left(bst) |> key == 3
  @test left(bst) |> left |> key == 1
  @test right(bst) |> key == 9

end

@testset "search" begin
  bst = BST{Int}([(5, 5.), (3, 3.), (9, .9), (2, 2.), (4, .4)])

  @test map(nt -> nt.key, bst) == [2, 3, 4, 5, 9 ] # only keys
  @test size(bst) == 5

  @test search(bst, 2) |> to_tuple == (2, 2.0) # returns a tuple
  @test search(bst, 7) |> to_tuple == nothing
end

@testset "min" begin
  bst = BST{Int}([(5, 5.), (3, 3.), (9, .9), (2, 2.), (4, .4)])
  @test min(bst) |> to_tuple == (2, 2.0) # returns a tuple

  bst = BST{Int}()
  @test min(bst) |> to_tuple == nothing

  bst = BST{Int}([(5, 5.), (9, .9) ])
  @test min(bst) |> to_tuple == (5, 5.0) # returns a tuple
end

@testset "max" begin
  bst = BST{Int}([(5, 5.), (3, 3.), (9, .9), (2, 2.), (4, .4)])
  @test max(bst) |> to_tuple == (9, .9) # returns a tuple

  bst = BST{Int}()
  @test max(bst) |> to_tuple == nothing

  bst = BST{Int}([(5, 5.), (3, .3) ])
  @test max(bst) |> to_tuple == (5, 5.0) # returns a tuple
end

@testset "pred" begin
  bst = BST{Int}([(9,), (5,), (15,), (7,), (12,), (17,)])
  @test size(bst) == 6

  @test pred(bst, 7) |> to_tuple == (5, nothing)
  @test pred(bst, 5) |> to_tuple == nothing    # because minimum
  @test pred(bst, 9) |> to_tuple == (7, nothing)
  @test pred(bst, 12) |> to_tuple == (9, nothing)
  @test pred(bst, 15) |> to_tuple == (12, nothing)
  @test pred(bst, 17) |> to_tuple == (15, nothing)

  insert!(bst, (10,))
  @test size(bst) == length(bst) == 7
  @test pred(bst, 10) |> to_tuple == (9, nothing)
  @test pred(bst, 12) |> to_tuple == (10, nothing)
  @test pred(bst, 17) |> to_tuple == (15, nothing)

  insert!(bst, (3,))
  @test size(bst) == length(bst) == 8
  @test pred(bst, 5) |> to_tuple == (3, nothing)
  @test pred(bst, 3) |> to_tuple == nothing

  bst = BST{Int}([(3,), (1,), (2,), (5,), (4,)])
  @test size(bst) == length(bst) == 5
  @test pred(bst, 3) |> to_tuple == (2, nothing)
  @test pred(bst, 1) |> to_tuple == nothing    # because minimum
  @test pred(bst, 4) |> to_tuple == (3, nothing)
  @test pred(bst, 5) |> to_tuple == (4, nothing)
  @test pred(bst, 2) |> to_tuple == (1, nothing)
end

@testset "delete /1" begin
  # 1st bst
  bst = BST{Int}([(10,), (20,), (15,), (30,), (12,), (17, ), (16,), (18,), (19,)])
  @test size(bst) == length(bst) == 9
  @test map(nt -> nt.key, bst) == [10, 12, 15, 16, 17, 18, 19, 20, 30] # only keys

  # 1st deletion
  delete!(bst, 20)
  @test size(bst) == length(bst) == 8
  @test map(nt -> nt.key, bst) == [10, 12, 15, 16, 17, 18, 19, 30] # only keys
  @test bst.root.right.key == 19

  # 2nd deletion - with some pre-check
  @test bst.root.right.left.left.key == 12
  @test bst.root.right.left.key == 15
  delete!(bst, 12)
  @test map(nt -> nt.key, bst) == [10, 15, 16, 17, 18, 19, 30] # only keys
  @test bst.root.right.left.key == 15
  @test bst.root.right.left.left == nothing
end

@testset "delete /2" begin
  # Another bst deletion
  bst = BST{Int}([(10,), (20,), (15,), (30,), (12,), (17, ), (16,), (18,), (19,)])
  @test size(bst) == length(bst) == 9
  delete!(bst, 30)
  @test size(bst) == length(bst) == 8
  @test map(nt -> nt.key, bst) == [10, 12, 15, 16, 17, 18, 19, 20]
  @test bst.root.right.right == nothing
  @test bst.root.right.left.key == 15

  sz = 8
  for k in [10, 12, 15, 16, 17, 18, 19, 20]
    delete!(bst, k)
    sz -= 1
    @test size(bst) == length(bst) == sz
  end

  @test map(nt -> nt.key, bst) == Any[]
  @test bst.root == nothing
end

@testset "delete /3" begin
  # delete the root of the bst - its (unique) child becomes the new root
  bst = BST{Int}([(10,), (20,), (15,), (30,), (12,), (17, ), (16,), (18,), (19,)])
  @test size(bst) == length(bst) == 9
  @test map(nt -> nt.key, bst) == [10, 12, 15, 16, 17, 18, 19, 20, 30]

  delete!(bst, 10)
  @test map(nt -> nt.key, bst) == [12, 15, 16, 17, 18, 19, 20, 30]
  @test bst.root.key == 20
end

@testset "delete /4" begin
  bst = BST{Int}([(10,), (20,), (13,), (30,), (12,), (16, ), (14,), (19,), (17,)])
  @test size(bst) == length(bst) == 9
  @test bst.root.key == 10
  @test map(nt -> nt.key, bst) == [10, 12, 13, 14, 16, 17, 19, 20, 30]


  delete!(bst, 20)
  @test size(bst) == length(bst) == 8
  @test map(nt -> nt.key, bst) == [10, 12, 13, 14, 16, 17, 19, 30]
  @test bst.root.right.key == 19
  @test bst.root.right.left.right.right.key == 17


  delete!(bst, 13)
  @test size(bst) == length(bst) == 7
  @test map(nt -> nt.key, bst) == [10, 12, 14, 16, 17, 19, 30]
  @test bst.root.right.left.key == 12
end

@testset "delete /5" begin
  bst = BST{Int}([(10,), (19,), (13,), (30,), (11,), (16,), (12,), (14,), (17,)])
  @test size(bst) == length(bst) == 9
  @test map(nt -> nt.key, bst) == [10, 11, 12, 13, 14, 16, 17, 19, 30]
  @test bst.root.right.left.key == 13

  delete!(bst, 13)
  @test size(bst) == length(bst) == 8
  @test map(nt -> nt.key, bst) == [10, 11, 12, 14, 16, 17, 19, 30]
  @test bst.root.right.left.key == 12
  @test bst.root.right.left.left.key == 11

  delete!(bst, 10)
  @test size(bst) == length(bst) == 7
  @test map(nt -> nt.key, bst) == [11, 12, 14, 16, 17, 19, 30]
  @test bst.root.key == 19

  delete!(bst, 12)
  @test size(bst) == length(bst) == 6
  @test map(nt -> nt.key, bst) == [11, 14, 16, 17, 19, 30]
  @test bst.root.left.key == 11

  delete!(bst, 16)
  @test size(bst) == length(bst) == 5
  @test map(nt -> nt.key, bst) == [11, 14, 17, 19, 30]
  @test bst.root.left.right.key == 14
  @test bst.root.left.right.right.key == 17

  delete!(bst, 14)
  @test size(bst) == length(bst) == 4
  @test map(nt -> nt.key, bst) == [11, 17, 19, 30]
  @test bst.root.key == 19
  @test bst.root.left.right.key == 17

  # key no longer in the tree! == NOOP
  delete!(bst, 14)
  @test size(bst) == length(bst) == 4
  @test map(nt -> nt.key, bst) == [11, 17, 19, 30]

  delete!(bst, 11)
  @test size(bst) == length(bst) == 3
  @test map(nt -> nt.key, bst) == [17, 19, 30]
  @test bst.root.left.key == 17

  delete!(bst, 19)
  @test size(bst) == length(bst) == 2
  @test map(nt -> nt.key, bst) == [17, 30]
  @test bst.root.key == 17

  delete!(bst, 17)
  @test size(bst) == length(bst) == 1
  @test map(nt -> nt.key, bst) == [30]
  @test bst.root.key == 30

  delete!(bst, 30)
  @test size(bst) == length(bst) == 0
  @test map(nt -> nt.key, bst) == Any[]
  @test bst.root == nothing
end

@testset "insert/delete" begin
  bst = BST{Int}([(15,), (19,), (13,), (30,), (10,), (16,), (12,), (14,), (17,), (18,), (21,), (25,) ])
  @test size(bst) == length(bst) == 12
  @test map(nt -> nt.key, bst) == [10, 12, 13, 14, 15, 16, 17, 18, 19, 21, 25, 30]

  sz = 12
  for k in [10, 15, 16, 17, 18, 19, 25]
    delete!(bst, k)
    sz -= 1
    @test size(bst) == length(bst) == sz
  end

  @test map(nt -> nt.key, bst) == [12, 13, 14, 21, 30]

  for k in [16, 18, 17, 19, 10, 15, 25]
    insert!(bst, (k,))
    sz += 1
    @test size(bst) == length(bst) == sz
  end

  @test map(nt -> nt.key, bst) == [10, 12, 13, 14, 15, 16, 17, 18, 19, 21, 25, 30]


  # delete all nodes...
  for k in [12, 10, 30, 13, 25, 14, 15, 16, 17, 18, 19, 21]
    delete!(bst, k)
    sz -= 1
    @test size(bst) == length(bst) == sz
  end

  @test map(nt -> nt.key, bst) == Any[]
  @test bst.root == nothing
  @test size(bst) == 0
end
