push!(LOAD_PATH, "../primes/src")
using YA_PRIMES


function sum_primes(n::T) where {T <: Integer}
  """
  returns the sum of the primes ≤ n
  """
  pr = Primes{T}(n)

  sum(pr)
end

function sum_primes(::Any)
  throw(ArgumentError("Not an integer argument"))
end
