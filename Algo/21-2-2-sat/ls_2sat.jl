"""
  2SAT problem using Papadimitriou’s 2-SAT Algorithm

  Repeat log₂(n) times:
    - Choose random initial assignment
    - Repeat 2n² times:
        - If current assignment satisfies all clauses, halt + report this
        - Else, pick arbitrary unsatisfied clause and flip the value of one of its variables
          [choose between the two uniformly at random]

  Report “unsatisfiable”

  In practice, to accelerate,  the execution time we pre-proces the clauses by performing  a
  reduction.
"""

using Random

const BN = Union{Nothing, Bool}

mutable struct Clause
  x::Integer
  y::Integer
  r::BN

  Clause(x, y) = new(x, y, nothing)
end

cl_vars(cl::Clause) = (cl.x, cl.y)

function cl_eval!(cl::Clause, hvars::Dict{T, BN}) where T <: Integer
  v_x = haskey(hvars, cl.x) ? hvars[cl.x] : !hvars[-cl.x]
  v_y = haskey(hvars, cl.y) ? hvars[cl.y] : !hvars[-cl.y]
  cl.r = v_x | v_y   ## using | instead of || to avoid shortcut boolean evaluation
end

## =========================================================================

function solve_2sat(infile::String, DT::DataType)
  hsh, n = load_data(infile, DT)
  @assert n > 0 "Expected n to be positify, got: $(n)"

  nᵣ = reduction!(hsh, DT)
  nᵣ == 0 && return ((true, nothing), )

  clauses, hvars = prep_clauses_vars(hsh, DT)
  (lsearch(clauses, hvars, nᵣ), clauses)
end

function lsearch(clauses::Vector{Clause}, hvars::Dict{T, BN}, n::T) where T <: Integer
  ix, ilim = 1, floor(T, log(n) / log(2))
  hvc = map_vars_clause_ix(hvars, clauses)

  jlim = Int64(n) * Int64(n) << 1
  @assert jlim > 0 "Expected positive value, got: $(jlim) / n: $(n) / $(typeof(n))"

  while ix ≤ ilim
    ix += 1
    jx = one(Int64)
    ix > 2 && random_assign!(hvars)

    while jx ≤ jlim
      jx += 1
      f_eval(clauses, hvars) && return (true, hvars)

      f_clauses = filter(cl -> !cl.r, clauses)
      r  = rand(1:3)
      if r == 1
        try_assign!(hvars, clauses, f_clauses, hvc)
      else
        kx = rand(1:length(f_clauses))
        (x, y) = cl_vars(f_clauses[kx])
        r == 2 ? flip(hvars, y) : flip(hvars, x)
      end
    end
  end

  (false, hvars)
end

function load_data(infile::String, DT::DataType)
  local n
  hsh = Dict{Integer, Vector{Integer}}()
  open(infile, "r") do fh
    for line in eachline(fh)  ## read only first line
      a = split(line, r"\s+")
      n = parse(DT, strip(a[1]))
      break
    end

    for line in eachline(fh)
      u, v = map(x -> parse(DT, strip(x)), split(line))
      u == -v && continue  ## pass tautology

      ## Record  x ∨ y and (symmetric) y ∨ x in other to ease the reduction phase
      for (x, y) in [(u, v), (v, u)]
        if haskey(hsh, x)
          y ∉ hsh[x] && push!(hsh[x], y)
        else
          hsh[x] = [y]
        end
      end
    end
  end
  (hsh, n)
end

function f_eval(clauses::Vector{Clause}, hvars::Dict{T, BN}) where T <: Integer
  foldl((r, cl) -> r & cl_eval!(cl, hvars), clauses; init=true)
  ## using & instead of && to avoid shortcut boolean evaluation
end

"""
  Reduction:

  Clauses for which variables appear only in one form (either positive or negative) can
  be eliminated - because these can be satistied by setting positive form var to True
  (resp. negative form to False) w/o impacting other clauses

"""
function reduction!(hsh::Dict{Integer, Vector{Integer}}, DT::DataType)
  while true
    dkeys = [k for k ∈ keys(hsh) if -k ∉ keys(hsh)]
    length(dkeys) == 0 && break

    ## eliminate all clauses which contains k (in only one form: >0 xor <0)
    akeys = Vector{DT}()            ## keys for which there is no longer any values

    for k ∈ dkeys
      for kv ∈ hsh[k]
        ! haskey(hsh, kv) && continue
        deleteat!(hsh[kv], findfirst(x -> x == k, hsh[kv]))
        length(hsh[kv]) == 0 && push!(akeys, kv)
      end
    end

    for k ∈ dkeys; delete!(hsh, k); end
    for k ∈ akeys; delete!(hsh, k); end
  end
  rm_symetrical!(hsh, DT)           ## to finish let's remove the symmetry

  n = length(hsh)
  @assert n ≥ 0 "Expecting n to be ≥ 0 - overflow with Int64?"
  nᵣ = DT(n)      ## DT can be Int32
  @assert Int(nᵣ) == n "Expecting nᵣ to be the same as n - Overflow?"
  nᵣ
