import Base: ==

const SUM_OPS = [:+, :-]
const MUL_OPS = [:*, :/]
const OPS = [SUM_OPS..., MUL_OPS..., :^]
const FNS = [:cos, :sin, :tan, :e, :exp, :ln]
const UNARY_OPS_FNS = [:-, FNS...]
const ALL_OPS = [OPS..., FNS...]

# At the moment we only deal with integer, later we will introduce decimal, real...
const DExpr = Union{Integer, Symbol}

const DEBUG = false

struct Atom
  value::DExpr
  wrt::Symbol

  Atom(s::DExpr; wrt=:x) = new(s, wrt)
end

Atom(::Any) = throw(ArgumentError("For now Atom are either Symbol or Integer"))

Base.show(io::IO, atom::Atom) = print(io, atom.value)
Base.length(::Atom) = 1

struct D2Expr
  op::Symbol
  lhs::Union{D2Expr, Atom}
  rhs::Union{D2Expr, Atom, Nothing}
  wrt::Symbol

  function D2Expr(op::Symbol, lhs::T1, rhs::T2; wrt=:x) where {T1 <: Union{D2Expr, Atom}, T2 <: Union{D2Expr, Atom, Nothing}}
    @assert Symbol(op) ∈ ALL_OPS
    new(op, lhs, rhs, wrt)
  end

  function D2Expr(op::Symbol, lhs::Atom, rhs::Atom; wrt=:x, dosimplify=true)
    @assert Symbol(op) ∈ ALL_OPS
    if dosimplify
      new(op, lhs, rhs, wrt) |> e -> simplify(e)
    else
      new(op, lhs, rhs, wrt)
    end
  end
end

function D2Expr(op::Symbol, lhs::D2Expr; wrt=:x)
  if op ∈ UNARY_OPS_FNS
    D2Expr(op, lhs, nothing; wrt)
  elseif op ∈ OPS # binary ops with only one operand => just return the operand
    lhs
  else
    throw(ArgumentError("bad expression: $(op) $(lhs)"))
  end
end

function D2Expr(op::Symbol, lhs::Atom; wrt=:x)
  if op == :+
    lhs
  elseif op == :-
    Atom(-lhs.value)
  elseif op ∈ UNARY_OPS_FNS
    D2Expr(op, lhs, nothing; wrt)
  elseif op ∈ OPS # binary ops with only one operand => just return the operand
    lhs
  else
    throw(ArgumentError("bad expression/666: $(op) $(lhs)"))
  end
end

## recursive
Base.show(io::IO, expr::D2Expr) =
  expr.rhs === nothing ? print(io, "($(expr.op) ", expr.lhs, ")") : print(io, "($(expr.op) ", expr.lhs, " ", expr.rhs, ")")

oper(dexpr::D2Expr) = dexpr.op
lhs(dexpr::D2Expr) = dexpr.lhs
rhs(dexpr::D2Expr) = dexpr.rhs
Base.length(dexpr::D2Expr) = dexpr.rhs === nothing ? 2 : 3

==(dexpr₁::D2Expr, dexpr₂::D2Expr) = dexpr₁.op == dexpr₂.op && dexpr₁.lhs == dexpr₂.lhs && dexpr₁.rhs == dexpr₂.rhs



# 1. turn expr into a DExpr => parser / tokenizer, where each token is a DExpr
# 2. differentiate and simplify
# 3. stringify back

function differentiate(expr::String; wrt=:x)::Union{D2Expr, Atom}
  dexpr = parser(expr; wrt)
  # println("______________ $(expr) was parsed as $(dexpr) | dexpr.wrt: $(dexpr.wrt)")

  expr = diff_on_op(dexpr)
  # println("______________ (simplify ∘ diff)($(dexpr)) => $(expr)")

  expr
end

differentiate(dexpr::D2Expr)::Union{D2Expr, Atom} = diff_on_op(dexpr)

differentiate(expr::Atom)::Atom = diffsym(expr)


