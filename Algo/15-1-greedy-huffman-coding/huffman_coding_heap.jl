push!(LOAD_PATH, "../08-heap/src")
push!(LOAD_PATH, "./src")
using YAH
using YATRIE

"""
  Insert the symbols into a min heap (using their frequency as keys)

  At each iteration, retrieve the min. twice: T₁ and T₂
  The merger T₃ of T₁ and T₂ is inserted into this min heap

  Heap operation like
  - retrieving the min is done in O(1)
  - insertion is done in O(ln(n)) - n number of items in the heap

  The total running time of the n - 1 iterations of the main loop is O(n × ln(n)).
"""

function from_file(infile::String, DT::DataType)
  # from a file each line is symbol, freq or only symbol
  try
    local nsymb, ix, tfreq

    open(infile, "r") do fh
      for line in eachline(fh)
        ## read only first line, where we expect 1 Integer ≡ num. of symbols
        a = split(line, r"\s+")
        nsymb = parse(Int, strip(a[1]))
        break
      end

      tfreq = Dict{UCS, DT}()
      ix = 1
      for line in eachline(fh)
        a = split(line, r"\s+")
        f = parse(DT, strip(a[1]))
        tfreq["s_$(ix)"] = f
        ix += 1
      end
    end
    @assert ix - 1 == nsymb "ix: $(ix) == nsymb: $(nsymb)"
    return tfreq

  catch err
    pritnln("Intercepted error: $(err)")
    exit(1)
  end
end


"""
  build_trie

  tfreq = Dict('A' => 5, 'B' => 2, 'D' => 1, 'R' => 2, 'C' => 1, '!' => 1)
  trie = build_trie(tfreq)

TrieNode{Int64}('\0', 12, TrieNode{Int64}('A', 5, nothing, nothing), TrieNode{Int64}('\0', 7, TrieNode{Int64}('\0', 3, TrieNode{Int64}('!', 1, nothing, nothing), TrieNode{Int64}('B', 2, nothing, nothing)), TrieNode{Int64}('\0', 4, TrieNode{Int64}('\0', 2, TrieNode{Int64}('D', 1, nothing, nothing), TrieNode{Int64}('C', 1, nothing, nothing)), TrieNode{Int64}('R', 2, nothing, nothing))))

"""
function build_trie(tfreq::Dict{T1, T}) where {T1 <: UCS, T}
  n = length(tfreq)
  @assert n > 1 "length of frequency (input) table must be > 1"

  min_heap = Heap{T, TrieNode{T}}(n)

  for k in keys(tfreq)
    tnode = TrieNode{T}(k, tfreq[k])
    insert!(min_heap, make_pair(tfreq[k], tnode))
  end

  while length(min_heap) > 1
    (k₁, x) = extract_min!(min_heap)
    (k₂, y) = extract_min!(min_heap)

    if k₁ == k₂
      string(key(x)) > string(key(y)) && ((x, y) = (y, x))
    end

    nfreq = freq(x) + freq(y)
    pnode = TrieNode{T}('\0', nfreq; l=x, r=y)  ## Create parent node form x, y
    insert!(min_heap, make_pair(nfreq, pnode))
  end

  return extract_min!(min_heap).value
end

make_pair(k::T, v::TrieNode{T}) where T = (key=k, value=v)

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

#
# include("./huffman_coding.jl");
# str = "ABRACADABRA!"
# tfreq = Dict('B' => 2, 'C' => 1, 'A' => 5, 'D' => 1, 'R' => 2, '!' => 1)
#
# trie = build_trie(tfreq)
# st = build_code(trie)
#
# enc = encode(str, st)
# == "0101111011010110001011110100"
#
# dec = expand(trie, enc)
#
