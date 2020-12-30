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

  @testset "tsp for $(file)" begin
    @time @test tsp("$(TF_DIR)/$(file)", Float64)[1] == exp_val
  end
end

## Stats

#   0.824102 seconds (2.57 M allocations: 130.811 MiB, 1.86% gc time)
# Test Summary:                 | Pass  Total
# tsp for input_simple_10_8.txt |    1      1

#   0.000100 seconds (322 allocations: 13.500 KiB)
# Test Summary:                 | Pass  Total
# tsp for input_simple_11_8.txt |    1      1

#   0.000098 seconds (362 allocations: 14.750 KiB)
# Test Summary:                 | Pass  Total
# tsp for input_simple_12_8.txt |    1      1

#   0.000089 seconds (420 allocations: 17.109 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_13_10.txt |    1      1

#   0.000075 seconds (426 allocations: 17.297 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_14_10.txt |    1      1

#   0.000086 seconds (466 allocations: 18.547 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_15_10.txt |    1      1

#   0.000058 seconds (450 allocations: 18.047 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_16_10.txt |    1      1

#   0.000139 seconds (1.46 k allocations: 53.016 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_17_20.txt |    1      1

#   0.000112 seconds (1.15 k allocations: 43.141 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_18_20.txt |    1      1

#   0.000098 seconds (1.26 k allocations: 46.766 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_19_20.txt |    1      1

#   0.000046 seconds (98 allocations: 4.938 KiB)
# Test Summary:                | Pass  Total
# tsp for input_simple_1_2.txt |    1      1

#   0.000097 seconds (1.28 k allocations: 47.453 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_20_20.txt |    1      1

#   0.000211 seconds (3.79 k allocations: 131.234 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_21_40.txt |    1      1

#   0.000212 seconds (3.44 k allocations: 120.234 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_22_40.txt |    1      1

#   0.000267 seconds (2.76 k allocations: 98.984 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_23_40.txt |    1      1

#   0.000238 seconds (3.80 k allocations: 131.422 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_24_40.txt |    1      1

#   0.000474 seconds (8.98 k allocations: 306.625 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_25_80.txt |    1      1

#   0.000486 seconds (10.64 k allocations: 358.250 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_26_80.txt |    1      1

#   0.000473 seconds (11.17 k allocations: 374.875 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_27_80.txt |    1      1

#   0.000394 seconds (8.44 k allocations: 289.500 KiB)
# Test Summary:                  | Pass  Total
# tsp for input_simple_28_80.txt |    1      1

#   0.000552 seconds (12.03 k allocations: 407.141 KiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_29_100.txt |    1      1

#   0.000059 seconds (98 allocations: 4.938 KiB)
# Test Summary:                | Pass  Total
# tsp for input_simple_2_2.txt |    1      1

#   0.000686 seconds (18.23 k allocations: 600.828 KiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_30_100.txt |    1      1

#   0.000565 seconds (13.91 k allocations: 465.953 KiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_31_100.txt |    1      1

#   0.000458 seconds (9.65 k allocations: 332.953 KiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_32_100.txt |    1      1

#   0.001250 seconds (31.13 k allocations: 1.016 MiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_33_200.txt |    1      1

#   0.001866 seconds (49.01 k allocations: 1.561 MiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_34_200.txt |    1      1

#   0.002078 seconds (42.26 k allocations: 1.355 MiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_35_200.txt |    1      1

#   0.002816 seconds (62.36 k allocations: 1.969 MiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_36_200.txt |    1      1

#   0.007138 seconds (128.59 k allocations: 4.042 MiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_37_400.txt |    1      1

#   0.007537 seconds (172.84 k allocations: 5.392 MiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_38_400.txt |    1      1

#   0.008476 seconds (192.27 k allocations: 5.985 MiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_39_400.txt |    1      1

#   0.000111 seconds (98 allocations: 4.938 KiB)
# Test Summary:                | Pass  Total
# tsp for input_simple_3_2.txt |    1      1

#   0.012533 seconds (225.49 k allocations: 6.999 MiB, 37.80% gc time)
# Test Summary:                   | Pass  Total
# tsp for input_simple_40_400.txt |    1      1

#   0.021156 seconds (649.57 k allocations: 20.062 MiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_41_800.txt |    1      1

#   0.039300 seconds (919.84 k allocations: 28.310 MiB, 9.63% gc time)
# Test Summary:                   | Pass  Total
# tsp for input_simple_42_800.txt |    1      1

#   0.017344 seconds (487.54 k allocations: 15.118 MiB)
# Test Summary:                   | Pass  Total
# tsp for input_simple_43_800.txt |    1      1

