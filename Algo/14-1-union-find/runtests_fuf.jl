using Test

push!(LOAD_PATH, "./src")
using YAFUF

const TF_DIR = "./testfiles"

function read_sol(ifile)
  open(ifile) do f
    readlines(f)
  end |> a -> parse(Int, a[1])
end


for file in filter((fs) -> occursin(r"\Ainput_.+\.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")

  @testset "(heap based) prim MST on: $(file)" begin
    uf = UnionFind("$(TF_DIR)/$(file)")
    @test count(uf) == exp_value
  end
end
