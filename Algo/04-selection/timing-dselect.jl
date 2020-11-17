include("file_utils.jl")
include("dselect.jl")

str = open("pi_first_100000.txt") do f
  readlines(f)[1]
end

n = length(str)
x = [ parse(Int, str[ix:ix + 10]) for ix in 3:10:(n - 10) ]

n = length(x)
@time dselect(x, n ÷ 2) == 50217159133
