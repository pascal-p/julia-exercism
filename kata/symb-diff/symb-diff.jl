
const OPS = [:+, :-, :*, :/, :^]
const FNS = [:cos, :sin, :tan, :e, :exp, :ln]
const UNARY_OPS_FNS = [:-, FNS...]
const ALL_OPS = [OPS..., FNS...]

const DExpr = Union{Number, Symbol}

struct Atom
  value::DExpr
  # Atom(s::DExpr) = new(s)
end

Base.show(io::IO, atom::Atom) = print(io, atom.value)

struct D2Expr
  op::Symbol
  lhs::Union{D2Expr, Atom}
  rhs::Union{D2Expr, Atom, Nothing}

  function D2Expr(op::Symbol, lhs::T1, rhs::T2) where {T1 <: Union{D2Expr, Atom}, T2 <: Union{D2Expr, Atom, Nothing}}
    @assert Symbol(op) ∈ ALL_OPS
    new(op, lhs, rhs)
  end
end

D2Expr(op::Symbol, lhs::T1) where {T1 <: Union{D2Expr, Atom}} = D2Expr(op, lhs, nothing)

D2Expr(op::Symbol, lhs::DExpr, rhs::DExpr) = D2Expr(op, lhs.value, rhs.value)
D2Expr(op::String, lhs::DExpr, rhs::DExpr) = D2Expr(Symbol(op), lhs.value, rhs.value)

# recursive
Base.show(io::IO, expr::D2Expr) =
  expr.rhs === nothing ? print(io, "($(expr.op) ", expr.lhs, ")") : print(io, "($(expr.op) ", expr.lhs, " ", expr.rhs, ")")

const DEBUG = true

function differentiate(expr::String; wrt="x")
  # 1. turn expr into a DExpr => parser / tokenizer, where each token is a DExpr

  # 2. differentiate and simplify

  # 3. stringify back
end

function parser(expr::String)::D2Expr
  reset_state()::Tuple = ("", 1, nothing)

  opstack, argstack = Symbol[], Union{D2Expr, Atom, Nothing}[]
  token, sign, pstate = reset_state()

  function build_expr!() # closure
    op = pop!(opstack)
    DEBUG && println("<< dealing with op: $(op) | $(argstack) | $(opstack)")

    if op ∈ OPS # binary case
      rhs, lhs = pop!(argstack), pop!(argstack)
      DEBUG && println("typeof(op: $(op) | typeof(rhs): $(typeof(rhs)) | typeof(lhs): $(typeof(lhs))")
      push!(argstack, D2Expr(op, lhs, rhs))
      return
    end

    if op ∈ UNARY_OPS_FNS # unary case
      lhs = pop!(argstack)
      DEBUG && println("typeof(op: $(op) | lhs: $(lhs)| typeof(lhs): $(typeof(lhs))")
      push!(argstack, D2Expr(op, lhs))
      return
    end

    throw(ArgumentError("invalid expression/1 starting with op: $(op)"))
  end

  function build_symb(ch::Char) # closure
    if pstate === nothing
      pstate = :symbol
      return (string(token, ch), pstate)
    end

    pstate == :number && throw(ArgumentError("invalid expression/3: mix of number and char"))
    pstate != :symbol && throw(ArgumentError("invalid expression/4: unknown state $(pstate)"))
    (string(token, ch), pstate)
  end

  function proc_minus_op(ix::Integer, ch::Char)
    sign = 1 # take a peek at the next char?
    if ix < length(expr)
      if isspace(expr[ix + 1])
        # OK binary ops -
        push!(opstack, ch |> Symbol)
      elseif expr[ix + 1] ∈ 'a':'z' || isdigit(expr[ix + 1])
        sign = -1
      end
    else
      throw(ArgumentError("invalid expression/2: starting from '-'"))
    end
    sign
  end

  function proc_symbol(symb::Symbol)
    if symb ∈ FNS
      push!(opstack, symb)
    else
      # take into account sign
      sign == -1 ? push!(argstack, D2Expr(:*, Atom(-1), Atom(symb))) : push!(argstack, Atom(symb))
    end
  end


  for (ix, ch) ∈ expr |> enumerate
    DEBUG && println(">> Processing ix: $(ix), ch: $(ch) | pstate: $(pstate) | opstack: $(opstack) | argstack: $(argstack)")

    if pstate == :symbol && (isspace(ch) || ch == '(' || ch == ')')
      proc_symbol(token |> Symbol)
      token, sign, pstate = reset_state()
      ch == ')' && build_expr!()

    elseif pstate == :number && (isspace(ch) || ch == ')')
      push!(argstack, Atom(parse(Int, token) * sign))
      token, sign, pstate = reset_state()
      ch == ')' && build_expr!()

    elseif isspace(ch)
      continue

    elseif ch == '('
      # capture beginning of expression

    elseif ch == ')'
      build_expr!() # opstack, argstack)

    elseif ch == '-'
      sign = proc_minus_op(ix, ch)

    elseif Symbol(ch) ∈ OPS
      push!(opstack, ch |> Symbol)

    elseif lowercase(ch) ∈ 'a':'z'
      token, pstate = build_symb(ch) # , token, pstate)

    elseif isdigit(ch) # NO dot for now...
      pstate = :number
      token = string(token, ch)

    else
      throw(ArgumentError("invalid expression/5"))
    end
  end

  @assert length(opstack) ≤ 1 "opstack should be at most 1 opeartor"
  length(opstack) == 1 && build_expr!()
  pop!(argstack)
end

function differentiate(expr::DExpr; wrt="x")::DExpr
  # dispatch on the oper
  expr
end

simplify(expr::DExpr)::DExpr = expr # identity for now

diffsum(lhs::DExpr, rhs::DExpr) = DExpr("+", (simplify ∘ differentiate)(lhs), (simplify ∘ differentiate)(rhs))
