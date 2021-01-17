const OPS = [:+, :-]
const NVALUES = 10  # 0..9

struct Eq
  op::Symbol                              ## +
  lhs::Tuple{Vararg{Vector{Char}}}        ## tuple of length at least 2
  rhs::Vector{Char}                       ## ['M', 'O', 'N', 'E', 'Y']

  function Eq(op, lhs, rhs)
    @assert op ∈ OPS

    _lhs, _rhs, fn = if length(lhs) == 2
      (Tuple(reverse(collect(a)) for a ∈ lhs), reverse(collect(rhs)), push!)
    else
      (Tuple(collect(a) for a ∈ lhs), collect(rhs), pushfirst!)
    end

    m = max(map(l -> length(l), _lhs)..., length(_rhs))
    for ix ∈ 1:length(_lhs)
      length(_lhs[ix]) < m && fn(_lhs[ix], '_')
    end

    length(_rhs) < m && fn(_rhs, '_')
    new(op, _lhs, _rhs)
  end
end

struct Env
  assign::Dict{Char, Integer}            ## assignment / if a var == -1 it is NOT assigned # whether a var is assigned or not
  poss::Dict{Char, Vector{Integer}}      ## constraint on the possible values of a given variable

  function Env(a, p)
    @assert length(a) == length(p)
    new(a, p)
  end
end

function clear_assign!(env::Env)
  for var ∈ keys(env.assign)
    env.assign[var] = -1
  end
end

## Try:
##   ulimit -s unlimited
##   julia
##   include("cryptarithmetic_solver.jl")
##
##   expr = "==(+(SEND, MORE), MONEY)"  or expr = "==(+(GERALD, DONALD), ROBERT)"
##   (env, pb) = read_input(expr)
##   @time _f, sol = solve(env, pb)

fact(n::Integer)::Integer = foldl((p, k) -> p *= k, collect(2:n); init=1)

"""
ex. expr == "==(+(SEND, MORE), MONEY)"
"""
function read_input(expr::String)
  m = match(r"\A(==)\(([\+\-])\(([A-Z]+(?:,\s+[A-Z]+)+)\),\s+([A-Z]+)\)\z", expr)

  if m != nothing
    @assert Symbol(m[1]) == :(==) "Expecting to deal with equality only, for now"
    @assert Symbol(m[2]) ∈ OPS "Expecting op to be in: $(OPS), got $(m[2])"

    a = map(s -> strip(s), split(m[3], ", "))
    pb = Eq(Symbol(m[2]), (a...,), m[4])

    ## get all the variables
    assign = Dict{Char, Integer}()
    poss = Dict{Char, Vector{Integer}}()

    binary = length(pb.lhs) == 2
    for lhs in pb.lhs
      yafill!(lhs, assign, poss; binary=binary)
    end
    yafill!(pb.rhs, assign, poss; binary=binary)

    env = Env(assign, poss)
    return (env, pb)
  end

  throw(ArgumentError("Problem with input expression..."))
end

function solve(env::Env, pb::Eq)
  nb_perms = fact(NVALUES)
  kx, perms = 0, gen_perms()
  np = length(perms)
  len_env = length(env.assign)

  function next_perm()
    kx += 1
    return kx < np ? perms[kx] : nothing
  end

  function _solve(n, ntry, perm, taken)
    perm == nothing && return (false, nothing)

    if n == len_env                   ## All var. assigned
      check_sol(Val(pb.op), env, pb) && return (true, env.assign)

    else
      for ix ∈ perm
        ix ∈ taken && continue

        for var ∈ keys(env.assign)
          if env.assign[var] == -1 && ix ∈ env.poss[var]
            env.assign[var] = ix
            push!(taken, ix)
            return _solve(n + 1, ntry, perm, taken)

          elseif env.assign[var] == -1
            break                     ## we need to get another value of ix

          end                         ## already assign - nothing to do
        end
      end

    end

    ## assign did not work - try another one if possible
    ntry += 1
    ntry > nb_perms && return (false, nothing) ## no assignment found
    ## reset
    n, taken = 0, Int[]
    clear_assign!(env)

    return _solve(n, ntry, next_perm(), taken)
  end

  _solve(0, 0, next_perm(), [])
end


"""
  pb (== problem) eq(op(s1, s2), res)
"""
function check_sol(::Val{:+}, env::Env, pb::Eq)::Bool
  if length(pb.lhs) == 2
    # requires lhs, rhs in reverse order...
    pc, c = 0, 0

    for (x₁, x₂, r) ∈ zip(pb.lhs[1], pb.lhs[2], pb.rhs)
      vx₁, vx₂ = get(env.assign, x₁, 0), get(env.assign, x₂, 0)
      vr = get(env.assign, r, 0)
      c = pc + vx₁ + vx₂ ≥ 10 ? 1 : 0   ## set the carry
      pc + vx₁ + vx₂ != vr + 10c &&     ## must be equal
        return false
      pc = c == 1 ? 1 : 0               ## set previous carry for next iteration
    end

    return true
  end

  al = [
    parse(Int, join(map(x -> get(env.assign, x, 0), lhs), "")) for lhs ∈ pb.lhs
  ]
  return sum(al) == parse(Int, join(map(x -> get(env.assign, x, 0), pb.rhs), ""))
end

function check_sol(::Val{:-}, env::Env, pb::Eq)::Bool
  if length(pb.lhs) == 2
    # requires lhs, rhs in reverse order...
    pc, c = 0, 0

    for (x₁, x₂, r) ∈ zip(pb.lhs[1], pb.lhs[2], pb.rhs)
      vx₁, vx₂ = get(env.assign, x₁, 0), get(env.assign, x₂, 0)
      vr = get(env.assign, r, 0)

      c = pc + vx₂ > vx₁ ? 1 : 0        ## set the carry
      10c + vx₁ - (vx₂ + pc) != vr &&   ## must be equal
        return false
      pc = c == 1 ? 1 : 0               ## set previous carry for next iteration
    end

    return true
    #
  else
    throw(ErrorException("Not implemented yet..."))
    # TODO: implement n-ary substraction...
  end
end

function yafill!(arg, assign, poss; binary=false)
  if binary
    ix, n = 0, length(arg)
    arg[end] == '_' && (n -= 1)

    for v in arg
      ix += 1
      v == '_' && continue
      assign[v] = -1
      if ix == n
        poss[v] = collect(1:NVALUES - 1)
      else
        haskey(poss, v) || (poss[v] = collect(0:NVALUES - 1))
      end
    end

  else
    ix = 0

    for v in arg
      v == '_' && continue
      assign[v] = -1
      if ix == 0
        poss[v] = collect(1:NVALUES - 1)
      else
        haskey(poss, v) || (poss[v] = collect(0:NVALUES - 1))
      end
      ix += 1
    end
  end
end

"""
  gen_perms()

# Examples:
```julia
julia> gen_perms()
[(1, 2, 3), (1, 3, 2), (2, 1, 3), (2, 3, 1), (3, 2, 1), (3, 1, 2)]

```
"""
function gen_perms(;n=NVALUES)
  function _perms(s)
    length(s) == 1 && return [[s]]
    length(s) == 2 && return [s, reverse(s)]

    sr = []
    for e ∈ s
      sₑ = yadiff(s, e)
      ns = yacons(e, _perms(sₑ))
      push!(sr, ns...)
    end
    return sr
  end

  return _perms(collect(0:n - 1))
end

function yadiff(s, e)
  filter(x -> x != e, s)
end

function yacons(e, ss)
  for s in ss
    pushfirst!(s, e)
  end
  ss
end
