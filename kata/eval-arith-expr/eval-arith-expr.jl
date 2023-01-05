import Base: +, -, *, /

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

  for ch ∈ strip(expr)
    DEBUG && println(" ", ch, " ", typeof(ch))

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
      # cstate = :space # DO NOT CHANGE current state
      pstate == :number && token != "" && (token = number!(operand_stack, token))
      continue
    end

    if ch ∈ OPS
      if ch == '-' && pstate == :start # not an operator, but sign
        forbiden, token = sign(ch)
        continue
      end

      pstate = cstate
      cstate = :operator

      if pstate == :operator && ch == '-' # not an operator, but sign
        forbiden, token = sign(ch) # do we need to change the state back?
        continue
      end

      pstate == :number && token != "" && (token = number!(operand_stack, token))
      oper = string(ch)
      pushfirst!(operator_stack, Symbol(oper))
      continue
    end

    if ch == '('
      # TODO
      continue
    end

    if ch == ')'
      # TODO
      continue
    end
  end

  DEBUG && println("[exit loop] operands: $(operand_stack) / operators: $(operator_stack)")

  if cstate == :number # pstate == :number || cstate == :number
    DEBUG && println("[left?] token: ", token)
    pushfirst!(operand_stack, token |> parse_num)
  end

  DEBUG && println("operands: $(operand_stack) / operators: $(operator_stack)")
  evalexpr(operator_stack, operand_stack)

  DEBUG && println("results: $(operand_stack[1])")
  pop!(operand_stack)
end

function number!(operand_stack, token)
  # we finish reading a number
  pushfirst!(operand_stack, token |> parse_num)
  token = "" # reset
end

function sign(ch::Char)
  DEBUG && println("set forbidden char...")
  forbiden = ' ' # we do not want space
  token = string(ch) # not an operator, but sign
  (forbiden, token)
end

function parse_num(token::String)
  # sign (nothing to do) and dot
  if occursin(".", token)
    return parse(TT, token) # decimal case
  end
  parse(Int, token)
end

function evalexpr(operator_stack::Vector{Symbol}, operand_stack::Vector)
  while !isempty(operator_stack)
    oper = pop!(operator_stack)
    x = pop!(operand_stack)
    y = pop!(operand_stack)
    iszero(y) && oper == :/ && (throw(DivideError())) # in this restricted case only division by zero is problematic
    oper == :/ && ((x, y) = (TT(x), TT(y)))

    push!(operand_stack, OPER_MAP[oper](x, y))
  end
end
