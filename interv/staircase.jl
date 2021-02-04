"""
  A child is running up a staircase with n steps, and can hop either 1 step, 2 steps,
  or 3 steps at a time. Implement a function to count how many possible ways the
  child can run up the stairs.
"""


const POSS_MOVES = [1, 2, 3]
const VInt = Vector{Int}
const VVInt = Vector{VInt}


"""
  Using Dynamic Programming - using recursion + memoization
"""

function count_staircase_dp(n::Int)::Int
  n < 0 && throw(ArgumentError("n must ne >0"))

  hsh = Dict{Int, Int}(0 => 0, 1 => 1, 2 => 2, 3 => 4)

  function _staircase(n::Int)
    n == 0 && return 0
    get(hsh, n, -1) != -1 && return hsh[n]

    for s ∈ POSS_MOVES
      if n - s ≥ 0
        hsh[n] = get(hsh, n, -1) == -1 ? _staircase(n - s) : hsh[n] + _staircase(n - s)
      #    hsh[n] = _staircase(n - s)
      #  else
      #    hsh[n] += _staircase(n - s)
      #  end
      end
    end

    return hsh[n]
  end

  _staircase(n)
end

count_staircase(n) = count_staircase_dp(n)


"""
  Brute-force version
  Runtime is exponential O(3^n)
"""
function count_staircase_bf(n::Int)::Int
  n < 0 && throw(ArgumentError("n must ne >0"))

  function _staircase(n::Int)
    n == 0 && return 0
    n == 1 && return 1
    n == 2 && return 2
    n == 3 && return 4 # [(1, 1, 1), (1, 2), (2, 1), (3))

    # n ≥ 4
    cnt = 0
    for s ∈ POSS_MOVES
      n - s ≥ 0 && (cnt += _staircase(n - s))
    end

    return cnt
  end

  _staircase(n)
end

"""
  Building tree of moves...

"""
function staircase(n::Int; poss::VVInt=VVInt([ ]))::Tuple{Int, VVInt}

  function _staircase(n::Int, cposs::VInt)
    if n == 0
      push!(poss, cposs)
      return 0
    elseif n == 1
      push!(poss, [cposs..., 1])
      return 1
    elseif n == 2
      push!(poss, [cposs..., 1, 1])
      push!(poss, [cposs..., 2])
      return 2
    elseif n == 3
      push!(poss, [cposs..., 1, 1, 1])
      push!(poss, [cposs..., 1, 2])
      push!(poss, [cposs..., 2, 1])
      push!(poss, [cposs..., 3])
      return 4
    end

    ## n ≥ 1
    cnt = 0
    for s ∈ POSS_MOVES
      n - s ≥ 0 && (cnt += _staircase(n - s, [cposs..., s]))
    end

    return cnt
  end

  (_staircase(n, VInt()), poss)
end
