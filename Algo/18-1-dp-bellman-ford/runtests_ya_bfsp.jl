using Test

push!(LOAD_PATH, "./src")
push!(LOAD_PATH, "../11-queue/src")
push!(LOAD_PATH, "../18-0-ewd/src")

using YA_BFSP

include("./utils/helper_files_fn.jl")

const TF_DIR = "./testfiles"


@testset "basics /1" begin
  ## build graph
  g = YA_BFSP.EWDiGraph{Int, Int}(5)

  ## (1, 2, 4) - edge from vertex 1 to vertex 2 weight 4
  YA_BFSP.build_graph!(g, [ (1, 2, 4), (1, 3, 2), (2, 4, 4), (3, 5, 2),
                            (3, 2, -1), (5, 4, 2), (5, 1, 0) ])
  ##
  src = 1
  bfsp = BFSP{Int, Int}(g, src)

  @test bfsp.dist_to == [0, 1, 2, 5, 4]

  @test has_path_to(bfsp, 4)
  @test path_to(bfsp, 4) == [1, 3, 2, 4]   ## dist(src ≡ 1, 4)
end

@testset "BFSP basics /2" begin
  ## build graph
  g = YA_BFSP.EWDiGraph{Int, Int}(5)
  ## (1, 2, -1) - edge from vertex 1 to vertex 2 weight -1
  YA_BFSP.build_graph!(g, [ (1, 2, -1), (1, 3, 4), (2, 3, 3), (2, 5, 2),
                            (2, 4, 2), (4, 2, 1), (4, 3, 5), (5, 4, -3) ])
  ##
  src = 1
  bfsp = BFSP{Int, Int}(g, src)

  @test bfsp.dist_to == [0, -1, 2, -2, 1]

  @test path_to(bfsp, 5) == [src, 2, 5]
  @test path_to(bfsp, 4) == [src, 2, 5, 4]
  @test path_to(bfsp, 3) == [src, 2, 3]
end

@testset "BFSP on tiny_ewd.txt" begin
  src = 1
  T, T1 = Int, Float32
  bfsp = BFSP{T, T1}("$(TF_DIR)/tiny_ewd.txt", src, YA_BFSP.EWDiGraph{T, T1})

  @test dist_to(bfsp, 1) ≈ 0.0    # dist(src==1, 1)
  @test dist_to(bfsp, 2) ≈ 1.05   # dist(src==1, 2)
  @test dist_to(bfsp, 7) ≈ 1.51   # dist(src==1, 7)
  @test dist_to(bfsp, 8) ≈ 0.6    # dist(src==1, 8)

  @test path_to(bfsp, 4) == [src, 3, 8, 4]
  @test path_to(bfsp, 5) == [src, 5]
end

@testset "BFSP on tiny_ewdn.txt" begin
  src = 1
  T, T1 = Int, Float32
  bfsp = BFSP{T, T1}("$(TF_DIR)/tiny_ewdn.txt", src, YA_BFSP.EWDiGraph{T, T1};
                     positive_weight=false)

  @test dist_to(bfsp, 1) ≈ 0.0    # dist(src==1, 1)
  @test dist_to(bfsp, 2) ≈ 0.93   # dist(src==1, 2)
  @test dist_to(bfsp, 7) ≈ 1.51   # dist(src==1, 7)

  @test path_to(bfsp, 6) == [src, 3, 8, 4, 7, 5, 6]
  @test path_to(bfsp, 2) == [src, 3, 8, 4, 7, 5, 6, 2]
  @test path_to(bfsp, 8) == [src, 3, 8]
end

@testset "BFSP on tiny_ewdnc.txt with negative cycle" begin
  src = 1
  T, T1 = Int, Float32
  bfsp = BFSP{T, T1}("$(TF_DIR)/tiny_ewdnc.txt", src, YA_BFSP.EWDiGraph{T, T1};
                     positive_weight=false)

  @test has_negative_cycle(bfsp)
  @test negative_cycle(bfsp) == [(5, 6), (6, 5)]  ## a negative cycle
  @test has_path_to(bfsp, 5)
  @test_throws ArgumentError dist_to(bfsp, 5)     ## because negative cycle
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
    bfsp = BFSP{T, T}("$(TF_DIR)/$(file)", src, YA_BFSP.EWDiGraph{T, T};
                      positive_weight=false)

    if exp_val == nothing
      @test has_negative_cycle(bfsp)

    else
      dst = path[end]
      @test min_dist(bfsp) == exp_val
      @test path_to(bfsp, dst) == path
    end
  end
end
