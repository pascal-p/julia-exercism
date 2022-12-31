const N = 3 # number of rails by default

function encode(s::AbstractString; n = N)::AbstractString
  @assert n ≥ 2
  s == "" && return ""

  rails = fill("", n)
  offset = 1
  for (ix, seq) ∈ enumerate(sequences(n=n))
    k, iseq = offset, 1
    while k ≤ length(s)
      rails[ix] = string(rails[ix], s[k])
      (iseq, k) = nextcharseq(seq, iseq, k)
    end
    offset += 1
  end
  rails |> ary2str
end

function decode(s::AbstractString; n = N)::AbstractString
  @assert n ≥ 2
  s == "" && return ""

  ds = fill("", length(s)) # pre-allocate
  ix, offset = 1, 1
  for seq ∈ sequences(n=n)
    k, iseq = offset, 1
    while k ≤ length(s)
      ds[k] = string(s[ix])
      (iseq, k) = nextcharseq(seq, iseq, k)
      ix += 1
    end
    offset += 1
  end
  ds |> ary2str
end

ary2str(src::Vector)::AbstractString =  src |> v -> join(v, "")

@inline function nextcharseq(seq::Tuple, iseq, k)
  seq[iseq] == 0 && (iseq = 3 - iseq)
  k += seq[iseq]
  iseq = 3 - iseq
  (iseq, k)
end

function sequences(;n = N)
  ## cf. runtests.jl for examples
  seed = 2 * n - 2
  zip(seed:-2:0, 0:2:seed) |> collect
end
