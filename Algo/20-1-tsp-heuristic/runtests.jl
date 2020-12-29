using Test

include("nn_tsp.jl")

const TF_DIR = "./testfiles"


function read_sol(ifile)
  s = open(ifile) do f
    readlines(f)
  end[1]

  return parse(Int, strip(s))
end


for file in filter((fs) -> occursin(r"\Ainput_simple_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile)")

  for tsp_fn ∈ (tsp, tsp_bf)
    @testset "$(tsp) for $(file)" begin
      @time @test tsp_fn("$(TF_DIR)/$(file)", Float64)[1] == exp_val
    end
  end
end


# 63.228142 seconds (64.14 M allocations: 1.913 GiB, 0.07% gc time)       # 34.992520 seconds (90.07 M allocations: 1.805 GiB, 0.13% gc time)
# Test Summary:                       | Pass  Total                       # Test Summary:                    | Pass  Total
# tsp_bf for input_simple_57_8000.txt |    1      1                       # tsp for input_simple_57_8000.txt |    1      1

# 63.371227 seconds (64.14 M allocations: 1.913 GiB, 0.23% gc time)       # 35.620104 seconds (116.38 M allocations: 2.409 GiB, 0.15% gc time)
# Test Summary:                       | Pass  Total                       # Test Summary:                    | Pass  Total
# tsp_bf for input_simple_58_8000.txt |    1      1                       # tsp for input_simple_58_8000.txt |    1      1

# 63.283086 seconds (64.14 M allocations: 1.913 GiB, 0.04% gc time)       # 36.778682 seconds (159.86 M allocations: 3.380 GiB, 0.21% gc time)
# Test Summary:                       | Pass  Total                       # Test Summary:                    | Pass  Total
# tsp_bf for input_simple_59_8000.txt |    1      1                       # tsp for input_simple_59_8000.txt |    1      1

# 63.188801 seconds (64.14 M allocations: 1.913 GiB, 0.05% gc time)       #  36.811445 seconds (162.83 M allocations: 3.456 GiB, 0.22% gc time)
# Test Summary:                       | Pass  Total                       # Test Summary:                    | Pass  Total
# tsp_bf for input_simple_60_8000.txt |    1      1                       # tsp for input_simple_60_8000.txt |    1      1

# 123.399353 seconds (100.18 M allocations: 2.988 GiB, 0.05% gc time)     #  68.747336 seconds (140.30 M allocations: 2.799 GiB, 0.23% gc time)
# Test Summary:                        | Pass  Total                      # Test Summary:                     | Pass  Total
# tsp_bf for input_simple_61_10000.txt |    1      1                      # tsp for input_simple_61_10000.txt |    1      1

# 123.628108 seconds (100.18 M allocations: 2.988 GiB, 0.06% gc time)     # 73.226911 seconds (309.68 M allocations: 6.622 GiB, 0.19% gc time)
# Test Summary:                        | Pass  Total                      # Test Summary:                     | Pass  Total
# tsp_bf for input_simple_62_10000.txt |    1      1                      # tsp for input_simple_62_10000.txt |    1      1

# 123.826492 seconds (100.18 M allocations: 2.988 GiB, 0.07% gc time)     # 72.023579 seconds (253.74 M allocations: 5.340 GiB, 0.16% gc time)
# Test Summary:                        | Pass  Total                      # Test Summary:                     | Pass  Total
# tsp_bf for input_simple_63_10000.txt |    1      1                      # tsp for input_simple_63_10000.txt |    1      1

# 123.906828 seconds (100.18 M allocations: 2.988 GiB, 0.10% gc time)     # 75.238314 seconds (257.17 M allocations: 5.439 GiB, 0.18% gc time)
# Test Summary:                        | Pass  Total                      # Test Summary:                     | Pass  Total
# tsp_bf for input_simple_64_10000.txt |    1      1                      # tsp for input_simple_64_10000.txt |    1      1

# 990.056887 seconds (400.36 M allocations: 11.936 GiB, 0.03% gc time)    # 592.786316 seconds (1.01 G allocations: 21.241 GiB, 0.09% gc time)
# Test Summary:                        | Pass  Total                      # Test Summary:                     | Pass  Total
# tsp_bf for input_simple_65_20000.txt |    1      1                      # tsp for input_simple_65_20000.txt |    1      1

# 994.097687 seconds (400.36 M allocations: 11.936 GiB, 0.04% gc time)    # 572.674645 seconds (1.13 G allocations: 23.895 GiB, 0.10% gc time)
# Test Summary:                        | Pass  Total                      # Test Summary:                     | Pass  Total
# tsp_bf for input_simple_66_20000.txt |    1      1                      # tsp for input_simple_66_20000.txt |    1      1

# 993.775502 seconds (400.36 M allocations: 11.936 GiB, 0.03% gc time)    #
# Test Summary:                        | Pass  Total                      #
# tsp_bf for input_simple_67_20000.txt |    1      1                      #

# 1052.302335 seconds (400.36 M allocations: 11.936 GiB, 0.03% gc time)   # 578.815901 seconds (1.05 G allocations: 22.173 GiB, 0.11% gc time)
# Test Summary:                        | Pass  Total                      # Test Summary:                     | Pass  Total
# tsp_bf for input_simple_68_20000.txt |    1      1                      # tsp for input_simple_68_20000.txt |    1      1

# 8568.697095 seconds (1.60 G allocations: 47.714 GiB, 0.02% gc time)     # 4521.033125 seconds (3.34 G allocations: 68.872 GiB, 0.04% gc time)
# Test Summary:                        | Pass  Total                      # Test Summary:                     | Pass  Total
# tsp_bf for input_simple_69_40000.txt |    1      1                      # tsp for input_simple_69_40000.txt |    1      1

#                                                                         # 4442.847100 seconds (3.18 G allocations: 65.289 GiB, 0.05% gc time)
#                                                                         # Test Summary:                     | Pass  Total
#                                                                         # tsp for input_simple_70_40000.txt |    1      1

## Using pre-allocated vector
# 16.531862 seconds (45.71 M allocations: 135.374 GiB, 6.08% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_56_4000.txt |    1      1

#  26.596217 seconds (39.87 M allocations: 240.727 GiB, 6.69% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_56_4000.txt |    1      1

# 121.521098 seconds (151.86 M allocations: 1.195 TiB, 3.70% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_57_8000.txt |    1      1

# 200.397666 seconds (175.73 M allocations: 1.871 TiB, 6.48% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_57_8000.txt |    1      1

# 123.159552 seconds (176.80 M allocations: 1.095 TiB, 9.72% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_58_8000.txt |    1      1
