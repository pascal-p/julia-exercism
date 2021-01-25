const FT{T} = Union{Tuple{T, Vector{Tuple{T, T}}}, Nothing} where T

struct Factors{T <: Integer}
  min_val::FT{T}
  max_val::FT{T}

  function Factors{T}(;min_factor::T=1, max_factor::T=9) where T
    min_factor > max_factor &&
      throw(ArgumentError("min_factor $(min_factor) must be < max_factor $(max_factor)"))

    v = gen_palindrome_factors(min_factor, max_factor)
    if length(v) > 1
      new(v[1], v[end])
    elseif length(v) == 1
      new(v[1], nothing)
    else
      new(nothing, nothing)
    end
  end
end

largest(f::Factors{T}) where T = f.max_val
smallest(f::Factors{T}) where T = f.min_val

for m ∈ (:largest, :smallest)

  @eval begin
    $(m)(;min_factor::T, max_factor::T) where T = Factors{T}(; min_factor, max_factor) |> f -> $(m)(f)
  end

end

#
# function largest(;min_factor::T, max_factor::T) where T
#   Factors{T}(; min_factor, max_factor) |> f -> largest(f)
# end
#
# function smallest(;min_factor::T, max_factor::T) where T
#   Factors{T}(; min_factor, max_factor) |> f -> smallest(f)
# end
#

##
## Internal Helpers
##

function is_palindrome(p:: T):: Bool where T
  sp = string(p)
  n = length(sp)
  for ix ∈ 1:n
    sp[ix] != sp[n + 1 - ix] && return false
  end
  true
end

function gen_palindrome_factors(a::T, b::T)::Vector{FT{T}} where T
  hsh = Dict{T, Vector{Tuple{T, T}}}()

  for x ∈ a:b, y ∈ x:b
    p = x * y
    is_palindrome(p) && (hsh[p] = push!(get(hsh, p, Vector{Tuple{T, T}}()), (x, y)))
  end

  return sort([(k, v) for (k, v) in hsh], by=x -> x[1])
end
