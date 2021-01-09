"""
  Eight queens puzzle (using backtracking)

  cf. https://en.wikipedia.org/wiki/Eight_queens_puzzle

  The eight queens puzzle has 92 distinct solutions.
  If solutions that differ only by the symmetry operations of rotation and reflection of the board are counted as one,
  the puzzle has 12 solutiones. These are called fundamental solutions; representatives of each are shown below.

  This implementation list all the solutions (regardless of rotations/symetries ...)
  ex. 92 solutions (for 8 queens) and so on...
"""

const DT = Int32

struct Queen
  n::DT
  vq::Vector{DT}

  function Queen(n::DT)
    @assert n > zero(DT) "Expecting n to be strictly positive"

    new(n, Vector{DT}(undef, n))
  end
end


"""
Check that position (r, c) is available (free) by comparing with positions already taken
"""
function free_pos(q::Queen, r::DT, c::DT)::Bool
  free = true

  for pr ∈ one(DT):r - one(DT)
    free = pos_not_taken(r, c, pr, q.vq[pr])
    !free && break
  end

  free
end


"""
  Try 1 solution, given a column c (thus taking initial position at (r=1, c)

"""
function queen_1sol(q::Queen; c::DT=one(DT))::Bool
  @assert one(DT) ≤ c ≤ q.n "Expecting  1 ≤ $(c) ≤ $(q.n)"

  function _place_next_queen(r::DT)::Bool
    r == q.n && return true

    poss = false

    for c ∈ one(DT):q.n
      nr = r + one(DT)

      if free_pos(q, nr, c)
        q.vq[nr] = c
        poss = _place_next_queen(nr)
      end

      poss && break
    end

    poss
  end

  q.vq[1] = c
  _place_next_queen(DT(1))
end


"""
  All solutions
"""
function queen_sols(q::Queen; display=false)
  cnt = zero(DT)

  function _place_next_queen(r::DT)
   if r == q.n
     display && display_sol(q)
     cnt += 1
     return

   else
     for c ∈ one(DT):q.n

       if free_pos(q, r + DT(1), c)
         q.vq[r + DT(1)] = c

          _place_next_queen(r + DT(1))
       end
     end
   end
  end

  _place_next_queen(zero(DT))
  return cnt
end


function display_sol(q::Queen)
  str = string("+", "---+" ^ q.n, "\n")

  for r in 1:q.n
    str = string(str, "|", "   |" ^ (q.vq[r] - 1), " Q |", "   |" ^ (q.n - q.vq[r]), "\n")
    str = string(str, "+", "---+" ^ q.n, "\n")
  end

  println(str)
end


"""
Check that a given queen at possible position(pr, pc) is not in conflict with another one
at position (r, c)

meaning these queens are NOT:
- on the same row      → trivially ensure by making pr < r
- on the same column   → check than c ≠ pc
- on the same diagonal → |c - pc| ≠ r - pr

(pr , pc) ≡ already (previously) taken row and col
"""
function pos_not_taken(r::DT, c::DT, pr::DT, pc::DT)::Bool
  @assert pr < r "Expected row $(pr) to be (strictly) less than (possible) row: $(r)"

  pc ≠ c && abs(c - pc) ≠ r - pr
end
