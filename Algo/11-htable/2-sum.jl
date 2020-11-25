# include("./src/htable.jl")
push!(LOAD_PATH, "./src")
using YAHT


# function two_sum(;keep=true)
#   htab = HTable{Int, Int}(1_00)
#   keys = rand(-10_000:10_000, 5_00)
#   println(keys)
#   for x in keys; add!(htab, x); end
#   core(htab, keys, -10_000:1_000:-1_000; keep)
# end

function two_sum(;n=1_000_000, keys=rand(-10_000_000_000:10_000_000_000, n), targets=-10_000:10_000,
                 distinct=true, keep=false)
  htab = HTable{Int, Int}(n ÷ 2)
  for x in keys; add!(htab, x); end

  core(htab, keys, -10_000:1_000:-1_000; distinct, keep)
end

function two_sum(infile::String; targets=-10_000:10_000, distinct=true, keep=false)
  keys = nothing
  try
    open(infile, "r") do fh
      keys = [parse(Int, line) for line in eachline(fh)]
    end

    htab = HTable{Int, Int}(length(keys) ÷ 2)
    for x in keys; add!(htab, x); end
    core(htab, keys, targets; distinct=distinct, keep=keep)

  catch err
    println("Error: $(typeof(err))...")
  end
end

function core(htab, keys, targets; distinct=true, keep=false)
  tot_sol = 0
  sols = !distinct ? Set{Tuple{Int, Int}}() : nothing

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
end
