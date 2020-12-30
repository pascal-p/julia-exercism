##
## Point in Euclidean space
##
struct Point{T}
  x::T
  y::T
end

"""
Load data from file

  with_index=false : file does not have index - we need to enumerate
  with_index=true  : file does have index, no need to enumerate
"""
function load_data(infile::String, DType::DataType; no_index=false, with_index=false)
  try
    local v, n
    open(infile, "r") do fh
      for line in eachline(fh)
        n = parse(Int, strip(line))
        break
      end

      v = if no_index
        load_no_index(fh, n, DType)
      elseif with_index
        load_wo_enum(fh, n, DType)
      else
        load_with_enum(fh, n, DType)
      end
    end
    v

  catch err
    if isa(err, ArgumentError)
      println("! Problem with content of file $(infile)")
    elseif isa(err, SystemError)
      println("! Problem opening $(infile) in read mode... Exit")
    else
      println("! Other error: $(err)...")
    end
    exit(1)
  end
end

function load_with_enum(fh, n::Integer, DType::DataType)
  v = Vector{Point{DType}}(undef, n)
  for (ix, line) in enumerate(eachline(fh))
    (x, y) = map(s -> parse(DType, strip(s)), split(line, r"\s+"))
    v[Int32(ix)] = Point(x, y)
  end
  v
end

function load_wo_enum(fh, n::Integer, DType::DataType)
  v = Vector{Tuple{Integer, Point{DType}}}(undef, n)
  for line in eachline(fh)
    a =  split(line, r"\s+")
    (ix, (x, y)) = (parse(Int32, a[1]),
                    map(s -> parse(DType, strip(s)), a[2:end]))
    v[ix] = (ix, Point(x, y))
  end

  @assert length(v) == n 
  v
end

function load_no_index(fh, n::Integer, DType::DataType)
  v = Vector{Point{DType}}(undef, n)
  for line in eachline(fh)
    
    a = split(line, r"\s+")
    (ix, (x, y)) = (parse(Int32, a[1]),
                    map(s -> parse(DType, strip(s)), a[2:end]))
    v[ix] = Point(x, y)
  end

  @assert length(v) == n 
  v
end

euclidean_dist(ori::Point{T}, dst::Point{T}) where T = √((ori.x - dst.x)^2 + (ori.y - dst.y)^2)

function round_dist(d::Real, DT::DataType)::Integer
  @assert DT <: Integer
  floor(DT, d)
end

"""
Calc. distm from vector of Points
"""
function calc_dist(vp::Vector{Point{T}}) where T
  n = length(vp)
  distm = Matrix{T}(undef, n, n)

  for ix in 1:n
    ori = vp[ix]
    distm[ix, ix] = zero(T)
    for jx in ix+1:n
      distm[ix, jx] = distm[jx, ix] = euclidean_dist(ori, vp[jx])
    end
  end

  distm
end

function calc_dist(vp::Vector{Tuple{Integer, Point{T}}}) where T
  n = length(vp)
  distm = Matrix{T}(undef, n, n)

  for ix in 1:n
    ori = vp[ix][2]
    distm[ix, ix] = zero(T)
    for jx in ix+1:n
      distm[ix, jx] = distm[jx, ix] = euclidean_dist(ori, vp[jx][2])
    end
  end

  distm
end
