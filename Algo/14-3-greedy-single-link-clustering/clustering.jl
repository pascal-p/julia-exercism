push!(LOAD_PATH, "../14-1-union-find/src")
using YAFUF                   ## (faster) union-find data struct.
# using YAUF

"""
Process input file and turn its content into a map/hash with key (input binary
string turned into a integer, base 10) / value (index)
"""
function from_file(infile::String)
  # local v_list
  local map_ix_v = Dict{Int, Set{Int}}()
  local n_v, n_bits

  try
    open(infile, "r") do fh
      for line in eachline(fh)
        ## read only first line, where we expect 2 Integers <num_vertices>, <n_bits>
        a = split(line, r"\s+")
        n_v, n_bits = map(x -> parse(Int, strip(x)), a)
        break
      end

      # v_list = zeros(Int, n_v)
      for (ix, line) in enumerate(eachline(fh))
        length(line) == 0 && continue

        ary = split(strip(line), r"\s+")
        @assert length(ary) == n_bits "ary: $(ary) should have length $(n_bits) got $(length(ary))"

        ##
        ## ary is a sequence of len n_bits with value "0" or "1"
        ##
        # v_list[ix] =
        c = map(x -> x == "0" ? 0 : 1, ary) |>
          a -> foldl((s, x) -> s = (s + x) * 2, a[1:end-1]; init=0) + a[end]

        s = get(map_ix_v, c, Set{Int}()) ## s = get(map_ix_v, v_list[ix], Set{Int}())
        push!(s, ix)
        map_ix_v[c] = s                  ## map_ix_v[v_list[ix]] = s
      end
    end

  return (n_v, n_bits, map_ix_v)         ## (n_v, n_bits, v_list, map_ix_v)

  catch err
    if isa(err, ArgumentError)
      println("! Problem with content of file $(infile)")

    elseif isa(err, SystemError)
      println("! Problem opening $(infile) in read mode... Exit")

    elseif isa(err, AssertionError)
      println("! Failed expectation: $(err)")

    else
      println("! other error: $(err)...")
    end
    exit(1)
  end
end

"""
For a 1 or 2 bit hamming distance
"""
function create_bitmask_lte_2(n_bits::Int)
  ## array of length 300 = 24 elements (1-bit) + 276 (2-bit sequence)
  # [0]
  a = sort(
           vcat(
                [1 << i for i in 1:n_bits],                                      ## 1 bit
                [xor(1 << i,
                     1 << j) for i in 0:(n_bits - 1) for j in i+1:(n_bits - 1)]) ## 2 bits
           )
  @assert length(a) == choose(n_bits, 1) + choose(n_bits, 2)
  a
end


"""
Merge vertices that are under same index, which means 0 hamming distance
"""
function merge_vertex!(uf, map_ix_v, n_clusters)
  println(">1> init. num. of clusters: $(uf.count)")

  for key in filter(k -> length(map_ix_v[k]) > 1, keys(map_ix_v))
    # coll = collect(map_ix_v[key])
    # u = coll[1]
    println(">1> map_ix_v[key: $(key)] same root!")
    u = first(map_ix_v[key])
    n_clusters -= 1
    # for v in coll[2:end]; union(uf, u, v); end
    for v ∈ map_ix_v[key]; union(uf, u, v); end
  end
  println(">1> post  num. of clusters: $(uf.count)")
  
  n_clusters
end

"""
Merge vertices that are up to 2-bits hamming distance (given distance vector) of each other
"""

function merge_vertex!(uf, map_ix_v, distance, n_clusters)
  marked = Dict{Tuple{Int, Int}, Bool}()
  nclu = uf.count

  for dist in distance, key in keys(map_ix_v)
    nkey = key ⊻ dist   # ≡ xor(key, dist)
    (haskey(marked, (nkey, key)) || haskey(marked, (key, nkey))) && continue

    if haskey(map_ix_v, nkey)
      print(">2> map_ix_v[key: $(key)]: $(map_ix_v[key]) U map_ix_v[nkey:$(nkey)]: $(map_ix_v[nkey]) / ")

      c = uf.count
      # n_clusters -= 1
      union(uf, first(map_ix_v[key]), first(map_ix_v[nkey]))
      
      if c - 1 == uf.count
        n_clusters -= 1
        nclu -= 1
        println("Actual Union / $(nclu)")
      end

      # map_ix_v[key] = union(map_ix_v[key], map_ix_v[nkey])
      # delete!(map_ix_v, nkey)

      marked[(key, nkey)] = true
    end
  end
  println("\n")
  
  n_clusters
end

function merge_vertex_ALT!(uf, map_ix_v, distance, n_clusters)
  while true
    count = uf.count
    marked = Dict{Tuple{Int, Int}, Bool}()

    for dist in distance, key in keys(map_ix_v)
      nkey = key ⊻ dist   # ≡ xor(key, dist)
      (haskey(marked, (nkey, key)) || haskey(marked, (key, nkey))) && continue

      if haskey(map_ix_v, nkey)
        println(">> Merge map_ix_v[key: $(key)]: $(map_ix_v[key]) with map_ix_v[nkey:$(nkey)]: $(map_ix_v[nkey])")

        c = uf.count
        union(uf, first(map_ix_v[key]), first(map_ix_v[nkey]))
        @assert uf.count ≥ c - 1 "uf.count should decr by 1 at most but we have: $(c) before and $(uf.count) after"
        uf.count == c - 1 && (n_clusters -= 1)

        # map_ix_v[key] = union(map_ix_v[key], map_ix_v[nkey])
        # delete!(map_ix_v, nkey)

        marked[(key, nkey)] = true
      end
    end
    println("===> count was: $(count) / cmp / uf.count: $(uf.count)")

    count == uf.count && break
  end

  n_clusters
end

function det_n_clusters(file::String)
  (n_v, n_bits, map_ix_v) = from_file(file)
  n_clusters = n_v

  println(">> n_v: $(n_v) vertices")
  # println(">> map_ix_v: $(map_ix_v)")

  uf = UnionFind(n_v)
  n_clusters = merge_vertex!(uf, map_ix_v, n_clusters)
  # println(">> uf: $(uf)")
  println(">> n_clusters left: $(n_clusters) / hamming distance 0")

  distance = create_bitmask_lte_2(n_bits)
  n_clusters = merge_vertex!(uf, map_ix_v, distance, n_clusters)

  println(">3> uf: $(unique(uf.parent))")

  for ix in 1:n_v
    find(uf, ix)
  end
  
  println(">4> uf: $(unique(uf.parent))")
  for ix in unique(uf.parent)
    find(uf, ix)
  end
  println(">44> uf: $(unique(uf.parent))")
  
  println(">5> uf: $(uf)")
  println(">> n_clusters left: $(n_clusters)")
  println(">> uf.count       : $(uf.count)")

  (uf.count, n_clusters)
end


## Internal checks

function fact(n::Int)::Int
  f = 1
  for ix = 2:n; f *= ix; end
  f
end

function choose(n::Int, p::Int)::Int
  f = 1
  if (n - p) > p
    for ix in (n - p + 1):n; f *= ix; end
    return f ÷ fact(p)
  else
    for ix in (p + 1):n; f *= ix; end
    return f ÷ fact(n - p)    
  end
end
