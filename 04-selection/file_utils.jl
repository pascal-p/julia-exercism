function slurp(ifile)
  open(ifile) do f
    readlines(f)
  end |> a -> map(s -> parse(Int, s), a)
end
