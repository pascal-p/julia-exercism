function spiral_matrix(n::Int)::Matrix{Int}
  n == 0 && return Matrix{Int}(undef, 0, 0)

  m = Matrix{Int}(undef, n, n)
  k, u, v = 0, 1, n
  incr() = k += 1  ## closure

  while u ≤ v
    for c ∈ u:v
      m[u, c] = incr()
    end

    for r ∈ u + 1:v
      m[r, v] = incr()
    end

    for c ∈ v - 1:-1:u
      m[v, c] = incr()
    end

    for r ∈ v - 1:-1:u + 1 ## fill left bottom/up
      m[r, u] = incr()
    end

    u += 1
    v -= 1
  end

  m
end
