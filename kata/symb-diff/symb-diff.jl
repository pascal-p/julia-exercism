
const SUM_OPS = [:+, :-]
const MUL_OPS = [:*, :/]
const OPS = [SUM_OPS..., MUL_OPS..., :^]
const FNS = [:cos, :sin, :tan, :e, :exp, :ln]
const UNARY_OPS_FNS = [:-, FNS...]
const ALL_OPS = [OPS..., FNS...]

const DEBUG = false
const DExpr = Union{Number, Symbol}

struct Atom
  value::DExpr
  # Atom(s::DExpr) = new(s)
end

Base.show(io::IO, atom::Atom) = print(io, atom.value)
Base.length(sym::Atom) = 1

struct D2Expr
  op::Symbol
  lhs::Union{D2Expr, Atom}
  rhs::Union{D2Expr, Atom, Nothing}

  function D2Expr(op::Symbol, lhs::T1, rhs::T2) where {T1 <: Union{D2Expr, Atom}, T2 <: Union{D2Expr, Atom, Nothing}}
    @assert Symbol(op) ∈ ALL_OPS
    new(op, lhs, rhs)
  end
end

D2Expr(op::Symbol, lhs::D2Expr) = D2Expr(op, lhs, nothing)

function D2Expr(op::Symbol, lhs::Atom)
  if op == :+
    lhs
  elseif op == :-
    Atom(-lhs.value)
  elseif op ∈ UNARY_OPS_FNS
    D2Expr(op, lhs, nothing)
  else
    throw(ArgumentError("bad expression: $(op) $(lhs)"))
  end
end


D2Expr(op::Symbol, lhs::DExpr, rhs::DExpr) = D2Expr(op, lhs.value, rhs.value)
D2Expr(op::String, lhs::DExpr, rhs::DExpr) = D2Expr(Symbol(op), lhs.value, rhs.value)

## recursive
Base.show(io::IO, expr::D2Expr) =
  expr.rhs === nothing ? print(io, "($(expr.op) ", expr.lhs, ")") : print(io, "($(expr.op) ", expr.lhs, " ", expr.rhs, ")")

oper(dexpr::D2Expr) = dexpr.op
lhs(dexpr::D2Expr) = dexpr.lhs
rhs(dexpr::D2Expr) = dexpr.rhs
Base.length(dexpr::D2Expr) = dexpr.rhs === nothing ? 2 : 3


# 1. turn expr into a DExpr => parser / tokenizer, where each token is a DExpr
# 2. differentiate and simplify
# 3. stringify back

function parser(expr::String)::Union{D2Expr, Atom}
  reset_state()::Tuple = ("", 1, nothing)

  opstack, argstack = Symbol[], Union{D2Expr, Atom, Nothing}[]
  token, sign, pstate = reset_state()

  ## Inner helper function
  function build_expr!() # closure
    op = pop!(opstack)

    if op ∈ OPS # binary case
      rhs, lhs = pop!(argstack), pop!(argstack)
      push!(argstack, D2Expr(op, lhs, rhs))
      return
    end

    if op ∈ UNARY_OPS_FNS # unary case
      lhs = pop!(argstack)
      push!(argstack, D2Expr(op, lhs))
      return
    end

    throw(ArgumentError("invalid expression: starting with op: $(op)"))
  end

  function build_symb(ch::Char) # closure
    if pstate === nothing
      pstate = :symbol
      return (string(token, ch), pstate)
    end

    pstate == :number && throw(ArgumentError("invalid expression: mix of number and char"))
    pstate != :symbol && throw(ArgumentError("invalid expression: unknown state $(pstate)"))
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
      throw(ArgumentError("invalid expression: starting from '-'"))
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

  ## main parser loop
  for (ix, ch) ∈ expr |> enumerate
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
      throw(ArgumentError("invalid expression: non expected character $(ch)"))
    end
  end

  ## Conclusion
  @assert length(opstack) ≤ 1 "opstack should be at most 1 opeartor"
  length(opstack) == 1 && build_expr!()

  if length(argstack) == 0
    if pstate == :symbol
      return Atom(token |> Symbol)
    elseif pstate == :number
      return Atom(parse(Int, token))
    else
      throw(ArgumentError("invalid expression: unknown state $(pstate)"))
    end
  end

  pop!(argstack)
end

function differentiate(expr::String; wrt=:x)::Union{D2Expr, Atom}
  # dispatch on the oper
  dexpr = parser(expr)
  diff_on_op(dexpr; wrt)
end

differentiate(dexpr::D2Expr; wrt=:x)::Union{D2Expr, Atom} = diff_on_op(dexpr; wrt)

differentiate(expr::Atom; wrt=:x)::Atom = diffsym(expr; wrt)

function diff_on_op(dexpr::D2Expr; wrt=:x)
  D2Expr(dexpr.op, (simplify ∘ DISPATCH_MAP[dexpr.op])(dexpr.lhs, dexpr.rhs; wrt))

  # dexpr.op == :+ && return D2Expr(dexpr.op, (simplify ∘ diffsum)(dexpr.lhs, dexpr.rhs; wrt))
  # dexpr.op == :- && return D2Expr(dexpr.op, (simplify ∘ diffsub)(dexpr.lhs, dexpr.rhs; wrt))
  # TODO ...

  ## DOES NOT WORK:
  # for (key, op) ∈ [(:diffsub, :-), (:diffsum, :+)]
  #   @eval begin
  #     dexpr.op == Symbol($(op)) && return D2Expr(dexpr.op, (simplify ∘ ($(key)))(dexpr.lhs, dexpr.rhs; wrt))
  #   end
  # end
