import Base.zero

const AVInt = AbstractVector{T} where {T <: Integer}

function all_your_base(digits::AVInt{T}, base_in::UInt, base_out::UInt)::AVInt{T} where {T <: Integer}
  check_digits(digits, base_in) && return [0]
  base_in == base_out && return digits
  n = to_base10(digits, base_in)
  # base_out == 10 && return map(s -> parse(Int, s), split(string(n), ""))

  try
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

  catch err
    if isa(err, InexactError)
      println("Intercepted Inexsact Error (conversion problem)")
      rethrow(err)
    end
    # do NOT handle other types of error
  end
end

function all_your_base(digits::AVInt{T}, base_in::Integer, base_out::Integer)::AVInt{T} where {T <: Integer}
  check_valid_bases(base_in, base_out)
  all_your_base(digits, UInt(base_in), UInt(base_out))
end

function all_your_base(digits::Any, base_in::Integer, base_out::Integer)::AVInt
  check_valid_bases(base_in, base_out)

  length(digits) == 0 && return [0]

  throw(DomainError("Not supported"))
end

"""
Convert to decimal base
"""
function to_base10(digits::AVInt{T}, base::Integer)::Integer where {T <: Integer}
  n = zero(digits)

  for ix in 1:length(digits) - 1
    p = (n + digits[ix]) * base
    if p < n  # => overflow
      p = (UInt128(n) + digits[ix]) * base # we can still have an overflow!
    end
    n = p
  end

  n += digits[end]
end

check_valid_bases(b_in::Integer, b_out::Integer) = (b_in ≤ 1 || b_out ≤ 1) && throw(DomainError("bases should be > 1"))

"""
Check whether each digit from digits (abstract) vector are ∈ [0..base-1]
Also if all digits are 0 - returns a boolean set to true to short-cut the execution
"""
function check_digits(digits::AVInt{T}, base::Integer)::Bool where {T <: Integer}
  ## At this stage digits vector is, at least, of length 1
  all_zeros = true  # we piggy-back on this check to verify whether all digits are 0
  zero_ = zero(digits)

  for d ∈ digits
    d ≠ zero_ && (all_zeros = false)

    (d < 0 || d ≥ base) && throw(DomainError("digit d: $(d) should be < that its base $(base)"))
  end

  return all_zeros
end

# digits array is at least of length 1
zero(digits::AVInt) = zero(typeof(digits[1]))
