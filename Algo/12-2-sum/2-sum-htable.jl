push!(LOAD_PATH, "../11-htable/src")
push!(LOAD_PATH, "../11-sllist/src")

using YAHT
using YASLL

function two_sum(;n=1_000_000, keys=rand(-10_000_000_000:10_000_000_000, n), targets=-10_000:10_000,
                 distinct=true, keep=false)

  keys = prep(keys, targets)
  htab = HTable{Int, Int}(n ÷ 2)
  for x in keys; add!(htab, x); end

  core(htab, keys, -10_000:1_000:-1_000; distinct, keep) # overwite range on purpose
end

function two_sum(infile::String; targets=-10_000:10_000, distinct=true, keep=false)
  try
    keys = open(infile, "r") do fh
      [parse(Int, line) for line in eachline(fh)]
    end
    println("\t1- file loaded... - length(keys): $(length(keys))")

    keys = prep(keys, targets)
    println("\t2- keys sorted and pruned... - length(keys): $(length(keys))")

    htab = HTable{Int, Int}(length(keys) ÷ 2)
    for x in keys; add!(htab, x); end
    println("\t3- htab loaded... - size: $(htab.size) / n: $(htab.n)")

    core(htab, keys, targets; distinct=distinct, keep=keep)

  catch err
    println("Error: $(typeof(err))...")
  end
end

function prep(keys::Vector{Int}, targets::Union{StepRange{Int, Int}, UnitRange{Int}})
  sort!(keys)
  l, h = 1, length(keys)

  # pruning
  while true   # l < h
    if keys[l] + keys[h] < first(targets)
      l += 1
      continue
    end

    if keys[l] + keys[h] > last(targets)
      h -= 1
      continue
    end

    break
  end

  keys[l:h]
end

function core(htab, keys, targets; distinct=true, keep=false)
  tot_sol = 0
  sols = Set{Tuple{Int, Int}}() # : nothing

  for t in targets

    nb_sol = 0

    for ix in 1:length(keys)
      y = t - keys[ix]

      if get(htab, y) == y
        (x₁, x₂) = keys[ix] < y ? (keys[ix], y) : (y, keys[ix])

        if distinct
          nb_sol += 1
          keep && push!(sols, (x₁, x₂))
          break
        end

        if (x₁, x₂) ∉ sols
          nb_sol += 1
          push!(sols, (x₁, x₂))
        end
      end
    end

    tot_sol += nb_sol
  end

  keep ? (tot_sol, sols) : (tot_sol,)
  # (tot_sol,)
end


#
# julia> @time two_sum("testfiles/problem12.4.txt.BAK"; targets=-10_000:-9950)
# ==> distinct=true, keep=false
# file loaded... - length(keys): 1000000
# htab loaded... - size: 999752 / n: 2000000
#  70.773893 seconds (769.28 M allocations: 14.784 GiB, 3.63% gc time)
# (2,)
#

# julia> @time two_sum("testfiles/problem12.4.txt.BAK"; targets=-10_000:-9900)
# ==> distinct=true, keep=false
# file loaded... - length(keys): 1000000
# htab loaded... - size: 999752 / n: 2000000
# 136.556437 seconds (1.52 G allocations: 29.224 GiB, 2.62% gc time)
# (2,)
