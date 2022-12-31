const N = 3 # number of rails

function encode(s::String; n = N)::String
  @assert n ≥ 2
  rails = fill("", n)
  offset = 1
  for (ix, seq) ∈ enumerate(sequences(n=n))
    k, iseq = offset, 1
    while k ≤ length(s)
      # println("offset: $(offset) / lim: $(length(s) - offset + 1) / ix: $(ix) / seq: $(seq) / s[k:$(k)]: $(s[k])")
      rails[ix] = string(rails[ix], s[k])
      seq[iseq] == 0 && (iseq = 3 - iseq)
      k += seq[iseq]
      iseq = 3 - iseq
    end
    offset += 1
  end
  rails |> v -> join(v, "")
end

function decode(s::String; n = N):: String
  ds = fill("", length(s)) # repeat(" ", length(s))
  ix, offset = 1, 1
  for seq ∈ sequences(n=n)
    k, iseq = offset, 1
    while k ≤ length(s)
      ds[k] = string(s[ix])
      seq[iseq] == 0 && (iseq = 3 - iseq)
      k += seq[iseq]
      iseq = 3 - iseq
      ix += 1
    end
    offset += 1
  end
  ds |> v -> join(v, "")
end

function sequences(;n = N)
  ## cf. runtests.jl for examples
  seed = 2 * n - 2
  zip(seed:-2:0, 0:2:seed) |> collect
end

# julia> decode("WECRLTEERDSOEEFEAOCAIVDEN")
# ERROR: MethodError: no method matching setindex!(::String, ::Char, ::Int64)
# Stacktrace:
#  [1] decode(s::String; n::Int64)
#    @ Main ~/Projects/Exercism/julia/kata/rail-cipher/rail-cipher.jl:28
#  [2] decode(s::String)
#    @ Main ~/Projects/Exercism/julia/kata/rail-cipher/rail-cipher.jl:21
#  [3] top-level scope
#    @ REPL[2]:1
