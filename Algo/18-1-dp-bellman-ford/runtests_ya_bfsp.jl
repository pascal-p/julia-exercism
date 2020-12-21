using Test

push!(LOAD_PATH, "./src")
using YA_BFSP

include("./utils/helper_files_fn.jl")

const TF_DIR = "./testfiles"


@testset "basics /1" begin
  ## build graph
  g = YA_BFSP.EWDiGraph{Int, Int}(5)

  add_edge(g, 1, 2, 4; positive_weight=false)
  add_edge(g, 1, 3, 2; positive_weight=false)
  add_edge(g, 2, 4, 4; positive_weight=false)

  add_edge(g, 3, 5, 2; positive_weight=false)
  add_edge(g, 3, 2, -1; positive_weight=false)

  add_edge(g, 5, 4, 2; positive_weight=false)

  ##
  src = 1
  bfsp = BFSP{Int, Int}(g, src)

  @test bfsp.dist_to == [0, 1, 2, 5, 4]

  @test has_path_to(bfsp, 4)
  @test path_to(bfsp, 4) == [(1, 3), (3, 2), (2, 4)]   ## dist(src ≡ 1, 4)
end

@testset "BFSP basics /2" begin
  ## build graph
  g =  YA_BFSP.EWDiGraph{Int, Int}(5)

  add_edge(g, 1, 2, -1; positive_weight=false)
  add_edge(g, 1, 3, 4; positive_weight=false)

  add_edge(g, 2, 3, 3; positive_weight=false)
  add_edge(g, 2, 5, 2; positive_weight=false)
  add_edge(g, 2, 4, 2; positive_weight=false)

  add_edge(g, 4, 2, 1; positive_weight=false)
  add_edge(g, 4, 3, 5; positive_weight=false)

  add_edge(g, 5, 4, -3; positive_weight=false)

  ##
  src = 1
  bfsp = BFSP{Int, Int}(g, src)

  @test bfsp.dist_to == [0, -1, 2, -2, 1]

  @test path_to(bfsp, 5) == [(src, 2), (2, 5)]
  @test path_to(bfsp, 4) == [(src, 2), (2, 5), (5, 4)]
  @test path_to(bfsp, 3) == [(src, 2), (2, 3)]
end

@testset "BFSP on tiny_ewd.txt" begin
  src = 1
  T, T1 = Int, Float32
  bfsp = BFSP{T, T1}("$(TF_DIR)/tiny_ewd.txt", src, EWDiGraph{T, T1})

  @test dist_to(bfsp, 1) ≈ 0.0    # dist(src==1, 1)
  @test dist_to(bfsp, 2) ≈ 1.05   # dist(src==1, 2)
  @test dist_to(bfsp, 7) ≈ 1.51   # dist(src==1, 7)
  @test dist_to(bfsp, 8) ≈ 0.6    # dist(src==1, 8)

  @test path_to(bfsp, 4) == [(src, 3), (3, 8), (8, 4)]
  @test path_to(bfsp, 5) == [(src, 5)]
end

@testset "BFSP on tiny_ewdn.txt" begin
  src = 1
  T, T1 = Int, Float32
  bfsp = BFSP{T, T1}("$(TF_DIR)/tiny_ewdn.txt", src, EWDiGraph{T, T1};
                     positive_weight=false)

  @test dist_to(bfsp, 1) ≈ 0.0    # dist(src==1, 1)
  @test dist_to(bfsp, 2) ≈ 0.93   # dist(src==1, 2)
  @test dist_to(bfsp, 7) ≈ 1.51   # dist(src==1, 7)

  @test path_to(bfsp, 6) == [(src, 3), (3, 8), (8, 4), (4, 7), (7, 5), (5, 6)]
  @test path_to(bfsp, 2) == [(src, 3), (3, 8), (8, 4), (4, 7), (7, 5), (5, 6), (6, 2)]
  @test path_to(bfsp, 8) == [(src, 3), (3, 8)]
end

@testset "BFSP on tiny_ewdnc.txt with negative cycle" begin
  src = 1
  T, T1 = Int, Float32
  bfsp = BFSP{T, T1}("$(TF_DIR)/tiny_ewdnc.txt", src, EWDiGraph{T, T1};
                     positive_weight=false)

  @test has_negative_cycle(bfsp)
  @test negative_cycle(bfsp) == [(5, 6), (6, 5)]  ## a negative cycle
  @test has_path_to(bfsp, 5)
  @test_throws ArgumentError dist_to(bfsp, 5)     ## because negative cycle
