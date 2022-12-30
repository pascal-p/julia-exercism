const T = Int16

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


#
# String only version
#
function mul(s₁::String, s₂::String) # ::String
  ## pre-processing: deal with sign, extra 0, and "."
  (s₁, pos₁, sign₁) = preprocessing(s₁)
  (s₂, pos₂, sign₂) = preprocessing(s₂)

  s₁, s₂ = s₁ < s₂ ? (s₁, s₂) : (s₂, s₁)
  # println("s₁: [$(s₁)] / s₂: [$(s₂)]")
  length(s₁) == 0 && return "0" # only contaions 0 and therefore was compress to empty string
  length(s₁) == 1 && s₂ == "1" && return s₁

  xs = split(s₁, "") |> v -> parse.(T, v)
  ys = split(s₂, "") |> v -> parse.(T, v)

  ## processing, i.e. multiplication
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

  s = sv |> reverse |> v -> join(v, "") # stringify

  ## place the "." if required
  l = length(s)
  s = (pos₁ > 0 || pos₂ > 0) ? string(SubString(s, 1, l - pos₁ - pos₂),
                                      ".",
                                      SubString(s, l - pos₁ - pos₂ + 1, l)) : s

  ## sign
  sign₁ * sign₂ == -1 ? string("-", s) : s
end

function preprocessing(s::String)
  (s, sign) = startswith(s, "-") ? (s[2:end], -1) : (s, 1)
  s = replace(s, r"^(?:0+)?" => "")
  pos = occursin(r"\.", s) ? find_ix(s) - 1 : -1
  s = pos ≥ 0 ? filter(s_ -> s_ != '.', s) : s
  (s, pos, sign)
end

function find_ix(s::String; ch = '.')
  for (ix, c) ∈ (enumerate ∘ reverse)(s)
    c == ch && return ix
  end
  nothing
end
