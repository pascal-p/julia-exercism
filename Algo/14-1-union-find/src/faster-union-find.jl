mutable struct UnionFind
  parent::Vector{Int}
  rank::Vector{UInt8}
  count::Int

  function UnionFind(n::Int)
    @assert n > 0
    count = n
    parent = zeros(Int, n)
    rank = zeros(UInt8, n)
    for ix in 1:n; parent[ix] = ix; end
    new(parent, rank, count)
  end

  function UnionFind(file::String)
    from_file(file)
  end
end

count(uf::UnionFind) = uf.count

connected(uf::UnionFind, p::Int, q::Int) = find(uf, p) == find(uf, q)

function find(uf::UnionFind, p::Int)::Int
  validate(uf, p)

  while p ≠ uf.parent[p]
    uf.parent[p] = uf.parent[uf.parent[p]]   ## path compression
    p = uf.parent[p]
  end
  return p
end

function union(uf::UnionFind, p::Int, q::Int)
  root_p, root_q = find(uf, p), find(uf, q)

  ## already in same component - we are done
  root_p == root_q && return

  ## otherwise, merge smaller rank pointer to root of larger rank
  if uf.rank[root_p] < uf.rank[root_q]
    uf.parent[root_p] = root_q

  elseif uf.rank[root_p] > uf.rank[root_q]
    uf.parent[root_q] = root_p

  else  ## tie
    uf.parent[root_q] = root_p
    uf.rank[root_p] += 1
  end

  uf.count -= 1
  return
end

#
# Internals
#

function validate(uf::UnionFind, p::Int)
  n = length(uf.parent)
  !(1 ≤ p ≤ n) && throw(ArgumentError("index p must be such that 1 ≤ p:$(p) ≤ n"))
  return
end

function from_file(file::String)::UnionFind
  local uf
  try
    open(file, "r") do fh
      local n = 0

      for line in eachline(fh)
        n = parse(Int, strip(line))
        break
      end

      uf = UnionFind(n)

      for line in eachline(fh)
        (p, q) = split(line, r"\s+") |>
          a -> map(x -> strip(x), a) |>
          a -> map(x -> parse(Int, x), a)

        union(uf, p, q)
      end

      return uf
    end

  catch err
    if isa(err, ArgumentError)
      println("! Problem with content of file $(infile)")

    elseif isa(err, SystemError)
      println("! Problem opening $(infile) in read mode... Exit")

    elseif isa(err, AssertionError)
      println("! Failed expectation: $(err): $(err.var)")

    else
      println("! other error: $(typeof(err)) - $(err)") # catch_backtrace()

    end
    exit(1)
  end
end
