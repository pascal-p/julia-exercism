using Test

include("./src/karger_mincut.jl")
include("./utils/file.jl")
include("./utils/runner.jl")

const TF_DIR = "./testfiles"
const FILE_PATTERN = r"\Ainput_random_(\d+)_(\d+)\.txt"

function gen_adj(ifile::String)
  Dict(
    [x[1] => x[2:end] for x ∈ slurp("$(TF_DIR)/$(ifile)")]
  )
end

get_files_from_dir(dir=TF_DIR) = filter((fs) -> occursin(FILE_PATTERN, fs), cd(readdir, dir))

for infile ∈ get_files_from_dir()
  # extract expected answer from filename
  m = match(FILE_PATTERN, infile)
  n₁, n₂ = map(s -> parse(Int, s), m.captures)

  @testset "mincut file: $(infile)" begin
    file = replace(infile, r"\Ainput_" => s"output_")
    exp_k = read_sol("$(TF_DIR)/$(file)")
    seed = 801  # re-seed each time
    adj_list = gen_adj(infile)
    gr = UnGraph{Int}(adj_list)

    ## how many times to run the mincut algorithm using different seeds
    n = if n₂ ≤ 10
      50
    elseif n₂ ≤ 20
      150
    elseif n₂ ≤ 25
      250
    elseif n₂ ≤ 50
      500
    elseif n₂ ≤ 75
      600
    elseif n₂ ≤ 125
      900
    elseif n₂ ≤ 150
      1200
    elseif n₂ ≤ 175
      1500
    else # ≥ 200
      n₁ == 40 && (seed = 799)
      2500
    end

    (k, _) = runner(gr; n=n, seed=seed)
    @test k == exp_k
  end

  # break
end


# pascal@Turing:~/Projects/Exercism/julia/Algo/05-graph-mincut (main)$ julia --project=../.. runtest-files.jl
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_01_006.txt |    1      1  0.9s
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_03_006.txt |    1      1  0.0s
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_05_010.txt |    1      1  0.0s
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_06_010.txt |    1      1  0.0s
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_07_010.txt |    1      1  0.0s
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_08_010.txt |    1      1  0.0s
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_09_025.txt |    1      1  0.1s
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_11_025.txt |    1      1  0.1s
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_14_050.txt |    1      1  1.0s
# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_18_075.txt |    1      1  3.3s

# mincut file: input_random_19_075.txt: Test Failed at ...
#   Expression: k == exp_k
#    Evaluated: 21 == 18
# Test Summary:                        | Fail  Total  Time
# mincut file: input_random_19_075.txt |    1      1  3.5s

# Test Summary:                        | Pass  Total  Time
# mincut file: input_random_21_100.txt |    1      1  9.2s
# Test Summary:                        | Pass  Total   Time
# mincut file: input_random_25_125.txt |    1      1  20.0s
# Test Summary:                        | Pass  Total   Time
# mincut file: input_random_27_125.txt |    1      1  20.6s
# Test Summary:                        | Pass  Total   Time
# mincut file: input_random_30_150.txt |    1      1  41.9s
# Test Summary:                        | Pass  Total     Time
# mincut file: input_random_33_175.txt |    1      1  1m11.3s
# Test Summary:                        | Pass  Total     Time
# mincut file: input_random_36_175.txt |    1      1  1m06.9s

# mincut file: input_random_39_200.txt: Test Failed at ...
#   Expression: k == exp_k
#    Evaluated: 59 == 51
# Test Summary:                        | Fail  Total     Time
# mincut file: input_random_39_200.txt |    1      1  2m57.0s

# real    10m17.456s
# user    10m17.550s
# sys     0m0.729s
