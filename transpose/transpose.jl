"""
  Given an input text output it transposed.
  Deal with unicode characters (where len of unicode char is > 1)
"""

const PAD_CH = '\0' ## CAUTION: transpose won't work if this sequence appears in the input!

function transpose_strings(input::AbstractArray)::AbstractArray
  isempty(input) && return input
  length(input) == 1 && return split(input[1], "")

  max_len = reduce(max, map(length, input))
  input = rpad_input(input, max_len)
  ninput, s₁ = fill("", max_len), input[1]

  for ix in 2:length(input)
    rix, s₂ = 1, input[ix]

    for (c₁, c₂) in zip(s₁, s₂)
      ninput[rix] = string(c₁, c₂)
      rix += 1
    end
    s₁ = ninput
  end

  return rm_added_pad(ninput)
end

function rpad_input(input::AbstractArray, max_len::Int)::AbstractArray
  "right pad, if necessary"
  rpad.(input, max_len, PAD_CH)
  # map(s -> rpad(s, max_len, PAD_CH), input)
  # map(s -> string(s, PAD_CH ^ (len - length(s))), input)
end

function rm_added_pad(input::AbstractArray)::AbstractArray
  "remove added padding"
  map(s -> replace(s, PAD_CH => " "),
      map(s -> rstrip(s, PAD_CH), input))
end

#
# using pre-alloc + index rix
# transpose_strings: 0.000071 seconds (2.91 k allocations: 100.078 KiB)
#

##
## ------------------------------------------------------------------------
##

function transpose_strings_alt1(input::AbstractArray)::AbstractArray
  isempty(input) && return input

  n = length(input)
  max_len = reduce(max, map(length, input))  ## 2nd dim - find max length (of inner string)
  ninput = fill("", max_len)                 ## allocate new container (array)

  function upd_ninput(inp)
    for (c, ch) in enumerate(split(inp, ""))
      ninput[c] = string(ninput[c], ch)
    end
  end

  len1 = length(input[1])
  upd_ninput(input[1])

  for c in len1+1:max_len ## 1st row - pad if necessary
    ninput[c] = string(PAD_CH)
  end

  for r in 2:n                                         ## other rows but last one
    upd_ninput(input[r])

    for c in min(max_len, length(input[r]))+1:max_len  ## padding for other rows
      ninput[c] = string(ninput[c], PAD_CH)
    end
  end

  ## finally remove any added padding
  return rm_added_pad(ninput)
end


function transpose_strings_alt2(input::AbstractArray)::AbstractArray
  isempty(input) && return input

  n = length(input)                         ## 1st dimension
  max_len = reduce(max, map(length, input)) ## 2nd dimension - find max length (of inner string)
  input = rpad_input(input, max_len)        ## right pad input

  function upd_ninput(inp)
    for (c, ch) in enumerate(split(inp, ""))
      ninput[c] = string(ninput[c], ch)
    end
  end

  ninput = fill("", max_len)                ## allocate new container
  upd_ninput(input[1])

  for r in 2:n
    upd_ninput(input[r])
  end

  return rm_added_pad(ninput)
end

# on biggest input:
#
# transpose_strings_alt1:  0.000126 seconds (5.14 k allocations: 273.453 KiB)
#                          0.000195 seconds (5.14 k allocations: 273.453 KiB)
#
# transpose_strings_alt2:  0.066695 seconds (210.85 k allocations: 11.182 MiB)
#                          0.093081 seconds (288.37 k allocations: 14.980 MiB, 3.68% gc time)


function transpose_strings_alt3(input::AbstractArray)::AbstractArray
  isempty(input) && return input

  ix, max_len = 1, reduce(max, map(length, input))
  input = rpad_input(input, max_len)    ## right pad input
  ninput = fill("", max_len)

  for t in zip(input...)
    ninput[ix] = join(t)
    ix += 1
  end

  return rm_added_pad(ninput)
end

# transpose_strings_alt3:  0.212639 seconds (1.64 M allocations: 74.226 MiB, 2.60% gc time)
