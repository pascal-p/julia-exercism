using Test

# include("dp_bellman_ford_sp.jl")
push!(LOAD_PATH, "./src")
using YA_BFSP_ALT

const TF_DIR = "./testfiles"

function read_sol(ifile)
  s = open(ifile) do f
    readlines(f)
  end[1]

  occursin(":", s) && (return nothing)
  T = occursin(r"\.", s) ? Float32 : Int
  return parse(T, strip(s))
end

function read_path(ifile)
  a = open(ifile) do f
    readlines(f)
  end[1]
  a == "null" && (return [])

  path = a |> s -> split(strip(s), r"[\[\],\s+]") |>
    a -> filter(s -> length(s) > 0, a) |>
    a -> map(s -> parse(Int, s), a)

  return path
end


for file in filter((fs) -> occursin(r"\Ainput_random_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile)")
  #
  ifile2 = replace(file, r"\Ainput_" => s"path_")   # get src and minimal length path
  path = read_path("$(TF_DIR)/$(ifile2)")

  @testset "for $(file)" begin
    src = length(path) > 0 ? path[1] : 1
    bfsp = BFSP{Int, Int}("$(TF_DIR)/$(file)", src; positive_weight=false)

    if exp_val == nothing
      @test has_negative_cycle(bfsp)

    else
      dst = path[end]
      @test min_dist(bfsp) == exp_val
      @test path_to(bfsp, dst) == path
    end
  end
end

@testset "BFSP basics /1" begin
  ## Prep.
  g = EWDiGraph{Int, Int}(5)

  add_edge(g, 1, 2, 4; positive_weight=false)
  add_edge(g, 1, 3, 2; positive_weight=false)
  add_edge(g, 2, 4, 4; positive_weight=false)
  add_edge(g, 3, 5, 2; positive_weight=false)
  add_edge(g, 3, 2, -1; positive_weight=false)
  add_edge(g, 5, 4, 2; positive_weight=false)

  ## Calc,
  src = 1
  bfsp = BFSP{Int, Int}(g, src)

  ## Expectations
  @test bfsp.dist_to == [0, 1, 2, 5, 4]     ## internal
  @test path_to(bfsp, 4) == [src, 3, 2, 4]

  @test min_dist(bfsp) == 1
end

@testset "BFSP basics /2" begin
  g = EWDiGraph{Int, Int}(5)

  add_edge(g, 1, 2, -1; positive_weight=false)
  add_edge(g, 1, 3, 4; positive_weight=false)
  add_edge(g, 2, 3, 3; positive_weight=false)
  add_edge(g, 2, 5, 2; positive_weight=false)
  add_edge(g, 2, 4, 2; positive_weight=false)
  add_edge(g, 4, 2, 1; positive_weight=false)
  add_edge(g, 4, 3, 5; positive_weight=false)
  add_edge(g, 5, 4, -3; positive_weight=false)

  src = 1
  bfsp = BFSP{Int, Int}(g, src)

  @test bfsp.dist_to == [0, -1, 2, -2, 1]

  @test path_to(bfsp, 5) == [src, 2, 5]
  @test path_to(bfsp, 4) == [src, 2, 5, 4]
  @test path_to(bfsp, 3) == [src, 2, 3]
end

@testset "BFSP on tiny_ewd.txt" begin
  src = 1
  bfsp = BFSP{Int, Float32}("$(TF_DIR)/tiny_ewd.txt", src)

  ## sssp ≡ Float32[0.0, 1.05, 0.26, 0.99, 0.38, 0.73, 1.51, 0.6]
  @test dist_to(bfsp, 1) ≈ 0.0    # dist(src==1, 1)
  @test dist_to(bfsp, 2) ≈ 1.05   # dist(src==1, 2)
  @test dist_to(bfsp, 7) ≈ 1.51   # dist(src==1, 7)
  @test dist_to(bfsp, 8) ≈ 0.6    # dist(src==1, 8)

  @test path_to(bfsp, 4) == [src, 3, 8, 4]
  @test path_to(bfsp, 5) == [src, 5]
end

@testset "BFSP on tiny_ewdn.txt" begin
  src = 1
  bfsp = BFSP{Int, Float32}("$(TF_DIR)/tiny_ewdn.txt", src; positive_weight=false)

  @test dist_to(bfsp, 1) ≈ 0.0    # dist(src==1, 1)
  @test dist_to(bfsp, 2) ≈ 0.93   # dist(src==1, 2)
  @test dist_to(bfsp, 7) ≈ 1.51   # dist(src==1, 7)

  @test path_to(bfsp, 6) == [src, 3, 8, 4, 7, 5, 6]
  @test path_to(bfsp, 2) == [src, 3, 8, 4, 7, 5, 6, 2]
  @test path_to(bfsp, 8) == [src, 3, 8]
end

@testset "BFSP on tiny_ewdnc.txt with negative cycle" begin
  src = 1
  bfsp = BFSP{Int, Float32}("$(TF_DIR)/tiny_ewdnc.txt", src; positive_weight=false)

  @test has_negative_cycle(bfsp)
end

@testset "on g1.txt" begin
  src = 1
  bfsp = BFSP{Int, Int}("$(TF_DIR)/g1.txt",
                                      src; positive_weight=false)

  @test has_negative_cycle(bfsp)
end

@testset "on g2.txt" begin
  src = 1
  bfsp = BFSP{Int, Int}("$(TF_DIR)/g2.txt", src; positive_weight=false)

  @test has_negative_cycle(bfsp)
end

@testset "on g3.txt" begin
  src = 1
  bfsp = BFSP{Int, Int}("$(TF_DIR)/g3.txt", src; positive_weight=false)

  @test !has_negative_cycle(bfsp)

  @test has_path_to(bfsp, 25)
  @test has_path_to(bfsp, 1000)
  @test has_path_to(bfsp, 456)

  # @test path_to(bfsp, 25) == [src, 392, 490, 324, 511, 620, 679, 806, 841, 629, 129, 828, 166, 25]
  # @test path_to(bfsp, 999) == [src, 392, 490, 324, 511, 541, 672, 534, 739, 930, 999]
  # @test path_to(bfsp, 513) == [src, 392, 490, 324, 680, 584, 658, 902, 459, 527, 761, 367, 7, 508, 513]
  # @test path_to(bfsp, 994) == [src, 392, 490, 324, 511, 620, 679, 806, 841, 963, 998, 515, 289, 566, 709, 766, 994]

  ## path_to
  # [400, 631, 290, 228, 220, 519, 367, 227, 84, 403, 319, 91, 268, 37, 895, 23, 27, 16, 116, 298, 193, 269, 90, 973, 166, 152, 543, 363, 255, 92, 39, 353, 152, 105, 81, 214, 409, 53, 24, 102, 434, 460, 758, 272, 355, 26, 324, 42, 488, 23, 163, 356, 449, 301, 171, 55, 725, 87, 138, 551, 345, 102, 108, 762, 89, 96, 333, 243, 308, 962, 26, 952, 401, 241, 443, 234, 221, 100, 5, 209, 686, 46, 487, 85, 8, 44, 578, 73, 566, 98, 95, 312, 800, 288, 235, 272, 413, 162, 843, 12, 22, 364, 219, 346, 88, 846, 378, 296, 351, 210, 242, 89, 132, 742, 113, 381, 333, 51, 264, 178, 506, 542, 129, 118, 147, 727, 538, 33, 629, 835, 413, 807, 294, 421, 26, 200, 309, 240, 55, 391, 624, 416, 527, 741, 23, 180, 663, 94, 138, 106, 427, 210, 638, 134, 508, 351, 334, 116, 691, 42, 631, 127, 236, 28, 243, 828, 32, 215, 275, 193, 211, 955, 735, 532, 69, 436, 18, 533, 223, 50, 75, 58, 287, 503, 257, 143, 177, 809, 109, 579, 137, 99, 307, 4, 543, 17, 23, 119, 11, 76, 310, 63, 997, 724, 480, 174, 648, 752, 548, 58, 25, 31, 462, 217, 29, 109, 194, 634, 551, 28, 23, 353, 182, 192, 63, 27, 62, 86, 246, 167, 9, 530, 82, 13, 113, 182, 47, 892, 122, 74, 853, 918, 193, 808, 248, 431, 154, 14, 133, 177, 204, 18, 71, 917, 13, 668, 162, 36, 46, 362, 124, 223, 108, 4, 240, 836, 491, 255, 15, 51, 21, 261, 395, 407, 67, 610, 144, 372, 291, 61, 10, 512, 752, 371, 19, 581, 40, 444, 515, 283, 189, 438, 223, 131, 617, 544, 315, 71, 530, 375, 321, 208, 292, 388, 187, 40, 79, 586, 123, 101, 136, 20, 412, 278, 296, 54, 83, 3, 80, 200, 150, 681, 651, 490, 349, 530, 258, 41, 184, 102, 136, 87, 271, 264, 93, 417, 463, 334, 179, 135, 14, 940, 163, 191, 723, 185, 121, 38, 36, 194, 327, 74, 925, 620, 711, 423, 719, 211, 250, 150, 471, 314, 65, 747, 279, 336, 243, 785, 164, 396, 854, 279, 184, 443, 807, 339, 79, 179, 921, 369, 162, 67, 311, 311, 55, 160, 589, 815, 952, 100, 7, 1, 6, 518, 30, 104, 52, 397, 29, 827, 314, 572, 920, 45, 470, 19, 113, 783, 597, 258, 789, 323, 289, 112, 60, 157, 327, 920, 362, 85, 804, 54, 401, 401, 799, 148, 377, 230, 705, 789, 395, 409, 373, 71, 995, 629, 355, 625, 252, 583, 708, 16, 334, 313, 205, 343, 325, 14, 161, 277, 499, 921, 128, 292, 231, 498, 117, 377, 124, 171, 290, 460, 348, 752, 424, 32, 118, 275, 218, 517, 30, 34, 251, 581, 525, 265, 197, 43, 148, 273, 408, 159, 6, 327, 291, 300, 133, 747, 995, 392, 354, 984, 480, 589, 92, 101, 969, 599, 339, 794, 615, 600, 158, 105, 390, 285, 885, 7, 500, 64, 324, 273, 49, 580, 423, 338, 426, 470, 385, 615, 324, 495, 57, 330, 304, 298, 459, 382, 324, 42, 235, 484, 734, 672, 635, 112, 698, 95, 401, 419, 511, 333, 511, 513, 373, 539, 379, 527, 691, 522, 239, 4, 421, 844, 521, 605, 183, 375, 334, 564, 409, 445, 543, 364, 121, 289, 326, 246, 289, 800, 967, 110, 423, 213, 403, 433, 458, 524, 85, 546, 458, 544, 852, 263, 134, 64, 553, 515, 670, 472, 746, 565, 630, 270, 332, 53, 398, 424, 340, 347, 609, 490, 299, 401, 254, 682, 705, 347, 389, 110, 712, 550, 935, 561, 171, 428, 398, 111, 517, 333, 573, 997, 511, 499, 566, 295, 851, 71, 841, 398, 660, 687, 547, 266, 423, 511, 493, 251, 565, 554, 445, 20, 311, 541, 143, 906, 298, 608, 614, 415, 810, 613, 235, 591, 598, 273, 72, 584, 292, 559, 541, 505, 603, 634, 458, 644, 466, 405, 382, 530, 683, 541, 625, 892, 84, 9, 674, 9, 620, 324, 251, 578, 722, 581, 438, 864, 708, 292, 774, 568, 484, 394, 543, 552, 693, 475, 61, 171, 206, 36, 655, 398, 259, 334, 534, 298, 792, 332, 566, 68, 475, 397, 667, 637, 881, 614, 693, 678, 410, 588, 763, 597, 545, 385, 517, 51, 659, 497, 462, 635, 192, 625, 299, 355, 344, 454, 566, 110, 534, 636, 962, 732, 971, 408, 874, 570, 379, 793, 508, 673, 594, 160, 621, 699, 562, 565, 87, 389, 695, 685, 34, 644, 332, 191, 634, 709, 785, 665, 573, 974, 736, 562, 543, 561, 701, 75, 720, 755, 546, 282, 395, 129, 550, 723, 289, 561, 515, 750, 618, 752, 607, 775, 713, 534, 771, 665, 466, 715, 781, 408, 115, 413, 793, 769, 409, 679, 628, 705, 507, 771, 343, 464, 643, 160, 588, 736, 561, 705, 742, 297, 362, 614, 560, 685, 723, 350, 292, 129, 739, 581, 569, 829, 129, 446, 206, 614, 559, 820, 774, 889, 806, 863, 932, 858, 796, 657, 397, 798, 667, 769, 759, 411, 753, 715, 288, 929, 968, 793, 163, 754, 470, 719, 618, 821, 405, 857, 424, 462, 604, 828, 499, 841, 401, 724, 659, 817, 610, 111, 734, 615, 864, 989, 362, 753, 803, 438, 517, 570, 790, 836, 567, 736, 581, 821, 810, 540, 690, 892, 829, 432, 896, 459, 122, 895, 883, 375, 644, 841, 617, 949, 376, 858, 89, 54, 715, 517, 830, 787, 641, 99, 908, 861, 862, 822, 685, 864, 811, 873, 925, 739, 693, 446, 373, 844, 771, 654, 874, 649, 295, 844, 732, 580, 478, 895, 912, 18, 607, 803, 724, 860, 863, 110, 500, 806, 934, 928, 935, 924, 766, 324, 289, 398, 841, 877, 774, 777, 589, 851, 822, 855, 860, 966, 409, 956, 803, 695, 880, 424, 783, 599, 762, 910, 864, 771, 685, 866, 956, 32, 599, 371, 720, 991, 839, 766, 741, 803, 669, 963, 930, 993]
  
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
