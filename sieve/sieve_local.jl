using Random

function sieve_v1(limit)
  limit <= 1 && (return [])
  limit == 2 && (return [2])

  ary = collect(1:2:limit)
  ary[1] = 2     # replace, first prime is 2

  ix = 2
  elem = ary[ix] # first prime after 2, 3

  while elem < √ limit
    # mark / delete all multiples
    for y in 2*elem:elem:limit
      y % 2 == 0 && continue

      jx = findfirst(isequal(y), ary)
      jx !== nothing && deleteat!(ary, jx)
      # deleteat!(ary, findall(x -> x == y, ary))
    end
    ix += 1 # next
    elem = ary[ix]
  end

  ary
end

function sieve_v2(limit)
  limit <= 1 && (return [])
  limit == 2 && (return [2])

  ary = fill(true, limit)
  ary[1] = false   ## exclude 1
  cand, ix = 2, 3  ## start with 2, and prep. for next candidate
  rlimit = convert(Int, ceil(√limit))

  while cand < rlimit
    for jx in 2*cand:cand:limit
      ary[jx] = false
    end

    while !ary[ix]; ix += 1; end
    cand = ix
    ix += 1
  end

  ## build actual array
  [ix for ix in 2:limit if ary[ix]]
end

function sieve_v3_off(limit)
  limit <= 1 && (return [])
  limit == 2 && (return [2])

  ary = fill(true, limit)
  ary[1] = false   ## exclude 1
  cand, ix = 2, 3  ## start with 2, and prep. for next candidate
  rlimit = convert(Int, ceil(√limit))

  while cand < rlimit
    for jx in 2*cand:cand:limit
      ary[jx] = false
    end

    while !ary[ix]; ix += 1; end
    cand = ix
    ix += 1
  end

  num_cand = sum(ary)

  ## build actual array, pre-allocate array
  n_ary, jx = Array{Int,1}(undef, num_cand), 1

  for ix in 2:limit
    if ary[ix]
      n_ary[jx] = ix
      jx +=1
    end
  end
  n_ary
end

function sieve_v3(limit)
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

  num_cand = sum(ary)

  ## build actual array, first pre-allocate array
  n_ary, jx = Array{Int,1}(undef, num_cand), 1

  #
  for ix in 2:limit
    ary[ix] && (n_ary[jx] = ix; jx +=1)
  end

  n_ary
end

function run_sieve(n)
  println("Timing sieve for all prime ≤ $(n)")
  # @time r1 = sieve_v1(n)

  if rand([0, 1], 1) == 0
    @time r2 = sieve_v2(n)
    @time r3 = sieve_v3(n)
  else
    @time r3 = sieve_v3(n)
    @time r2 = sieve_v2(n)
  end

  # @assert r1 == r2
  @assert r2 == r3
  println()
end

run_sieve(20)
run_sieve(1_000)
run_sieve(10_000)
run_sieve(10_000_000)
run_sieve(100_000)
run_sieve(500_000)
run_sieve(1_000_000)
run_sieve(100_000_000)
run_sieve(500_000_000)
