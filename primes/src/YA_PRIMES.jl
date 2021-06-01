module YA_PRIMES

  import Base: length, iterate, collect, eltype, sum

  export Primes, v, nth, get_primes, generate_n_firstprimes,
    length, iterate, collect, eltype, sum

  include("primes.jl")
end