end

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

@testset "on g3.txt" begin
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

  @test min_dist(bfsp) == -12

  ## println(map(t -> t[1], bfsp.edge_to))
  # [-1, 631, 563, 228, 505, 519, 367, 684, 84, 403, 319, 91, 268, 201, 895, 643, 27, 690, 158, 298, 193, 491, 90, 973, 166, 152, 543, 973, 255, 92, 39, 353, 152, 105, 81, 214, 409, 405, 253, 102, 434, 460, 758, 330, 358, 26, 324, 235, 488, 216, 866, 739, 449, 301, 463, 55, 725, 193, 455, 551, 345, 378, 108, 762, 448, 96, 429, 243, 308, 962, 26, 952, 401, 480, 443, 234, 221, 100, 230, 209, 997, 46, 487, 244, 8, 391, 578, 73, 566, 98, 931, 312, 859, 288, 235, 405, 413, 611, 843, 12, 22, 364, 219, 386, 88, 846, 378, 296, 564, 210, 242, 468, 132, 742, 113, 381, 576, 51, 264, 569, 506, 542, 129, 118, 147, 727, 538, 33, 629, 851, 434, 807, 294, 457, 26, 200, 872, 240, 55, 391, 624, 416, 527, 846, 507, 288, 721, 211, 138, 106, 427, 773, 638, 134, 508, 351, 334, 423, 691, 42, 631, 127, 236, 84, 243, 828, 224, 215, 275, 193, 211, 955, 735, 532, 602, 528, 175, 709, 223, 50, 354, 58, 670, 503, 257, 268, 177, 809, 278, 579, 453, 276, 307, 244, 543, 17, 23, 119, 11, 187, 310, 490, 997, 724, 480, 174, 648, 752, 548, 377, 360, 31, 462, 217, 29, 428, 450, 634, 666, 70, 352, 353, 182, 192, 672, 27, 62, 186, 246, 225, 9, 530, 82, 13, 719, 182, 47, 892, 463, 74, 853, 918, 193, 808, 248, 431, 797, 694, 375, 177, 204, 18, 71, 917, 13, 668, 615, 36, 46, 482, 231, 377, 108, 211, 240, 836, 491, 318, 15, 51, 21, 504, 395, 407, 67, 672, 144, 372, 291, 631, 713, 512, 752, 650, 447, 581, 40, 444, 515, 283, 189, 438, 223, 131, 617, 544, 315, 71, 530, 375, 321, 208, 292, 388, 187, 40, 79, 586, 385, 101, 136, 20, 412, 278, 296, 54, 840, 3, 491, 200, 150, 681, 651, 490, 349, 530, 258, 41, 531, 199, 136, 87, 271, 264, 93, 782, 463, 334, 502, 135, 721, 940, 163, 191, 723, 185, 121, 914, 36, 194, 327, 74, 925, 620, 711, 423, 719, 211, 656, 150, 471, 314, 65, 747, 279, 336, 761, 785, 164, 396, 854, 868, 300, 443, 807, 339, 79, 899, 921, 369, 162, 67, 311, 344, 55, 160, 589, 815, 952, 100, 7, 1, 880, 518, 584, 104, 52, 397, 29, 827, 845, 572, 920, 45, 470, 19, 113, 783, 597, 653, 789, 698, 289, 468, 60, 157, 327, 920, 613, 85, 804, 54, 401, 401, 799, 148, 377, 230, 705, 789, 395, 409, 531, 71, 995, 629, 355, 829, 658, 583, 708, 16, 334, 579, 205, 343, 325, 14, 161, 277, 561, 921, 128, 292, 246, 498, 117, 377, 902, 171, 290, 460, 359, 752, 424, 445, 249, 275, 425, 517, 286, 303, 251, 581, 525, 265, 197, 145, 148, 273, 408, 487, 6, 327, 615, 300, 133, 747, 995, 392, 354, 984, 480, 589, 92, 101, 969, 599, 339, 794, 615, 700, 341, 221, 390, 467, 919, 7, 500, 64, 324, 273, 508, 700, 998, 338, 426, 470, 385, 615, 324, 495, 57, 377, 424, 298, 459, 429, 324, 685, 235, 484, 734, 672, 635, 112, 698, 95, 401, 553, 511, 333, 511, 513, 373, 539, 379, 527, 925, 522, 239, 4, 526, 844, 521, 605, 183, 375, 947, 644, 409, 445, 543, 407, 524, 289, 326, 246, 289, 800, 967, 110, 423, 213, 403, 438, 458, 524, 150, 546, 458, 785, 852, 680, 706, 64, 553, 515, 670, 472, 746, 565, 799, 270, 332, 53, 398, 424, 340, 347, 609, 490, 299, 630, 589, 682, 705, 812, 389, 110, 712, 550, 935, 561, 171, 428, 398, 111, 517, 511, 573, 997, 511, 499, 566, 295, 851, 71, 841, 398, 660, 687, 547, 299, 887, 511, 493, 251, 565, 554, 445, 20, 311, 541, 143, 906, 298, 608, 614, 415, 970, 613, 235, 591, 598, 636, 511, 584, 292, 559, 541, 505, 603, 634, 458, 644, 466, 405, 382, 530, 815, 541, 625, 892, 84, 9, 674, 9, 620, 324, 511, 578, 722, 581, 438, 864, 741, 292, 774, 568, 484, 615, 543, 552, 693, 475, 624, 171, 206, 36, 655, 398, 259, 334, 534, 298, 792, 332, 566, 68, 475, 397, 667, 637, 881, 614, 693, 678, 438, 588, 763, 597, 545, 385, 517, 51, 659, 663, 462, 635, 192, 625, 299, 355, 344, 454, 566, 110, 534, 636, 962, 732, 971, 660, 874, 857, 379, 793, 706, 673, 594, 160, 867, 699, 562, 565, 87, 389, 695, 685, 527, 644, 703, 191, 634, 709, 785, 665, 573, 974, 736, 562, 543, 561, 966, 75, 720, 755, 991, 282, 395, 480, 550, 723, 289, 561, 515, 750, 618, 752, 607, 775, 713, 534, 771, 665, 466, 715, 781, 408, 115, 413, 793, 769, 409, 679, 628, 705, 507, 771, 343, 464, 643, 160, 588, 736, 561, 705, 742, 297, 362, 614, 560, 685, 723, 350, 292, 129, 739, 581, 569, 829, 129, 446, 206, 614, 559, 820, 774, 963, 806, 863, 932, 858, 796, 657, 397, 862, 667, 769, 759, 783, 753, 715, 288, 929, 968, 793, 163, 754, 470, 719, 618, 821, 405, 857, 424, 462, 604, 828, 499, 841, 401, 724, 659, 817, 610, 111, 734, 615, 864, 989, 362, 753, 803, 438, 517, 570, 790, 836, 567, 736, 581, 821, 810, 540, 690, 892, 829, 432, 896, 658, 122, 895, 883, 375, 644, 841, 617, 949, 376, 858, 89, 54, 715, 517, 830, 787, 641, 576, 908, 861, 862, 822, 685, 864, 811, 873, 925, 739, 693, 446, 373, 844, 771, 654, 874, 649, 295, 844, 732, 580, 478, 895, 912, 18, 607, 803, 724, 860, 863, 110, 500, 806, 934, 928, 935, 924, 766, 324, 289, 963, 841, 877, 774, 777, 589, 851, 822, 855, 860, 966, 409, 956, 803, 695, 880, 424, 783, 599, 762, 977, 864, 771, 685, 866, 956, 32, 599, 371, 720, 991, 839, 766, 741, 803, 669, 963, 930, 993]
end


for file in filter((fs) -> occursin(r"\Ainput_random_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile1 = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile1)")

  ifile2 = replace(file, r"\Ainput_" => s"path_")   # get src and minimal length path
  path = read_path("$(TF_DIR)/$(ifile2)")

  @testset "for $(file)" begin
    src = length(path) > 0 ? path[1] : 1
    T = Int
    bfsp = BFSP{T, T}("$(TF_DIR)/$(file)", src, EWDiGraph{T, T};
                      positive_weight=false)

    if exp_val == nothing
      @test has_negative_cycle(bfsp)

    else
      dst = path[end]
      act_path = path_to(bfsp, dst) |>
        a -> map(t -> t[1], a)
      push!(act_path, dst)

      @test min_dist(bfsp) == exp_val
      @test path == act_path
    end
  end
end
