# canonical data version: 1.2.0

using Test

include("binary-search.jl")

@testset "default binary search" begin
  @testset "value in array" begin
    @test binarysearch([6], 6) == 1:1
    @test binarysearch([1, 3, 4, 6, 8, 9, 11], 6) == 4:4
    @test binarysearch([1, 3, 4, 6, 8, 9, 11], 1) == 1:1
    @test binarysearch([1, 3, 4, 6, 8, 9, 11], 11) == 7:7
    @test binarysearch([1, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 634], 144) == 10:10
    @test binarysearch([1, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377], 21) == 6:6

    # only first occ
    @test binarysearch([1, 2, 3, 5, 7, 8, 13, 17, 19, 20, 21, 21, 21, 21, 21, 21, 21, 21, 23, 25, 27,
                        34, 55, 89, 144, 233, 377, 379, 391, 393, 297, 400],
                       21) == 16:16
  end

  @testset "value not in array" begin
    @test binarysearch([1, 3, 4, 6, 8, 9, 11], 7) == 5:4
    @test binarysearch([1, 3, 4, 6, 8, 9, 11], 0) == 1:0
    @test binarysearch([1, 3, 4, 6, 8, 9, 11], 13) == 8:7
    @test binarysearch([], 1) == 1:0
  end

  @testset "multiple matches" begin
    @test binarysearch([1, 1, 1, 2, 2, 3, 3, 4, 5], 2; all=true) == 4:5
    @test binarysearch([1, 2, 2, 2, 3, 3, 4, 4, 5], 2; all=true) == 2:4
    @test binarysearch([0, 1, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 5, 6, 7], 3; all=true) == 6:11
    @test binarysearch([1, 1, 2, 3, 3, 4], 1; all=true) == 1:2
    @test binarysearch([1, 2, 3, 4, 5, 6, 7, 7, 7, 7], 7; all=true) == 7:10

    @test binarysearch([1, 2, 3, 5, 7, 8, 13, 17, 19, 20, 21, 21, 21, 21, 21, 21, 21, 21, 23, 25, 27,
                        34, 55, 89, 144, 233, 377, 379, 391, 393, 297, 400],
                       21; all=true) == 11:18
  end
end

@testset "bonus tasks" begin
  @testset "reverse search" begin
    @testset "value in array" begin
      @test_skip binarysearch([6], 6, rev = true) == 1:1
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 6, rev = true) == 4:4
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 1, rev = true) == 7:7
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 11, rev = true) == 1:1
      @test_skip binarysearch([634, 377, 233, 144, 89, 55, 34, 21, 13, 8, 5, 3, 1], 144, rev = true) == 4:4
      @test_skip binarysearch([377, 233, 144, 89, 55, 34, 21, 13, 8, 5, 3, 1], 21, rev = true) == 7:7
    end

    @testset "value not in array" begin
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 7, rev = true) == 4:3
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 0, rev = true) == 8:7
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 13, rev = true) == 1:0
      @test_skip binarysearch([], 1, rev = true) == 1:0
    end
  end

  @testset "apply transformation" begin
    @testset "value in array" begin
      @test_skip binarysearch([5.5], 6, by = round) == 1:1
      @test_skip binarysearch([1.1, 2.9, 4.4, 5.5, 8.1, 9.0, 10.8], 6, by = round) == 4:4
      @test_skip binarysearch([1.1, 2.9, 4.4, 5.5, 8.1, 9.0, 10.8], 1, by = round) == 1:1
      @test_skip binarysearch([1.1, 2.9, 4.4, 5.5, 8.1, 9.0, 10.8], 11, by = round) == 7:7
      @test_skip binarysearch([1, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 634], 144.4, by = round) == 10:10
      @test_skip binarysearch([1, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377], 20.6, by = round) == 6:6
    end
    @testset "value not in array" begin
      @test_skip binarysearch([1.1, 2.9, 4.4, 5.5, 8.1, 9.0, 10.8], 7, by = round) == 5:4
      @test_skip binarysearch([1.1, 2.9, 4.4, 5.5, 8.1, 9.0, 10.8], 0, by = round) == 1:0
      @test_skip binarysearch([1.1, 2.9, 4.4, 5.5, 8.1, 9.0, 10.8], 13, by = round) == 8:7
      @test_skip binarysearch([], 1, by = round) == 1:0
    end
  end

  @testset "compare with > instead of <" begin
    # this is equivalent to searching in reverse order
    @testset "value in array" begin
      @test_skip binarysearch([6], 6, lt = >) == 1:1
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 6, lt = >) == 4:4
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 1, lt = >) == 7:7
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 11, lt = >) == 1:1
      @test_skip binarysearch([634, 377, 233, 144, 89, 55, 34, 21, 13, 8, 5, 3, 1], 144, lt = >) == 4:4
      @test_skip binarysearch([377, 233, 144, 89, 55, 34, 21, 13, 8, 5, 3, 1], 21, lt = >) == 7:7
    end

    @testset "value not in array" begin
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 7, lt = >) == 4:3
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 0, lt = >) == 8:7
      @test_skip binarysearch([11, 9, 8, 6, 4, 3, 1], 13, lt = >) == 1:0
      @test_skip binarysearch([], 1, lt = >) == 1:0
    end
  end
end
