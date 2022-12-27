
import Base: +, -, *, /, %

+(x::String, y::String)::Integer = parse(Int, x) + parse(Int, y)

-(x::String, y::String)::Integer = parse(Int, x) - parse(Int, y)

*(x::String, y::String)::Integer = parse(Int, x) * parse(Int, y)

function /(x::String, y::String)::Float64
  y = parse(Int, y)
  y == 0 && return NaN
  parse(Int, x) / y |> r -> round(r; digits=2)
end

%(x::String, y::String)::Integer = parse(Int, x) % parse(Int, y)

const OpMap = Dict{String, Function}(
  "+" => +,
  "-" => -,
  "*" => *,
  "/" => /,
  "%" => %
)

function calc(x::Integer, y::Integer, op::String)
  OpMap[op](string(x), string(y))
end
