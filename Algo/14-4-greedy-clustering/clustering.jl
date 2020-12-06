push!(LOAD_PATH, "../14-1-union-find/src")
using YAFUF                   ## (faster) union-find data struct.

"""
  Procedure:
  1. Read file line by line and build dictionary/hash/map with key (binary value converted to base 10 == Int)
     and value a set of line numbers (indexes aka nodes/vertices from 1 to n) as same binary value can appear
     several times.
     Here n is 200_000

  2. Create UnionFind instance with node 1..n
     Initially all nodes are in their own clusters (therefore n clusters)

  3. Union/Merge all nodes with hamming distance 0 - those are the sets (from part 1 - the built map) with
     cardinal > 1
     number of clusters is now ≤ n (can still be n if no such nodes exist)

  4. Generate bitmask for all 1-bit and 2-bit hamming distance, store them into an array (called it distance
     for example)
     If m is the number of bits (24 here) we should have "m choose 1" + "m choose 2" such combinations
     (m=24 => 24 + 276 = 300 combinations)
     This bitmask will be used in step 5

  5. (outer) Loop over the distance -> d, (inner) loop over the keys from map (built in 1.) -> key
     calculate: key xor d  -> nkey
     then if nkey is in the map, it means those nodes/vertices are at 1-bit or 2-bit hamming distance
     and therefore these should be in the same cluster, therefore union key/nodes with nkey/nodes
     Each time we union/merge those keys, the number of clusters is decremented by 1


  6. Return the final number of clusters. This answers the question


  Running time complexity - n number of vertices/nodes:
  - Step 1. is O(n)
  - Step 2. is O(n)
  - Step 3. O(n × ln(n))
  - Step 4. O(m²)         - m number of bits
  - Step 5. O(n × ln(n))
  Total running time: O(n × ln(n))

"""


"""
  from_file(infile)

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
        # @assert ary[end] ∈ ["0", "1"] "last bit should be 0 or 1, got: $(ary[end])"

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
  a = sort(
           vcat(
  #              [0],                                                            ## 0 bit
                [1 << i for i in 0:(n_bits-1)],                                  ## 1 bit
                [xor(1 << i,
                     1 << j) for i in 0:(n_bits - 1) for j in i+1:(n_bits - 1)]) ## 2 bits
           )
  @assert length(a) == choose(n_bits, 1) + choose(n_bits, 2) + (a[1] == 0 ? 1  : 0)
  a
end


"""
Merge vertices that are under same index, which means 0 hamming distance
"""
function merge_vertex!(uf, map_ix_v)
  for key in filter(k -> length(map_ix_v[k]) > 1,
                    keys(map_ix_v))
    u = first(map_ix_v[key])
    for v ∈ map_ix_v[key]; union(uf, u, v); end
  end
end

"""
Merge vertices that are up to 2-bits hamming distance (given distance vector) of each other
"""

function merge_vertex!(uf, map_ix_v, distance)
  # marked = Dict{Tuple{Int, Int}, Bool}()
  for dist in distance, key in keys(map_ix_v)
    nkey = key ⊻ dist   ## ≡ xor(key, dist)

    # (haskey(marked, (nkey, key)) || haskey(marked, (key, nkey))) && continue
    if haskey(map_ix_v, nkey)
      union(uf, first(map_ix_v[key]),
            first(map_ix_v[nkey]))  ## union by rank + compression path

      # marked[(key, nkey)] = true
    end
  end
end

function det_n_clusters(file::String)
  (n_v, n_bits, map_ix_v) = from_file(file) ## prep. step build map
  uf = UnionFind(n_v)                       ## init.

  merge_vertex!(uf, map_ix_v)               ## union/merge vertices at 0-hamming distance of each other

  distance = create_bitmask_lte_2(n_bits)   ## gen. bitmask for 1-bit and 2-bit hamming distance
  merge_vertex!(uf, map_ix_v, distance)     ## union/merge vertices at 1 or 2-hamming distance of each other

  uf.count
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
