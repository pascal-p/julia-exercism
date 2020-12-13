"""
  With slight optimization for the frequency (using a matrix of the pre-computed values)

  Thus use more space and depends on init_freq_matrix(...) function
"""
function opt_bst(n::Int, freq::Vector{T}) where T <: Real
  a::Matrix{T} = zeros(T, n + 2, n + 1)   ## this encompass base case
  mfreq = init_freq_matrix(n, freq)

  for s in 0:n-1, i in 2:(n - s + 1)
    minₐ = typemax(T)

    for k in i:i+s
      minₐ = min(minₐ, a[i, k - 1] + a[k + 1, i + s])
    end

    a[i, i + s] = mfreq[s + 1, i + s] + minₐ
  end

  (a, a[2, n+1])
end


"""
  Vanilla version
"""
function opt_bst_alt(n::Int, freq::Vector{T}) where T <: Real
  a::Matrix{T} = zeros(T, n + 2, n + 1)   ## this encompass base case

  for s in 0:n-1, i in 2:(n - s + 1)
    minₐ, pₖ = typemax(T), zero(T)

    for k in i:i+s
      pₖ += freq[k]
      sa = a[i, k - 1] + a[k + 1, i + s]
      minₐ = min(minₐ, sa)
    end

    a[i, i+s] = pₖ + minₐ
  end

  (a, a[2, n+1])
end

##
## Helpers
##

function init_freq_matrix(n::Int, freq::Vector{T}) where T <: Real
  mfreq::Matrix{T} = zeros(T, n + 1, n + 1)

  for j in 1:n+1
    mfreq[1, j] = freq[j]
  end

  for i in 2:n+1, (k, j) = enumerate(i:n+1)
    mfreq[i, j] = sum(freq[k:j])
  end

  mfreq
end

function from_file(infile::String)
  try
    local nkeys, freq, T

    open(infile, "r") do fh
      for line in eachline(fh)
        ## read only first line, where we expect 1 Integer (≡ number of keys)
        a = split(strip(line), r"\s+")
        nkeys = parse(Int, a[1])
        break
      end

      for line in eachline(fh)
        a = split(strip(line), r"[\s+,]")
        T = occursin(r"\.", a[1]) ? Float32 : Int
        freq = [zero(T), map(s -> parse(T , strip(s)), a)...]
      end

      @assert length(freq) == nkeys + 1
    end
    return (nkeys, freq)

  catch err
    println("Intercepted error: $(err)")
    exit(1)
  end
end
