push!(LOAD_PATH, "../09-bst/lib")
using YAB

const MOD = 10_000 # only the last 4 digits

"""
  Compute the "rolling" median of a stream of digits in logarithmic time per round.

  Using augmented BST
"""

function median_maint(infile::String; with_medians=false)
  ary = []
  try
    open(infile, "r") do fh
      ary = [parse(Int, line) for line in eachline(fh)]
    end
    median_maint(ary; with_medians=with_medians)

  catch err
    println("Error: $(typeof(err))...")
  end
end

function median_maint(v::Vector{Int}; with_medians=false)
  bst = BST{Int}()
  median_calc(v, bst; with_medians=with_medians)
end

function median_calc(v::Vector{Int}, bst::BST{Int}; with_medians=false)
  medians = with_medians ? Dict{Int, Int}() : Nothing

  cmed = 0
  for x in v
    insert!(bst, (x,))
    k = ceil(Int, size(bst) / 2) # + 1
    median = (select(bst, k) |> to_tuple)[1]
    with_medians && (medians[median] = get(medians, median, 0) + 1)
    cmed += median
  end

  last4digits = cmed % MOD
  with_medians ? (last4digits, sort(collect(medians))) : (last4digits, )
end
