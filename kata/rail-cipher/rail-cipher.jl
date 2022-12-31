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
end

function sequences(;n = N)
  ## cf. runtests.jl for examples
  seed = 2 * n - 2
  zip(seed:-2:0, 0:2:seed) |> collect
end
