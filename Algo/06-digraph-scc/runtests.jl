using Test

include("di_graph_scc.jl")
include("utils/macro_helpers.jl")

const TF_DIR = "./testfiles/"

function read_sol(ifile)
  line = open(ifile) do f
    readline(f)
  end
  map(
    x -> parse(Int, strip(x)),
    split(line, ",")
  )
end

@testset "loading a DiGraph from file 11v_17e" begin
  g = DiGraph{Int}("$(TF_DIR)/11v_17e.txt")
  gᵣ = reverse(g)

  @test v(g) == 11   # num. of vertices
  @test e(g) == 17   # num. of edges

  @test g.adj[1] == [3]      # [[3], [4, 10], [5, 11], [7], [1, 7, 9], [10], [9], [6], [2, 4, 8], [8], [6]]
  @test g.adj[2] == [4, 10]

  @test gᵣ.adj[1] == [5]     # [[5], [9], [1], [2, 9], [3], [8, 11], [4, 5], [9, 10], [5, 7], [2, 6], [3]]
  @test gᵣ.adj[4] == [2, 9]
end


@testset "reverse post order on DiGraph 11v_17e" begin
  g = DiGraph{Int}("$(TF_DIR)/11v_17e.txt")
  ord_g = DFO{Int}(g)

  @test collect(rev_post(ord_g)) == [1, 3, 11, 5, 7, 9, 2, 10, 8, 6, 4]
  # DataStructures.Stack{Int64}(Deque [[4, 6, 8, 10, 2, 9, 7, 5, 11, 3, 1]])
end

@testset "SCC 11v_17e " begin
  (scc_g, _g) = calc_scc("$(TF_DIR)/11v_17e.txt")

  @test count(scc_g) == 4  #  4 SCC in DiGraph g

  @test id(scc_g, 1) == id(scc_g, 3) == id(scc_g, 5)
  @test id(scc_g, 1) != id(scc_g, 11)  # vertices 1, 11 are not in the same SCC
  @test id(scc_g, 6) == id(scc_g, 8) == id(scc_g, 10)

  @yatest topn(scc_g) ==  [3 => 4, 4 => 3, 1 => 3, 2 => 1]
end

@testset "SCC 13v_21e" begin
  (scc_g, _g) = calc_scc("$(TF_DIR)/13v_21e.txt")

  @test count(scc_g) == 5  #  5 SCC in DiGraph g

  @test id(scc_g, 1) == id(scc_g, 3) == id(scc_g, 4) == id(scc_g, 5) == id(scc_g, 6)
  @test id(scc_g, 1) != id(scc_g, 2)  # vertices 1, 2 are not in the same SCC
  @test id(scc_g, 10) == id(scc_g, 11) == id(scc_g, 12) == id(scc_g, 13)

  @yatest topn(scc_g) == [3 => 5, 1 => 4, 4 => 2, 2 => 1, 5 => 1,]
end


# Test case #1: A 9-vertex 11-edge graph. Top 5 SCC sizes: 3,3,3,0,0
@testset "SCC 9v_11e" begin
  (scc_g, _g) = calc_scc("$(TF_DIR)/9v_11e_tc.txt")
  # [1, 3, 2, 1, 3, 2, 1, 3, 2]

  @test count(scc_g) == 3

  @test id(scc_g, 1) == id(scc_g, 4) == id(scc_g, 7)
  @test id(scc_g, 3) == id(scc_g, 6) == id(scc_g, 9)
  @test id(scc_g, 2) == id(scc_g, 5) == id(scc_g, 8)

  @yatest topn(scc_g) == [2 => 3, 3 => 3, 1 => 3]
end

# Test case #2: An 8-vertex 14-edge graph. Top 5 SCC sizes: 3,3,2,0,0
@testset "SCC 8v_14e" begin
  (scc_g, _g) = calc_scc("$(TF_DIR)/8v_14e_tc.txt")
  # [3, 3, 3, 1, 1, 2, 2, 2]

  @test count(scc_g) == 3

  @test groupby(scc_g, 3) == [1, 2, 3]
  @test groupby(scc_g, 1) == [4, 5]
  @test groupby(scc_g, 2) == [6, 7, 8]

  @yatest topn(scc_g) == [2 => 3, 3 => 3, 1 => 2]
end

# Test case #3: An 8-vertex 9-edge graph. Top 5 SCC sizes: 3,3,1,1,0
@testset "SCC 8v_9e" begin
  (scc_g, _g) = calc_scc("$(TF_DIR)/8v_9e_tc.txt")
  # [4, 4, 4, 1, 3, 2, 2, 2]

  @test count(scc_g) == 4

  @test groupby(scc_g, 4) == [1, 2, 3]
  @test groupby(scc_g, 1) == [4]
  @test groupby(scc_g, 3) == [5]
  @test groupby(scc_g, 2) == [6, 7, 8]

  @yatest topn(scc_g) == [4 => 3, 2 => 3, 3 => 1, 1 => 1]
end

# Test case #4: An 8-vertex 11-edge graph. Top 5 SCC sizes: 7,1,0,0,0
@testset "SCC 8v_11e" begin
  (scc_g, _g) = calc_scc("$(TF_DIR)/8v_11e_tc.txt")
  # [1, 1, 1, 1, 2, 1, 1, 1]

  @test count(scc_g) == 2

  @test groupby(scc_g, 1) == [1, 2, 3, 4, 6, 7, 8]
  @test groupby(scc_g, 2) == [5]

  @yatest topn(scc_g) == [1 => 7, 2 => 1]
end

# Test case #5: A 12-vertex 20-edge graph. Top 5 SCC sizes: 6,3,2,1,0
@testset "SCC 12v_20e" begin
  (scc_g, _g) = calc_scc("$(TF_DIR)/12v_20e_tc.txt")
  # [4, 3, 2, 3, 3, 2, 1, 1, 1, 1, 1, 1]

  @test count(scc_g) == 4

  @test groupby(scc_g, 4) == [1]
  @test groupby(scc_g, 3) == [2, 4, 5]
  @test groupby(scc_g, 2) == [3, 6]
  @test groupby(scc_g, 1) == [7, 8, 9, 10, 11, 12]

  @yatest topn(scc_g) == [1 => 6, 3 => 3, 2 => 2, 4 => 1] # [6, 3, 2, 1]
end

for file in filter((fs) -> occursin(r"\Ainput_scc_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile)")

  @testset "SCC for $(file)" begin
    DT = Int
    m = match(r"\Ainput_scc_\d+_(\d+)", file)
    m === nothing && throw(ArgumentError("Expecting a filename like: input_scc_\\d+_(\\d+)"))
    n = parse(DT, m[1])

    @time (scc_g, _g) = calc_scc("$(TF_DIR)/$(file)"; n=n)

    act_val = map(p -> p[2], topn(scc_g))
    la = length(act_val)
    if la < 5
      for ix ∈ la+1:5; push!(act_val, zero(DT)); end
    end

    @yatest act_val == exp_val
  end
end
