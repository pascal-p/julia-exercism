module YA_PRIMES

  import Base: length, iterate, collect, eltype

  export Primes, nth, get_primes,
    length, iterate, collect, eltype

  include("primes.jl")
end
