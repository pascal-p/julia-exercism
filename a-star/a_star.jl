push!(LOAD_PATH, "../Algo/08-heap/src")
push!(LOAD_PATH, "../Algo/13-0-ungraph/src")

using YAH
using YAUG

"""
  A* finds a path from start to goal

  A* selects the path that minimizes f(n) = g(n) + h(n), where:
  - n is the next node on the path,
  - g(n) is the cost of the path from the start node to n, and
  - h(n) is a heuristic function that (under-)estimates the cost of the cheapest path from n to the goal.

  ref. https://en.wikipedia.org/wiki/A*_search_algorithm
"""

function a_star(ug::UnGraph{T, T2}, start::T, goal::T, h::Function)::Union{Nothing, Vector{T}} where {T, T2}
  open_set = Heap{T2, T}(v(ug))  ## at most all the vertices of ug
  path_from = Dict{T, T}()       ## for node n, path_from[n] is the node immediately preceding it on the
  #                              ## cheapest path from (node) start
  visited = Vector{T}()

  insert!(open_set, (key=zero(T2), value=start))

  ## For node n, g_score[n] is the cost of the cheapest path from start to n (currently known).
  g_score = Dict{T, T2}(n => typemax(T2) for n ∈ 1:v(ug))
  g_score[start] = zero(T)

  ##
  ## For node n, f-score[n] = g-score[n] + h(n).
  ##   f-score[n] represents our current best guess as to how short
  ##   a path from start to goal can be if it goes through n.
  f_score = Dict{T, T2}(n => typemax(T2) for n ∈ 1:v(ug))
  f_score[start] = zero(T2)


  while !isempty(open_set)
    c_node = extract_min!(open_set).value

    c_node == goal &&
      (return construct_path(path_from, c_node))  ## we are done

    push!(visited, c_node)

    for (node, weight) ∈ adj(ug, c_node)
      ng_score = g_score[c_node] + weight

      if ng_score < g_score[node]
        path_from[node] = c_node
        g_score[node] = ng_score
        f_score[node] = g_score[node] + h(node)

        node ∉ visited &&
          insert!(open_set, (key=f_score[node], value=node))
      end
    end

  end

  return nothing
end


function construct_path(path_from::Dict{T, T}, c_node::T)::Vector{T}  where T
  path = Vector{T}()
  push!(path, c_node)

  while c_node ∈ keys(path_from)
    c_node = path_from[c_node]
    pushfirst!(path, c_node)
  end

  path
end
