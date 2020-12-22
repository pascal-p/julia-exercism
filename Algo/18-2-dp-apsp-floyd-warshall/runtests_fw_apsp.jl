using Test

push!(LOAD_PATH, "./src")
using YA_FWAPSP
include("./utils/helper_files_fn.jl")

const TF_DIR = "./testfiles"

@testset "APSP basics /1" begin
  g = EWDiGraph{Int32, Int32}(Int32(5))

  add_edge(g, Int32(1), Int32(2), Int32(4); positive_weight=false)
  add_edge(g, Int32(1), Int32(3), Int32(2); positive_weight=false)
  add_edge(g, Int32(2), Int32(4), Int32(4); positive_weight=false)
  add_edge(g, Int32(3), Int32(5), Int32(2); positive_weight=false)
  add_edge(g, Int32(3), Int32(2), Int32(-1); positive_weight=false)
  add_edge(g, Int32(5), Int32(4), Int32(2); positive_weight=false)

  ## Calc,
  exp_mat = [0 1 2 5 4;
             infinity(Int32) 0 infinity(Int32) 4 infinity(Int32);
             infinity(Int32) -1 0 3 2;
             infinity(Int32) infinity(Int32) infinity(Int32) 0 infinity(Int32);
             infinity(Int32) infinity(Int32) infinity(Int32) 2 0]

  fw_apsp = FWAPSP{Int32, Int32}(g)

  @test fw_apsp.dist_to == exp_mat
  @test path_to(fw_apsp, Int32(1), Int32(4)) == [1, 3, 2, 4]
  @test dist_to(fw_apsp, Int32(1), Int32(4)) == 5

  @test min_dist(fw_apsp) == (Int32(-1), [Int32(3), Int32(2)])
end

@testset "APSP basics /2" begin
  g = EWDiGraph{Int, Int}(4)

  add_edge(g, 1, 3, 1)
  add_edge(g, 2, 3, 6)
  add_edge(g, 3, 4, 5)
  add_edge(g, 4, 2, 2)
  add_edge(g, 2, 1, 7)

  fw_apsp = FWAPSP{Int, Int}(g)

  @test path_to(fw_apsp, 1, 2) == [1, 3, 4, 2]
  @test path_to(fw_apsp, 2, 3) == [2, 3]
  @test path_to(fw_apsp, 3, 1) == [3, 4, 2, 1]

  @test min_dist(fw_apsp) == (1, [1, 3])
end

for file in filter((fs) -> occursin(r"\Ainput_random_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile1 = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile1)")

  ifile2 = replace(file, r"\Ainput_" => s"path_")   # get src and minimal length path
  path = read_path("$(TF_DIR)/$(ifile2)")

  @testset "for $(file)" begin
    fw_apsp = FWAPSP{Int32, Int32}("$(TF_DIR)/$(file)"; positive_weight=false)

    if exp_val == nothing
      @test has_negative_cycle(fw_apsp)

    else
      @test min_dist(fw_apsp) == (Int32(exp_val), path)

    end
  end
end


# Test Summary:  | Pass  Total
# APSP basics /1 |    4      4
# Test Summary:  | Pass  Total
# APSP basics /2 |    4      4

# Test Summary:             | Pass  Total
# for input_random_12_8.txt |    1      1
# Test Summary:              | Pass  Total
# for input_random_13_16.txt |    1      1
# Test Summary:              | Pass  Total
# for input_random_16_16.txt |    1      1
# Test Summary:              | Pass  Total
# for input_random_17_32.txt |    1      1
# Test Summary:              | Pass  Total
# for input_random_18_32.txt |    1      1
# Test Summary:            | Pass  Total
# for input_random_1_2.txt |    1      1
# Test Summary:              | Pass  Total
# for input_random_21_64.txt |    1      1
# Test Summary:               | Pass  Total
# for input_random_27_128.txt |    1      1
# Test Summary:               | Pass  Total
# for input_random_28_128.txt |    1      1
# Test Summary:            | Pass  Total
# for input_random_2_2.txt |    1      1
# Test Summary:               | Pass  Total
# for input_random_32_256.txt |    1      1
# Test Summary:               | Pass  Total
# for input_random_36_512.txt |    1      1
# Test Summary:                | Pass  Total
# for input_random_37_1024.txt |    1      1
# Test Summary:                | Pass  Total
# for input_random_38_1024.txt |    1      1
# Test Summary:                | Pass  Total
# for input_random_39_1024.txt |    1      1
# Test Summary:            | Pass  Total
# for input_random_3_2.txt |    1      1

# Test Summary:                | Pass  Total
# for input_random_40_1024.txt |    1      1

# Test Summary:                | Pass  Total
# for input_random_41_2048.txt |    1      1

# Test Summary:                | Pass  Total
# for input_random_42_2048.txt |    1      1

# Test Summary:                | Pass  Total
# for input_random_43_2048.txt |    1      1

# Test Summary:                | Pass  Total
# for input_random_44_2048.txt |    1      1

# Test Summary:            | Pass  Total
# for input_random_4_2.txt |    1      1
# Test Summary:            | Pass  Total
# for input_random_5_4.txt |    1      1
# Test Summary:            | Pass  Total
# for input_random_6_4.txt |    1      1
# Test Summary:            | Pass  Total
# for input_random_7_4.txt |    1      1
# Test Summary:            | Pass  Total
# for input_random_8_4.txt |    1      1
# Test Summary:            | Pass  Total
# for input_random_9_8.txt |    1      1
