const B = 10

function radix_sort!(ary::Vector{Int})
  max_val = maximum(ary)

  digitp = 1
  while max_val ÷ digitp > 0
    counting_sort!(ary, digitp)
    digitp *= 10
  end
end

function counting_sort!(ary::Vector{Int}, digitp::Int)
  n = length(ary)
  # @assert (digitp > 1 && digitp % B == 0) || digitp == 1

  ## Prep. output array (will contains sorted ary)
  output = zeros(Int, n)

  ## Prep. count array
  count = zeros(Int, B + 1)
  # @assert length(count) == B + 1

  ## Compute frequency counts.
  for ix in 1:n
    indx = (ary[ix] ÷ digitp) % 10  ## indx ∈ [0, digitp[
    count[indx + 1] += 1
  end

  ## Transform counts to indices.
  for ix in 2:B+1
    count[ix] += count[ix - 1]
  end

  ## Build the output array by distributing...
  for ix in n:-1:1
    indx = (ary[ix] ÷ digitp) % 10  ## indx ∈ [0, digitp[
    output[count[indx + 1]] = ary[ix]
    count[indx + 1] -= 1
  end

  copyto!(ary, output)
end
