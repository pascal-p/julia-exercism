using Test

push!(LOAD_PATH, "./src")
using YA_BFSP

include("./utils/helper_files_fn.jl")

const TF_DIR = "./testfiles"

@testset "on g1.txt" begin
  src = 1
  T = Int
  bfsp = BFSP{T, T}("$(TF_DIR)/g1.txt", src, EWDiGraph{T, T};
                    positive_weight=false)

  @test has_negative_cycle(bfsp)
end

@testset "on g2.txt" begin
  src = 1
  T, T1 = Int, Float32
  bfsp = BFSP{T, T1}("$(TF_DIR)/g2.txt", src, EWDiGraph{T, T1};
                     positive_weight=false)

  @test has_negative_cycle(bfsp)
end

@testset "on g3.txt with src ≡ 1" begin
  src = 1
  T = Int
  bfsp = BFSP{T, T}("$(TF_DIR)/g3.txt", src, EWDiGraph{T, T};
                    positive_weight=false)

  @test !has_negative_cycle(bfsp)

  @test has_path_to(bfsp, 25)
  @test has_path_to(bfsp, 1000)
  @test has_path_to(bfsp, 456)

  @test path_to(bfsp, 25) == [(1, 392), (392, 490), (490, 324), (324, 511), (511, 620), (620, 679), (679, 806), (806, 841), (841, 629), (629, 129), (129, 828), (828, 166), (166, 25)]
  @test path_to(bfsp, 999) == [(1, 392), (392, 490), (490, 324), (324, 511), (511, 541), (541, 672), (672, 534), (534, 739), (739, 930), (930, 999)]
  @test path_to(bfsp, 513) == [(1, 392), (392, 490), (490, 324), (324, 680), (680, 584), (584, 658), (658, 902), (902, 459), (459, 527), (527, 761), (761, 367), (367, 7), (7, 508), (508, 513)]
  @test path_to(bfsp, 994) == [(1, 392), (392, 490), (490, 324), (324, 511), (511, 620), (620, 679), (679, 806), (806, 841), (841, 963), (963, 998), (998, 515), (515, 289), (289, 566), (566, 709), (709, 766), (766, 994)]

  @test dist_to(bfsp, 1) ≡ 0
  @test dist_to(bfsp, 474) ≡ 0
  @test dist_to(bfsp, 513) ≡ 1
  @test dist_to(bfsp, 999) ≡ -7
  @test dist_to(bfsp, 994) ≡ -8
  @test dist_to(bfsp, 1000) ≡ -6
  @test dist_to(bfsp, 666) ≡ 0
  @test dist_to(bfsp, 777) ≡ -9
  @test dist_to(bfsp, 42) ≡ -2

  @test min_dist(bfsp) == -12 # !
end

@testset "on g3.txt with src ≡ 399" begin
  src = 399
  T = Int
  bfsp = BFSP{T, T}("$(TF_DIR)/g3.txt", src, EWDiGraph{T, T};
                    positive_weight=false)

  @test min_dist(bfsp) == -19

  @test path_to(bfsp, 904) == [(399, 175), (175, 177), (177, 250), (250, 150), (150, 360), (360, 211), (211, 148), (148, 426), (426, 517), (517, 470), (470, 861), (861, 630), (630, 604), (604, 869), (869, 292), (292, 454), (454, 736), (736, 771), (771, 810), (810, 895), (895, 904)]

end
