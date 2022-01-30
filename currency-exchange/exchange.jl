using Printf

# a Decimal type
struct Decimal <: Real
  x::Real
  Decimal(x::Real) = new(round(Float64(x); digits=2))
end

const ExcVal = NamedTuple{(:raw, :exc), Tuple{Real, Integer}}


"""
    exchange_money(budget::Real, exchange_rate::Real)::Decimal

Compute the value of the exchanged currency

# Examples
```julia-repl
julia> exchange_money(127.5, 1.2)
106.25
```
"""
function exchange_money(budget::Real, exchange_rate::Real)::Decimal
  f = 100.0
  r = budget * f / exchange_rate # Float64
  Decimal(r / f)
end

exchange_money(::Any, ::Any) = throw(ArgumentError("Expecting numbers as input to `exchange_money`"))


"""
    get_change(budget::Real, exchanging_value::Real)::Decimal

Compute the amount of money that *is left* from the budget.

# Examples
```julia-repl
julia> get_change(127.5, 120)
7.5
```
"""
function get_change(budget::Real, exchanging_value::Real)::Decimal
  exchanging_value > budget && throw(
    ArgumentError("Expecting exchanging_value(= $(exchanging_value)) ≤ budget(= $(budget))")
  )
  budget - exchanging_value |> Decimal
end

get_change(::Any, ::Any) = throw(
  ArgumentError("Expecting numbers as input to `get_change`")
)

"""
    get_value_of_bills(denomination::Unsigned, number_of_bills::Unsigned)::Unsigned

Return only the total value of the bills (_excluding fractional amounts_)

# Examples
```julia-repl
julia> get_value_of_bills(5, 128)
640
```
"""
function get_value_of_bills(denomination::Unsigned, number_of_bills::Unsigned)::Signed
  # use Signed to get back a decimal value (otherwise, getting an hex value)
  # problem with this is possible overflow!
  denomination * number_of_bills |> Integer
end

function get_value_of_bills(denomination::Integer, number_of_bills::Integer)
  (denomination < 0 || number_of_bills < 0) && throw(ArgumentError(
    "Expecting natural integer (zero included)"
  ))
  get_value_of_bills(
    Unsigned(denomination),
    Unsigned(number_of_bills)
  )
end

get_value_of_bills(::Any, ::Any) = throw(
  ArgumentError("Expecting numbers(natural integers) as input to `get_value_of_bills`")
)


"""
    exchangeable_value(budget::Real, exchange_rate::Real,
                            spread::Signed, denomination::Signed)::Signed

Return the _number of new currency bills_ that you can receive within the given _budget_.

# Examples
```julia-repl
julia> exchangeable_value(127.25, 1.20, 10, 20)
80
julia> exchangeable_value(127.25, 1.20, 10, 5)
95
```
"""
function exchangeable_value(budget::Real, exchange_rate::Real,
                            spread::Unsigned, denomination::Unsigned)::Signed
  exch_value_helper(budget, exchange_rate, spread,
                    denomination).exc
end

function exchangeable_value(budget::Real, exchange_rate::Real,
                            spread::Integer, denomination::Integer)::Signed
  (denomination < 0 || spread < 0) && throw(ArgumentError(
    "Expecting natural integer (zero included) for `spread` and `denomination`"
  ))
  exchangeable_value(budget, exchange_rate, Unsigned(spread), Unsigned(denomination))
end

exchangeable_value(::Any, ::Any, ::Any, ::Any) = throw(
  ArgumentError("Expecting numbers as input to `exchangeable_value`")
)

"""
    non_exchangeable_value(budget::Real, exchange_rate::Real,
                                spread::Signed, denomination::Signed)

Return the value that is *not* exchangeable due to the *denomination* of the bills.

# Examples
```julia-repl
julia> non_exchangeable_value(127.25, 1.20, 10, 20)
16
julia> non_exchangeable_value(127.25, 1.20, 10, 5)
1
```
"""
function non_exchangeable_value(budget::Real, exchange_rate::Real,
                                spread::Unsigned, denomination::Unsigned)::Signed
  raw, exc_val = exch_value_helper(budget, exchange_rate, spread,
                                   denomination)
  Int(floor(raw; digits=0)) - exc_val
end

function non_exchangeable_value(budget::Real, exchange_rate::Real,
                                spread::Integer, denomination::Integer)::Signed
  (denomination < 0 || spread < 0) && throw(ArgumentError(
    "Expecting natural integer (zero included) for `spread` and `denomination`"
  ))
  non_exchangeable_value(budget, exchange_rate, Unsigned(spread), Unsigned(denomination))
end

non_exchangeable_value(::Any, ::Any, ::Any, ::Any) = throw(
  ArgumentError("Expecting numbers as input to `non_exchangeable_value`")
)

## Internal helpers

function exch_value_helper(budget::Real, exchange_rate::Real,
                           spread::Unsigned, denomination::Unsigned)::ExcVal
  spreadf = Float64(spread) / 100.0                 # convert spread to Float64
  exc_rate_spread = exchange_rate * (1.0 + spreadf) # applying spread to echange rate
  res = budget / exc_rate_spread
  whole_res = round(res; digits=0) |> Integer
  (raw = res, exc = (whole_res ÷ denomination) * denomination)
end

function Base.show(io::IO, d::Decimal)
  if Float64(d.x - round(d.x; digits=0)) == zero(Float64)
    print(io, @sprintf "%d" d.x)
  else
    print(io, @sprintf "%.2f" d.x)
  end
end
