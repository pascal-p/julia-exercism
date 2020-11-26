include("./utils/file.jl")
include("src/dselect.jl")

const TF_DIR = "./testfiles"

str = open("$(TF_DIR)/pi_first_100000.txt") do f
  readlines(f)[1]
end

n = length(str)
x = [ parse(Int, str[ix:ix + 10]) for ix in 3:10:(n - 10) ]

n = length(x)
@time dselect(x, n ÷ 2) == 50217159133
