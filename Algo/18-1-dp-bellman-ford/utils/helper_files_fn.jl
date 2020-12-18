function read_sol(ifile)
  s = open(ifile) do f
    readlines(f)
  end[1]

  occursin(":", s) && (return nothing)
  T = occursin(r"\.", s) ? Float32 : Int
  return parse(T, strip(s))
end

function read_path(ifile)
  a = open(ifile) do f
    readlines(f)
  end[1]
  a == "null" && (return [])

  path = a |> s -> split(strip(s), r"[\[\],\s+]") |>
    a -> filter(s -> length(s) > 0, a) |>
    a -> map(s -> parse(Int, s), a)

  return path
end
