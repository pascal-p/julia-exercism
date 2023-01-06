import Base: +, -, *, /, pushfirst!

const OPS = ['+', '-', '*', '/']
const DIGITS = '0':'9'
const DOT = '.'
const OPER_MAP = Dict{Symbol, Function}(
  :+ => +,
  :- => -,
  :* => *,
  :/ => /,
)
const TT = Float32


#
# 1 pass over the entire expression (parse) to build 2 stacks (which enforce evaluation order):
#  - one for operands and
#  - one for operatoras
#
# 1 pass over the 2 stacks to compute the result of the arithmetic expression
#
# check for validity of the expression
#
# most complicated part is to deal with changes of the eval order within parenthesized expression
#

function evalexpr(expr::String)
  (operator_stack, operand_stack) = parseexpr(expr)
  evalexpr_(operator_stack, operand_stack)
  pop!(operand_stack)
end

function parseexpr(expr::String)
  cstate, pstate = :start, :start
  operand_stack, operator_stack = [], Symbol[]
  token, forbiden = "", '_'
  porder, order = nothing, :l2r # :r2l

  for ch ∈ strip(expr)
    ch == forbiden && throw(ArgumentError("space not allowed at this position"))
    forbiden = '_'

    if ch ∈ DIGITS
      pstate, cstate, token = (cstate, :number, string(token, ch))
      continue
    end

    if ch == DOT
      cstate != :number && throw(ArgumentError("(decimal) dot not allowed at this position"))
      pstate, cstate, token = (cstate, :number, string(token, ch))
      continue
    end

    if ch == ' '
      pstate = cstate
      # DO NOT CHANGE current state
      pstate == :number && token != "" && (token = number!(operand_stack, token, order))
      continue
    end

    if ch ∈ OPS
      if ch == '-' && pstate ∈ (:start, :operator) # not an operator, but sign
        forbiden, token = sign(ch)
        continue
      end

      pstate, cstate = cstate, :operator
      pstate == :number && token != "" && (token = number!(operand_stack, token, order))
      pushfirst!(operator_stack, (Symbol ∘ string)(ch), order)
      continue
    end

    if ch == '('
      order == :l2r && ((porder, order) = (:l2r, :r2l))
      pstate == :number && throw(ArgumentError("Arithmetic expression not well formed :("))
      pstate, cstate = cstate, :open_par
      token = (Symbol ∘ string)(ch)
      Base.pushfirst!(operand_stack, token)
      Base.pushfirst!(operator_stack, token)
      token = ""
      continue
    end

    if ch == ')'
      Symbol("(") ∉ operand_stack && throw(ArgumentError("Arithmetic expression not well formed :)"))
      cstate == :number && length(string(token)) ≥ 1 && (token = number!(operand_stack, token, order))
      evalexpr_(operator_stack, operand_stack; limit='(') # need to eval expr up to first matching '('
      order == :r2l && ((porder, order) = (nothing, :l2r))
      pstate = cstate
      cstate = :close_par
      continue
    end
  end

  cstate == :number && pushfirst!(operand_stack, token |> parse_num, order)
  (operator_stack, operand_stack)
end

function pushfirst!(opstack::Vector, token::Union{Number, Symbol, String}, order::Symbol)
  if order == :l2r
    Base.pushfirst!(opstack, token)
    return
  end
  if opstack[1] == Symbol("(")
    Base.pushfirst!(opstack, token)
  else
    ## Insert at left pos of leftmost Symbol("(")
    ix = find_index(Symbol("("), opstack)
    push_at!(opstack, ix - 1, token)
  end
end

function number!(operand_stack, token, order)  # we finish reading a number
  pushfirst!(operand_stack, token |> parse_num, order)
  token = "" # reset
end

function sign(ch::Char)
  forbiden = ' '     # we do not want space
  token = string(ch) # not an operator, but sign
  (forbiden, token)
end

