using Test

include("ls_2sat.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)
  s = open(ifile) do f
    readlines(f)
  end[1]

  return parse(Int, strip(s))
end


for file in filter((fs) -> occursin(r"\Ainput_2sat_.+\.txt\z", fs),
                   # occursin(r"\Ainput_2sat_23_1000.txt\z", fs),
                   # occursin(r"\Ainput_2sat_.+\_([4-8]|10|20).txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile)")

  @testset "2SAT for $(file)" begin
    # @time ((act_val, assign), clauses) = solve_2sat("$(TF_DIR)/$(file)", Int32)
    @time ((act_val, _assign), ) = solve_2sat("$(TF_DIR)/$(file)", Int32)

    @test Integer(act_val) == exp_val
  end
end

# n :20 and after reduction: 5
#   0.998318 seconds (2.79 M allocations: 144.827 MiB, 1.92% gc time)
# Test Summary:                 | Pass  Total
# 2SAT for input_2sat_10_20.txt |    1      1

# n :40 and after reduction: 4
#   0.000246 seconds (1.23 k allocations: 57.719 KiB)
# Test Summary:                 | Pass  Total
# 2SAT for input_2sat_11_40.txt |    1      1

# n :40 and after reduction: 8
#   0.000488 seconds (1.54 k allocations: 96.172 KiB)
# Test Summary:                 | Pass  Total
# 2SAT for input_2sat_12_40.txt |    1      1
#   0.012037 seconds (7.33 k allocations: 395.195 KiB)
# Test Summary:                 | Pass  Total
# 2SAT for input_2sat_13_80.txt |    1      1

# n :80 and after reduction: 4
#   0.000676 seconds (2.48 k allocations: 110.703 KiB)
# Test Summary:                 | Pass  Total
# 2SAT for input_2sat_14_80.txt |    1      1

# n :100 and after reduction: 11
#   0.001292 seconds (3.72 k allocations: 227.875 KiB)
# Test Summary:                  | Pass  Total
# 2SAT for input_2sat_15_100.txt |    1      1
#   0.000426 seconds (3.08 k allocations: 131.688 KiB)
# Test Summary:                  | Pass  Total
# 2SAT for input_2sat_16_100.txt |    1      1
#   0.000700 seconds (6.36 k allocations: 268.703 KiB)
# Test Summary:                  | Pass  Total
# 2SAT for input_2sat_17_200.txt |    1      1

# n :200 and after reduction: 22
#   0.029495 seconds (102.81 k allocations: 6.006 MiB)
# Test Summary:                  | Pass  Total
# 2SAT for input_2sat_18_200.txt |    1      1

# n :400 and after reduction: 4
#   0.001397 seconds (13.07 k allocations: 525.734 KiB)
# Test Summary:                  | Pass  Total
# 2SAT for input_2sat_19_400.txt |    1      1
#   0.000191 seconds (104 allocations: 5.234 KiB)
# Test Summary:               | Pass  Total
# 2SAT for input_2sat_1_2.txt |    1      1

# n :400 and after reduction: 34
#   0.042094 seconds (22.37 k allocations: 4.048 MiB, 9.09% gc time)
# Test Summary:                  | Pass  Total
# 2SAT for input_2sat_20_400.txt |    1      1

# n :800 and after reduction: 6
#   0.002475 seconds (33.03 k allocations: 1.166 MiB)
# Test Summary:                  | Pass  Total
# 2SAT for input_2sat_21_800.txt |    1      1

# n :800 and after reduction: 64
#   0.314264 seconds (1.16 M allocations: 43.972 MiB, 1.18% gc time)
# Test Summary:                  | Pass  Total
# 2SAT for input_2sat_22_800.txt |    1      1

# n :1000 and after reduction: 14
#   0.003139 seconds (44.31 k allocations: 1.500 MiB)
# Test Summary:                   | Pass  Total
# 2SAT for input_2sat_23_1000.txt |    1      1

# n :1000 and after reduction: 63
#   0.240188 seconds (1.14 M allocations: 36.717 MiB)
# Test Summary:                   | Pass  Total
# 2SAT for input_2sat_24_1000.txt |    1      1
#   0.011025 seconds (103.36 k allocations: 3.084 MiB, 40.76% gc time)
# Test Summary:                   | Pass  Total
# 2SAT for input_2sat_25_2000.txt |    1      1

# n :2000 and after reduction: 71
#   0.396375 seconds (2.96 M allocations: 78.189 MiB, 0.48% gc time)
# Test Summary:                   | Pass  Total
# 2SAT for input_2sat_26_2000.txt |    1      1

# n :4000 and after reduction: 16
#   0.014357 seconds (212.03 k allocations: 6.466 MiB)
# Test Summary:                   | Pass  Total
# 2SAT for input_2sat_27_4000.txt |    1      1

# n :4000 and after reduction: 28
#   0.030150 seconds (344.67 k allocations: 9.988 MiB, 6.64% gc time)
# Test Summary:                   | Pass  Total
# 2SAT for input_2sat_28_4000.txt |    1      1

# n :8000 and after reduction: 24
#   0.029041 seconds (512.24 k allocations: 14.130 MiB)
# Test Summary:                   | Pass  Total
# 2SAT for input_2sat_29_8000.txt |    1      1

# n :2 and after reduction: 2
#   0.000171 seconds (125 allocations: 6.906 KiB)
# Test Summary:               | Pass  Total
# 2SAT for input_2sat_2_2.txt |    1      1

# n :8000 and after reduction: 180
#   8.111239 seconds (66.64 M allocations: 1.584 GiB, 1.79% gc time)
# Test Summary:                   | Pass  Total
# 2SAT for input_2sat_30_8000.txt |    1      1

# n :10000 and after reduction: 188
#   0.086061 seconds (1.02 M allocations: 28.195 MiB, 5.14% gc time)
# Test Summary:                    | Pass  Total
# 2SAT for input_2sat_31_10000.txt |    1      1

# n :10000 and after reduction: 86
#   0.774193 seconds (6.85 M allocations: 169.714 MiB, 2.10% gc time)
# Test Summary:                    | Pass  Total
# 2SAT for input_2sat_32_10000.txt |    1      1

# n :20000 and after reduction: 249
#   0.194056 seconds (2.22 M allocations: 58.729 MiB, 1.62% gc time)
# Test Summary:                    | Pass  Total
# 2SAT for input_2sat_33_20000.txt |    1      1

# n :20000 and after reduction: 95
#   1.121467 seconds (9.81 M allocations: 241.351 MiB, 6.89% gc time)
# Test Summary:                    | Pass  Total
# 2SAT for input_2sat_34_20000.txt |    1      1

# n :40000 and after reduction: 4
#   0.201334 seconds (2.34 M allocations: 70.153 MiB, 20.59% gc time)
# Test Summary:                    | Pass  Total
# 2SAT for input_2sat_35_40000.txt |    1      1

# n :40000 and after reduction: 147
#   4.518954 seconds (40.48 M allocations: 984.734 MiB, 1.27% gc time)
# Test Summary:                    | Pass  Total
# 2SAT for input_2sat_36_40000.txt |    1      1

# n :80000 and after reduction: 20
#   0.355867 seconds (4.68 M allocations: 135.177 MiB, 12.23% gc time)
# Test Summary:                    | Pass  Total
# 2SAT for input_2sat_37_80000.txt |    1      1

# n :80000 and after reduction: 290
#  38.649713 seconds (348.58 M allocations: 8.046 GiB, 1.30% gc time)
# Test Summary:                    | Pass  Total
# 2SAT for input_2sat_38_80000.txt |    1      1

# n :100000 and after reduction: 159
#   0.933713 seconds (9.50 M allocations: 253.354 MiB, 17.33% gc time)
# Test Summary:                     | Pass  Total
# 2SAT for input_2sat_39_100000.txt |    1      1

#   0.000244 seconds (153 allocations: 7.297 KiB)
# Test Summary:               | Pass  Total
# 2SAT for input_2sat_3_4.txt |    1      1

# n :100000 and after reduction: 170
#   7.025703 seconds (66.31 M allocations: 1.586 GiB, 2.46% gc time)
# Test Summary:                     | Pass  Total
# 2SAT for input_2sat_40_100000.txt |    1      1

# n :4 and after reduction: 2
#   0.000116 seconds (199 allocations: 10.547 KiB)
# Test Summary:               | Pass  Total
# 2SAT for input_2sat_4_4.txt |    1      1

# n :8 and after reduction: 2
#   0.000105 seconds (311 allocations: 14.688 KiB)
# Test Summary:               | Pass  Total
# 2SAT for input_2sat_5_8.txt |    1      1

# n :8 and after reduction: 5
#   0.000285 seconds (429 allocations: 27.750 KiB)
# Test Summary:               | Pass  Total
# 2SAT for input_2sat_6_8.txt |    1      1

#   0.000169 seconds (311 allocations: 15.141 KiB)
# Test Summary:                | Pass  Total
# 2SAT for input_2sat_7_10.txt |    1      1

# n :10 and after reduction: 2
#   0.000214 seconds (391 allocations: 19.656 KiB)
# Test Summary:                | Pass  Total
# 2SAT for input_2sat_8_10.txt |    1      1

# n :20 and after reduction: 4
#   0.000235 seconds (673 allocations: 30.766 KiB)
# Test Summary:                | Pass  Total
# 2SAT for input_2sat_9_20.txt |    1      1
