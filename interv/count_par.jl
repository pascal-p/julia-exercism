const TIV = Tuple{Int, Vector{String}}
const RT = Union{Int, TIV}

function count_par(n::Int; count_only=true)::RT
  n == 0 && return count_only ? 0 : (0, [])
  n == 1 && return count_only ? 1 : (1, ["()"])
  n == 2 && return count_only ? 2 : (2, ["(())", "()()"])

  return count_only ? count_par(n, 0, 0) : count_par(n, 0, 0, String[])
end

function count_par(n::Int, po::Int, pc::Int)
  po == n && pc == n && return 1

  if po == 0 && pc == 0
    # start with "("
    return count_par(n, po + 1, po)

  elseif po == pc && po < n
    # continue with "("
    return count_par(n, po + 1, po)

  elseif po < n && pc < n
    # either use "(" xor ")"
    return count_par(n, po + 1, pc) + count_par(n, po, pc + 1)

  # elseif po < n
  #   # keep going with "("
  #   @assert pc < n
  #   return count_par(n, po + 1, pc)

  else
    @assert po == n
    # only possibility is ")"
    return count_par(n, po, pc + 1)
  end
end

function count_par(n::Int, po::Int, pc::Int, expr::Vector{String})::TIV
  po == n && pc == n && return (1, [join(expr, "")])

  if po == 0 && pc == 0
    return count_par(n, po + 1, po, [expr..., "("])

  elseif po == pc && po < n
    return count_par(n, po + 1, po, [expr..., "("])

  elseif po < n && pc < n
    (c1, nexpr1) = count_par(n, po + 1, pc, [expr..., "("])
    (c2, nexpr2) = count_par(n, po, pc + 1, [expr..., ")"])
    return (c1 + c2, [nexpr1..., nexpr2...])

  # # Simplifying
  # elseif po < n
  #   # keep going with "("
  #   @assert pc < n
  #   return count_par(n, po + 1, pc, [expr..., "("])

  else
    @assert po == n
    # only possibility is ")"    #push!(expr, ")")
    return count_par(n, po, pc + 1, [expr..., ")"])
  end
end
