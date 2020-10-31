import Base.zero

const VInt = Vector{T} where {T <: Integer}

function all_your_base(digits::VInt, base_in::Integer, base_out::Integer)::VInt
  (base_in ≤ 1 || base_out ≤ 1) && throw(DomainError("bases should be > 1"))

  check_digits(digits, base_in) && return [0]

  n = to_base10(digits, base_in)

  base_out == 10 && return map(s -> parse(Int, s), split(string(n), ""))

  ## how many digits in the target base => inexactError: trunc(Int64, -Inf), if n ≤ 0
  hmd = floor(Integer, log(n) / log(base_out)) + 1
  ndigits = zeros(Int, hmd)
  ix = length(ndigits)
  while n > 0
    (n, r) = divrem(n, base_out)
    ndigits[ix] = r
    ix -= 1
  end

  return ndigits
end

function all_your_base(digits::Any, base_in::Integer, base_out::Integer)::VInt
  (base_in ≤ 1 || base_out ≤ 1) && throw(DomainError("bases should be > 1"))

  length(digits) == 0 && return [0]

  throw(DomainError("Not supported"))
end


function to_base10(digits::VInt, base::Integer)::Integer
  n = zero(digits)

  for ix in 1:length(digits) - 1
    p = (n + digits[ix]) * base
    if p < n  # => overflow
      p = (UInt128(n) + digits[ix]) * base
      ## we can stil have overflow!
    end
    n = p
  end

  n += digits[end]
end

function check_digits(digits::VInt, base::Integer)::Bool
  ## At this stage digits is of length 1 at least
  all_zeros = true  # we piggy-back on this check to verify whether all digits are 0
  zero_ = zero(digits)

  for d in digits
    d != zero_ && (all_zeros = false)

    (d < 0 || d ≥ base) && throw(DomainError("digit d; $(d) should be < that its base $(base)"))
  end

  return all_zeros
end

# digits array is at least of length 1
zero(digits::VInt) = zero(typeof(digits[1]))
