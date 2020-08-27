"""
  1 - Find proprer divisors of n

  2 - Sum of divisors

  3 - Classify perfect or abundant or deficient
"""

for (fun, op) in ((:isperfect, ==), (:isabundant, >),)
  @eval begin
    function $fun(n::Integer)::Bool
      check_domain(n)

      ($op)(Σ_proper_divisors(n), n)  ## ($op)(find_proper_divisors(n) |> sum, n)
    end
  end
end

function isdeficient(n::Integer)::Bool
  check_domain(n)
  n == 1 && return true

  Σ_proper_divisors(n) < n            ## find_proper_divisors(n) |> sum < n
end


function check_domain(n::Integer)
  (n < 0 || iszero(n)) && throw(DomainError("Expecting a strictly positive integer"))
end

function Σ_proper_divisors(n::Integer)::Integer
  "Do not need to build a divisors array, just calculate the sum"

  d, sum_ = 2, 1
  while d * d ≤ n
    m, r = divrem(n, d)
    if r == 0
      sum_ += m == d ? d : d + m
    end
    d += 1
  end

  return sum_
end

# function find_proper_divisors(n::Integer)::Vector{Integer}
#   ary::Vector{Integer} = [1, ]

#   d = 2
#   while d * d ≤ n
#     m, r = divrem(n, d)
#     if r == 0
#       m == d ? push!(ary, d) : push!(ary, d, m)
#     end
#     d += 1
#   end

#   return ary
# end
