push!(LOAD_PATH, "../primes/src")
using YA_PRIMES

const MAX_PRIME_LIM = 1_000_000  # =>  78_498 first primes, last prime:   999_983
#                     2_000_000  # => 148_933 first primes, last prime: 1_999_993
#                     5_000_000  # => 348_513 first primes, last prime: 4_999_999

function prime(num::Integer; lim=MAX_PRIME_LIM)::Integer
  0 < num < lim || throw(ArgumentError("Out of bounds"))

  # pr = Primes{typeof(lim)}(lim)
  primes = gen_primes_lt(lim)
  n_pr = length(collect(primes))
  
  if num > n_pr
    throw(ArgumentError("You need to increase the current limit of $(lim) to get the $(num)-th prime / currently only $(n_pr) primes available"))
  end

  nth(primes, num)
end

let primes = nothing, lim = 0

  global function gen_primes_lt(n::Integer)
    primes = Primes{typeof(n)}(n)
    lim = n
    return primes
  end

end