function parser(expr::String; wrt=:x)::Union{D2Expr, Atom}
  reset_state()::Tuple = ("", 1, nothing)

  opstack, argstack = Symbol[], Union{D2Expr, Atom, Nothing}[]
  token, sign, pstate = reset_state()

  ## Inner helper function
  function build_expr!() # closure
    op = pop!(opstack)

    if op ∈ OPS # binary case
      rhs, lhs = pop!(argstack), pop!(argstack)
      push!(argstack, D2Expr(op, lhs, rhs; wrt))
      return
    end

    if op ∈ UNARY_OPS_FNS # unary case
      lhs = pop!(argstack)
      push!(argstack, D2Expr(op, lhs; wrt))
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
      sign == -1 ? push!(argstack, D2Expr(:*, Atom(-1; wrt), Atom(symb; wrt); wrt)) : push!(argstack, Atom(symb; wrt))
    end
  end

  ## main parser loop
  for (ix, ch) ∈ expr |> enumerate
    if pstate == :symbol && (isspace(ch) || ch == '(' || ch == ')')
      proc_symbol(token |> Symbol)
      token, sign, pstate = reset_state()
      ch == ')' && build_expr!()

    elseif pstate == :number && (isspace(ch) || ch == ')')
      push!(argstack, Atom(parse(Int, token) * sign; wrt))
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
      return Atom(token |> Symbol; wrt)
    elseif pstate == :number
      return Atom(parse(Int, token); wrt)
    else
      throw(ArgumentError("invalid expression: unknown state $(pstate)"))
    end
  end

  pop!(argstack)
end

diff_on_op(dexpr::D2Expr) = isnothing(dexpr.rhs) ? (simplify ∘ DIFF_FN[dexpr.op])(dexpr.lhs) :
  (simplify ∘ DIFF_FN[dexpr.op])(dexpr.lhs, dexpr.rhs)

diff_on_op(sym::Atom) = diffsym(sym)

## derivative rules
# for (key, op) ∈ [(:diff_sub, :-), (:diff_sum, :+)]
#   @eval begin
#     ($(key))(lhs::Union{D2Expr, Atom}, rhs::Union{D2Expr, Atom}; wrt=:x) = D2Expr(
#       Symbol($(op)),
#       (simplify ∘ differentiate)(lhs),
#       (simplify ∘ differentiate)(rhs)
#     )
#   end
# end

# d(u + v)/dx = du/dx + dv/dx
diff_sum(lhs::Union{D2Expr, Atom}, rhs::Union{D2Expr, Atom}) = D2Expr(
  :+,
  (simplify ∘ differentiate)(lhs),
  (simplify ∘ differentiate)(rhs)
)

# d(u - v)/dx = du/dx - dv/dx
function diff_sub(lhs::Union{D2Expr, Atom}, rhs::Union{D2Expr, Atom})
  s_lhs = (simplify ∘ differentiate)(lhs)
  s_rhs = (simplify ∘ differentiate)(rhs)

  if s_lhs === nothing
    D2Expr(:*,
           Atom(-1),
           s_rhs)
  elseif s_rhs === nothing
    s_lhs
  else
    D2Expr(
      :-,
      (simplify ∘ differentiate)(lhs),
      (simplify ∘ differentiate)(rhs)
    )
  end
end

# duv/dx = du/dx ⨱ v + dv/dx ⨱ u
diff_mul(lhs::Union{D2Expr, Atom}, rhs::Union{D2Expr, Atom}) = D2Expr(
    :+,
    D2Expr(:*,
           (simplify ∘ differentiate)(lhs),
           rhs),
    D2Expr(:*,
           lhs,
           (simplify ∘ differentiate)(rhs))
)

# (du/dx)/(dv/dx) = (du/dx ⨱ v - dv/dx ⨱ u) / v^2
diff_div(lhs::Union{D2Expr, Atom}, rhs::Union{D2Expr, Atom}) = D2Expr(
  :/,
  D2Expr(
    :-,
    D2Expr(
      :*,
      (simplify ∘ differentiate)(lhs),
      rhs;
      wrt=lhs.wrt
    ) |> simplify,
    D2Expr(
      :*,
      lhs,
      (simplify ∘ differentiate)(rhs);
      wrt=rhs.wrt
    ) |> simplify;
    wrt=lhs.wrt
  ) |> simplify,
  D2Expr(
    :^,
    rhs,
    Atom(2);
    wrt=rhs.wrt
  ); # "(* 3 (^ x 2))"
  wrt=lhs.wrt
)

# dx^p/dx = p ⨱ x^(p - 1) / du^p/dx = p ⨱ u^(p-1) ⨱ du/dx
diff_pow(lhs::Union{D2Expr, Atom}, rhs::Atom) = D2Expr(
  :*,
  D2Expr(
    :*,
    rhs,
    D2Expr(
      :^,
      lhs,
      D2Expr(:-, rhs, Atom(1); wrt=lhs.wrt) |> simplify; # D2Expr(:-, rhs, 1; wrt=lhs.wrt)
      wrt=lhs.wrt
    );
    wrt=rhs.wrt
  ),
  diff_on_op(lhs);
  wrt=lhs.wrt
)

