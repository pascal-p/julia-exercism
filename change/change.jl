const T = Int
const VT = AbstractVector{T}
const VTV = Vector{Tuple{T, VT}}

function find_fewest_coins(coins::VT, target::T)::VT
  """
    Correctly determine the fewest number of coins to be given to a customer such
    that the sum of the coins' value would equal the correct amount of change.

    Using DP technique.
    res_ary is an array of array: [number of coins, [array of change]]
  """
  target < zero(T) && throw(ArgumentError("Negative totals are not allowed."))
  target == zero(T) && (return [])
  res_ary = solve(coins, target, alloc_array)

  (length(res_ary[target + 1][2][1:end-1]) == 0 ||
   sum(res_ary[target + 1][2][1:end-1]) != target) &&
   throw(ArgumentError("The total $(target) cannot be represented in the given currency."))

  res_ary[target + 1][2][1:end-1]
end

function find_fewest_coins₂(coins::VT, target::T)::VT
  """
    Correctly determine the fewest number of coins to be given to a customer such
    that the sum of the coins' value would equal the correct amount of change.

    Using DP technique.
    res_ary is an array of array: [number of coins, [array of change]]
  """
  target < 0 && throw(ArgumentError("Negative totals are not allowed."))
  target == 0 && (return [])
  res_ary = solve(coins, target, alloc_array₂)

  (length(res_ary[target + 1][2]) == 0 ||
   sum(res_ary[target + 1][2]) != target) &&
   throw(ArgumentError("The total $(target) cannot be represented in the given currency."))

  res_ary[target + 1][2]
end

@inline function solve(coins::VT, target::T, fn)::VTV
  res_ary = fn(target)
  for t ∈ 2:target + 1, c ∈ filter(c -> t - c > zero(T), coins)
    (n, ch) = res_ary[t - c]
    n != typemax(T) && (n + 1) < res_ary[t][1] && (res_ary[t] = (n+1, [c, ch...]))
  end
  res_ary
end

function alloc_array(target::Int)::Vector{Tuple{Int, Vector{Int}}}
  ary = Vector{Tuple{Int64, Vector{Int64}}}(undef, target + 1)
  ## fill!(ary, [typemax(Int), []], target + 1) # beware fill use ref, ref to typemax(Int)...
  ## res_ary[1] = [0, [0]]                      # ... using fill, this populate the whole array with 0!
  for t in 2:target + 1; ary[t] = (typemax(Int), [0]) end
  ary[1] = (0, [0])
  ary
end

function alloc_array₂(target::Int)::Vector{Tuple{Int, Vector{Int}}}
  ary = [ (typemax(Int), []) for _ in 1:target + 1 ]
  ary[1] = (0, [])
  ary
end
