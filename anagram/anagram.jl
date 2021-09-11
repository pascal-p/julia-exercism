function detect_anagrams(subject::AbstractString, candidates::Vector{String})
  subject_lw, subject_len = lowercase(subject), length(subject)
  subject_char_sorted = str_arychar(subject)

  ary::Vector{typeof(subject)} = fill("", length(candidates))
  ix = 1

  for cand ∈ candidates
    lowercase(cand) == subject_lw && continue ## Ignore case
    length(cand) ≠ subject_len && continue    ## Ignore ≠ length

    if subject_char_sorted == str_arychar(cand) && cand ∉ ary[1:ix-1]
      ary[ix] = cand
      ix += 1
    end
  end

  view(ary, 1:ix-1)
end

@inline function str_arychar(input::AbstractString)
  ch_ary = fill(' ', length(input)) # pre-allocate

  for (ix, ch) ∈ enumerate(input)   # fill
    ch_ary[ix] = ch |> lowercase
  end

  ch_ary |> sort
end
