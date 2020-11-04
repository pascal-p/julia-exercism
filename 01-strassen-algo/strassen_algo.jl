const MInt = Matrix{T} where T <: Real

"""
   strassen algo:
   given two squared (n × n) matrix X and Y, Calculate the dot product Z = X × Y

   The straitghforward (naive) algorithm has a running time of Ω(n³) but we can do better
   with the Strassen algorithm which sub-cubic.

   X (n × n) can be written as |A B|   and Y (n × n) |E F|
                               |C D|                 |G H|

  A, B, ... H are all (n ÷ 2 × n ÷ 2) matrices

  one property of matrix multiplication is taht equal size blocks behave just like individual
  entries, thus:
       X × Y = | A × E + B × G   A × F + B × H |
               | C × E + D × G   C × F + D × H |

  This leads to a recursive algorithm that sadly is still Ω(n³)

  The Strassen algorithm takes this one step further and replaces the 8 multiplications above
  by 7 carefully chosen ones, thus 1 less recursive call replaced by a constant number of
  additional additions and substractions.
  This yields a subcubic running time.

  The 7 recursives operations are as followed:
     P₁ = A × (F - H)
     P₂ = (A + B) × H
     P₃ = (C + D) × E
     P₄ = D × (G - E)
     P₅ = (A + D) × (E + F)
     P₆ = (B - D) × (G + H)
     P₇ = (A - C) × (E + F)

  X × Y = |P₅ + P₄ - P₂ + P₆        P₁ + P₂     |
          |     P₃ + P₄        P₁ + P₅ - P₃ - P₇|


  The running time of the Strassen algorithm can be found by using the Master Method (parameterized
  by 3 var. a,b and d) as follows:
  - a = 7 (number of recursive calls or sub-problems)
  - b = 2 (each sub-problems is half the size of the original one)
  - d = 1 (outside the rec. call we need to do some addtions and subtractions - which is done in linear
           time)

  Therefore: a (= 7) > bᵈ (= 2), master method states that the running time is:
    O(n^(log₂(7))) ≈ O(n².⁸¹) (subcubic)
    And actually Ω(n².⁸¹)
"""

function strassen_fn(X::MInt, Y::MInt)::MInt
  # Assert square matrix
  (n₁, n₂) = size(X)
  (m₁, m₂) = size(Y)
  @assert n₁ == n₂ && n₁ == m₁ && m₁ == m₂

  expand = false
  n = closest_power_of_2(n₁)
  if n > n₁
    X = expand_matrix(X, n₁, n) # to closest power of 2
    Y = expand_matrix(Y, n₁, n)
    expand = true
  end

  function _calc(X, Y)
    local (n, _ ) = size(X) # or size(Y)

    if n == 1
      Z = zeros(eltype(X), 1, 1)
      Z[1, 1] = X[1, 1] * Y[1, 1]
      return Z
    end

    A, B, C, D = sub_matrices(X, n)
    E, F, G, H = sub_matrices(Y, n)

    P₁ = _calc(A, F - H)
    P₂ = _calc(A + B, H)
    P₃ = _calc(C + D, E)
    P₄ = _calc(D, G - E)
    P₅ = _calc(A + D, E + H)
    P₆ = _calc(B - D, G + H)
    P₇ = _calc(A - C, E + F)

    return pack_matrix(P₅ + P₄ - P₂ + P₆,
                       P₁ + P₂,
                       P₃ + P₄,
                       P₁ + P₅ - P₃ - P₇)
  end

  Z = _calc(X, Y)
  return expand ? shrink_matrix(Z, n, n₁) : Z
end

function sub_matrices(X::MInt, n::Integer)::Tuple{MInt, MInt, MInt, MInt}
  n₂ = n ÷ 2
  A, B, C, D = X[1:n₂, 1:n₂], X[1:n₂, n₂+1:end], X[n₂ + 1:end, 1:n₂], X[n₂ + 1:end, n₂ + 1:end]

  return (A, B, C, D)
end

function pack_matrix(A::MInt, B::MInt, C::MInt, D::MInt)::MInt
  n = size(A)[1]
  Z = zeros(eltype(A), 2n, 2n)
  Z[1:n, 1:n] = A
  Z[1:n, n+1:end] = B
  Z[n + 1:end, 1:n] = C
  Z[n + 1:end, n + 1:end] = D

  return Z
end

function closest_power_of_2(n::Integer)::Integer
  @assert n > 0
  p = ceil(Integer, log(n) / log(2))
  2^p
end

function expand_matrix(X::MInt, n::Integer, p::Integer)::MInt
  # expand dims of X from n to p (== power of 2), padded with 0
  # from top-left corner
  XE = zeros(eltype(X), p, p)

  offset = p - n + 1
  XE[offset:end, offset:end] = X
  XE
end


function shrink_matrix(X::MInt, p::Integer, n::Integer)::MInt
  # shrink dims of X p (== power of 2) downto n, getting rid
  # of superfluous 0.
  offset = p - n + 1
  X[offset:end, offset:end]
end


function simple_dot_prod(X::MInt, Y::MInt)::MInt
  (n, _) = size(X)
  Z = zeros(eltype(X), n , n)

  for ix in 1:n, jx in 1:n, kx in 1:n
    Z[ix,jx] += X[ix, kx] * Y[kx, jx]
  end

  Z
end
