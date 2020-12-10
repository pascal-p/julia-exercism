push!(LOAD_PATH, "./src")

using YATRIE   ## for trie
using YARX     ## for radix sort
using YAQ      ## For Qs

include("./utils/common.jl")  # define TPair, ...


"""
  Sort the symbols by frequency and insert them in increasing order into a queue Q₁ .
  Initialize an empty queue Q₂
  => Use sort in linear time => radix)

  Maintain the following invariants:
  (i) the elements of Q₁ correspond to single-node trees in the current forest F,
  stored in increasing order of frequency;

  (ii) the elements of Q₂ correspond to the multi-node trees of F,
  stored in increasing order of sum of symbol frequencies.

  In each iteration of the algorithm, the trees T₁ and T₂ with the smallest sums of
  symbol frequencies can be identified and removed using a constant number of operations
  at the fronts of Q₁ and Q₂ .
  The merger T₃ of T₁ and T₂ is inserted at the back of Q₂

  Exercise: why does invariant (ii) continue to hold?

  Every queue operation (removing from the front or adding to the back) runs in O(1)
  time, so the total running time of the n - 1 iterations of the main loop is O(n).
"""

"""
  build_trie

  tfreq = Dict('A' => 5, 'B' => 2, 'D' => 1, 'R' => 2, 'C' => 1, '!' => 1)
  trie = build_trie(tfreq)

TrieNode{Int64}('\0', 12, TrieNode{Int64}('A', 5, nothing, nothing), TrieNode{Int64}('\0', 7, TrieNode{Int64}('\0', 3, TrieNode{Int64}('!', 1, nothing, nothing), TrieNode{Int64}('B', 2, nothing, nothing)), TrieNode{Int64}('\0', 4, TrieNode{Int64}('\0', 2, TrieNode{Int64}('D', 1, nothing, nothing), TrieNode{Int64}('C', 1, nothing, nothing)), TrieNode{Int64}('R', 2, nothing, nothing))))

"""

function build_trie(tfreq::Vector{T}) where T
  n = length(tfreq)
  @assert n > 1 "length of frequency (input) table must be > 1"

  radix_sort!(tfreq)
  q₁ = Q{TPair{T}}(n)
  q₂ = Q{TPair{T}}(n ÷ 2)

  for ix in 1:n
    freq = tfreq[ix]
    tnode = TrieNode{T}("\\$(ix)", freq)
    enqueue!(q₁, make_pair(freq, tnode))
  end

  @assert length(q₁) == n

  # 1st time
  (k₁, x) = dequeue!(q₁)
  (k₂, y) = dequeue!(q₁)

  while true
    enqueue_node!(q₂, (k₁, x), (k₂, y))
    isempty(q₁) && break

    # next
    (k₁, x) = first(q₁).key < first(q₂).key ? dequeue!(q₁) : dequeue!(q₂)

    if !isempty(q₁) && !isempty(q₂)
      (k₂, y) = first(q₁).key < first(q₂).key ? dequeue!(q₁) : dequeue!(q₂)
    elseif isempty(q₁) && !isempty(q₂)
      (k₂, y) = dequeue!(q₂)
    else
      (k₂, y) = dequeue!(q₁)
    end
  end
  @assert isempty(q₁) "q₁ should be empty"

  while length(q₂) > 1
    (k₁, x) = dequeue!(q₂)
    (k₂, y) = dequeue!(q₂)
    enqueue_node!(q₂, (k₁, x), (k₂, y))
  end
  @assert length(q₂) == 1 "q₂ should be of length 1"

  return dequeue!(q₂).value
end

function from_file(infile::String, DT::DataType)::Vector{DT}
  try
    local nsymb, ix, tfreq

    open(infile, "r") do fh
      for line in eachline(fh)
        ## read only first line, where we expect 1 Integer ≡ num. of symbols
        a = split(line, r"\s+")
        nsymb = parse(Int, strip(a[1]))
        break
      end

      tfreq = Vector{DT}(undef, nsymb) # Dict{UCS, DT}()
      for (ix, line) in enumerate(eachline(fh))
        a = split(line, r"\s+")
        tfreq[ix] = parse(DT, strip(a[1]))
        # tfreq["s_$(ix)"] = f
      end
    end
    return tfreq

  catch err
    println("Intercepted error: $(err)")
    exit(1)
  end
end

function enqueue_node!(q₂::Q{TPair{T}}, p₁, p₂) where T
  (k₁, x) = p₁
  (k₂, y) = p₂

  if k₁ == k₂
    string(key(x)) > string(key(y)) && ((x, y) = (y, x))
  end

  nfreq = freq(x) + freq(y)
  pnode = TrieNode{T}(nfreq; l=x, r=y)
  enqueue!(q₂, make_pair(nfreq, pnode))
end

##
## for challenge
##
function huffman(infile::String, DT::DataType)
  st = from_file(infile, DT) |>
    tfreq -> build_trie(tfreq) |>
    trie -> build_code(trie)

  min_len_cw, max_len_cw = typemax(DT), typemin(DT)

  for k in keys(st)
    len = length(st[k])
    if len < min_len_cw
      min_len_cw = len
    elseif len > max_len_cw
      max_len_cw = len
    end
  end

  return (min_len_cw, max_len_cw)
end

## Challenge:
##   0.001048 seconds (17.05 k allocations: 916.859 KiB)
## Test Summary:                    | Pass  Total
## clustering on: input_huffman.txt |    1      1
