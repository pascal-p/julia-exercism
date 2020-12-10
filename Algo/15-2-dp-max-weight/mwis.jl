"""
  MWIS ≡ Maximum-Weight Independent Set of a path graph, using DP

  1 - Top-Down approach: Recursion + memoization

  2 - Bottom-Up iterative approach
"""



struct WGraph{T}
  _v::Int        ## num. of vertices
  _w::Vector{T}  ## vector of weight

  function WGraph{T}(w::Vector{T}) where T
    n = length(w)
    ## defensive copy
    nw = Vector{T}(undef, n)
    copyto!(nw, w)
    new(n, nw)
  end

  function WGraph{T}(file::String) where T
    n, w = from_file(file, T)
    new(n, w)
  end
end

v(wg::WGraph{T}) where T = wg._v
weight(wg::WGraph{T}) where T = wg._w

const TS{T} = Vector{T} where T        ## maintaining order
# const TS{T} = Set{T} where T


"""
  Purely recursive function

  Runtime is exponential
"""
function calc_mwis_rec(wg::WGraph{T}) where T
  n = v(wg)

  function _wis(n::Int)
    n == 0 && return TS{T}()
    n == 1 && return init_ary(1)

    s₁ = _wis(n - 1)
    s₂ = _wis(n - 2)
    return calc_max(wg, s₁, union(s₂, init_ary(n)))
  end

  a = _wis(n)
  (a, do_sum(wg, a))
end


"""
  Recursive function with memoization (DP top-down approach)

  Runtime is now linear  (trading sapce for time)
"""
function calc_mwis_rec_memo(wg::WGraph{T}) where T
  n = v(wg)
  hsh = Dict{Int, TS{T}}(0 => TS{T}[], 1 => init_ary(1)) ## mapping where the key is a vertex (=index) and the value is the weight?

  function _wis(n::Int)
    n ≤ 1 && return hsh[n]

    a₁ = haskey(hsh, n - 1) ? hsh[n - 1] : _wis(n - 1)
    a₂ = haskey(hsh, n - 2) ? hsh[n - 2] : _wis(n - 2)

    return hsh[n] = calc_max(wg, a₁, union(a₂, init_ary(n)))
  end

  a = _wis(n)
  (a, do_sum(wg, a))
end


"""
  Iterative version (DP bottom-up approach)

  Runtime is linear
"""
function calc_mwis_iter(wg::WGraph{T}) where T
  n = v(wg)
  vs = TS{T}(undef, n + 1)

  # all vertices shifted by 1
  vs[1] = 0
  vs[2] = weight(wg)[1]

  for ix in 3:n+1
    vs[ix] = max(vs[ix - 1], vs[ix - 2] + weight(wg)[ix - 1])
  end

  return (path_recons(wg, vs), vs[n + 1])
end


##
## Helper functions
##

function calc_max(wg::WGraph{T}, c₁::TS{T}, c₂::TS{T}) where T
  w_s₁, w_s₂ = do_sum(wg, c₁), do_sum(wg, c₂)

  w_s₁ > w_s₂ ? c₁ : c₂
end

do_sum(wg::WGraph{T}, s::TS{T}) where T = foldl((tw, v) -> tw += weight(wg)[v], s; init=0)

function init_ary(val::T) where T
  un = TS{T}(undef, 1)
  un[1] = val
  un
end

function from_file(infile::String, DT::DataType)
  #try
    local nv, ix, w

    open(infile, "r") do fh
      for line in eachline(fh)
        ## read only first line, where we expect 1 Integer ≡ num. of vertices
        a = split(line, r"\s+")
        nv = parse(Int, strip(a[1]))
        break
      end

      w = Vector{DT}(undef, nv)
      ix = 1
      for line in eachline(fh)
        a = split(line, r"\s+")
        w_ = parse(DT, strip(a[1]))
        w[ix] = w_
        ix += 1
      end
    end
    @assert ix - 1 == nv "ix: $(ix) == nv: $(nv)"
    return (nv, w)

  #catch err
  #  println("Intercepted error: $(err)")
  #  exit(1)
  #end
end

"""
  Path reconstruction for iterative version
"""
function path_recons(wg::WGraph{T}, c::TS{T}) where T
  n = v(wg)   # ≡ length(c) - 1
  ix = n + 1
  a = TS{T}[]

  while ix ≥ 3
    if c[ix - 1] ≥ c[ix - 2] + weight(wg)[ix - 1]
      ix -= 1
    else
      a = union(init_ary(ix - 1), a)
      ix -= 2
    end
  end

  ix == 2 && (a = union(init_ary(1), a))
  return a
end
