"""
  Given an input text output it transposed.

  Deal with unicode characters (where len of unicode char is > 1)
"""

const PAD_CH = '\0'
# CAUTION: transpose won't work if this sequence appears in the input!

function transpose_strings_alt(input)
  isempty(input) && return input

  n = length(input)                     ## 1st dimension
  len = reduce(max, map(length, input)) ## 2nd dimension - find max length (of inner string)
  input = map(s -> string(s, (PAD_CH) ^ (len - length(s))), input)  ## right pad input

  function upd_ninput(inp)
    for (c, ch) in enumerate(split(inp, ""))
      ninput[c] = string(ninput[c], ch)
    end
  end

  ninput = fill("", len)  ## allocate new container
  upd_ninput(input[1])

  for r in 2:n
    upd_ninput(input[r])
  end

  return map(s -> replace(s, PAD_CH => " "),
             map(s -> rstrip(s, [PAD_CH]), ninput))
end

function transpose_strings(input)
  isempty(input) && return input

  n = length(input)
  max_len = reduce(max, map(length, input))  ## 2nd dim - find max length (of inner string)
  ninput = fill("", max_len)  ## allocate new container (array)

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

  for r in 2:n            ## other rows but last one
    upd_ninput(input[r])
    rlen = length(input[r])
    for c in min(max_len, rlen)+1:max_len   ## padding for other rows
      ninput[c] = string(ninput[c], PAD_CH)
    end
  end

  ## finally remove any added padding
  return map(s -> replace(s, PAD_CH => " "),
             map(s -> rstrip(s, [PAD_CH]), ninput))
end
