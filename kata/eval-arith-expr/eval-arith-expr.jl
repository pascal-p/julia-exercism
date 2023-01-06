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
const DEBUG = false

function parseexpr(expr::String)
  cstate, pstate = :start, :start
  operand_stack, operator_stack = [], Symbol[]
  token, oper, forbiden = "", "", '_'
  porder, order = nothing, :l2r # :r2l

  for ch ∈ strip(expr)
    ch == forbiden && throw(ArgumentError("space not allowed at this position"))
    forbiden = '_'

    if ch ∈ DIGITS
      pstate = cstate
      cstate = :number
      token = string(token, ch)
      continue
    end

    if ch == DOT
      pstate = cstate
      cstate = :number
      pstate != :number && throw(ArgumentError("(decimal) dot not allowed at this position"))
      token = string(token, ch)
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

      pstate = cstate
      cstate = :operator

      pstate == :number && token != "" && (token = number!(operand_stack, token, order))
      oper = string(ch)
      pushfirst!(operator_stack, Symbol(oper), order)
      continue
    end

    if ch == '('
      order == :l2r && ((porder, order) = (:l2r, :r2l))
      pstate == :number && throw(ArgumentError("Arithmetic expression not well formed :("))

      pstate = cstate
      cstate = :open_par

      token = string(token, ch)
      Base.pushfirst!(operand_stack, token)
      Base.pushfirst!(operator_stack, Symbol(token))
      token = ""

      continue
    end

    if ch == ')'
      "(" ∉ operand_stack && throw(ArgumentError("Arithmetic expression not well formed :)"))

      cstate == :number && length(string(token)) ≥ 1 && (token = number!(operand_stack, token, order))
      # need to eval expr up to first matching '('
      evalexpr(operator_stack, operand_stack; limit='(')

      order == :r2l && ((porder, order) = (nothing, :l2r))
      pstate = cstate
      cstate = :close_par # :number  # akin to number state...
      continue
    end
  end

  if cstate == :number
    DEBUG && println("[left?] token: <$(token)>")
    pushfirst!(operand_stack, token |> parse_num, order)
  end

  evalexpr(operator_stack, operand_stack)
  pop!(operand_stack)
end

function pushfirst!(operator_stack::Vector{Symbol}, token::Symbol, order::Symbol) # for operator
  if order == :l2r
    Base.pushfirst!(operator_stack, token)
    return
  end

  if operator_stack[1] == Symbol("(")
    Base.pushfirst!(operator_stack, token)
  else
    ## Insert at left pos of leftmost Symbol("(")
    ix = find_index(Symbol("("), operator_stack)
    push_at!(operator_stack, ix - 1, token)
  end
end

function pushfirst!(operand_stack::Vector{Any}, token::Union{Number, String}, order::Symbol) # for operands
  if order == :l2r
    Base.pushfirst!(operand_stack, token)
    return
  end

  if operand_stack[1] == "("
    Base.pushfirst!(operand_stack, token)
  else
    ## Insert at left pos of leftmost "("
    ix = find_index("(", operand_stack)
    push_at!(operand_stack, ix - 1, token)
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

function evalexpr(operator_stack::Vector{Symbol}, operand_stack::Vector; limit=nothing)
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
      if !isempty(operand_stack) && operand_stack[1] == "("
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
