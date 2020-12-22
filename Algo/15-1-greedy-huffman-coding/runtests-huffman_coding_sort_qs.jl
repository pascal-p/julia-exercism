using Test

include("./huffman_coding_sort_qs.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)
  a = open(ifile) do f
    readlines(f)
  end |> a -> map(s -> parse(Int, s), a)
  (a[2], a[1])
end


for file in filter((fs) -> occursin(r"\Ainput_random_\d+_\d+\.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_values = read_sol("$(TF_DIR)/$(ifile)")

  @testset "Huffman coding on: $(file)" begin
    (min_len_cw, max_len_cw) = huffman("$(TF_DIR)/$(file)", Int)

    @test (min_len_cw, max_len_cw) == exp_values
  end
end

## challenge file is "$(TF_DIR)/test_clustering_big.txt"
for file in filter((fs) -> occursin(r"\Ainput_huffman.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")

  @testset "clustering on: $(file)" begin
    @time @test huffman("$(TF_DIR)/$(file)", Int) == exp_value
  end
end
