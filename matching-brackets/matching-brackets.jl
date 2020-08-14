const BRACKETS = ['[', ']', '{', '}', '(', ')']

## NOTE opening brackets at indexes which are odd (integer)
const OPENING_BRACKETS = [BRACKETS[ix] for ix in 1:2:length(BRACKETS)]
const CLOSING_BRACKETS = [BRACKETS[ix] for ix in 2:2:length(BRACKETS)]

const HSHMAP = Dict(ch => ix for (ix, ch) in enumerate(BRACKETS))  ## to detect matching pairs
const STACK_LEN = 20

"""
Checking for matching brackets
"""
function matching_brackets(expr::String)::Bool
  isempty(expr) && return true

  stack = stack_maker(STACK_LEN)
  for ch in expr
    ch ∉ BRACKETS && continue  ## non-brackets character are ignored...

    if ch ∈ OPENING_BRACKETS
      stack.push(ch)
      continue

    elseif ch ∈ CLOSING_BRACKETS
      stack.isempty() && return false

      n_ch = stack.pop()  ## get opening bracket
      HSHMAP[ch] - 1 ≠ HSHMAP[n_ch] && return false
    end
  end

  return stack.isempty()
end


"""
A Stack implementation for convenience
"""
function stack_maker(lim::Int)
  ## internal state:
  lim = lim ≤ STACK_LEN ? STACK_LEN : lim
  ix = 0
  stack = Vector{Char}(undef, lim)

  ## methods
  function push(item::Char)
    ix ≥ length(stack) && throw(BoundsError("Error: the stack if full!"))
    ix += 1
    stack[ix] = item
    return
  end

  function pop()::Char
    ix == 0 && throw(BoundsError("Error: the stack if empty!"))
    ch = stack[ix]
    ix -= 1
    return ch
  end

  function peek()::Char
    ix == 0 && throw(BoundsError("Error: the stack if empty!"))
    return stack[ix]
  end

  isempty()::Bool = ix == 0
  isfull()::Bool = ix == lim

  ## make methods public
  return () -> (push, pop, peek, isempty, isfull)
end
