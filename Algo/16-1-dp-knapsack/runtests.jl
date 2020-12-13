using Test

include("./knapsack_dp.jl")

const TF_DIR = "./testfiles"

function read_sol(ifile)::T_Int
  open(ifile) do f
    readlines(f)
  end[1] |> s -> parse(T_Int, strip(s))
end

function small_ds()
  items = [TItem{T_Int, T_Int}(T_Int(3), T_Int(4)), TItem{T_Int, T_Int}(T_Int(2), T_Int(3)), TItem{T_Int, T_Int}(T_Int(4),T_Int(2)), TItem{T_Int, T_Int}(T_Int(4), T_Int(3))]
  capa = T_Int(6)
  exp_value = 8
  (items, capa, exp_value)
end


@testset "basics of knapsack iterative version" begin
  items, capa, exp_value = small_ds()

  # expect items == [3, 4]
  @test knapsack_iter(items, capa) == ([3, 4], exp_value)
  @test knapsack_iter_opt(items, capa) == exp_value
end

@testset "basics of knapsack recursive version" begin
  items, capa, exp_value = small_ds()

  @test knapsack_rec(items, capa)[1] == exp_value
end

@testset "basics of knapsack recursive memo version" begin
  items, capa, exp_value = small_ds()

  @test knapsack_rec_memo(items, capa) == exp_value
end

for file in filter((fs) -> occursin(r"\Ainput_random_\d+_\d+_\d+.txt", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_value = read_sol("$(TF_DIR)/$(ifile)")
  (items, capa) = from_file("$(TF_DIR)/$(file)", T_Int, T_Int)
  # sort!(items, by=(itm) -> size(itm))

  @testset "iter version: $(file)" begin
    @test knapsack_iter_opt(items, capa) == exp_value
  end

  #@testset "iter version: $(file)" begin
  #  @test knapsack_iter(items, capa)[2] == exp_value
  #end

  @testset "recursion-memo version: $(file)" begin
    @test knapsack_rec_memo(items, capa) == exp_value
  end

end
