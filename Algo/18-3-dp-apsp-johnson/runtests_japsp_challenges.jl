using Test

push!(LOAD_PATH, "../11-queue/src")
push!(LOAD_PATH, "../18-0-ewd/src")
push!(LOAD_PATH, "../18-1-dp-bellman-ford/src")
push!(LOAD_PATH, "../07-dijkstra-sp/src")
push!(LOAD_PATH, "./src")
using YA_JAPSP

include("./utils/helper_files_fn.jl")

const TF_DIR = "./testfiles"

@testset "on g1.txt" begin
  T = Int32
  japsp = JAPSP{T, T}("$(TF_DIR)/g1.txt", YA_JAPSP.EWDiGraph{T, T}; positive_weight=false)

  @test has_negative_cycle(japsp)
end

@testset "on g2.txt" begin
  T = Int32
  japsp = JAPSP{T, T}("$(TF_DIR)/g2.txt", YA_JAPSP.EWDiGraph{T, T}; positive_weight=false)

  @test has_negative_cycle(japsp)
end

@testset "on g3.txt" begin
  T = Int32
  japsp = JAPSP{T, T}("$(TF_DIR)/g3.txt", YA_JAPSP.EWDiGraph{T, T}; positive_weight=false)

  @test !has_negative_cycle(japsp)

  @test has_path_to(japsp, T(1), T(25))
  @test has_path_to(japsp, T(1), T(1000))
  @test has_path_to(japsp, T(1), T(456))

  @test dist_to(japsp, T(1), T(1)) ≡ T(0)
  @test dist_to(japsp, T(1), T(474)) ≡ T(0)
  @test dist_to(japsp, T(1), T(513)) ≡ T(1)
  @test dist_to(japsp, T(1), T(999)) ≡ T(-7)
  @test dist_to(japsp, T(1), T(994)) ≡ T(-8)
  @test dist_to(japsp, T(1), T(1000)) ≡ T(-6)
  @test dist_to(japsp, T(1), T(666)) ≡ T(0)
  @test dist_to(japsp, T(1), T(777)) ≡ T(-9)
  @test dist_to(japsp, T(1), T(42)) ≡ T(-2)

  ## FIXME: discrepancy with FW APSP
  # @test path_to(japsp, T(1), T(25)) == T[1, 392, 490, 324, 511, 620, 679, 806, 841, 629, 129, 828, 166, 25]
  # T[1, 392, 490, 324, 511,
  #   543, 563, 3, 318, 268, 186, 228, 4, 194, 217, 214, 36, 258, 327, 351, 109, 189, 291, 279, 372, 278, 314, 401, 423, 356, 52, 397, 398, 597, 722,
  #   828, 166, 25]

  # @test path_to(japsp, T(1), T(999)) == T[1, 392, 490, 324, 511, 541, 672, 534, 739, 930, 999]
  # @test path_to(japsp, T(1), T(513)) == T[1, 392, 490, 324, 511, 543, 563, 3, 318, 268, 13, 234, 76, 200, 320, 225, 230, 79, 307, 193, 243, 367, 7, 508, 513]
  # @test path_to(japsp, T(1), T(994)) == T[1, 392, 490, 324, 511, 543, 563, 3, 318, 268, 186, 228, 4, 194, 217, 214, 36, 258, 327, 351, 109, 189, 291, 279, 372, 278, 314, 401, 423, 515, 289, 566, 709, 766, 994]

  ## Answer for Assignment #1
  @test min_dist(japsp) == (-19,
                            T[399, 175, 177, 250, 359, 463, 239, 551, 60, 415, 377, 458, 665, 796, 845, 401, 604, 869, 292, 454, 736, 771, 810, 895, 904])
                            # T[399, 175, 177, 187, 200, 320, 225, 230, 79, 307, 193, 58, 182, 223, 179, 194, 217, 214, 36, 258, 327, 351,
                            #   109, 189, 291, 279, 372, 278, 314, 401, 423, 515, 289, 566, 625, 438, 292, 454, 736, 771, 810, 895, 904])
end


@testset "on large.txt" begin
  T = Int32
  japsp = JAPSP{T, T}("$(TF_DIR)/large.txt", YA_JAPSP.EWDiGraph{T, T}; positive_weight=false)

  @test min_dist(japsp) == (-6,
                            T[11658, 11124, 17194, 13552, 9563, 2155, 17177, 12835, 7218, 17150, 18405, 14044, 7292, 11765, 3909, 15200, 4323, 19567, 2223])
end

# Test Summary: | Pass  Total
# on g1.txt     |    1      1

# Test Summary: | Pass  Total
# on g2.txt     |    1      1

# Test Summary: | Pass  Total
# on g3.txt     |   18     18

# Test Summary: | Pass  Total
# on large.txt  |    1      1
