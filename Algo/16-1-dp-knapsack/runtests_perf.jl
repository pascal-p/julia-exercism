include("./knapsack_dp.jl")

const TF_DIR = "./testfiles"

for file in filter((fs) -> occursin(r"\Ainput_random_[34]\d_\d+_\d+.txt", fs),
                   cd(readdir, "$(TF_DIR)"))


  (items, capa) = from_file("$(TF_DIR)/$(file)", T_Int, T_Int)
  println("knapsack iter bottom/up $(file)")
  @time knapsack_iter(items, capa)

  (items, capa) = from_file("$(TF_DIR)/$(file)", T_Int, T_Int)
  println("knapsack rec-memo top/down $(file)")
  @time knapsack_rec_memo(items, capa)

  println()
end

# knapsack iter bottom/up input_random_36_100000_2000.txt
#   3.209107 seconds (7 allocations: 763.329 MiB, 1.05% gc time)
# knapsack rec-memo top/down input_random_36_100000_2000.txt
# 117.092202 seconds (1.54 G allocations: 36.016 GiB, 1.54% gc time)

# knapsack iter bottom/up input_random_37_1000000_2000.txt
#  54.414846 seconds (7 allocations: 7.454 GiB, 0.00% gc time)
# knapsack rec-memo top/down input_random_37_1000000_2000.txt
# Killed
