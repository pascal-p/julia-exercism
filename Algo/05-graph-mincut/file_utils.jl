function slurp(ifile)
  open(ifile) do f
    readlines(f)
  end |> a -> map(s -> split(s, "\t")[1:end - 1], a) |> a -> map(xa -> map(s -> parse(Int, s), xa), a)
end

# karger_mincut.txt
# 200-element Array{Array{Int64,1},1}:
# [1, 37, 79, 164, 155, 32, 87, 39, 113, 15  …  4, 160, 97, 191, 100, 91, 20, 69, 198, 196]
# [2, 123, 134, 10, 141, 13, 12, 43, 47, 3  …  182, 117, 116, 36, 103, 51, 154, 162, 128, 30]
# ...
# [200, 149, 155, 52, 87, 120, 39, 160, 137, 27  …  23, 126, 84, 166, 150, 62, 67, 1, 69, 35]
