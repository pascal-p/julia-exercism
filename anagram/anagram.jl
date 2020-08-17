function detect_anagrams(subject::AbstractString, candidates::Vector{String})

  function str_arychar(input::AbstractString)
    ch_ary = fill(' ', length(input)) # pre-allocate
    for (ix, ch) in enumerate(input)  # fill
      ch_ary[ix] = lowercase(ch)
    end
    return sort(ch_ary)               # sort
  end

  subject_lw, subject_len = lowercase(subject), length(subject)
  subject_char_sorted = str_arychar(subject)
  ary::Vector{typeof(subject)} = fill("", length(candidates))
  ix = 1

  for cand in candidates
    lowercase(cand) == subject_lw && continue ## Ignore case
    length(cand) ≠ subject_len && continue

    if subject_char_sorted == str_arychar(cand) && cand ∉ ary[1:ix-1]
      ary[ix] = cand
      ix += 1
    end
  end

  return ary[1:ix-1]  ## return only the found match(es)
end
