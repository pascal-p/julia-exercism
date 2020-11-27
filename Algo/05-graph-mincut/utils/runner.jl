# deps on src/karger_mincut.jj

function runner(gr; n=100)
  res = Dict{Integer, Real}()

  # min_mc = 1_000_000
  for ix in 1:n
    c_gr = copy(gr)
    mc = mincut!(c_gr)

    # mc <  min_mc && (min_mc = mc)
    # println("iter: $(ix), mincut:: $(mc) / min(mincut): $(min_mc)")
    res[mc] = mc ∈ keys(res) ? res[mc] + 1. : 1.
  end

  for k ∈ keys(res)
    res[k] /= Real(n)
  end

  return (min(keys(res)...), res)
end

#
# julia runtests-challenge.jl | tee -a out1.txt
# julia runtests-challenge.jl | tee -a out2.txt
#