# d cos(u(x))/dx = -sin(u(x)) ⨱ du/dx
diff_cos(lhs::Union{D2Expr, Atom}) = D2Expr(
  :*,
  D2Expr(
    :*,
    Atom(-1),
    D2Expr(
      :sin,
      lhs;
      wrt=lhs.wrt
    );
    wrt=lhs.wrt
  ),
  (simplify ∘ differentiate)(lhs);
  wrt=lhs.wrt
)

# d sin(u(x))/dx = cos(u(x)) ⨱ du/dx
diff_sin(lhs::Union{D2Expr, Atom}) = D2Expr(
  :*,
  D2Expr(
    :cos,
    lhs;
    wrt=lhs.wrt
  ),
  (simplify ∘ differentiate)(lhs);
  wrt=lhs.wrt
)

diffsym(sym::Atom) = sym.value == sym.wrt ? Atom(1) : Atom(0)

const DIFF_FN = Dict{Symbol, Function}(
  :+ => diff_sum,
  :- => diff_sub,
  :* => diff_mul,
  :/ => diff_div,
  :^ => diff_pow,
  :cos => diff_cos,
  :sin => diff_sin,
)

## simplification rules

function simplify(dexpr::D2Expr)::Union{D2Expr, Atom}
  r = SIMPLIFY_FN[dexpr.op](dexpr.lhs, dexpr.rhs)
  isnothing(r) ? dexpr : r
end

simplify(sym::Atom)::Atom = sym

simplify_add(lhs::D2Expr, rhs::D2Expr) = D2Expr(:+, simplify(lhs), simplify(rhs); wrt=lhs.wrt)

function simplify_add(lhs::Atom, rhs::D2Expr)
  if isinteger(lhs.value) && iszero(lhs.value)
    rhs
  else
    D2Expr(:+, lhs, simplify(rhs); wrt=lhs.wrt)
  end
end

function simplify_add(lhs::D2Expr, rhs::Atom)
  if isinteger(rhs.value) && iszero(rhs.value)
    lhs
  else
    D2Expr(:+, simplify(lhs), rhs; wrt=lhs.wrt)
  end
end

function simplify_add(lhs::Atom, rhs::Atom)::Union{D2Expr, Atom, Nothing}
  if isnumber(lhs) && isnumber(rhs)
    Atom(lhs.value + rhs.value)
  elseif isnumber(lhs) && iszero(lhs.value)
    rhs
  elseif isnumber(rhs) && iszero(rhs.value)
    lhs
  else
    nothing
  end
end

function simplify_sub(lhs::D2Expr, rhs::D2Expr)
  s_lhs, s_rhs = simplify(lhs), simplify(rhs)
  if s_lhs === nothing
    D2Expr(:*, Atom(-1), s_rhs)
  elseif s_rhs === nothing
    s_lhs
  elseif s_lhs != lhs || s_rhs != rhs
    D2Expr(:-, s_lhs, s_rhs; wrt=lhs.wrt)
  else
    nothing
  end
end

function simplify_sub(lhs::Atom, rhs::D2Expr)
  if isinteger(lhs.value) && iszero(lhs.value)
    D2Expr(:*, Atom(-1), simplify(rhs); wrt=rhs.wrt)
  else
    s_rhs = simplify(rhs)
    if s_rhs === nothing
      lhs
    else
      D2Expr(:-, lhs, s_rhs; wrt=lhs.wrt)
    end
  end
end

function simplify_sub(lhs::D2Expr, rhs::Atom)
  if isinteger(rhs.value) && iszero(rhs.value)
    lhs
  else
    s_lhs = simplify(lhs)
    if s_lhs === nothing
      D2Expr(:*, Atom(-1), lhs; wrt=lhs.wrt)
    elseif s_lhs != lhs
      D2Expr(:-, s_lhs, rhs; wrt=rhs.wrt)
    else
      nothing
    end
  end
end

function simplify_sub(lhs::Atom, rhs::Atom)
  if isnumber(lhs) && isnumber(rhs)
    Atom(lhs.value - rhs.value)
  elseif isnumber(lhs) && iszero(lhs.value)
    D2Expr(:*, Atom(-1), simplify(rhs); wrt=rhs.wrt)
  elseif isnumber(rhs) && iszero(rhs.value)
    lhs
  else
    nothing
  end
