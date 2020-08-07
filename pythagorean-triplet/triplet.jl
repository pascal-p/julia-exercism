const ϵ = 1e-7

struct Triplet
  x::Int
  y::Int
  z::Int
end

function Base.show(io::IO, t::Triplet)
  print(io, "<$(t.x), $(t.y), $(t.z)>")
end

function is_primitive(triplet::Triplet, args...)::Bool
  x::Int, y::Int, z::Int = args  # exactly 3 arguments

  p = y / triplet.y
  abs(x / triplet.x - p) > ϵ || abs(z / triplet.z - p) > ϵ
end

function is_primitive(triplet::Triplet, otriplet::Triplet)::Bool
  is_primitive(triplet, otriplet.x, otriplet.y, otriplet.z)
end

function is_primitive(triples::Array{Triplet, 1}, otriplet::Triplet)::Bool
  isempty(triples) && return true

  for triplet in triples
    !is_primitive(triplet, otriplet) && return false
  end

  return true
end

function is_primitive(triples::Array{Triplet, 1}, args...)::Bool
  isempty(triples) && return true
  x::Int, y::Int, z::Int = args  # exactly 3 arguments

  for triplet in triples
    triplet.x % x == 0 && continue
    triplet.y % y == 0 && continue

    !is_primitive(triplet, x, y, z) && return false
  end

  return true
end

function gcd(a, b)
  a, b = a < b ? (a, b) : (b, a)
  r = a  
  while r > 1
    r = a % b
    a, b = b, r
  end  
  return r == 0 ? a : r
end


function triplet0(n)
  triples = [Triplet(1, 1, 1)]
  ncand = 0
  for a in 1:n, b in a+1:n, c in b+1:n
    ncand += 1
    
    if a * a + b * b == c * c
      is_primitive(triples, a, b, c) && (triples = vcat(triples, Triplet(a, b, c)))
    end
  end

  return triples[2:end], length(triples) - 1, ncand
end

function triplet1(n)
  triples = [Triplet(1, 1, 1)]
  ncand = 0
  for a in 2:n
    if a % 2 == 0
      for b in a+1:2:n     # odd
        for c in b+2:2:n   # odd
          ncand += 1
          if a * a + b * b == c * c
            is_primitive(triples, a, b, c) && (triples = vcat(triples, Triplet(a, b, c)))
          end
        end
      end
    else
      for b in a+1:2:n     # even
        for c in b+1:2:n   # odd
          ncand += 1
          if a * a + b * b == c * c
            is_primitive(triples, a, b, c) && (triples = vcat(triples, Triplet(a, b, c)))
          end
        end
      end
    end
  end

  return triples[2:end], length(triples) - 1, ncand
end


function triplet2(n)
  triples = [Triplet(1, 1, 1)]
  ncand = 0
  for a in 1:n

    for b in a+1:n
      b % a == 0 && continue

      for c in b+1:n
        c % b == 0 && continue
        ncand += 1

        if a ^ 2 + b ^ 2 == c ^ 2
          is_primitive(triples, a, b, c) && (triples = vcat(triples, Triplet(a, b, c)))
          # triples = vcat(triples, Triplet(a, b, c))
        end
      end
    end
  end

  return triples[2:end], length(triples) - 1, ncand
end

function triplet(n::Int)
  """
  fastest version, using Euclid's formulae
  
  take `s` and `t` 2 integers, such that s > t > 0, s & t coprime and not both odd
  
  Here we do NOT check that s & t are coprime, thus we may generate non primitive triplet
    hence the need for checking that the triplet is indeed primitive

  Ex. primitive triplet (3, 4, 5)
      non primitive triplet (27, 36, 45) = 9 * (3, 4, 5)  
  """
  triples = [Triplet(1, 1, 1)]
  ncand = 0

  for t in 1:n
    for s in t+1:2:n
      ncand += 1
      c = s * s + t * t
      c > n && break
      
      a, b = s * s - t * t, 2 * s * t
      a, b = a < b ? (a, b) : (b, a)
      b > n && break

      is_primitive(triples, a, b, c) && (triples = vcat(triples, Triplet(a, b, c)))
    end
  end

  return triples[2:end], length(triples) - 1, ncand
end

function tripletf2(n::Int)
  """
  fastest version, using Euclid's formulae
  
  take `s` and `t` 2 integers, such that s > t > 0, s & t coprime and not both odd
  
  Here we do NOT check that s & t are coprime, thus we may generate non primitive triplet
    hence the need for checking that the triplet is indeed primitive

  Ex. primitive triplet (3, 4, 5)
      non primitive triplet (27, 36, 45) = 9 * (3, 4, 5)  
  """
  triples = [Triplet(1, 1, 1)]
  ncand = 0

  for t in 1:n
    for s in t+1:2:n
      gcd(s, t) != 1 && continue
      
      ncand += 1
      c = s * s + t * t
      c > n && break
      
      a, b = s * s - t * t, 2 * s * t
      a, b = a < b ? (a, b) : (b, a)
      b > n && break

      triples = vcat(triples, Triplet(a, b, c))
    end
  end

  return triples[2:end], length(triples) - 1, ncand
end
