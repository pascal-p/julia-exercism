using Base: InvasiveLinkedListSynchronized

#
# Using BigInt makes it too easy (and why using string then?)
#
function mul_cheat(s₁::String, s₂::String)::String
  r = 0

  s₁, s₂ = s₁ < s₂ ? (s₁, s₂) : (s₂, s₁)
  xs = split(s₁, "") |> v -> parse.(BigInt, v)
  y = parse(BigInt, s₂)
  p = 0
  for x ∈ xs |> reverse
    sm  = string(y * x, "0"^p)
    r += parse(BigInt, sm)
    p += 1
  end

  string(r)
end


const T = Int16
#
# String only version
#
function mul(s₁::String, s₂::String) # ::String
  # deal with sign
  # deal with extra 0
  s₁ = replace(s₁, r"^(?:0+)?" => "")
  s₂ = replace(s₂, r"^(?:0+)?" => "")

  r = 0
  s₁, s₂ = s₁ < s₂ ? (s₁, s₂) : (s₂, s₁)
  xs = split(s₁, "") |> v -> parse.(T, v)
  ys = split(s₂, "") |> v -> parse.(T, v)

  vv = []
  shift = 0
  for x ∈ xs |> reverse
    c, v = zero(T), T[]
    for y ∈ ys |> reverse
      m = x * y + c
      (c, m) = m > T(9) ? divrem(m, T(10)) : (zero(T), m)
      push!(v, m)
    end

    c > zero(T) && push!(v, c)
    for _ ∈ 1:shift
      pushfirst!(v, zero(T))
    end
    shift += 1
    push!(vv, v)
    c = zero(T)
  end

  l = length(vv[end])
  for v ∈ vv
    lᵥ = length(v)
    for _ ∈ 1:(l - lᵥ)
      push!(v, zero(T))
    end
  end

  sv = sum(vv)
  c = zero(T)
  for ix ∈ 1:length(sv)
    sv[ix] += c
    (c, sv[ix]) = sv[ix] > T(9) ? divrem(sv[ix], T(10)) : (zero(T), sv[ix])
  end
  c > zero(T) && push!(sv, c)
  sv |> reverse |> v -> join(v, "")
end
