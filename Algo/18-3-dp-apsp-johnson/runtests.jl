using Test

push!(LOAD_PATH, "../11-queue/src")
push!(LOAD_PATH, "../18-0-ewd/src")
push!(LOAD_PATH, "../18-1-dp-bellman-ford/src")
push!(LOAD_PATH, "../07-dijkstra-sp/src")
push!(LOAD_PATH, "./src")
using YA_JAPSP

const TF_DIR = "./testfiles"

include("./utils/helper_files_fn.jl")

@testset "basics" begin
  T, T1 = Int, Int
  g = YA_JAPSP.EWDiGraph{T, T1}(4)
  YA_JAPSP.build_graph!(g, [(1, 2, 4), (1, 3, 2), (2, 4, 2), (3, 2, -1), (3, 4, 3)])

  japsp = JAPSP{T, T}(g)

  @test path_to(japsp, 1, 4) == [1, 3, 2, 4]
  @test dist_to(japsp, 1, 4) == 3

  println("All dist japsp: $(japsp.distm)")
end

@testset "JAPSP on tiny_ewdnc.txt - negative cycle" begin
  T, T1 = Int, Float32
  japsp = JAPSP{T, T1}("$(TF_DIR)/tiny_ewdnc.txt", YA_JAPSP.EWDiGraph{T, T1}; positive_weight=false)

  @test has_negative_cycle(japsp)
end

@testset "JAPSP on tiny_ewd.txt" begin
  T, T1 = Int, Float32
  japsp = JAPSP{T, T1}("$(TF_DIR)/tiny_ewd.txt", YA_JAPSP.EWDiGraph{T, T1}; positive_weight=false)

  @test dist_to(japsp, 1, 1) ≈ 0.0
  @test dist_to(japsp, 1, 2) ≈ 1.05
  @test dist_to(japsp, 1, 7) ≈ 1.51
  @test dist_to(japsp, 1, 8) ≈ 0.6

  @test path_to(japsp, 1, 4) == [1, 3, 8, 4]
  @test path_to(japsp, 1, 5) == [1, 5]
end

@testset "JAPSP on tiny_ewdn.txt" begin
  T, T1 = Int, Float32
  japsp = JAPSP{T, T1}("$(TF_DIR)/tiny_ewdn.txt", YA_JAPSP.EWDiGraph{T, T1};
                       positive_weight=false)

  @test dist_to(japsp, 1, 1) ≈ 0.0
  @test dist_to(japsp, 1, 2) ≈ 0.93
  @test dist_to(japsp, 1, 7) ≈ 1.51

  @test path_to(japsp, 1, 6) == [1, 3, 8, 4, 7, 5, 6]
  @test path_to(japsp, 1, 2) == [1, 3, 8, 4, 7, 5, 6, 2]
  @test path_to(japsp, 1, 8) == [1, 3, 8]
end


for file in filter((fs) -> occursin(r"\Ainput_random_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile1 = replace(file, r"\Ainput_" => s"output_")
  exp_min = read_sol("$(TF_DIR)/$(ifile1)")

  ifile2 = replace(file, r"\Ainput_" => s"path_")   # get src and minimal length path
  exp_path = read_path("$(TF_DIR)/$(ifile2)")

  @testset "for $(file)" begin
    src = length(exp_path) > 0 ? exp_path[1] : 1
    T = Int
    japsp = JAPSP{T, T}("$(TF_DIR)/$(file)", YA_JAPSP.EWDiGraph{T, T};
                        positive_weight=false)

    if exp_min == nothing
      @test has_negative_cycle(japsp)

    else
      act_mindist, act_path = min_dist(japsp)

      @test act_mindist == exp_min
      @test act_path == exp_path
    end
  end
end
