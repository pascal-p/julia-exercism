using Test

include("./huffman_coding_sort_qs.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)
  a = open(ifile) do f
    readlines(f)
  end |> a -> map(s -> parse(Int, s), a)
  (a[2], a[1])
end


# @testset "basics huffamn coding: ABRACADABRA!" begin
#   s = "ABRACADABRA!"
#   tfreq = Dict{UCS, Int}('A' => 5, 'B' => 2, 'D' => 1, 'R' => 2, 'C' => 1, '!' => 1)

#   trie = build_trie(tfreq)
#   st = build_code(trie)

#   @test st['A'] == "0"
#   @test st['B'] == "101"
#   @test st['C'] == "1100"
#   @test st['D'] == "1101"
#   @test st['R'] == "111"
#   @test st['!'] == "100"

#   enc = encode(s, st)
#   @test enc == "0101111011000110101011110100"

#   dec = expand(trie, enc)
#   @test dec == s
# end

# @testset "basics huffamn coding: ABCDEF" begin
#   tfreq = Dict{UCS, Int}('A' => 3, 'B' => 2, 'C' => 6, 'D' => 8, 'E' => 2, 'F' => 6)

#   trie = build_trie(tfreq)
#   st = build_code(trie)

#   @test st['A'] == "100"  # "000"
#   @test st['B'] == "1010" # "0010"
#   @test st['C'] == "00"   # "10"
#   @test st['D'] == "11"   # "01"
#   @test st['E'] == "1011" # "0011"
#   @test st['F'] == "01"   # "11"
# end


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