end

function rm_symetrical!(hsh::Dict{Integer, Vector{Integer}},  DT::DataType)
  dkeys, done = Vector{DT}(), Vector{DT}()

  for k ∈ keys(hsh)
    k ∈ done && continue

    for kv in hsh[k]
      kv == k && continue
      ix = findfirst(x -> x == k, hsh[kv])
      if ix != nothing
        deleteat!(hsh[kv], ix)
        length(hsh[kv]) == 0 && push!(dkeys, kv)
      end
      push!(done, kv)
    end
  end

  if length(dkeys) > 0 && length(hsh) > 0
    for k ∈ dkeys; delete!(hsh, k); end
  end
end

function prep_clauses_vars(hsh::Dict{Integer, Vector{Integer}}, DT::DataType)
  akeys, n = Vector{DT}(), 0

  for (k, vs) ∈ hsh
    push!(akeys, k)
    push!(akeys, vs...)
    n += length(vs)
  end

  clauses, hvars = Vector{Clause}(undef, n), Dict{DT, BN}()
  det_assign!(hvars, akeys)
  ix = 1
  for u ∈ keys(hsh), v in hsh[u]
    clauses[ix] = Clause(u, v)
    ix += 1
  end

  (clauses, hvars)
end

# Deterministic assign.
function det_assign!(hvars::Dict{T, BN}, akeys::Vector{T}) where T
  for k ∈ unique(akeys)
    if -k ∉ keys(hvars)
      hvars[k] = k > 0
    end
  end

end

function random_assign!(hvars::Dict{T, BN}) where T
  for (ix, k) in enumerate(keys(hvars))
    hvars[k] = ix % 2 == 0 ? rand(1:2) == 1 : !hvars[k]
  end
end

"""
  An attempt at avoiding random flip...

  Observe the consequnce of flipping a var (with the other clauses that var. appears in)
  Becasue of the reduction (pre-step) every var appears at least twice (at least once in
  its positive form and at least once in its negative form)
"""
function try_assign!(hvars::Dict{T, BN}, clauses::Vector{Clause},
                     f_clauses::Vector{Clause}, hvc::Dict{T, Vector{T}}) where T

  for fcl ∈ f_clauses
    x, y = cl_vars(fcl)

    flip(hvars, x)
    try_setup!(hvars, clauses, hvc, fcl, x) && return
    flip(hvars, x)  # revert back

    flip(hvars, y)
    try_setup!(hvars, clauses, hvc, fcl, y) && return
    flip(hvars, y)  # revert back
  end

  ## did not work -> random assignment
  kx = rand(1:length(f_clauses))
  (x, y) = cl_vars(f_clauses[kx])
  rand(1:2) == 2 ? flip(hvars, y) : flip(hvars, x)
end

function try_setup!(hvars::Dict{T, BN}, clauses::Vector{Clause}, hvc::Dict{T, Vector{T}},
                    fcl::Clause, x::T) where T
  nx = abs(x) # nx =  haskey(hvc, x) ? x : -x

  for ix in hvc[nx]
    clauses[ix] == fcl && continue

    xcl = clauses[ix]
    cl_eval!(xcl, hvars)  ## try with nx flipped
    xcl.r && return true
  end

  false
end

function map_vars_clause_ix(hvars::Dict{T, BN}, clauses::Vector{Clause}) where T
  hvc = Dict{T, Vector{T}}()
  for (ix, cl) in enumerate(clauses)
    for vx ∈ cl_vars(cl)
      vx = abs(vx)
      haskey(hvc, vx) ? push!(hvc[vx], ix) : hvc[vx] = T[ix]
    end
  end
  hvc
end

function flip(hvars::Dict{T, BN}, x::T) where T
  if haskey(hvars, x)
    hvars[x] = !hvars[x]
  else
    ## -x ∈ keys(hvars)
    hvars[-x] = !hvars[-x]
  end
end
