using Test

include("dp_tsp.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)
  s = open(ifile) do f
    readlines(f)
  end[1]

  return parse(Int, strip(s))
end


for tsp ∈ (tsp_m, tsp_h)
  @testset "Basics $(tsp) 4×4 graph / 13" begin
    distm = Matrix{Int}(undef, 4, 4) # Expect 13

    distm[1,1]=0; distm[1,2]=1; distm[1,3]=2; distm[1,4]=4
    distm[2,1]=1; distm[2,2]=0; distm[2,3]=3; distm[2,4]=6
    distm[3,1]=2; distm[3,2]=3; distm[3,3]=0; distm[3,4]=5
    distm[4,1]=4; distm[4,2]=6; distm[4,3]=5; distm[4,4]=0

    @test round_dist(tsp(distm), Int) == 13
  end

  @testset "Basics $(tsp) 4×4 graph / 21" begin
    distm = Matrix{Int}(undef, 4, 4) # Expect 21

    distm[1,1]=0; distm[1,2]=2; distm[1,3]=9; distm[1,4]=10
    distm[2,1]=1; distm[2,2]=0; distm[2,3]=6; distm[2,4]=4
    distm[3,1]=15; distm[3,2]=7; distm[3,3]=0; distm[3,4]=8
    distm[4,1]=6; distm[4,2]=3; distm[4,3]=12; distm[4,4]=0

    @test round_dist(tsp(distm), Int) == 21
  end
end

for file in filter((fs) -> occursin(r"\Ainput_float_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile)")

  for tsp ∈ (tsp_m, tsp_h)
    @testset "$(tsp) for $(file)" begin
      distm = init_distm("$(TF_DIR)/$(file)", Float32)

      @time @test round_dist(tsp(distm), Int) == exp_val
    end
  end
end

# Test Summary:               | Pass  Total
# Basics tsp_m 4×4 graph / 13 |    1      1
# Test Summary:               | Pass  Total
# Basics tsp_m 4×4 graph / 21 |    1      1
# Test Summary:               | Pass  Total
# Basics tsp_h 4×4 graph / 13 |    1      1
# Test Summary:               | Pass  Total
# Basics tsp_h 4×4 graph / 21 |    1      1
#   0.125982 seconds (341.35 k allocations: 17.409 MiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_10_4.txt |    1      1
#   0.213362 seconds (513.29 k allocations: 25.013 MiB, 2.31% gc time)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_10_4.txt |    1      1
#   0.000124 seconds (281 allocations: 15.844 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_11_4.txt |    1      1
#   0.000047 seconds (295 allocations: 17.156 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_11_4.txt |    1      1
#   0.000032 seconds (281 allocations: 15.844 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_12_4.txt |    1      1
#   0.000033 seconds (295 allocations: 17.156 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_12_4.txt |    1      1
#   0.000048 seconds (820 allocations: 45.516 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_13_5.txt |    1      1
#   0.000068 seconds (846 allocations: 49.078 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_13_5.txt |    1      1
#   0.000046 seconds (820 allocations: 45.516 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_14_5.txt |    1      1
#   0.000050 seconds (846 allocations: 49.078 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_14_5.txt |    1      1
#   0.000055 seconds (820 allocations: 45.516 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_15_5.txt |    1      1
#   0.000056 seconds (846 allocations: 49.078 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_15_5.txt |    1      1
#   0.000113 seconds (2.33 k allocations: 125.047 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_17_6.txt |    1      1
#   0.000127 seconds (2.37 k allocations: 130.016 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_17_6.txt |    1      1
#   0.000104 seconds (2.33 k allocations: 125.047 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_18_6.txt |    1      1
#   0.000112 seconds (2.37 k allocations: 130.016 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_18_6.txt |    1      1
#   0.000104 seconds (2.33 k allocations: 125.047 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_19_6.txt |    1      1
#   0.000111 seconds (2.37 k allocations: 130.016 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_19_6.txt |    1      1
#   0.000101 seconds (2.33 k allocations: 125.047 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_20_6.txt |    1      1
#   0.000115 seconds (2.37 k allocations: 130.016 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_20_6.txt |    1      1
#   0.000238 seconds (5.98 k allocations: 317.406 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_21_7.txt |    1      1
#   0.000281 seconds (6.05 k allocations: 325.031 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_21_7.txt |    1      1
#   0.000566 seconds (14.82 k allocations: 780.625 KiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_27_8.txt |    1      1
#   0.000623 seconds (14.97 k allocations: 799.312 KiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_27_8.txt |    1      1
#   0.001340 seconds (35.85 k allocations: 1.829 MiB)
# Test Summary:                  | Pass  Total
# tsp_m for input_float_29_9.txt |    1      1
#   0.001506 seconds (36.13 k allocations: 1.864 MiB)
# Test Summary:                  | Pass  Total
# tsp_h for input_float_29_9.txt |    1      1
#   0.003335 seconds (87.89 k allocations: 4.441 MiB)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_36_10.txt |    1      1
#   0.003508 seconds (88.42 k allocations: 4.516 MiB)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_36_10.txt |    1      1
#   0.007924 seconds (205.00 k allocations: 10.307 MiB)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_37_11.txt |    1      1
#   0.009716 seconds (206.05 k allocations: 10.437 MiB)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_37_11.txt |    1      1
#   0.010138 seconds (205.00 k allocations: 10.307 MiB, 34.67% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_40_11.txt |    1      1
#   0.006955 seconds (206.05 k allocations: 10.437 MiB)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_40_11.txt |    1      1
#   0.015724 seconds (472.57 k allocations: 23.668 MiB)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_42_12.txt |    1      1
#   0.018900 seconds (474.64 k allocations: 23.946 MiB, 15.01% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_42_12.txt |    1      1
#   0.080964 seconds (2.44 M allocations: 121.560 MiB, 6.55% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_49_14.txt |    1      1
#   0.086503 seconds (2.45 M allocations: 122.729 MiB, 5.56% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_49_14.txt |    1      1
#   0.076191 seconds (2.44 M allocations: 121.560 MiB, 4.23% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_50_14.txt |    1      1
#   0.086131 seconds (2.45 M allocations: 122.729 MiB, 5.66% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_50_14.txt |    1      1
#   0.176888 seconds (5.49 M allocations: 272.464 MiB, 5.43% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_56_15.txt |    1      1
#   0.288419 seconds (5.50 M allocations: 274.516 MiB, 31.30% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_56_15.txt |    1      1
#   0.487315 seconds (12.25 M allocations: 607.018 MiB, 19.68% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_57_16.txt |    1      1
#   0.521001 seconds (12.28 M allocations: 611.437 MiB, 19.46% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_57_16.txt |    1      1
#   0.385731 seconds (12.25 M allocations: 607.018 MiB, 5.45% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_58_16.txt |    1      1
#   0.528485 seconds (12.28 M allocations: 611.437 MiB, 19.68% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_58_16.txt |    1      1
#   2.191170 seconds (61.23 M allocations: 2.985 GiB, 12.62% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_66_18.txt |    1      1
#   2.430913 seconds (61.36 M allocations: 3.003 GiB, 13.86% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_66_18.txt |    1      1
#   2.192200 seconds (61.23 M allocations: 2.985 GiB, 12.85% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_67_18.txt |    1      1
#   2.416883 seconds (61.36 M allocations: 3.003 GiB, 13.95% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_67_18.txt |    1      1
#   4.781185 seconds (134.37 M allocations: 6.535 GiB, 9.66% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_70_19.txt |    1      1
#   5.437864 seconds (134.64 M allocations: 6.565 GiB, 14.52% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_70_19.txt |    1      1
#   4.934684 seconds (134.37 M allocations: 6.535 GiB, 9.62% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_72_19.txt |    1      1
#   5.656025 seconds (134.64 M allocations: 6.565 GiB, 14.13% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_72_19.txt |    1      1
#  11.021729 seconds (293.58 M allocations: 14.246 GiB, 8.11% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_76_20.txt |    1      1
#  12.311985 seconds (294.10 M allocations: 14.301 GiB, 13.71% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_76_20.txt |    1      1
#  26.539605 seconds (638.86 M allocations: 30.930 GiB, 8.75% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_79_21.txt |    1      1
#  28.983951 seconds (639.91 M allocations: 31.052 GiB, 13.51% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_79_21.txt |    1      1
#  66.544700 seconds (1.39 G allocations: 66.918 GiB, 10.36% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_81_22.txt |    1      1
#  69.912670 seconds (1.39 G allocations: 67.156 GiB, 15.19% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_81_22.txt |    1      1
# 151.302727 seconds (2.99 G allocations: 144.334 GiB, 10.98% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_85_23.txt |    1      1
# 161.645441 seconds (3.00 G allocations: 144.765 GiB, 14.87% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_85_23.txt |    1      1
# 154.694006 seconds (2.99 G allocations: 144.334 GiB, 11.39% gc time)
# Test Summary:                   | Pass  Total
# tsp_m for input_float_86_23.txt |    1      1
# 162.333504 seconds (3.00 G allocations: 144.765 GiB, 14.51% gc time)
# Test Summary:                   | Pass  Total
# tsp_h for input_float_86_23.txt |    1      1
