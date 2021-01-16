struct Triplet{T <: Integer}
  x::T
  y::T
  z::T
end

function Base.show(io::IO, t::Triplet)
  print(io, "($(t.x), $(t.y), $(t.z))")  # Tuple(t.x, t.y, t.z))
end

function to_tuple(t::Triplet)
  return (Triplet.x, Triplet.y, Triplet.z)
end

function gcd(a, b)
  # ensure a & b are non negative
  a, b = abs(a), abs(b)

  (signbit(a) || signbit(a)) && throw(Overflow("Detected integer overflow..."))

  a, b = a < b ? (b, a) : (a, b)
  b == 0 && return a

  r = a
  while r > 1
    r = a % b
    a, b = b, r
  end
  return r == 0 ? a : r
end

function ptriplets(n::Int)
  """
  Version using Euclid's formulae (cf. https://en.wikipedia.org/wiki/Pythagorean_triple)
  Take `s` and `t` 2 integers, such that s > t > 0, s & t coprime and not both odd

  Ex. primitive triplet (3, 4, 5)
      non primitive triplet (27, 36, 45) = 9 * (3, 4, 5)
  """
  triples = [Triplet(1, 1, 1)]
  ncand = 0

  for t ∈ 1:n
    for s ∈ t+1:2:n
      gcd(s, t) != 1 && continue

      ncand += 1
      s₂ = s * s
      t₂ = t * t
      c = s₂ + t₂
      c > n && break

      a, b = s₂ - t₂, (s * t) << 1
      a, b = a < b ? (a, b) : (b, a)
      b > n && break

      triples = vcat(triples, Triplet(a, b, c))
    end
  end

  return triples[2:end], length(triples) - 1, ncand
end

##
## relevant to exercism context (Pythagorean Triplet)
##
function pythagorean_triplets(n::Integer)::Array{Tuple{Integer,Integer,Integer},1}
  triples::Array{Tuple{Integer,Integer,Integer},1} = [(1, 1, 1)]

  for t ∈ 1:n
    for s ∈ t+1:2:n
      c = s * s + t * t
      c > n && break

      a, b = s * s - t * t, 2 * s * t
      a, b = a < b ? (a, b) : (b, a)
      b > n && break

      a + b + c == n && (triples = vcat(triples, (a, b, c)))

      for k ∈ 2:n
        k * (a + b + c) > n && break
        k * (a + b + c) == n && (triples = vcat(triples, (k * a,  k * b, k * c)))
      end
    end
  end

  return unique(triples[2:end]) |>
    ary -> sort(ary, lt=(t1, t2) -> t1[1] ≤ t2[1])
end
