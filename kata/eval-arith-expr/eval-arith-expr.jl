using Base: start_reading
const OPS = ['+', '-', '*', '/']
import Base: +, -, *, /

const DIGITS = '0':'9'

const OPER_MAP = Dict{Symbol, Function}(
  :+ => +,
  :- => -,
  :* => *,
  :/ => /,
)

const DEBUG = false

function parseexpr(expr::String)
  cstate, pstate = :start, :start
  operand_stack, operator_stack = [], []
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

    if ch == ' '
      pstate = cstate
      # cstate = :space # DO NOT CHANGE current state
      pstate == :number && token != "" && (token = number!(operand_stack, token))
      continue
    end

    if ch ∈ OPS
      if ch == '-' && pstate == :start
        # not an operator, but sign
        DEBUG && println("set forbidden char...")
        forbiden = ' ' # we do not want space
        token = string(ch) # not an operator, but sign
        continue
      end

      pstate = cstate
      cstate = :operator
      if pstate == :operator # || pstate == :space
        if ch == '-'
          DEBUG && println("set forbidden char...")
          forbiden = ' ' # we do not want space
          token = string(ch) # not an operator, but sign
          continue
        end
      elseif pstate == :number && token != ""
        token = number!(operand_stack, token)
      end
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

  while !isempty(operator_stack)
    oper = pop!(operator_stack)
    x = pop!(operand_stack)
    y = pop!(operand_stack)
    push!(operand_stack, OPER_MAP[oper](x, y))
  end

  DEBUG && println("results: $(operand_stack[1])")
  pop!(operand_stack)
end

function number!(operand_stack, token)
  # we finish reading a number
  pushfirst!(operand_stack, token |> parse_num)
  token = "" # reset
end

function parse_num(token::String)
  # sign (nothing to do) and dot
  if occursin(".", token)
    # decimal case
    parse(Float32, token)
  end
  parse(Int, token)
end
