module YA_PRIMES

  import Base: length, iterate, collect, eltype, sum

  export Primes, nth, get_primes,
    length, iterate, collect, eltype, sum

  include("primes.jl")
end
