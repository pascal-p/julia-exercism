function wordcount(sentence)
  """
  Count the number of words in a given sentence
  Retuns a dictionay with the count by words
  """
  wc = Dict{String,Int}()
  punctuation = ['\'', ':', ';', '?', '!', ',', '.']

  ## define one liner to update dictionary/hash wc
  update_wc(word) = wc[word] = get(wc, word, 0) + 1

  for word in split(sentence, r"\t|\n|\s|,")
    word = strip(word, punctuation) |> lowercase

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



