const V_REXP = r"\A\d+(?:\.\d){0,}\Z"
const SEP = '.'

function nextversion(v::String)::String
  !occursin(V_REXP, v) && throw(ArgumentError("Expecting a string with format \\d+(?:\\.\\d)*"))

  args = split(v, SEP) |> v -> parse.(Int, v)
  ix = length(args)

  while true
    (ix == 1 || args[ix] < 9) && break
    args[ix] = 0
    ix -= 1
  end

  args[ix] += 1
  join(args |> v -> string.(v), SEP)
end

nextversion(::Any)::Nothing = throw(ArgumentError("Expecting a string with format \\d+(?:\\.\\d)*"))
