struct Task{T1<:Real, T2<:Real}        ## Excluding complex, otherwise take Number
  weight::T1
  length::T2

  function Task{T1, T2}(w::T1, l::T2) where {T1, T2}
    @assert w > 0 && l > 0
    new(w, l)
  end
end

const VTasks{T1, T2} = Vector{Task{T1, T2}}

function load_data(file::String, T::DataType)
  try
    vtasks = open(file) do fh
      n = readline(fh) |> s -> parse(Int, s)
      vt = VTasks{T, T}(undef, n)

      ## order is (weight, length)
      for (ix, line) in enumerate(eachline(fh))
        (w, l) = split(strip(line), r"\s+") |> a -> map(s -> parse(T, s), a)
        vt[ix] = Task{T, T}(w, l)
      end

      @assert length(vt) == n
      vt
    end
    vtasks   ## explicit return

  catch err
    println("Intercepted error: $(err)")
    exit(1)
  end
end

function sort_data!(tasks::VTasks{T1, T2}; by=:ratio) where {T1, T2}
  if by == :ratio
    sort_on_ratio!(tasks)
  elseif by == :diff
    sort_on_diff!(tasks)
  else
    throw(ArgumentError("Sort criteria $(by) not managed yet?"))
  end
end

"""
  sort_on_diff!(tasks)

Sort on decreasing order of the difference (weight - length)
"""
function sort_on_diff!(tasks::VTasks{T1, T2}) where {T1, T2}
  sort!(tasks,
        lt=(t1, t2) -> t1.weight - t1.length > t2.weight - t2.length ||
           (t1.weight - t1.length == t2.weight - t2.length && t1.weight > t2.weight),
        rev=false)
end

"""
  sort_on_diff!(tasks)

Sort on decreasing order of the ratio weight / length
"""
function sort_on_ratio!(tasks::VTasks{T1, T2}) where {T1, T2}
  sort!(tasks,
        lt=(t1, t2) -> t1.weight / t1.length > t2.weight / t2.length,
        rev=false)
end

function calc_cost(tasks::VTasks{T1, T2})::Real where {T1, T2}
  reducer_fn = function(acc, ctask::Task{T1, T2})
    (tot, clen) = acc
    clen += ctask.length
    tot += ctask.weight * clen
    (tot, clen)
  end

  (tot, ) = foldl(reducer_fn, tasks; init=(zero(T1), zero(T2)))
  tot
end

function cost(file::String; by=:ratio)
  vtasks = load_data(file::String, Int)
  sort_data!(vtasks; by)
  calc_cost(vtasks)
end

function cost(vtasks::VTasks{T1, T2}; by=:ratio) where {T1, T2}
  sort_data!(vtasks; by)
  calc_cost(vtasks)
end

#
# Note on sort!(v; alg::Algorithm=defalg(v), lt=isless, by=identity, rev::Bool=false, order::Ordering=Forward)
#   Sort the vector v in place.
#   QuickSort is used by default for numeric arrays while MergeSort is used for other arrays.
#   You can specify an algorithm to use via the alg keyword (see Sorting Algorithms for available algorithms).
#   the by keyword lets you provide a function that will be applied to each element before comparison;
#   the lt keyword allows providing a custom "less than" function; use rev=true to reverse the sorting order.
#   These options are independent and can be used together in all possible combinations: if both by and lt are specified,
#   the lt function is applied to the result of the by function;
#   rev=true reverses whatever ordering specified via the by and lt keywords
#
