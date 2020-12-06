using Test

include("./clustering.jl")
const TF_DIR = "./testfiles"

# Question 2
#
# In this question your task is again to run the clustering algorithm from lecture, but on a MUCH bigger graph.
# So big, in fact, that the distances (i.e., edge costs) are only defined implicitly, rather than being provided as an explicit list.
#
# The data set is below.
# clustering_big.txt
#
# The format is:
#
# [# of nodes] [# of bits for each node's label]
# [first bit of node 1] ... [last bit of node 1]
# [first bit of node 2] ... [last bit of node 2]
# ...
#
# For example, the third line of the file "0 1 1 0 0 1 1 0 0 1 0 1 1 1 1 1 1 0 1 0 1 1 0 1" denotes the 24 bits associated with node #2.
#
# The distance between two nodes uuu and vvv in this problem is defined as the Hamming distance --- the number of differing bits ---
# between the two nodes' labels. For example, the Hamming distance between the 24-bit label of node #2 above and the label
# "0 1 0 0 0 1 0 0 0 1 0 1 1 1 1 1 1 0 1 0 0 1 0 1" is 3 (since they differ in the 3rd, 7th, and 21st bits).
#
# The question is: what is the largest value of k such that there is a k-clustering with spacing at least 3?
# That is, how many clusters are needed to ensure that no pair of nodes with all but 2 bits in common get split into different clusters?
# => differing of 0, 1 or 2 bits
#
# NOTE: The graph implicitly defined by the data file is so big that you probably can't write it out explicitly, let alone sort the edges by cost.
# So you will have to be a little creative to complete this part of the question.
# For example, is there some way you can identify the smallest distances without explicitly looking at every pair of nodes?
#

function read_sol(ifile)
  open(ifile) do f
    readlines(f)
  end |> a -> parse(Int, a[1])
end


for file in filter((fs) -> occursin(r"\Ainput_random_\d+_\d+_\d+\.", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")

  @testset "clustering on: $(file)" begin
    @time @test det_n_clusters("$(TF_DIR)/$(file)") == exp_value
  end
end

## challenge file is "$(TF_DIR)/test_clustering_big.txt"
for file in filter((fs) -> occursin(r"\Ainput_clustering_big.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")

  @testset "clustering on: $(file)" begin
    @time @test det_n_clusters("$(TF_DIR)/$(file)") == exp_value
  end
end

#
#  3.210582 seconds (12.40 M allocations: 1.032 GiB, 7.77% gc time)
# Test Summary:                           | Pass  Total
# clustering on: input_clustering_big.txt |    1      1
#
