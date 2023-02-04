
const OPS = [:+, :-, :*, :/, :^]
const FNS = [:cos, :sin, :tan, :e, :exp, :ln]
const UNARY_OPS_FNS = [:-, [FNS]...]

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
    @assert Symbol(op) ∈ OPS
    new(op, lhs, rhs)
  end
end

D2Expr(op::Symbol, lhs::T1) where {T1 <: Union{D2Expr, Atom}} = D2Expr(op, lhs, nothing)

D2Expr(op::Symbol, lhs::DExpr, rhs::DExpr) = D2Expr(op, lhs.value, rhs.value)
D2Expr(op::String, lhs::DExpr, rhs::DExpr) = D2Expr(Symbol(op), lhs.value, rhs.value)

# recursive
Base.show(io::IO, expr::D2Expr) = print(io, "($(expr.op) ", expr.lhs, " ", expr.rhs, ")")

const DEBUG = false

function differentiate(expr::String; wrt="x")
  # 1. turn expr into a DExpr => parser / tokenizer, where each token is a DExpr

  # 2. differentiate and simplify

  # 3. stringify back
end

function parser(expr::String)::D2Expr
  opstack = []
  argstack = []
  pstate = nothing
  token, sign = "", 1

  for (ix, ch) ∈ expr |> enumerate
    DEBUG && println(">> Processing ix: $(ix), ch: $(ch) | pstate: $(pstate) | opstack: $(opstack) | argstack: $(argstack)")

    if pstate == :symbol && (isspace(ch) || ch == ')')
      symb = Symbol(token)
      DEBUG && println("... Symbol: $(symb) | sign: $(sign) | ch: [$(ch)]")
      if symb ∈ FNS
        push!(opstack, symb)
      else
        # take into account sign
        if sign == -1
          push!(argstack, D2Expr(:*, Atom(-1), Atom(symb)))
        else
          push!(argstack, Atom(symb))
        end
      end
      token, sign = "", 1
      pstate = nothing
      ch == ')' && build_expr!(opstack, argstack)

    elseif pstate == :number && (isspace(ch) || ch == ')')
      n = parse(Int, token)
      push!(argstack, Atom(n * sign))
      token, sign = "", 1
      pstate = nothing
      ch == ')' && build_expr!(opstack, argstack)

    elseif isspace(ch)
      continue

    elseif ch == '('
      # capture beginning of expression

    elseif ch == ')'
      build_expr!(opstack, argstack)

    elseif ch == '-'
      # take a peek at the next char?
      if ix < length(expr)
        if isspace(expr[ix + 1])
          # OK binary ops -
          push!(opstack, ch)
        elseif expr[ix + 1] ∈ 'a':'z' || isdigit(expr[ix + 1])
          sign = -1
        end
      else
        throw(ArgumentError("invalid expression/2: starting from '-'"))
      end
    elseif Symbol(ch) ∈ OPS
      push!(opstack, ch)

    elseif lowercase(ch) ∈ 'a':'z'
      if pstate === nothing
        pstate = :symbol
      elseif pstate == :number
        throw(ArgumentError("invalid expression/3: mix of number and char"))
      elseif  pstate != :symbol
        throw(ArgumentError("invalid expression/4: unknown state $(pstate)"))
      end
      token = string(token, ch)

    elseif isdigit(ch) # NO dot for now...
      pstate = :number
      token = string(token, ch)

    else
      throw(ArgumentError("invalid expression/5"))
    end
  end

  DEBUG && println("=>  opstack: ", opstack, " argstack: ", argstack)

  @assert length(opstack) == 0 "opstack should be empty"
  robj = pop!(argstack)

  robj
end

function build_expr!(opstack, argstack)
  op = pop!(opstack) |> Symbol
  DEBUG && println("<< dealing with op: $(op) / $(OPS) / typeof of op ", typeof(op))
  if op ∈ OPS
    rhs, lhs = pop!(argstack), pop!(argstack)
    DEBUG && println("typeof(op: $(op) | typeof(rhs): $(typeof(rhs)) | typeof(lhs): $(typeof(lhs))")
    push!(argstack, D2Expr(op, lhs, rhs))
  elseif op ∈ UNARY_OPS_FNS
    # unary
    lhs = pop!(argstack)
    push!(argstack, D2Expr(op, lhs))
  else
    throw(ArgumentError("invalid expression/1"))
  end

  DEBUG && println(">> opstack: $(opstack) | argstack: $(argstack)")
end

function differentiate(expr::DExpr; wrt="x")::DExpr
  # dispatch on the oper
  expr
end

simplify(expr::DExpr)::DExpr = expr # identity for now

diffsum(lhs::DExpr, rhs::DExpr) = DExpr("+", (simplify ∘ differentiate)(lhs), (simplify ∘ differentiate)(rhs))
