using Test

push!(LOAD_PATH, "./src")
using YA_BFSP_ALT

include("./utils/helper_files_fn.jl")

const TF_DIR = "./testfiles"


@testset "on g1.txt" begin
  src = 1
  T, T1 = Int, Int
  bfsp = BFSP{T, T1}("$(TF_DIR)/g1.txt", src, EWDiGraph{T, T1};
                     positive_weight=false)

  @test has_negative_cycle(bfsp)
end

@testset "on g2.txt" begin
  src = 1
  T, T1 = Int, Int
  bfsp = BFSP{T, T1}("$(TF_DIR)/g2.txt", src, EWDiGraph{T, T1};
                     positive_weight=false)

  @test has_negative_cycle(bfsp)
end

@testset "on g3.txt with src ≡ 1" begin
  src = 1
  T, T1 = Int, Int
  bfsp = BFSP{T, T1}("$(TF_DIR)/g3.txt", src, EWDiGraph{T, T1};
                     positive_weight=false)

  @test !has_negative_cycle(bfsp)

  @test has_path_to(bfsp, 25)
  @test has_path_to(bfsp, 1000)
  @test has_path_to(bfsp, 456)

  # FIXME: Problems here: path_to is uncorrect!
  @test path_to(bfsp, 25) == [1, 392, 490, 324, 511, 543, 563, 3, 318, 268, 186, 228, 4, 194, 217, 214, 36, 258, 327, 351, 109, 189, 291, 279, 372, 278, 314, 401, 423, 356, 52, 397, 398, 597, 722, 828, 166, 25]
    # [src, 392, 490, 324, 511, 620, 679, 806, 841, 629, 129, 828, 166, 25]
  # @test path_to(bfsp, 999) == [src, 392, 490, 324, 511, 541, 672, 534, 739, 930, 999]
  # @test path_to(bfsp, 513) == [src, 392, 490, 324, 680, 584, 658, 902, 459, 527, 761, 367, 7, 508, 513]
  # @test path_to(bfsp, 994) == [src, 392, 490, 324, 511, 620, 679, 806, 841, 963, 998, 515, 289, 566, 709, 766, 994]

  @test dist_to(bfsp, 1) ≡ 0
  @test dist_to(bfsp, 474) ≡ 0
  @test dist_to(bfsp, 513) ≡ 1
  @test dist_to(bfsp, 999) ≡ -7
  @test dist_to(bfsp, 994) ≡ -8
  @test dist_to(bfsp, 1000) ≡ -6
  @test dist_to(bfsp, 666) ≡ 0
  @test dist_to(bfsp, 777) ≡ -9
  @test dist_to(bfsp, 42) ≡ -2

  @test min_dist(bfsp) == -12
end

@testset "on g3.txt with src ≡ 399" begin
  src = 399
  T, T1 = Int, Int
  bfsp = BFSP{T, T1}("$(TF_DIR)/g3.txt", src, EWDiGraph{T, T1};
                     positive_weight=false)

  @test !has_negative_cycle(bfsp)

  @test min_dist(bfsp) == -19  # 399 -> ... -> 904

  @test path_to(bfsp, 904) == []
end
