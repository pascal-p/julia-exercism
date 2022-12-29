const LENBASE = 3

fₙ(n::Unsigned) = n == zero(Unsigned) ? zero(Unsigned) : fact_by(n + 1)

function fₙ(n::Integer)
  @assert n ≥ 0
  fₙ(unsigned(n))
end

fact_by(n::Unsigned, x = unsigned(2)) = (n * (n - 1)) ÷ x

function decompose(n::Unsigned)
  @assert n > zero(Unsigned)
  f = factor(n)
  cn, base = n, Unsigned[]

  while true
    x = fₙ(f)
    while x > cn
      (f, x) = next_factor(f)
    end

    if cn - x ≥ 0 && f ∉ base
      (cont, cn, f, base) = decision(cn, f, x, n, base)
      cont ? continue : return base
    end

    ## cn - x < 0
    (f, x) = next_factor(f)
    while x > cn
      (f, x) = next_factor(f)
    end

    (cont, cn, f, base) = decision(cn, f, x, n, base)
    cont ? continue : return base
  end
end

function decompose(n::Integer)
  @assert n > 0
  decompose(unsigned(n))
end

Σ(base::AbstractVector{<: Unsigned}) = sum(fₙ.(base))

# highest factor base: solving p ⨱ (p - 1) = 2n
factor(n::Unsigned)::Unsigned = floor(Unsigned, (one(Unsigned) + √(one(Unsigned) + unsigned(8)*n)) / unsigned(2))

@inline function next_factor(f::Unsigned)
  f -= 1
  x = fₙ(f)
  (f, x)
end

function process_cases(cn::Unsigned, f::Unsigned, n::Unsigned, base::AbstractVector{<: Unsigned})
  cn == 0 && Σ(base) == n && length(base) == LENBASE && return (false, cn , f, base |> transform)
  if cn == 0 && Σ(base) == n && length(base) == LENBASE - 1
    zero(Unsigned) ∉ base && return (false, cn , f, [base..., zero(Unsigned)] |> transform)
    return (true, redo(n, base)...)
  elseif cn ≥ 0 && length(base) < LENBASE
    f = factor(cn)
    return (true, cn, f, base)
  end
  (true, redo(n, base)...)
end

function decision(cn::Unsigned, f::Unsigned, x::Unsigned, n::Unsigned, base::AbstractVector{<: Unsigned})
  cn -= x
  push!(base, f)
  process_cases(cn, f, n, base) # => (cont, cn, f, base)
end

transform(base::AbstractVector{<: Unsigned})::Tuple{Integer, Integer, Integer} = base |> sort |> v -> Int.(v) |> Tuple

function redo(n, base)
  f = base[1] - 1
  @assert f > zero(Unsigned) "factor f must be positive or zero"
  base = Unsigned[]
  (n, f, base)
end