end

diff_on_op(sym::Atom; wrt=:x) = diffsym(sym; wrt)

## derivative rules
for (key, op) ∈ [(:diffsub, :-), (:diffsum, :+)]
  @eval begin
    ($(key))(lhs::Union{D2Expr, Atom}, rhs::Union{D2Expr, Atom}; wrt=:x) = sumrule(Symbol($(op)), lhs, rhs; wrt)
  end
end

diffmul(lhs::Union{D2Expr, Atom}, rhs::Union{D2Expr, Atom}; wrt=:x) = mulrule(:*, lhs, rhs; wrt)

diffdiv(lhs::Union{D2Expr, Atom}, rhs::Union{D2Expr, Atom}; wrt=:x) = divrule(:/, lhs, rhs; wrt )


const DISPATCH_MAP = Dict{Symbol, Function}(
  :+ => diffsum,
  :- => diffsub,
  :* => diffmul,
  :/ => diffdiv,
  # ...
)

diffsym(sym::Atom; wrt=:x) = sym.value == wrt ? Atom(1) : Atom(0)

sumrule(op::Symbol, lhs::D2Expr, rhs::D2Expr; wrt=:x)::D2Expr = D2Expr(
  op,
  (simplify ∘ differentiate)(lhs; wrt),
  (simplify ∘ differentiate)(rhs; wrt)
)

sumrule(op::Symbol, lhs::D2Expr, rhs::Atom; wrt=:x)::D2Expr = D2Expr(
  op,
  (simplify ∘ differentiate)(lhs; wrt),
  diffsym(rhs; wrt)
)

sumrule(op::Symbol, lhs::Atom, rhs::D2Expr; wrt=:x)::D2Expr = D2Expr(
  op,
  diffsym(lhs; wrt),
  (simplify ∘ differentiate)(rhs; wrt)
)

sumrule(op::Symbol, lhs::Atom, rhs::Atom; wrt=:x) = D2Expr(
  op,
  diffsym(lhs; wrt),
  diffsym(rhs; wrt)
)

function mulrule(op::Symbol, lhs::D2Expr, rhs::D2Expr; wrt=:x)::D2Expr
  D2Expr(
    :+,
    D2Expr(op,
           (simplify ∘ differentiate)(lhs; wrt),
           rhs),
    D2Expr(op,
           lhs,
           (simplify ∘ differentiate)(rhs; wrt))
  )
end

# mulrule(op::Symbol, lhs::D2Expr, rhs::Atom; wrt=:x)::D2Expr = D2Expr(
#   op,
#   (simplify ∘ differentiate)(lhs; wrt),
#   diffsym(rhs; wrt)
# )

# mulrule(op::Symbol, lhs::Atom, rhs::D2Expr; wrt=:x)::D2Expr = D2Expr(
#   op,
#   diffsym(lhs; wrt),
#   (simplify ∘ differentiate)(rhs; wrt)
# )

# mulrule(op::Symbol, lhs::Atom, rhs::Atom; wrt=:x) = D2Expr(
#   op,
#   diffsym(lhs; wrt),
#   diffsym(rhs; wrt)
# )

function divrule(op::Symbol, lhs::D2Expr, rhs::D2Expr; wrt=:x)::D2Expr
  # TODO...
end

## simplification rules

function simplify(dexpr::D2Expr; _wrt=:x)::Union{D2Expr, Atom}
  if dexpr.op == :+
    simplify_add(dexpr.lhs, dexpr.rhs)
  elseif dexpr.op == :-
    simplify_sub(dexpr.lhs, dexpr.rhs)
  end
end

simplify(sym::Atom; wrt=:x)::Atom = sym

simplify_add(lhs::D2Expr, rhs::D2Expr; wrt=:x) = D2Expr(:+, simplify(lhs; wrt), simplify(rhs; wrt))

function simplify_add(lhs::Atom, rhs::D2Expr; wrt=:x)
  if  isinteger(lhs.value) && iszero(lhs.value)
    rhs
  else
    D2Expr(:+, simplify(lhs; wrt), simplify(rhs; wrt))
  end
end

function simplify_add(lhs::D2Expr, rhs::Atom; wrt=:x)
  if isinteger(rhs.value) && iszero(rhs.value)
    lhs
  else
    D2Expr(:+, simplify(lhs; wrt), simplify(rhs; wrt))
  end
end

function simplify_add(lhs::Atom, rhs::Atom; wrt=:x)::Union{D2Expr, Atom}
  if isinteger(lhs.value) && isinteger(rhs.value)
    Atom(lhs.value + rhs.value)
  elseif isinteger(lhs.value) && iszero(lhs.value)
    rhs
  elseif isinteger(rhs.value) && iszero(rhs.value)
    lhs
  else
    D2Expr(:+, lhs, rhs)
  end
end

simplify_sub(lhs::D2Expr, rhs::D2Expr; wrt=:x) = D2Expr(:-, simplify(lhs; wrt), simplify(rhs; wrt))

function simplify_sub(lhs::Atom, rhs::D2Expr; wrt=:x)
  # TODO...
end

function simplify_sub(lhs::D2Expr, rhs::Atom; wrt=:x)
  # TODO...
end

function simplify_sub(lhs::Atom, rhs::Atom; wrt=:x)
  if isinteger(lhs.value) && isinteger(rhs.value)
    Atom(lhs.value - rhs.value)
  elseif isinteger(lhs.value) && iszero(lhs.value)
    rhs
  elseif isinteger(rhs.value) && iszero(rhs.value)
    lhs
  else
    D2Expr(:-, lhs, rhs)
  end
end

# TODO: same for sub
