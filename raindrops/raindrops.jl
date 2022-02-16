
# type stability check
"""
julia> include("raindrops.jl")
decomp (generic function with 1 method)

julia> @code_warntype raindrops(53)
Variables
  #self#::Core.Const(raindrops)
  num::Int64
  res::Vector{String}

Body::String
1 ─       Core.NewvarNode(:(res))
│   %2  = (num ≤ 1)::Bool
└──       goto #3 if not %2
2 ─ %4  = Main.string(num)::String
└──       return %4
3 ─ %6  = (num ∈ Main.FACTORS)::Union{Missing, Bool}
└──       goto #5 if not %6
4 ─ %8  = Base.getindex(Main.MAP, num)::Symbol
│   %9  = (%8 |> Main.string)::String
└──       return %9
5 ─       (res = Main.decomp(num))
│   %12 = Main.length(res)::Int64
│   %13 = (%12 == 0)::Bool
└──       goto #7 if not %13
6 ─ %15 = Main.string(num)::String
└──       return %15
7 ─ %17 = Main.join(res, "")::String
└──       return %17
"""

const MAP = Dict{Integer, Symbol}(
  3 => :Pling,
  5 => :Plang,
  7 => :Plong
)

const FACTORS = keys(MAP) |> collect |> v -> sort(v)


function raindrops(num::Integer)::String
  num ≤ 1 && return string(num)
  num ∈ FACTORS && return MAP[num] |> string

  res = decomp(num)
  length(res) == 0 ? string(num) : join(res, "")
end

function decomp(num::Integer)::Vector{String}
  res = Vector{String}()
  ix = 1
  while ix ≤ length(FACTORS)
    f = FACTORS[ix]

    if num % f == 0
      push!(res, MAP[f] |> string)

      while num % f == 0
        num ÷= f
      end
    end
    ix += 1
    # not interested by any factor other than FACTORS
  end
  res
end


