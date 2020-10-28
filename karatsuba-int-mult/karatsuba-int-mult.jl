const TInteger = Tuple{Integer, Integer}

"""
   karatsuba(x, y)

   Principle (B = base),
   x = x₁ × Bᵐ + x₀
   y = y₁ × Bᵐ + y₀

   x×y = (x₁ × Bᵐ + x₀) × (y₁ × Bᵐ + y₀)
       = z₂ × B²ᵐ + z₁ × Bᵐ + z₀

   where: z₂ = x₁ × y₁
          z₀ = x₀ × y₀
          z₁ = x₁ × y₀ + x₀ × y₁ = (x₁ + x₀) × (y₁ + y₀) - z₂ - z₀ (or = (x₀ - x₁) × (y₁ - y₀) +  z₂ + z₀)

  ref. https://en.wikipedia.org/wiki/Karatsuba_algorithm

  the issue with (x₁ + x₀) × (y₁ + y₀) - z₂ - z₀ is that it can result in an overflow => result in  Bᵐ ≤ result ≤ 2×Bᵐ,
  whereas with (x₀ - x₁) × (y₁ - y₀) +  z₂ + z₀ the result is in -Bᵐ < result < Bᵐ

"""
function karatsuba(x::Integer, y::Integer)::Integer
  (x < 10 || y < 10) && return x * y
  ((x₁, x₀), (y₁, y₀), m) = split(x, y)

  z₀ = karatsuba(x₀, y₀)
  z₂ = karatsuba(x₁, y₁)
  z₁ = karatsuba(x₀ - x₁, y₁ - y₀) + z₂ + z₀ # karatsuba(x₁ + x₀, y₁ + y₀) - z₂ - z₀

  b₂, b₁ = power10(2m), power10(m)
  z₂ * b₂ + z₁ * b₁ + z₀
end

function split(x::Integer, y::Integer)::Tuple{TInteger, TInteger, Integer}
  n = max(length(string(x)), length(string(y)) )
  m = ceil(Integer, n / 2)

  b = convert(Integer, power10(m))

  x₁, x₀ = divrem(x, b)  # x ÷ b, x % b
  y₁, y₀ = divrem(y, b)  # y ÷ b, y % b

  ((x₁, x₀), (y₁, y₀), m)
end

function power10(m::Integer)::Integer
  m ≤ 18 && return 10^m

  string("1", string("0" ^ m)) |>
    s -> parse(BigInt, s)
end
