function collatz_steps(n::BigInt)::Unsigned
  n ≤ 0 && throw(DomainError("n must be > 0"))
  _collatz_steps(n)
end

function collatz_steps(n::Integer)::Unsigned
  n ≤ 0 && throw(DomainError("n must be > 0"))

  # default - can still overflow...
  _collatz_steps(UInt128(n))
end

function _collatz_steps(n::Integer)::Unsigned
  n_step::Unsigned = 0

  while n > 1
    n = isodd(n) ? 3n + 1 : n ÷ 2

    n_step += 1
  end

  return n_step
end
