function sieve(limit)
  limit <= 1 && (return [])
  limit == 2 && (return [2])

  ary = fill(true, limit)
  ary[1] = false   ## exclude 1
  cand, ix = 2, 3  ## start with 2, and prep. for next candidate

  ## upper limit for candidate prime (cand)
  rlimit = convert(Int, ceil(√limit))

  while cand ≤ rlimit
    for jx in 2*cand:cand:limit
      ary[jx] = false
    end

    while !ary[ix]; ix += 1; end
    cand = ix
    ix += 1
  end

  ## how many primes
  num_cand = sum(ary)

  ## build actual array, first pre-allocate array
  n_ary, jx = Array{Int,1}(undef, num_cand), 1

  ## then populate
  for ix in 2:limit
    ary[ix] && (n_ary[jx] = ix; jx += 1)
  end

  n_ary
end
