TT = UInt8
Domino = Tuple{TT, TT}
Dominoes = Vector{Domino}


function can_chain(dominoes::Dominoes)::Union{Nothing, Dominoes}
  length(dominoes) == 0 && return Dominoes[]

  if length(dominoes) == 1
    return dominoes[1][1] == dominoes[1][2] ? dominoes : nothing
  end

  n = length(dominoes)
  cp_dominoes = [dominoes...]
  for domino ∈ dominoes
    remove!(cp_dominoes::Dominoes, domino::Domino)
    res, chain = find_chain(cp_dominoes, [domino], TT(n), TT(1))
    res && return chain
  end

  nothing
end

can_chain(dominoes::Vector{Any}) = length(dominoes) == 0 ? [] : nothing

function find_chain(dominoes::Dominoes, chain::Dominoes, n::TT, p::TT)::Tuple{Bool, Dominoes}
  if length(dominoes) == 0 && length(chain) == n
    return chain[1][1] == chain[end][2] ? (true, chain) : (false, [])
  elseif length(dominoes) == 0
    return (false, [])
  end

  curr = chain[end]
  candidates = find_next(dominoes, curr)
  if length(candidates) == 0
    # no more candidate, are we at the end of a valid chain?
    if chain[1][1] == dominoes[1][2] && chain[end][2] == dominoes[1][1]
      push!(chain, dominoes[end])
      return length(chain) == n ? (true, chain) : (false, [])
    end
    return (false, [])
  end

  while length(candidates) > 0
    cand = candidates[1]
    remove!(dominoes, cand)
    candidates = candidates[2:end]
    res, fchain = find_chain(dominoes, [chain..., cand], n, p + TT(1))
    res && return (res, fchain)
    # backtrack
    push!(dominoes, cand)
  end

  return (false, [])
end

function remove!(dominoes::Dominoes, domino::Domino)
  ix = findfirst(d -> d == domino || (d[1] == domino[2] && d[2] == domino[1]),
                 dominoes)
  ix != nothing && deleteat!(dominoes, ix)
end

function find_next(dominoes::Dominoes, domino::Domino)::Union{Nothing, Dominoes}
  s = Set{Domino}(
    d for d ∈ dominoes if domino[2] == d[1]
  )
  if length(s) == 0
    s = Set{Domino}(
      (d[2], d[1]) for d ∈ dominoes if domino[2] == d[2]
    )
  end
  Dominoes([s...])
end
