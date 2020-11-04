using Test

include("counting_inversions.jl")

@testset "basic tests on inversions" begin
  @test counting_inversions([])[end] == 0                    # emtpy array, no inversions
  @test counting_inversions([1])[end] == 0                   # singleton array, no inversions
  @test counting_inversions([1, 2])[end] == 0                # sorted pair, no inversion
  @test counting_inversions([1, 2, 3])[end] == 0             # sorted pair, no inversion

  @test counting_inversions([1, 2, 3, 4, 5, 6, 7])[end] == 0 # sorted array, no inversions
  @test counting_inversions([0, 2, 4, 6, 8, 10])[end] == 0   # sorted array, no inversions

  @test counting_inversions([2, 1])[end] == 1                # inverted pair == 1 inversion
  @test counting_inversions([3, 2, 1])[end] == 3             # inverted triplet == 2 inversions

  @test counting_inversions([true, false])[end] == 1         # [1, 0] => 1 inversion
end

@testset "tests on inversions" begin
  @test counting_inversions([1, 3, 5, 2, 4, 6])[end] == 3
  @test counting_inversions([1, 5, 6, 4, 20])[end] == 2
  @test counting_inversions([1, 20, 6, 4, 5 ])[end] == 5
  @test counting_inversions([2, 4, 1, 3, 5])[end] == 3

  @test counting_inversions([1, 4, 3, 2, 5, 6, 10, 9, 7, 8])[end] == 8

  @test counting_inversions([14, 12, 10, 8, 6, 4, 2, 0])[end] == 28  # max. num of inversions with sorted array in decr. order
end

@testset "more tests" begin
  # src: http://www.algorithmsilluminated.org/datasets/problem3.5test.txt
  @test counting_inversions([54044, 14108, 79294, 29649, 25260,
                             60660, 2995, 53777, 49689, 9083])[end] == 28
end

@testset "coursera Stanford Algo - The basics" begin
  # src: http://www.algorithmsilluminated.org/datasets/problem3.5.txt
  # downloade locally

  ary = open("file.txt.BAK") do f
    readlines(f)
  end |> a -> map(s -> parse(Int, s), a)

  @test counting_inversions(ary)[end] == 2_407_905_288
end

@testset "tests with Float" begin
  @test counting_inversions([1., 2., 3., 4., 5., 6., 7.])[end] == 0
  @test counting_inversions([1., 4., 3., 2., 5., 6., 10., 9., 7., 8.])[end] == 8

  @test counting_inversions([14., 12., 10., 8., 6., 4., 2., 0.])[end] == 28

  @test counting_inversions([5404.4, 14.108, 79.294, 296.49, 252.60,
                             6.0660, 2.995, 53.777, 49.689, 90.83])[end] == 28
end

@testset "Exceptions" begin
  @test_throws ArgumentError counting_inversions(["titi", "totoche", "tutu", "tata"])

  @test_throws ArgumentError counting_inversions([[1, 2, 3], [4, 5, 6]])
end
