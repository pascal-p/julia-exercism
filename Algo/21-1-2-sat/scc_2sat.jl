"""
  2SAT problem using SCC (in digraph)

  SAT (Boolean SAT-isfiability problem) is the problem of assigning Boolean values to variables to satisfy a given
  Boolean formula (usually given as disjunction of CNF[Conjunctive Normal Form])

  2-SAT (where CNF are biary, hence the 2) is a restriction of the SAT problem,
  2-SAT can be solved in polynomial time (O(n + m), where n is the number of vars and m isthe number of clauses) whereas the
  general problem from canonical 3-SAT is NP-complete (cf. Cook–Levin theorem [https://en.wikipedia.org/wiki/Cook%E2%80%93Levin_theorem])

  In this implementation, we convert CNF into a digraph of implication normal form. Remenber:
  x v y ≡ ¬ x → y ^ ¬ y → x

  Thus when constructing the graph, we will, for each var., add 2 vertices vₓ and -vₓ. An edge will correspong to one implication

  Next, note that if x is reachable from ¬ x and ¬ x is reachable from x, then the problem has no solution, since any value (T or F)
  will result in a contradiction
  Now, in a (di)graph if a vertex is reachable from another vertex it means that both are in the same SCC (Strongly Connected Component)

  Thus Solving the 2SAT problem can be reduced to compute the SCC (using kosaraju's Alg, cf. 06-digraph-scc ) on the digraph (of implication
  normal form)

  Finally, we check that if x and ¬x are in the same SCC, the input cannot be satisfied, otherwise there is at least 1 possible
  assignment for the (input) vars. Such an assignment can be computed by noticing that if scc[x] < scc[¬x] then x is F(alse) and
  T(rue) otherwise (¬x is reachable from x xor x is reachable from ¬x in the constrcuted digraph - not simultaneously)

"""

push!(LOAD_PATH, "../06-digraph-scc/src")
push!(LOAD_PATH, "../11-queue/src")         ## for YAQ

using YAG_SCC


function solve_2sat(infile::String, DT::DataType)
  g = load_data(infile, DT)

  (scc_g, _) = calc_scc(g)

  assign::Vector{Bool} = fill(false, v(g) ÷ 2)
  n = DT(v(g) ÷ 2)
  for ix ∈ one(DT):n
    id(scc_g, ix) == id(scc_g, ix + n)  && (return (false, nothing))

    assign[ix] = id(scc_g, ix) < id(scc_g, ix + n)
  end

  return (true, assign)
end

function calc_scc(g::DiGraph{T}) where T
  scc_g = SCC{T}(g)
  return (scc_g, g)
end

function load_data(infile::String, DT::DataType)
  local g, n, m

  open(infile, "r") do fh
    for line in eachline(fh)  ## read only first line
      a = split(line, r"\s+")
      if length(a) > 1
        n, m = map(x -> parse(Int, strip(x)), a)
      else
        n = parse(Int, strip(a[1]))
        m = nothing
      end
      break
    end

    g = DiGraph{DT}(2n)

    ## read: edge by edge
    for line in eachline(fh)
      u, v = map(x -> parse(DT, strip(x)), split(line))
      add_edge_to_graph(g, u, v)
    end
  end

  @assert v(g) == 2n "Expected number of vertices to be $(2n), got: $(v(g))"
  if m != nothing
    # FIXME
    @assert e(g) == 2m "Expected number of edges to be $(2m), got: $(e(g))"
  end

  return g
end


function add_edge_to_graph(g::DiGraph{T}, u₀::T, u₁::T) where T
  n = T(v(g) ÷ 2)

  if u₀ > 0 && u₁ > 0            ## ≡ u₀ v u₁
    add_edge(g, u₀ + n, u₁)      ## ≡ ¬u₀ → u₁
    add_edge(g, u₁ + n, u₀)      ## ≡ ¬u₁ → u₀
    # println(">1> u₀:$(u₀), u₁:$(u₁) - edge: $(u₀ + n) →  $(u₁) / edge: $(u₁ + n) → $(u₀)")

  elseif u₀ < 0 && u₁ > 0        ## ¬u₀ v u₁
    add_edge(g, -u₀, u₁)         ## ≡ u₀ → u₁
    add_edge(g, u₁ + n, -u₀ + n) ## ≡ ¬u₁ → ¬u₀
    # println(">2> u₀:$(u₀), u₁:$(u₁) - edge: $(-u₀) →  $(u₁) / edge: $(u₁ + n) → $(-u₀ + n)")

  elseif u₀ < 0 && u₁ < 0        ## ¬u₀ v ¬u₁
    add_edge(g, -u₀, -u₁ + n)    ## ≡ u₀ → ¬u₁
    add_edge(g, -u₁, -u₀ + n)    ## ≡ u₁ → ¬u₀
    # println(">3> u₀:$(u₀), u₁:$(u₁) - edge: $(-u₀) →  $(-u₁ + n) / edge: $(-u₁) → $(-u₀ + n)")

  else   ## u₀ ≥ 0 && u₁ ≤ 0     ## ≡ u₀ v ¬u₁
    add_edge(g, u₀ + n, -u₁ + n) ## ≡ ¬u₀ → ¬u₁
    add_edge(g, -u₁, u₀)         ## ≡ u₁ → u₀
    # println(">4> u₀:$(u₀), u₁:$(u₁) - edge: $(u₀ + n) →  $(-u₁ + n) / edge: $(-u₁) → $(u₀)")

  end
end
