
TT = UInt8
Domino = Tuple{TT, TT}
Dominoes = Vector{Domino}


function can_chain(dominoes::Dominoes)::Union{Nothing, Dominoes}
  length(dominoes) == 0 && return Dominoes[]

  if length(dominoes) == 1
    return dominoes[1][1] == dominoes[1][2] ? dominoes : nothing
  end

  n = length(dominoes)
  for domino ∈ dominoes
    res, chain = find_chain(filter(x -> x != domino, dominoes), [domino], TT(n), TT(1))
    res && return chain
  end

  nothing
end

can_chain(dominoes::Vector{Any}) = length(dominoes) == 0 ? [] : nothing

function find_chain(dominoes::Dominoes, chain::Dominoes, n::TT, p::TT)::Tuple{Bool, Dominoes}
  if length(dominoes) == 0 && length(chain) == n
    return chain[1][1] == chain[end][2] ? (true, chain) : (false, [])
  end

  # TBD ...
end
