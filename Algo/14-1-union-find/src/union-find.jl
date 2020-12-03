mutable struct UnionFind
  id::Vector{Int}
  sz::Vector{Int}
  count::Int

  function UnionFind(n::Int)
    @assert n > 0
    count = n
    id = zeros(Int, n)
    sz = ones(Int, n)
    for ix in 1:n; id[ix] = ix; end
    new(id, sz, count)
  end

  function UnionFind(file::String)
    from_file(file)
  end
end

count(uf::UnionFind) = uf.count

connected(uf::UnionFind, p::Int, q::Int) = find(uf, p) == find(uf, q)

function find(uf::UnionFind, p::Int)::Int
  while p != uf.id[p]; p = uf.id[p]; end
  return p
end

function union(uf::UnionFind, p::Int, q::Int)
  ix, jx = find(uf, p), find(uf, q)

  ## already in same component - we are done
  ix == jx && return   

  ## otherwise, merge smaller root into larger one
  if uf.sz[ix] < uf.sz[jx]
    uf.id[ix] = jx
    uf.sz[jx] += uf.sz[ix]
  else
    uf.id[jx] = ix
    uf.sz[ix] += uf.sz[jx]
  end

  uf.count -= 1
  return
end

#
# Internals
#

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
        # println("$(p) $(q)")
      end
      # println("found: $(count(uf)) components.")
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
