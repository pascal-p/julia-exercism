# deps on src/karger_mincut.jj

function runner(gr; n=100, seed=42)
  res = Dict{Integer, Real}()

  for ix in 1:n
    seed += 3
    c_gr = copy(gr)           ## make copy of graph

    mc = mincut!(c_gr; seed)  ## run mincut and record results
    res[mc] = mc ∈ keys(res) ? res[mc] + 1. : 1.
  end

  for k ∈ keys(res); res[k] /= Real(n); end

  return (min(keys(res)...), res)
end
