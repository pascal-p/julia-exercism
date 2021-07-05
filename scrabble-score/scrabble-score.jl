const Letter_Value = Dict{Char, Int}(
  'A' => 1, 'E' => 1, 'I' => 1, 'O' => 1, 'U' => 1, 'L' => 1, 'N' => 1, 'R' => 1, 'S' => 1, 'T' => 1,
  'D' => 2, 'G' => 2,
  'B' => 3, 'C' => 3, 'M' => 3, 'P' => 3,
  'F' => 4, 'H' => 4, 'V' => 4, 'W' => 4, 'Y' => 4,
  'K' => 5,
  'J' => 8, 'X' => 8,
  'Q' => 10, 'Z' => 10
)

function score(word::String;
               double_letter=Char[], triple_letter=Char[])::Integer
  length(word) == 0  && return 0

  match(r"\s+", word) ≠ nothing && throw(ArgumentError("Not a valid word!"))

  # Eliminate non English alpha char.
  word = filter(l -> match(r"[A-Za-z]", l) ≠ nothing,
                split(word, "")) |> ws -> join(ws, "")

  length(word) == 0 && throw(ArgumentError("Not a valid word!"))

  ## Add the following constraints (do not care if it is possible or not in game)
  double_letter = check_and_normalize(double_letter, length(triple_letter))
  triple_letter = check_and_normalize(triple_letter, length(double_letter))

  extra, vopt, fact = false, nothing, 1
  for (opt, k) ∈ ((double_letter, 2), (triple_letter, 3))
    length(opt) > 0 && check_validity(opt, word) && ((extra, vopt, fact) = (true, opt, k))
  end

  extra ? score_with_bonus(word, vopt, fact) :
    [Letter_Value[Char(uppercase(l))] for l ∈ word] |> sum
end

function score_with_bonus(word::String, vopt::Vector{Char}, fact::Integer)::Integer
  """
  if letter to double/triple appears several times in word, make sure it is
  doubled/tripled only once
  """
  tot_score, used_letters = 0, Dict{Char, Bool}()

  for l ∈ word
    l = l |> uppercase
    l_score = Letter_Value[Char(l)]

    score = if l ∈ vopt && !get(used_letters, l, false)
      used_letters[l] = true
      fact * l_score
    else
      l_score
    end

    tot_score += score
  end

  tot_score
end

function check_and_normalize(vopt::Vector{Char}, len::Integer)
  """
  double letters (no more than 2/per word) xor
  triple letters (no more than 2/per word) not both
  """
  if 0 < length(vopt) ≤ 2
    @assert len == 0
    ## normalize double/triple => uppercase
    vopt = uppercase.(vopt)
  end

  vopt
end

function check_validity(vopt::Vector{Char}, word::String)::Bool
  """
  Check given letters from vopt are used in word
  """
  word = word |> uppercase
  for letter ∈ vopt
    @assert occursin(letter |> uppercase , word) "Expecting letter $(letter) to be in word: $(word)"
  end

  true
end
