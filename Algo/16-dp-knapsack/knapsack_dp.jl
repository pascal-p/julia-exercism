"""
  TODO: description...

"""

const T_Int = Int32

struct TItem{T1, T2 <: Integer}
  _val::T1       ## value
  _sz::T2        ## size or weight

  function TItem{T1, T2}(value::T1, size::T2) where {T1, T2 <: Integer}
    @assert value > 0 "value must be > 0"
    @assert size > 0 "size must be > 0"
    new(value, size)
  end
end

value(item::TItem{T1, T2}) where {T1, T2} = item._val
size(item::TItem{T1, T2}) where {T1, T2} = item._sz

"""
  Bottom-Up iterative approach...

"""
function knapsack_iter(items::Vector{TItem{T1, T2}}, capa::T2) where {T1, T2 <: Integer}
  @assert capa > 0 "Capacity must be strictly positive"

  n = length(items)
  mat = Matrix{T2}(undef, n + 1, capa + 1)

  for c in 1:capa + 1; mat[1, c] = 0; end

  for ix in 2:(n + 1), c in 1:(capa + 1)
    sz = size(items[ix - 1])

    if sz ≥ c
      mat[ix, c] = mat[ix - 1, c]

    else
      mat[ix, c] = max(mat[ix - 1, c], mat[ix - 1, c - sz] + value(items[ix - 1]))

    end
  end

  (recons_opt_sol(items, capa, mat), mat[n + 1, capa + 1])
end


"""
  Top-Down recursive memoization approach...

"""
function knapsack_rec_memo(items::Vector{TItem{T1, T2}}, capa::T2) where {T1, T2 <: Integer}
  @assert capa > 0 "Capacity must be strictly positive"

  hsh = Dict{Tuple{T_Int, T2}, T1}()

  function _knapsack(n::T_Int, c::T_Int)
    (n ≤ zero(T_Int) || c ≤ zero(T_Int)) && return zero(T_Int)

    if !haskey(hsh, (n, c))
      k₁ = _knapsack(T_Int(n - 1), c)

      hsh[(n, c)] = if size(items[n]) > c
        k₁
      else
        k₂ = _knapsack(T_Int(n - 1), T_Int(c - size(items[n]))) + value(items[n])
        max(k₁, k₂)
      end
    end

    return hsh[(n, c)]
  end

  n::T_Int = length(items)
  return _knapsack(n, capa)
end

function knapsack_rec(items::Vector{TItem{T1, T2}}, capa::T2) where {T1, T2 <: Integer}
  @assert capa > 0 "Capacity must be strictly positive"

  function _knapsack(n::T_Int, c::T_Int) # , v::T_Int)
    (n ≤ zero(T_Int) || c ≤ zero(T_Int)) && return zero(T_Int)

    k₁ = _knapsack(T_Int(n - 1), c)
    if size(items[n]) > c
      return k₁
    else
      k₂ = _knapsack(T_Int(n - 1), T_Int(c - size(items[n]))) + value(items[n])
      return max(k₁, k₂)
    end
  end

  return _knapsack(T_Int(length(items)), capa)
end

function recons_opt_sol(items::Vector{TItem{T1, T2}}, capa::T2, mat::Matrix{T2}) where {T1, T2 <: Integer}
  c, n = capa + 1, T_Int(length(items))
  a = Vector{T_Int}()

  for ix in n+1:-1:2
    sz = size(items[ix - 1])
    if sz < c && mat[ix, c - sz] + value(items[ix - 1]) ≥ mat[ix, c]
      pushfirst!(a, T_Int(ix - 1))
      c -= T_Int(sz)
    end
  end

  return a
end


##
## Helpers
##
function from_file(infile::String, T1::DataType, T2::DataType)
  try
    local capa::T_Int, n::T_Int, items
    open(infile, "r") do fh
      for line in eachline(fh)
        ## read only first line, where we expect 2 Integers ≡ (knapsack capa, number of items)
        a = split(line, r"\s+")
        (capa, n) = map(s -> parse(T_Int, strip(s)), a)
        break
      end

      items = Vector{TItem{T1, T2}}(undef, n)
      for (ix, line) in enumerate(eachline(fh))
        a = split(line, r"\s+")
        v, w = parse(T1, strip(a[1])), parse(T2, strip(a[2]))
        items[ix] = TItem{T1, T2}(v, w)
      end
    end
    @assert length(items) == n "number of items must be $(n), got $(length(items))"
    return (items, capa)

  catch err
    println("Intercepted error: $(err)")
    exit(1)
  end
end
