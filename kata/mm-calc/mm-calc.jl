
add(x::Integer, y::Integer)::Integer = x + y

sub(x::Integer, y::Integer)::Integer = x - y

mul(x::Integer, y::Integer)::Integer = x * y

function fdiv(x::Integer, y::Integer)::Float64
  y == zero(Integer) && return NaN

  x / y |> r -> round(r; digits=2)
end

mod(x::Integer, y::Integer)::Integer = x % y

const OpMap = Dict{String, Function}(
  "+" => add,
  "-" => sub,
  "*" => mul,
  "/" => fdiv,
  "%" => mod
)

function calc(x::Integer, y::Integer, op::String)
  OpMap[op](x, y)
end
