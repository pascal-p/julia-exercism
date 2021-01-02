using Test

include("ls_2sat.jl")

const TF_DIR = "./testfiles"
const expected = Vector{Bool}([true, false, true, true, false, false]) # 101100

for (ix, file) in enumerate(filter((fs) -> occursin(r"\A2sat\d\.txt\z", fs),
                                   cd(readdir, "$(TF_DIR)")))

  @testset "Challenge 2SAT for $(file)" begin
    @time ((act_val, _assign), ) = solve_2sat("$(TF_DIR)/$(file)", Int32)

    @test act_val == expected[ix]
  end
end

# n :100000 and after reduction: 6
#   1.500509 seconds (8.62 M allocations: 307.336 MiB, 9.85% gc time)
# Test Summary:                | Pass  Total
# Challenge 2SAT for 2sat1.txt |    1      1

# n :200000 and after reduction: 56
#   1.444817 seconds (13.97 M allocations: 388.005 MiB, 25.20% gc time)
# Test Summary:                | Pass  Total
# Challenge 2SAT for 2sat2.txt |    1      1

# n :400000 and after reduction: 287
#   3.290108 seconds (28.67 M allocations: 785.074 MiB, 28.03% gc time)
# Test Summary:                | Pass  Total
# Challenge 2SAT for 2sat3.txt |    1      1

# n :600000 and after reduction: 11
#   4.498766 seconds (38.18 M allocations: 1.055 GiB, 31.39% gc time)
# Test Summary:                | Pass  Total
# Challenge 2SAT for 2sat4.txt |    1      1

# n :800000 and after reduction: 98
#   7.196926 seconds (60.53 M allocations: 1.607 GiB, 27.61% gc time)
# Test Summary:                | Pass  Total
# Challenge 2SAT for 2sat5.txt |    1      1

# n :1000000 and after reduction: 26
#   7.940000 seconds (65.19 M allocations: 1.738 GiB, 30.38% gc time)
# Test Summary:                | Pass  Total
# Challenge 2SAT for 2sat6.txt |    1      1
