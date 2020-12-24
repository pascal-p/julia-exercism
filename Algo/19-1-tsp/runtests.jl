using Test

include("dp_tsp.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)
  s = open(ifile) do f
    readlines(f)
  end[1]

  return parse(Int, strip(s))
end


@testset "Basics 4×4 graph / 13" begin
  distm = Matrix{Int}(undef, 4, 4) # Expect 13

  distm[1,1]=0; distm[1,2]=1; distm[1,3]=2; distm[1,4]=4
  distm[2,1]=1; distm[2,2]=0; distm[2,3]=3; distm[2,4]=6
  distm[3,1]=2; distm[3,2]=3; distm[3,3]=0; distm[3,4]=5
  distm[4,1]=4; distm[4,2]=6; distm[4,3]=5; distm[4,4]=0

  @test tsp(distm) == 13
end

@testset "Basics 4×4 graph / 21" begin
  distm = Matrix{Int}(undef, 4, 4) # Expect 21

  distm[1,1]=0; distm[1,2]=2; distm[1,3]=9; distm[1,4]=10
  distm[2,1]=1; distm[2,2]=0; distm[2,3]=6; distm[2,4]=4
  distm[3,1]=15; distm[3,2]=7; distm[3,3]=0; distm[3,4]=8
  distm[4,1]=6; distm[4,2]=3; distm[4,3]=12; distm[4,4]=0

  @test tsp(distm) == 21
end


for file in filter((fs) -> occursin(r"\Ainput_float_.+\.txt\z", fs),
                   cd(readdir, "$(TF_DIR)"))
  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_val = read_sol("$(TF_DIR)/$(ifile)")

  @testset "for $(file)" begin
    distm = init_distm("$(TF_DIR)/$(file)", Float32)

    @time @test floor(Int, tsp(distm)) == exp_val
  end
end


# Test Summary:         | Pass  Total
# Basics 4×4 graph / 13 |    1      1

# Test Summary:         | Pass  Total
# Basics 4×4 graph / 21 |    1      1

# 0.118027 seconds (305.75 k allocations: 15.543 MiB)
# Test Summary:            | Pass  Total
# for input_float_10_4.txt |    1      1

#   0.000040 seconds (365 allocations: 20.141 KiB)
# Test Summary:            | Pass  Total
# for input_float_11_4.txt |    1      1

#   0.000038 seconds (365 allocations: 20.141 KiB)
# Test Summary:            | Pass  Total
# for input_float_12_4.txt |    1      1

#   0.000047 seconds (1.02 k allocations: 54.578 KiB)
# Test Summary:            | Pass  Total
# for input_float_13_5.txt |    1      1

#   0.000045 seconds (1.02 k allocations: 54.578 KiB)
# Test Summary:            | Pass  Total
# for input_float_14_5.txt |    1      1

#   0.000078 seconds (1.02 k allocations: 54.578 KiB)
# Test Summary:            | Pass  Total
# for input_float_15_5.txt |    1      1

#   0.000161 seconds (2.63 k allocations: 139.016 KiB)
# Test Summary:            | Pass  Total
# for input_float_17_6.txt |    1      1

#   0.000094 seconds (2.63 k allocations: 139.016 KiB)
# Test Summary:            | Pass  Total
# for input_float_18_6.txt |    1      1

#   0.000132 seconds (2.63 k allocations: 139.016 KiB)
# Test Summary:            | Pass  Total
# for input_float_19_6.txt |    1      1

#   0.000130 seconds (2.63 k allocations: 139.016 KiB)
# Test Summary:            | Pass  Total
# for input_float_20_6.txt |    1      1

#   0.000271 seconds (6.57 k allocations: 344.000 KiB)
# Test Summary:            | Pass  Total
# for input_float_21_7.txt |    1      1

#   0.000636 seconds (16.03 k allocations: 834.250 KiB)
# Test Summary:            | Pass  Total
# for input_float_27_8.txt |    1      1

#   0.001551 seconds (39.66 k allocations: 1.997 MiB)
# Test Summary:            | Pass  Total
# for input_float_29_9.txt |    1      1

#   0.007866 seconds (93.28 k allocations: 4.674 MiB, 54.99% gc time)
# Test Summary:             | Pass  Total
# for input_float_36_10.txt |    1      1

#   0.007138 seconds (216.60 k allocations: 10.808 MiB)
# Test Summary:             | Pass  Total
# for input_float_37_11.txt |    1      1

#   0.008253 seconds (216.60 k allocations: 10.808 MiB)
# Test Summary:             | Pass  Total
# for input_float_40_11.txt |    1      1

#   0.025233 seconds (497.53 k allocations: 24.750 MiB, 20.49% gc time)
# Test Summary:             | Pass  Total
# for input_float_42_12.txt |    1      1

#   0.085573 seconds (2.56 M allocations: 126.585 MiB, 5.50% gc time)
# Test Summary:             | Pass  Total
# for input_float_49_14.txt |    1      1

#   0.084753 seconds (2.56 M allocations: 126.585 MiB, 5.41% gc time)
# Test Summary:             | Pass  Total
# for input_float_50_14.txt |    1      1

#   0.189646 seconds (5.73 M allocations: 283.242 MiB, 5.58% gc time)
# Test Summary:             | Pass  Total
# for input_float_56_15.txt |    1      1

#   0.520756 seconds (12.77 M allocations: 634.299 MiB, 19.40% gc time)
# Test Summary:             | Pass  Total
# for input_float_57_16.txt |    1      1

#   0.531458 seconds (12.77 M allocations: 634.299 MiB, 19.87% gc time)
# Test Summary:             | Pass  Total
# for input_float_58_16.txt |    1      1

#   2.494924 seconds (63.59 M allocations: 3.086 GiB, 11.80% gc time)
# Test Summary:             | Pass  Total
# for input_float_66_18.txt |    1      1

#   2.432990 seconds (63.59 M allocations: 3.086 GiB, 9.12% gc time)
# Test Summary:             | Pass  Total
# for input_float_67_18.txt |    1      1

#   5.277313 seconds (139.35 M allocations: 6.750 GiB, 8.73% gc time)
# Test Summary:             | Pass  Total
# for input_float_70_19.txt |    1      1

#   5.326509 seconds (139.35 M allocations: 6.750 GiB, 8.19% gc time)
# Test Summary:             | Pass  Total
# for input_float_72_19.txt |    1      1

#  12.430911 seconds (304.07 M allocations: 14.699 GiB, 8.02% gc time)
# Test Summary:             | Pass  Total
# for input_float_76_20.txt |    1      1

#  32.040468 seconds (660.88 M allocations: 31.883 GiB, 9.96% gc time)
# Test Summary:             | Pass  Total
# for input_float_79_21.txt |    1      1

#  73.942795 seconds (1.43 G allocations: 68.918 GiB, 10.65% gc time)
# Test Summary:             | Pass  Total
# for input_float_81_22.txt |    1      1

# 166.739019 seconds (3.09 G allocations: 148.522 GiB, 10.90% gc time)
# Test Summary:             | Pass  Total
# for input_float_85_23.txt |    1      1

# 163.555053 seconds (3.09 G allocations: 148.522 GiB, 10.99% gc time)
# Test Summary:             | Pass  Total
# for input_float_86_23.txt |    1      1
