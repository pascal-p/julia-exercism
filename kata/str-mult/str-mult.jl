const T = Int16

#
# String only version
#
function mul(s₁::String, s₂::String)::String
  ## pre-processing
  (s₁, pos₁, sign₁) = preprocessing(s₁)
  (s₂, pos₂, sign₂) = preprocessing(s₂)

  s₁, s₂ = s₁ < s₂ ? (s₁, s₂) : (s₂, s₁) # re-roder

  length(s₁) == 0 && return "0" # only contaions 0 and therefore was compress to empty string
  length(s₁) == 1 && s₂ == "1" && return s₁

  ## processing, i.e. multiplication
  xs = split(s₁, "") |> reverse |> v -> parse.(T, v)
  ys = split(s₂, "") |> reverse |> v -> parse.(T, v)
  vv = mul(xs, ys)
  # println("before vv: <$(vv)>")
  alignseq!(vv)
  # println(" after vv: <$(vv)>")
  s = sumseq(vv) |> reverse |> v -> join(v, "") # sum && stringify

  postprocessing(s, pos₁, pos₂, sign₁, sign₂)
end

function mul(xs::Vector{T}, ys::Vector{T})::Vector
  vv, shift = Vector{}[], 0
  for x ∈ xs
    push!(vv, vcat(zeros(T, shift), ys .* x)) ## Using vectorization
    shift += 1
  end
  vv
end

function alignseq!(vv::Vector)
  l = length(vv[end]) # this is the longest sequence by construction
  for v ∈ vv
    lᵥ = length(v)
    for _ ∈ 1:(l - lᵥ)
      push!(v, zero(T))
    end
  end
  nothing
end

function sumseq(vv::Vector)::Vector{T}
  sv, c = sum(vv), zero(T)
  for ix ∈ 1:length(sv)
    sv[ix] += c
    (c, sv[ix]) = sv[ix] > T(9) ? divrem(sv[ix], T(10)) : (zero(T), sv[ix])
  end
  c > zero(T) && push!(sv, c) # carry
  sv
end

function preprocessing(s::String)
  ## deal with sign, extra 0, and "."
  (s, sign) = startswith(s, "-") ? (s[2:end], -1) : (s, 1)
  s = replace(s, r"^(?:0+)?" => "")
  pos = occursin(r"\.", s) ? find_ix(s) - 1 : -1
  s = pos ≥ 0 ? filter(s_ -> s_ != '.', s) : s
  (s, pos, sign)
end

function postprocessing(s::String, pos₁, pos₂, sign₁, sign₂)
  ## place the "." if required
  l = length(s)
  s = (pos₁ > 0 || pos₂ > 0) ? string(SubString(s, 1, l - pos₁ - pos₂),
                                      ".",
                                      SubString(s, l - pos₁ - pos₂ + 1, l)) : s

  ## sign
  sign₁ * sign₂ == -1 ? string("-", s) : s
end

function find_ix(s::String; ch = '.')
  for (ix, c) ∈ (enumerate ∘ reverse)(s)
    c == ch && return ix
  end
  nothing
end

## alternative mul. w/o vectorization
function mul_(xs::Vector{T}, ys::Vector{T})::Vector
  vv, shift = Vector{}[], 0
  for x ∈ xs
    c, v = zero(T), T[]
    for y ∈ ys
      m = x * y + c
      (c, m) = m > T(9) ? divrem(m, T(10)) : (zero(T), m)
      push!(v, m)
    end
    c > zero(T) && push!(v, c) # carry
    for _ ∈ 1:shift
      pushfirst!(v, zero(T))
    end
    shift += 1
    push!(vv, v)
    c = zero(T) # reset carry
  end
  vv
end

##
## Using BigInt makes it too easy (and why using string then?)
##
# function mul_cheat(s₁::String, s₂::String)::String
#   r = 0
#   s₁, s₂ = s₁ < s₂ ? (s₁, s₂) : (s₂, s₁)
#   xs = split(s₁, "") |> v -> parse.(BigInt, v)
#   y = parse(BigInt, s₂)
#   p = 0
#   for x ∈ xs |> reverse
#     sm  = string(y * x, "0"^p)
#     r += parse(BigInt, sm)
#     p += 1
#   end
#   string(r)
# end