end

simplify_mul(lhs::D2Expr, rhs::D2Expr) = D2Expr(:*, simplify(lhs), simplify(rhs); wrt=lhs.wrt)

function simplify_mul(lhs::Atom, rhs::D2Expr)
  if isnumber(lhs)
    if iszero(lhs.value)
      Atom(0)
    elseif isone(lhs.value)
      rhs
    end
  else
    D2Expr(:*, lhs, simplify(rhs); wrt=lhs.wrt)
  end
end

function simplify_mul(lhs::D2Expr, rhs::Atom)
  if isnumber(rhs)
    if iszero(rhs.value)
      Atom(0)
    elseif isone(rhs.value)
      lhs
    end
  else
    D2Expr(:*, simplify(lhs), rhs; wrt=lhs.wrt)
  end
end

function simplify_mul(lhs::Atom, rhs::Atom)
  if isnumber(lhs) && isnumber(rhs)
    Atom(lhs.value * rhs.value)
  elseif isnumber(rhs)
     if iszero(rhs.value)
      Atom(0)
    elseif isone(rhs.value)
       lhs
     #elseif isone(-1 * rhs.value) && isnumber(rhs)
     #  Atom(-1 * lhs.value)
     end
  elseif isnumber(lhs)
     if iszero(lhs.value)
      Atom(0)
    elseif isone(lhs.value)
       rhs
     #elseif isone(-1 * lhs.value) && isnumber(rhs)
     #  Atom(-1 * rhs.value)
    end
  else
    nothing
  end
end

simplify_div(lhs::D2Expr, rhs::D2Expr) = D2Expr(:/, simplify(lhs), simplify(rhs); wrt=lhs.wrt)

function simplify_div(lhs::Atom, rhs::D2Expr)
  # = nothing
  if isnumber(lhs) && iszero(lhs.value)
    Atom(0)
  else
    D2Expr(:/, lhs, simplify(rhs); wrt=lhs.wrt)
  end
end

function simplify_div(lhs::D2Expr, rhs::Atom)
  if isnumber(rhs)
    if iszero(rhs.value)
      throw(DivideError())
    elseif isone(rhs.value)
      lhs
    end
  else
    D2Expr(:/, simplify(lhs), rhs; wrt=lhs.wrt)
  end
end

function simplify_div(lhs::Atom, rhs::Atom)
  if isnumber(lhs) && isnumber(rhs)
    iszero(rhs.value) && throw(DivideError())
    #
    # reduce to same denominator
    n = gcd(lhs.value, rhs.value)
    l, r = lhs.value ÷ n, rhs.value ÷ n
    isone(r) && return Atom(l)
    D2Expr(:/, Atom(l), Atom(r); wrt=lhs.wrt, dosimplify=false)
    #
  elseif isnumber(rhs) && iszero(rhs.value)
    throw(DivideError())
    #
  elseif isnumber(lhs) && iszero(lhs.value)
    Atom(0)
  else
    nothing
  end
end

simplify_pow(lhs::D2Expr, rhs::D2Expr) = nothing
simplify_pow(lhs::Atom, rhs::D2Expr) = nothing
simplify_pow(lhs::D2Expr, rhs::Atom) = nothing

function simplify_pow(lhs::Atom, rhs::Atom)
  if isnumber(lhs) && isnumber(rhs)
    # 0^0 undefined
    iszero(lhs.value) && iszero(rhs.value) && throw(ArgumentError("Undefined form 0^0"))
    Atom(lhs.value ^ rhs.value)
  elseif isnumber(rhs)
    if iszero(rhs.value)
      Atom(0)
    elseif isone(rhs.value)
      lhs
    end
  else
    nothing
  end
end


# names(Main) => list all symbol under Main

const SIMPLIFY_FN = Dict{Symbol, Function}(
  :+ => simplify_add,
  :- => simplify_sub,
  :* => simplify_mul,
  :/ => simplify_div,
  :^ => simplify_pow,
  # ...
)

isnumber(atom::Atom)::Bool = match(r"\A-?\d+\z", string(atom)) !== nothing

"""
  Calculate gcd(n, d)
"""
function gcd(n::Integer, d::Integer)::Integer
  n, d = n < d ? (d, n) : (n, d)
  iszero(d) && return n
  r = n
  while r > 1
    r = n % d
    n, d = d, r
  end
  iszero(r) ? n : r
end
