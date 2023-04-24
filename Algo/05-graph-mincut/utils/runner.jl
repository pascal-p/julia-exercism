# deps on src/karger_mincut.jl

"""
   runner(gr; n=100, seed=42)

gr: undirected graph
n: number of times we want to run the mincut algorithm
seed: the initial seed
"""
function runner(gr; n=100, seed=42)
  res = Dict{Integer, Real}() # to memorize the result from each run

  for _ ∈ 1:n
    seed += 5                      ## shift the seed
    c_gr = copy(gr)                ## make copy of (undirected) graph

    mc = mincut!(c_gr; seed=seed)  ## run mincut and record results in mc
    res[mc] = mc ∈ keys(res) ? res[mc] + 1 : 1
  end

  for k ∈ keys(res); res[k] /= Real(n); end

  (min(keys(res)...), res)
end
