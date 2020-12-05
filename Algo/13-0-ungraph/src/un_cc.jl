"""
  Find Connected Components in Undirected Graph (with weighted edge ≡ cost or distance)
"""

import Base: count

struct UnCC{T1}
  _marked::Vector{Bool}
  _id::Vector{T1}
  _count::Int

  function UnCC{T1}(ug::UnGraph{T1, T2}) where {T1, T2}
    marked = fill(false, v(ug))
    id = Vector{T1}(undef, v(ug))
    count = 1

    for s in 1:v(ug)
      if !marked[s]
        _dfs(ug, marked, id, count, s)
        count += 1
      end
    end

    count -= 1
    new(marked, id, count)
  end
end

id(uncc::UnCC{T1}, v::T1) where T1 = uncc._id[v]
ids(uncc::UnCC{T1}) where T1 = uncc._id

connected(uncc::UnCC{T1}, v::T1, w::T1) where T1 = uncc._id[v] == uncc._id[w]

count(uncc::UnCC{T1}) where T1 = uncc._count

function vertex_from_cluster(uncc::UnCC{T1}, id::Int) where T1
  1 ≤ id ≤ uncc._count || throw(ArgumentError("id must be in range [1..$(uncc._count)]"))
  filter(ix -> uncc._id[ix] == id, 1:length(uncc._id))
end


#
# Internal
#
function _dfs(ug::UnGraph{T1, T2}, marked::Vector{Bool}, id::Vector{T1}, count::Int, v::T1) where {T1, T2}
  marked[v] = true
  id[v] = count

  for (w, _c) in adj(ug, v)
    !marked[w] && _dfs(ug, marked, id, count, w)
  end
end
