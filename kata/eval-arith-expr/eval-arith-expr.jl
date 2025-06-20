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
# 1 pass with reduction  (eval) as soon as possible
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
  limit = nothing

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
      # before pushing can we eval what we have?
      if length(operand_stack) ≥ 2 && isnumeric(string(operand_stack[1])) && isnumeric(string(operand_stack[2]))
        # yes
        limit === nothing && Symbol("(") ∈ operand_stack && (limit = '(')
        (oper, x, y) = getops!(operator_stack, operand_stack, limit === nothing ? pop! : popfirst!)
        r = OPER_MAP[oper](x, y) # FIXME: possible / by 0
        Base.pushfirst!(operand_stack, r)
      end

      pstate == :number && token != "" && (token = number!(operand_stack, token, order))
      pushfirst!(operator_stack, (Symbol ∘ string)(ch), order)
      Symbol("(") ∉ operand_stack && (limit = nothing)
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
      limit = nothing
      continue
    end

    if ch == ')'
      limit === nothing && Symbol("(") ∈ operand_stack && (limit = '(')
      Symbol("(") ∉ operand_stack && throw(ArgumentError("Arithmetic expression not well formed :)"))
      cstate == :number && length(string(token)) ≥ 1 && (token = number!(operand_stack, token, order))
      ##
      evalexpr_(operator_stack, operand_stack; limit=limit) # need to eval expr up to first matching '('
      ##
      order == :r2l && ((porder, order) = (nothing, :l2r))
      pstate = cstate
      cstate = :close_par
      Symbol("(") ∉ operand_stack && (limit = nothing)
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
        popfirst!(operator_stack) # we no longer need Symbol("(")
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

isnumeric(expr::String)::Bool = match(r"\A\-?\d+(?:\.\d*)?\Z", expr) !== nothing
