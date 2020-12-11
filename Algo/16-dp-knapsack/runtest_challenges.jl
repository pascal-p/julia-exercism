using Test

include("./knapsack_dp.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)::T_Int
  open(ifile) do f
    readlines(f)
  end[1] |> s -> parse(T_Int, strip(s))
end

## challenge file are "$(TF_DIR)/input_knapsack1.txt", "$(TF_DIR)/input_knapsack_big.txt"
for file in filter((fs) -> occursin(r"\Ainput_knapsack.+.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")
  (items, capa) = from_file("$(TF_DIR)/$(file)", T_Int, T_Int)
  # sort!(items, by=(itm) -> size(itm))

  @testset "recursion-memo version on challenge $(file)" begin
    @time @test knapsack_rec_memo(items, capa) == exp_value
  end

  @testset "iter-opt version on challenge $(file)" begin
    @time @test knapsack_iter_opt(items, capa) == exp_value
  end
end

# Test Summary:                                           | Pass  Total
# recursion-memo version on challenge input_knapsack1.txt |    1      1
# 0.607190 seconds (7.60 M allocations: 209.361 MiB, 9.56% gc time)

# Test Summary:                                              | Pass  Total
# recursion-memo version on challenge input_knapsack_big.txt |    1      1
# 5.005124 seconds (85.99 M allocations: 1.685 GiB, 6.28% gc time)

#  0.027707 seconds (52.79 k allocations: 2.852 MiB)
# Test Summary:                                     | Pass  Total
# iter-opt version on challenge input_knapsack1.txt |    1      1

#  7.114379 seconds (15 allocations: 15.260 MiB)
# Test Summary:                                        | Pass  Total
# iter-opt version on challenge input_knapsack_big.txt |    1      1
