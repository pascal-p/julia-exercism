using StableRNGs

const VM{T} = Union{Vector{T}, Matrix{T}} where T

struct YaMatrix{T <: Number}
  _content::VM{T} 
  _shape::Tuple{Vararg{Int}}

  function YaMatrix{T}(shape::Tuple{Vararg{Int}}; seed=0) where T
    @assert shape[1] ≥ 1

    if length(shape) ≥ 2
      for n in shape[2:end]
        @assert n >= 0
      end
    end

    content = seed == 0 ? VM{T}(undef, shape...) :
      rand(StableRNG(seed), T, shape...)
    new(content, shape)
  end

  function YaMatrix{T}(input::String) where T
    @assert length(input) > 0

    ary = split(input, r"\n")
    shape = (length(ary), length(split(ary[1], r"\s+")))

    content = Matrix{T}(undef, shape...)
    for (ix, row) ∈ enumerate(ary), (jx, s) ∈ enumerate(split(row, r"\s+"))
      content[ix, jx] = parse(T, s)
    end

    new(content, shape)
  end
end

shape(m::YaMatrix{T}) where T = m._shape

function row(m::YaMatrix{T}, ix::Int)::Vector{T} where T
  @assert 1 ≤ ix ≤ m._shape[1]
  m._content[ix, :]
end

function column(m::YaMatrix{T}, ix::Int)::Vector{T} where T
  @assert 1 ≤ ix ≤ m._shape[2]
  m._content[:, ix]
end
