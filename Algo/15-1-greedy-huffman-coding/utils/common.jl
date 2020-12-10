# deps on UCS

const TPair{T} = NamedTuple{(:key, :value),Tuple{T,TrieNode{T}}} where T

function make_pair(k::T, v::TrieNode{T})::TPair{T} where T
  (key=k, value=v)
end

function from_file(infile::String, DT::DataType)
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
    println("Intercepted error: $(err)")
    exit(1)
  end
end
