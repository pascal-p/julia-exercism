function lpp(n::Integer)::Union{Integer, Nothing}
  n ≤ 0 && throw(ArgumentError("lpp is expecting a (stritcly) positive integer value"))

  T = eltype(n)
  m_cp = typemin(T)
  m = 10^n - 1    # n = 7 => 9_999_999

  d = 10^(n-1)    # 1000000, 999999
  f = d - 1
  for nix in m:-1:(m ÷ d) * f     # 1_000_000)*999_999
    for pix in nix:-1:(m ÷ d) * f # 1_000_000)*999_999
      cp = nix * pix

      if ispalindrome(cp) && cp > m_cp
        m_cp = cp

      elseif cp < m_cp
        break
      end
    end
  end

  m_cp > typemin(T) ? m_cp : nothing
end

function lpp(::Any)
  throw(ArgumentError("lpp is expecting a (stritcly) positive integer value"))
end

function lpp₂(n::Integer; f=0.09)   # 0.0099 good for n < 6 / 0.00099: 7. 8
  n ≤ 0 && throw(ArgumentError("lpp is expecting a (stritcly) positive integer value"))

  T = eltype(n)
  m_cp = typemin(T)
  p, q = zero(T), zero(T)

  m = 10^n - 1
  lim = ceil(Int, m * (1 - f))

  for nix in m:-1:lim
    for pix in nix:-1:lim
      cp = nix * pix

      if ispalindrome(cp) && cp > m_cp
        m_cp = cp
        p = nix
        q = pix
      elseif cp < m_cp
        break
      end
    end
  end

  if m_cp > typemin(T)
    return (m_cp, p, q)
  else
    return nothing
  end
end

@inline function ispalindrome(n::Integer)::Bool
  sn = string(n)
  len = length(sn)

  for l in 1:len ÷ 2
    sn[l] != sn[end - l + 1] && return false
  end
  true
end
