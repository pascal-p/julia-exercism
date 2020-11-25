
function two_sum(infile::String; targets=-10_000:10_000, distinct=true, keep=false)
  try
    ary = open(infile, "r") do fh
      [parse(Int, line) for line in eachline(fh)]
    end

    sort!(ary)
    core(ary, targets; distinct=distinct, keep=keep)

  catch err
    println("Error: $(typeof(err))...")
  end
end

function core(ary::Vector{Int}, targets::UnitRange{Int}; distinct=true, keep=false)
  sols = distinct ? Set{Int}() : Set{Tuple{Int, Int, Int}}()
  l, h = 1, length(ary)

  while l < h
    if ary[l] + ary[h] < first(targets)
      l += 1
      continue
    end

    if ary[l] + ary[h] > last(targets)
      h -= 1
      continue
    end

    ## count and keep sum satisfying the conditions 
    il = l
    s = ary[il] + ary[h]
    while first(targets) ≤ s ≤ last(targets)            
      distinct ? push!(sols, s) : push!(sols, (s, ary[il], ary[h])) 
      il += 1      
      il ≥ h && break
      s = ary[il] + ary[h]
    end

    ## prune again...
    h -= 1
  end

  length(sols), sols
end


#
# Challenge (in REPL):
#
# include("./2-sum-alt.jl")
# @time two_sum("testfiles/problem12.4.txt.BAK"; targets=-10000:10000)
#
#  0.251484 seconds (2.01 M allocations: 55.132 MiB, 1.69% gc time)
# (427, Set([5494, -1585, -2702, -6055, 464, 7356, 1862, 9405, -8196, -1211  …  7450, -2330, 6052, 745, -3726, -2982, 9313, 9126, -5588, 9125]))
#
