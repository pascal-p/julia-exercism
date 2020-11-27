using Test

include("./src/karger_mincut.jl")
include("./utils/file.jl")
include("./utils/runner.jl")

const TF_DIR = "./testfiles"

function gen_adj(ifile::String)
  a = slurp("$(TF_DIR)/$(ifile)")
  Dict([x[1] => x[2:end] for x in a])
end

for file in filter((fs) -> occursin(r"\Ainput_random_\d+_\d+", fs),
                   cd(readdir, "$(TF_DIR)"))

  m = match(r"\Ainput_random_(\d+)_(\d+)\.txt", file)
  n1, n2 = map(s -> parse(Int, s), m.captures)

  @testset "mincut file: $(file)" begin
    ifile = replace(file, r"\Ainput_" => s"output_")
    exp_k = read_sol("$(TF_DIR)/$(ifile)")

    adjl = gen_adj(file)
    gr = UnGraph{Int}(adjl)

    seed = 801
    n = if n2 ≤ 10
      50
    elseif n2 ≤ 25
      250
    elseif n2 ≤ 50
      500
    elseif n2 ≤ 75
      600
    elseif n2 ≤ 125
      900
    elseif n2 ≤ 150
      1200
    elseif n2 ≤ 175
      1500
    else # ≥ 200
      if n1 == 40
        seed = 799
      end
      2500
    end

    (k, ) = runner(gr; n, seed)
    @test k == exp_k
  end
end


# time julia ./runtestfiles.jl

# Test Summary:                        | Pass  Total
# mincut file: input_random_01_006.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_03_006.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_05_010.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_06_010.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_07_010.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_08_010.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_09_025.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_11_025.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_14_050.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_18_075.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_19_075.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_21_100.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_25_125.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_27_125.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_30_150.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_33_175.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_36_175.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_39_200.txt |    1      1

# Test Summary:                        | Pass  Total
# mincut file: input_random_40_200.txt |    1      1

# real    10m17.456s
# user    10m17.550s
# sys     0m0.729s
