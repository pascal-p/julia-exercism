using Test

include("./mwis.jl")

const TF_DIR = "./testfiles"
const A = [1, 2, 3, 4, 17, 117, 517, 997]


function basic_tcs()
  # pair of weigths / solution
  [
   ([1, 4, 5, 4], ([2, 4], 8)),
   ([2, 4, 1, 5, 4, 7], ([2, 4, 6], 16)),
   ([3, 2, 1, 6, 4, 5], ([1, 4, 6], 14)),
   ]
end

function read_sol(ifile)
  open(ifile) do f
    readlines(f)
  end[1]
end

function bitstr(a::TS{T}) where T
  n = length(A)
  bs = ""

  for ix in 1:length(a) # min(length(a), n)
    jx = findfirst(isequal(a[ix]), A)

    if jx ≠ nothing
      bs = string(bs, '0' ^ (jx - length(bs) - 1))
      bs = string(bs, '1')
    end

    length(bs) ≥ n && break
  end

  length(bs) < n && (bs = string(bs, "0" ^ (n - length(bs))))
  # println("a: $(a) / bs: $(bs)")
  return bs
end


@testset "basics / purely recursive version" begin
  for (w, exp) in basic_tcs()
    wg = WGraph{Int}(w)

    @test calc_mwis_rec(wg) == exp
  end
end

@testset "basics / memo-recursive version" begin
  for (w, exp) in basic_tcs()
    wg = WGraph{Int}(w)

    @test calc_mwis_rec_memo(wg) == exp
  end
end

@testset "basics / iterative version" begin
  for (w, exp) in basic_tcs()
    wg = WGraph{Int}(w)

    @test calc_mwis_iter(wg) == exp
  end
end

for file in filter((fs) -> occursin(r"\Ainput_random_\d+_\d+\.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")

  @testset "iter version: $(file)" begin
    wg = WGraph{Int}("$(TF_DIR)/$(file)")
    (a, _s) = calc_mwis_iter(wg)

    @test bitstr(a[1:end]) == exp_value
  end

  @testset "recursion-memo version: $(file)" begin
    wg = WGraph{Int}("$(TF_DIR)/$(file)")
    (a, _s) = calc_mwis_rec_memo(wg)

    @test bitstr(a[1:end]) == exp_value
  end

end

## challenge file is "$(TF_DIR)/input_mwis.txt"
for file in filter((fs) -> occursin(r"\Ainput_mwis.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")

  @testset "iter version on challenge $(file)" begin
    wg = WGraph{Int}("$(TF_DIR)/$(file)")
    (a, _s) = calc_mwis_iter(wg)

    @time @test bitstr(a[1:end]) == exp_value
  end

  @testset "recursion-memo version on challenge $(file)" begin
    wg = WGraph{Int}("$(TF_DIR)/$(file)")
    (a, _s) = calc_mwis_rec_memo(wg)

    @time @test bitstr(a[1:end]) == exp_value
  end
end
