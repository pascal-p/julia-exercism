
# struct D2Expr; end
# struct D1Expr; end
# struct D0Expr; end

const OPS = [:+, :-, :*, :/, :^]
const FNS = [:cos, :sin, :tan, :e, :exp, :ln]
const UNARY_OPS_FNS = [:-, [FNS]...]

# abstract type DExpr end
const DExpr = Union{Number, Symbol}

# abstract type Number <: DExpr end
# abstract type Symbol <: DExpr end

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

D2Expr(op::Symbol, lhs::DExpr, rhs::DExpr) = D2Expr(op, lhs.value, rhs.value)
D2Expr(op::String, lhs::DExpr, rhs::DExpr) = D2Expr(Symbol(op), lhs.value, rhs.value)

# recursive
Base.show(io::IO, expr::D2Expr) = print(io, "($(expr.op) ", expr.lhs, " ", expr.rhs, ")")

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
    # isspace(ch) && continue
    println(">> Processing ix: $(ix), ch: $(ch) | pstate: $(pstate) | opstack: $(opstack) | argstack: $(argstack)")

    if pstate == :symbol && (isspace(ch) || ch == ')')
      symb = Symbol(token)
      println("... Symbol: $(symb)")
      if symb ∈ FNS
        push!(opstack, symb)
      else
        push!(argstack, Atom(symb))
      end
      token = ""
      pstate = nothing
      ch == ')' && build_expr!(opstack, argstack)

    elseif pstate == :number && (isspace(ch) || ch == ')')
      n = parse(Int, token)
      push!(argstack, Atom(n))
      token = ""
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
        if isspace(expr[ix])
          # OK binary ops -
          push!(opstack, ch)
        elseif expr[ix] ∈ 'a':'z'
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

  println("=>  opstack: ", opstack)
  println("=> argstack: ", argstack)

  @assert length(opstack) == 0 "opstack should be empty"
  robj = pop!(argstack)

  robj
end

function build_expr!(opstack, argstack)
  # mark end of current expr - pop and build depending on whether op is unary or binary...
  op = pop!(opstack) |> Symbol
  println("<< dealing with op: $(op) / $(OPS) / typeof of op ", typeof(op))
  if op ∈ OPS
    rhs, lhs = pop!(argstack), pop!(argstack)
    println("typeof(op: $(op) | typeof(rhs): $(typeof(rhs)) | typeof(lhs): $(typeof(lhs))")
    push!(argstack, D2Expr(op, lhs, rhs))
  elseif op ∈ UNARY_OPS_FNS
    # unary
    lhs = pop!(argstack)
    push!(argstack, D1Expr(op, lhs))
  else
    throw(ArgumentError("invalid expression/1"))
  end

  println(">> opstack: $(opstack) | argstack: $(argstack)")
end

function differentiate(expr::DExpr; wrt="x")::DExpr
  # dispatch on the oper
  expr
end

simplify(expr::DExpr)::DExpr = expr # identity for now

diffsum(lhs::DExpr, rhs::DExpr) = DExpr("+", (simplify ∘ differentiate)(lhs), (simplify ∘ differentiate)(rhs))

# ERROR: MethodError: Cannot `convert` an object of type
#   D2Expr to an object of type
#   Union{Number, Symbol}
# Closest candidates are:
#   convert(::Type{T}, ::T) where T at Base.jl:61
# Stacktrace:
#  [1] parser(expr::String)
#    @ Main ~/Projects/Exercism/julia/kata/symb-diff/symb-diff.jl:124
#  [2] top-level scope
#    @ REPL[2]:1
