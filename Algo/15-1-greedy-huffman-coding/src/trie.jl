const UCS = Union{Char, String}

"""
  TrieNode structure
"""
struct TrieNode{T<:Number}
  _ch::UCS
  _freq::T   ## Int or Float
  _left::Union{TrieNode, Nothing}
  _right::Union{TrieNode, Nothing}

  function TrieNode{T}(ch::UCS, freq::T; l::Union{TrieNode, Nothing}=nothing,
                     r::Union{TrieNode, Nothing}=nothing) where T
    @assert freq > zero(T)
    new(ch, freq, l, r)
  end
end

isleaf(tn::TrieNode{T}) where T = tn._left == nothing && tn._right == nothing

left(tn::TrieNode{T}) where T = tn._left
right(tn::TrieNode{T}) where T = tn._right
key(tn::TrieNode{T}) where T = tn._ch
freq(tn::TrieNode{T}) where T = tn._freq

"""
  Expand (or decompress ?)

  expand(trie, "0101111011010110001011110100")
  == "ABRACADABRA!"
"""

function expand(root::TrieNode{T}, input::String) where T
  ix = 1
  decoded::String = ""
  while ix ≤ length(input)
    x = root
    while !isleaf(x)
      ch = input[ix]
      ix += 1
      x = ch == '0' ? left(x) : right(x)
    end
    decoded = string(decoded, key(x))
  end
  decoded
end


"""
  build_code Table (mapping char / sequences of bits 0 and 1)

julia> st = build_code(trie)
Dict{Char,String} with 5 entries:
  'B' => "111"
  'D' => "1100"
  'A' => "0"
  'R' => "10"
  'C' => "1101"

"""
function build_code(root::TrieNode{T})::Dict{UCS, String} where T
  st = Dict{UCS, String}()

  function _build_code(x::TrieNode{T}, s::String) where T
    if isleaf(x)
      st[key(x)] = s
      return
    end

    _build_code(left(x), string(s, "0"))
    _build_code(right(x), string(s,  "1"))
  end

  _build_code(root, "")
  return st
end


"""
  encode (or compress)

  encode("ABRACADABRA!", st) == "0 101 111 0 1101 0110001011110100"
                                 A B   R   A ...
"""
function encode(input::String, st::Dict{UCS, String}) where T
  foldl((s, ch) -> string(s, st[ch]), input; init="")
end
