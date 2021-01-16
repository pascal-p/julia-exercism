push!(LOAD_PATH, "../primes/src")
using YA_PRIMES

function sieve(lim::Integer)
  pr = Primes{typeof(lim)}(lim)

  return collect(pr)
end

function sieve(::Any)
  throw(ArgumentError("the sieve argument must be an integer"))
end
