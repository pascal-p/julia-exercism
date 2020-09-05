function luhn(str::AbstractString)::Bool
  nstr = replace(str, r"[\s\t\n\r]+" => "")         # remove any space

  length(nstr) ≤ 1 && (return false)                # check length

  !occursin(r"\A[0-9]+\z", nstr) && (return false)  # consider only digit

  return extract_calc(split(nstr, "")) % 10 == 0    # calculate and conclude
end

function extract_calc(ary)
  """
  Do not build arrya => too expensive

  Extract, double and sum every 2nd digit while
    extract and sum every 1st digit

  return sum of these two sums
  """
  ds, s = 0, 0
  r = length(ary) % 2 == 0 ? 0 : 1

  res = foldl(enumerate(ary); init=[0, 0]) do csum, (ix, ch)
    d = parse(Int, ch)
    if ix % 2 == r
      csum[1] += d                                  # accumulate
    else
      x = 2d
      csum[2] += x > 9 ? x - 9 : x                  # double, normalize, accumulate
    end
    csum
  end

  return sum(res)
end

# ===============================================================

function luhn_v0(str::AbstractString)::Bool
  nstr = replace(str, r"[\s\t\n\r]+" => "")         # remove any space

  length(nstr) ≤ 1 && (return false)                # check length

  !occursin(r"\A[0-9]+\z", nstr) && (return false)  # consider only digit

  ary₁, ary₂ = unzip(split(nstr, ""))               # unzip to get 2 arrays

  nary₂ =  map(ary₂) do x                           # double every  digit and normalize (ary₂)
    d = 2x
    d > 9 ? d - 9 : d
  end

  return (sum(ary₁) + sum(nary₂)) % 10 == 0         # sum all digits and check mod 10
end

function unzip(ary)
  """
  unzip(["4", "5", "3", "9". "3", "1", "9", "5", "0", "3", "4", "3", "6", "4", "6", "7"])
    => ([4, 3, 3, 9, 0, 4, 6, 6], [5, 9, 1, 5, 3, 3, 4, 7])

  digit only!
  """

  len = length(ary)
  n = len ÷ 2
  ary₂::Vector{Integer} = zeros(n)                        # allocate 1st array
  ary₁::Vector{Integer} = zeros(length(ary) - n)          # ...

  nary = foldl(enumerate(ary); init=[ary₁, ary₂]) do cary, (ix, ch)
    d = parse(Int, ch)
    if ix % 2 == 0
      cary[2][ix ÷ 2] = d
    else
      cary[1][(ix + 1) ÷ 2] = d
    end
    cary                                                  # return cumulative ary
  end

  len % 2 == 0 ? (nary[2], nary[1]) : (nary[1], nary[2])  # re-order
end
