"""
Given a candidate (subject) and a list of candidates return the
  (sub)list of candidates that are anagram of subject

julia> detect_anagrams("listen", ["enlists", "google", "inlets", "banana"])
1-element view(::Vector{String}, 1:1) with eltype String:
 "inlets"
"""
function detect_anagrams(subject::AbstractString, candidates::AbstractVector{String})
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

detect_anagrams(::Any, ::Any) = throw(ArgumentError("Expecting a string and a vector of strings"))

@inline function str_arychar(input::AbstractString)
  ch_ary = fill(' ', length(input)) # pre-allocate
  for (ix, ch) ∈ enumerate(input)   # fill
    ch_ary[ix] = ch |> lowercase
  end
  ch_ary |> sort
end