function parse_num(token::String)::Number
  # sign (nothing to do) and dot
  occursin(".", token) && (return parse(TT, token)) # decimal case
  parse(Int, token)
end

function evalexpr_(operator_stack::Vector{Symbol}, operand_stack::Vector; limit=nothing)
  while !isempty(operator_stack)
    if length(operator_stack) == 1 && operator_stack[1] == Symbol("(") && length(operand_stack) == 1
      pop!(operator_stack)
      break
    end

    (oper, x, y) = getops!(operator_stack, operand_stack, limit === nothing ? pop! : popfirst!)

    iszero(y) && oper == :/ && (throw(DivideError())) # in this restricted case only division by zero is problematic
    oper == :/ && ((x, y) = (TT(x), TT(y)))
    r = OPER_MAP[oper](x, y)
    if limit !== nothing
      if !isempty(operand_stack) && operand_stack[1] == Symbol("(")
        operand_stack[1] = r
        break
      end
      Base.pushfirst!(operand_stack, r)
      continue
    end

    Base.push!(operand_stack, r)
  end
end

function getops!(operator_stack, operand_stack, popoper!)
  oper = popoper!(operator_stack)

  # oper == Symbol("(") && (oper = popoper!(operator_stack)) ## ASSUME operator_stack is NOT of length 0
  if oper == Symbol("(")
    @assert !isempty(operator_stack)
    oper = popoper!(operator_stack)
  end

  x = popoper!(operand_stack)
  y = popoper!(operand_stack)
  (oper, x, y)
end

function find_index(e::Union{String, Symbol}, stack::Vector)
  for ix ∈ 1:length(stack)
    stack[ix] == e && return ix
  end
  nothing
end

function push_at!(stack::Vector, ix, token)
  Base.pushfirst!(stack, :_) # placeholder
  for jx ∈ 1:ix              # push to left
    stack[jx] = stack[jx + 1]
  end
  stack[ix + 1] = token      # insert
end

# parenthesized arithmetic evaluation: Error During Test at /home/pascal/Projects/Exercism/julia/kata/eval-arith-expr/runtests.jl:54
#   Test threw exception
#   Expression: evalexpr("2. * (1 + ((3 * -2) + 2.)) + 3.") == -3.0f0
#   KeyError: key Symbol("(") not found
#   Stacktrace:
#    [1] getindex(h::Dict{Symbol, Function}, key::Symbol)
#      @ Base ./dict.jl:498
#    [2] evalexpr_(operator_stack::Vector{Symbol}, operand_stack::Vector{Any}; limit::Char)
#      @ Main ~/Projects/Exercism/julia/kata/eval-arith-expr/eval-arith-expr.jl:141
#    [3] parseexpr(expr::String)
#      @ Main ~/Projects/Exercism/julia/kata/eval-arith-expr/eval-arith-expr.jl:87
#    [4] evalexpr(expr::String)
#      @ Main ~/Projects/Exercism/julia/kata/eval-arith-expr/eval-arith-expr.jl:28
#    [5] macro expansion
#      @ ~/Projects/julia-1.8.4/share/julia/stdlib/v1.8/Test/src/Test.jl:464 [inlined]
#    [6] macro expansion
#      @ ~/Projects/Exercism/julia/kata/eval-arith-expr/runtests.jl:54 [inlined]
#    [7] macro expansion
#      @ ~/Projects/julia-1.8.4/share/julia/stdlib/v1.8/Test/src/Test.jl:1363 [inlined]
#    [8] top-level scope
#      @ ~/Projects/Exercism/julia/kata/eval-arith-expr/runtests.jl:42
# Test Summary:                       | Pass  Error  Total  Time
# parenthesized arithmetic evaluation |   15      1     16  1.0s
# ERROR: LoadError: Some tests did not pass: 15 passed, 0 failed, 1 errored, 0 broken.
# in expression starting at /home/pascal/Projects/Exercism/julia/kata/eval-arith-expr/runtests.jl:41
