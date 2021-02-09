const VS = Vector{String}

const ANIMALS = String["fly", "spider", "bird", "cat", "dog", "goat", "cow", "horse"]

const TEMPLATES = Dict{Int,
  String}(
          1 => "I know an old lady who swallowed a ",
          -1 => "I don't know why she swallowed the fly. Perhaps she'll die.",
          2 => " that wriggled and jiggled and tickled inside her.",
          3 => "She swallowed the ",
          4 => " to catch the ",
          5 => "She swallowed the <s1> to catch the <s2>",
)

const SPEC = Dict{Int,
  Union{String, Nothing}}(
                          1 => nothing,
                          2 => "It wriggled and jiggled and tickled inside her.",
                          3 => "How absurd to swallow a <s>!",
                          4 => "Imagine that, to swallow a <s>!",
                          5 => "What a hog, to swallow a <s>!",
                          6 => "Just opened her throat and swallowed a <s>!",
                          7 => "I don't know how she swallowed a <s>!",
                          8 => "She's dead, of course!",
)


function recite(startv::Int, endv::Int)::VS
  @assert 1 ≤ startv ≤ endv

  poem = String[]
  for ix ∈ startv:endv
    a_strophe = strophe(ix)
    poem = [poem..., a_strophe..., ""]
  end

  return view(poem, 1:length(poem) - 1)
end

function strophe(startv::Int)
  ## begin strophe
  a_strophe = VS([string(TEMPLATES[1], ANIMALS[startv], ".")])

  if startv == 8
    push!(a_strophe, SPEC[8])
    return a_strophe
  end

  if startv ≥ 2
    push!(a_strophe, replace(SPEC[startv], "<s>" => ANIMALS[startv]))
  end

  if startv ≥ 4
    ### "She swallowed the ANIMALS[startv] to catch the ANIMALS[startv - 1].",
    for ix ∈ startv:-1:4
      push!(a_strophe,
            string(TEMPLATES[3], ANIMALS[ix], TEMPLATES[4], ANIMALS[ix - 1], "."))
    end
  end

  if startv ≥ 3
    ## "She swallowed the " <bird> " to catch the " <spider> " that wriggled and jiggled
    ## and tickled inside her.",
    push!(a_strophe,
          string(TEMPLATES[3], ANIMALS[3], TEMPLATES[4], ANIMALS[2], TEMPLATES[2]))
  end

  if startv ≥ 2
    ## "She swallowed the spider to catch the fly."
    str = replace(replace(TEMPLATES[5], "<s1>" => ANIMALS[2]),
                  "<s2>" => ANIMALS[1])
    push!(a_strophe, string(str, "."))
  end

  ## end strophe:
  ## "I don't know why she swallowed the fly. Perhaps she'll die."
  push!(a_strophe, TEMPLATES[-1])

  return a_strophe
end