#   0.031406 seconds (746.41 k allocations: 23.018 MiB, 10.56% gc time)
# Test Summary:                   | Pass  Total
# tsp for input_simple_44_800.txt |    1      1

#   0.035094 seconds (892.82 k allocations: 27.526 MiB)
# Test Summary:                    | Pass  Total
# tsp for input_simple_45_1000.txt |    1      1

#   0.038469 seconds (1.07 M allocations: 33.031 MiB, 4.25% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_46_1000.txt |    1      1

#   0.033815 seconds (981.43 k allocations: 30.230 MiB, 3.69% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_47_1000.txt |    1      1

#   0.038818 seconds (1.20 M allocations: 36.785 MiB, 2.50% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_48_1000.txt |    1      1

#   0.196198 seconds (5.91 M allocations: 180.789 MiB, 1.87% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_49_2000.txt |    1      1

#   0.000118 seconds (98 allocations: 4.938 KiB)
# Test Summary:                | Pass  Total
# tsp for input_simple_4_2.txt |    1      1

#   0.155951 seconds (4.72 M allocations: 144.441 MiB, 1.88% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_50_2000.txt |    1      1

#   0.175274 seconds (5.31 M allocations: 162.645 MiB, 2.37% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_51_2000.txt |    1      1

#   0.089720 seconds (2.72 M allocations: 83.573 MiB, 2.44% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_52_2000.txt |    1      1

#   0.838425 seconds (22.81 M allocations: 697.191 MiB, 1.77% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_53_4000.txt |    1      1

#   0.678311 seconds (19.44 M allocations: 594.337 MiB, 1.88% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_54_4000.txt |    1      1

#   0.591925 seconds (17.13 M allocations: 523.895 MiB, 2.20% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_55_4000.txt |    1      1

#   0.491865 seconds (14.06 M allocations: 430.211 MiB, 2.36% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_56_4000.txt |    1      1

#   1.189312 seconds (30.92 M allocations: 945.268 MiB, 2.53% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_57_8000.txt |    1      1

#   1.878501 seconds (45.14 M allocations: 1.347 GiB, 7.13% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_58_8000.txt |    1      1

#   3.169918 seconds (66.79 M allocations: 1.992 GiB, 1.85% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_59_8000.txt |    1      1

#   0.000078 seconds (166 allocations: 7.562 KiB)
# Test Summary:                | Pass  Total
# tsp for input_simple_5_4.txt |    1      1

#   3.142363 seconds (68.93 M allocations: 2.056 GiB, 2.19% gc time)
# Test Summary:                    | Pass  Total
# tsp for input_simple_60_8000.txt |    1      1

#   1.858046 seconds (47.36 M allocations: 1.414 GiB, 2.97% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_61_10000.txt |    1      1

#   6.952683 seconds (134.55 M allocations: 4.012 GiB, 2.55% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_62_10000.txt |    1      1

#   5.136533 seconds (104.44 M allocations: 3.115 GiB, 3.02% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_63_10000.txt |    1      1

#   5.100433 seconds (107.66 M allocations: 3.211 GiB, 3.17% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_64_10000.txt |    1      1

#  24.275588 seconds (412.95 M allocations: 12.312 GiB, 1.93% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_65_20000.txt |    1      1

#  28.513743 seconds (474.22 M allocations: 14.137 GiB, 2.05% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_66_20000.txt |    1      1

#  25.996499 seconds (434.91 M allocations: 12.966 GiB, 2.63% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_67_20000.txt |    1      1

#  31.364005 seconds (522.19 M allocations: 15.567 GiB, 2.80% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_68_20000.txt |    1      1

#  81.568660 seconds (1.28 G allocations: 38.259 GiB, 1.53% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_69_40000.txt |    1      1

#   0.000097 seconds (162 allocations: 7.438 KiB)
# Test Summary:                | Pass  Total
# tsp for input_simple_6_4.txt |    1      1

#  65.837481 seconds (1.20 G allocations: 35.773 GiB, 1.98% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_70_40000.txt |    1      1

#  82.917915 seconds (1.44 G allocations: 42.918 GiB, 2.15% gc time)
# Test Summary:                     | Pass  Total
# tsp for input_simple_72_40000.txt |    1      1

#   0.000085 seconds (166 allocations: 7.562 KiB)
# Test Summary:                | Pass  Total
# tsp for input_simple_7_4.txt |    1      1

#   0.000052 seconds (160 allocations: 7.375 KiB)
# Test Summary:                | Pass  Total
# tsp for input_simple_8_4.txt |    1      1

#   0.000060 seconds (356 allocations: 14.547 KiB)
# Test Summary:                | Pass  Total
# tsp for input_simple_9_8.txt |    1      1
