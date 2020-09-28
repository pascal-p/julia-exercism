"""
Assume input contains only valid score with defined letters from 'A'..'Z'
"""

function transform_v1(input::AbstractDict)::Dict{AbstractChar, Int}
  ninput = Dict{AbstractChar, Int}()

  for (k, vs) in input
    ## elegant:
    # ninput = merge(ninput, Dict(lowercase(v) => k for v in vs))

    ## more efficient
    ## for v in lowercase.(vs); ninput[v] = k; end
    for v in vs; ninput[lowercase(v)] = k; end
  end

  return ninput
end

function transform(input::AbstractDict)::Dict{AbstractChar, Int}

  λ = function(hsh, (k, vs))
    foldl((nhsh, v) -> (nhsh[lowercase(v)] = k; nhsh), vs, init=hsh)

    ## or:
    #for v in vs; hsh[lowercase(v)] = k; end
    #hsh
  end

  return foldl(λ, input, init=Dict{AbstractChar, Int}())
end
