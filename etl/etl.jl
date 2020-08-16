"""
Assume input contains only valid score with defined letters from 'A'..'Z'
"""

function transform(input::AbstractDict)
  ninput = Dict{AbstractChar, Int}()

  for (k, vs) in input
    ## elegant:
    # ninput = merge(ninput, Dict(lowercase(v) => k for v in vs))

    ## more efficient
    for v in vs; ninput[lowercase(v)] = k; end  ## for v in lowercase.(vs); ninput[v] = k; end
  end

  return ninput
end
