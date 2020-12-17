using Test

push!(LOAD_PATH, "./src")
using YA_BFSP

const FILEDIR = "./testfiles"

@testset "basics" begin
  ## build graph
  g = EWDiGraph{Int, Int}(5)

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
  g = EWDiGraph{Int, Int}(5)

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
  bfsp = BFSP{Int, Float32}("$(FILEDIR)/tiny_ewd.txt", src)

  @test dist_to(bfsp, 1) ≈ 0.0    # dist(src==1, 1)
  @test dist_to(bfsp, 2) ≈ 1.05   # dist(src==1, 2)
  @test dist_to(bfsp, 7) ≈ 1.51   # dist(src==1, 7)
  @test dist_to(bfsp, 8) ≈ 0.6    # dist(src==1, 8)

  @test path_to(bfsp, 4) == [(src, 3), (3, 8), (8, 4)]
  @test path_to(bfsp, 5) == [(src, 5)]
end

@testset "BFSP on tiny_ewdn.txt" begin
  src = 1
  bfsp = BFSP{Int, Float32}("$(FILEDIR)/tiny_ewdn.txt",
                            src; positive_weight=false)

  @test dist_to(bfsp, 1) ≈ 0.0    # dist(src==1, 1)
  @test dist_to(bfsp, 2) ≈ 0.93   # dist(src==1, 2)
  @test dist_to(bfsp, 7) ≈ 1.51   # dist(src==1, 7)

  @test path_to(bfsp, 6) == [(src, 3), (3, 8), (8, 4), (4, 7), (7, 5), (5, 6)]
  @test path_to(bfsp, 2) == [(src, 3), (3, 8), (8, 4), (4, 7), (7, 5), (5, 6), (6, 2)]
  @test path_to(bfsp, 8) == [(src, 3), (3, 8)]
end

@testset "BFSP on tiny_ewdnc.txt with negative cycle" begin
  src = 1
  bfsp = BFSP{Int, Float32}("$(FILEDIR)/tiny_ewdnc.txt", src;
                            positive_weight=false)

  @test has_negative_cycle(bfsp)
  @test negative_cycle(bfsp) == [(5, 6), (6, 5)]  ## a negative cycle
  @test has_path_to(bfsp, 5)
  @test_throws ArgumentError dist_to(bfsp, 5)     ## because negative cycle
end

@testset "on g1.txt" begin
  src = 1
  bfsp = BFSP{Int, Int}("$(FILEDIR)/g1.txt", src;
                            positive_weight=false)

  @test !has_negative_cycle(bfsp)

  @test path_to(bfsp, 4) == [(1, 82), (82, 4)]
  @test path_to(bfsp, 99) == [(1, 14), (14, 261), (261, 99)]
  @test path_to(bfsp, 474) == [(1, 14), (14, 261), (261, 474)]
  @test path_to(bfsp, 996) == [(1, 14), (14, 261), (261, 996)]
  @test path_to(bfsp, 774) == [(1, 14), (14, 261), (261, 774)]

  @test !has_path_to(bfsp, 1_000)

  @test dist_to(bfsp, 1) ≡ 0
  @test dist_to(bfsp, 4) ≡ 61
  @test dist_to(bfsp, 474) ≡ 33
  @test dist_to(bfsp, 996) ≡ 42
  @test dist_to(bfsp, 774) ≡ 69
end

@testset "on g2.txt" begin
  src = 1
  bfsp = BFSP{Int, Int}("$(FILEDIR)/g2.txt", src;
                        positive_weight=false)

  @test !has_negative_cycle(bfsp)

  @test !has_path_to(bfsp, 4)
  @test !has_path_to(bfsp, 555)
  @test !has_path_to(bfsp, 666)
  @test !has_path_to(bfsp, 777 )
  @test !has_path_to(bfsp, 999)

  @test path_to(bfsp, 99) == [(1, 227), (227, 99)]
  @test path_to(bfsp, 190) == [(1, 215), (215, 139), (139, 190)]
  @test path_to(bfsp, 423) == [(1, 215), (215, 139), (139, 423)]
  @test path_to(bfsp, 456) == [(1, 215), (215, 139), (139, 456)]
  @test path_to(bfsp, 1000) == [(1, 2), (2, 1000)]
  @test path_to(bfsp, 965) == [(1, 215), (215, 139), (139, 965)]

  @test dist_to(bfsp, 1) ≡ 0
  @test dist_to(bfsp, 474) ≡ 35
  @test dist_to(bfsp, 456) ≡ 43
  @test dist_to(bfsp, 1000) ≡ 38

  ## discounting infinity which might happen (given the graph)
  max_dist, min_dist = 0, typemax(Int)
  for ix in 2:v(bfsp.g)
    dist_to(bfsp, ix) ≡ typemax(Int) && continue
    
    if dist_to(bfsp, ix) > max_dist
      max_dist = dist_to(bfsp, ix)
      
    elseif dist_to(bfsp, ix) < min_dist
      min_dist = dist_to(bfsp, ix)
    end
  end

  @test min_dist == -2
  @test max_dist == 98
end

@testset "on g3.txt" begin
  src = 1
  bfsp = BFSP{Int, Int}("$(FILEDIR)/g3.txt", src;
                        positive_weight=false)

  @test !has_negative_cycle(bfsp)

  @test has_path_to(bfsp, 25)
  @test !has_path_to(bfsp, 1000)
  @test !has_path_to(bfsp, 456)
  
  @test path_to(bfsp, 25) == [(1, 63), (63, 25)]
  @test path_to(bfsp, 999) == [(1, 76), (76, 999)]
  @test path_to(bfsp, 513) == [(1, 120), (120, 513)]
  @test path_to(bfsp, 994) == [(1, 100), (100, 994)]
  
  @test dist_to(bfsp, 1) ≡ 0
  @test dist_to(bfsp, 474) ≡ 5
  @test dist_to(bfsp, 513) ≡ 69
  @test dist_to(bfsp, 999) ≡ 55
  @test dist_to(bfsp, 994) ≡ 69
end
