const Punctuation = ['\'', ':', ';', '?', '!', ',', '.']

function wordcount_v1(sentence::AbstractString)::Dict{AbstractString, Int}
  """
  Count the number of words in a given sentence
  Retuns a dictionary with the count by words
  """
  wc = Dict{AbstractString, Int}()

  ## define one liner to update dictionary/hash wc
  update_wc(word) = wc[word] = get(wc, word, 0) + 1

  for word in split(sentence, r"\t|\n|\s|,")
    word = strip(word, Punctuation) |> lowercase

    if occursin(r"\A[\w']+\z", word)
      update_wc(word)
    else
      ## word prefixed or suffixed with non-word?
      m = match(r"\A[^\w]*([\w']+)[^\w]*\z", word)

      ## then if match and not reduced to single quote, count it
      m !== nothing && m[1] != "'" && update_wc(m[1])
    end
  end

  return wc
end

function wordcount(sentence::AbstractString)::Dict{AbstractString, Int}
  """
  Count the number of words in a given sentence (using FP approach)
  Retuns a dictionary with the count by words
  """
  update(wc, w) = wc[w] = get(wc, w, 0) + 1

  fn = function(wc, w)
    occursin(r"\A[\w']+\z", w) ? update(wc, w) :
    (m = match(r"\A[^\w]*([\w']+)[^\w]*\z", w)) !== nothing && m[1] != "'" && update(wc, m[1])
    return wc
  end

  split(sentence, r"\t|\n|\s|,|_") |>
    ws -> map(w -> strip(w, Punctuation), ws) |>
    ws -> map(w -> lowercase(w), ws) |>
    ws -> foldl((wc, w) -> fn(wc, w), ws, init=Dict{AbstractString, Int}())
end
