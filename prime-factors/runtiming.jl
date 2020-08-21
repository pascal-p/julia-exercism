# canonical data version 1.1.0

include("prime-factors.jl")

# create a macro

macro show_time(what, body)
  return quote
    println("+ ", $(esc(what)), ": ")

    @time $(esc(body))
  end
end

for algo in (pf_trial, pf_wheel,)
  println("\n=== method $(algo)")

  @show_time "no factors" begin
    prime_factors(1; algo)
  end

  for n in FIRST_PRIMES
    @show_time "prime factors of $(n)" begin
      prime_factors(n; algo)
    end
  end

  for n in [2_345_678_917, ]
    @show_time "prime factors of $(n)" begin
      prime_factors(n; algo) == [n]
    end
  end

  for (n, _) in [
                 (9, [3,3]), (49, [7,7]), (121, [11, 11]),
                 (169, [13, 13]), (25, [5, 5]), (4, [2, 2])
                 ]
    @show_time "square of a prime of $(n)" begin
      prime_factors(n; algo)
    end
  end

  @show_time "cube of a prime" begin
    prime_factors(8; algo)
  end

  @show_time "power of 2" begin
    prime_factors(1024; algo)
  end

  @show_time "product of primes and non-primes" begin
    prime_factors(12; algo)
  end

  @show_time "product of primes" begin
    prime_factors(901255; algo)
    prime_factors(5959; algo)
    prime_factors(1000009; algo)
  end

  @show_time "random integer" begin
    prime_factors(199_999_999; algo)
    prime_factors(199_999_999_998; algo)
    prime_factors(700_666_999_666; algo)
    prime_factors(1_099_511_627_775; algo)
  end

  @show_time "factors include a large prime" begin
    prime_factors(93819012551; algo)
  end

  @show_time "factors of a huge integer 2^64 - 1" begin
    prime_factors(UInt128(340282366920938463463374607431768211455); algo)
  end
end
