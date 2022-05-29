using Parameters

@enum States ONGOING LOSE WIN

const NUM_GUESSES = 9

@with_kw mutable struct HangmanState
  masked_word::String = ""
  remaining_guesses::Integer = NUM_GUESSES
  letters::Set{Char} = Set{Char}()
  status::States = ONGOING::States
end

struct Hangman
  word::String
  state::HangmanState

  function Hangman(word::String)
    hs = HangmanStateInit(length(word))
    new(word |> lowercase, hs)
  end
end

function HangmanStateInit(n::Integer)::HangmanState
  n ≥ 0 && (return HangmanState(masked_word=repeat("_", n)))
  throw(ArgumentError("n must be ≥ 0"))
end

HangmanStateInit(::Any) = throw(ArgumentError("argument must be an integer ≥ 0"))

function guess(hg::Hangman, ch::Char)::Nothing
  ch = ch |> lowercase

  if hg.state.remaining_guesses < 0 || hg.state.status != ONGOING::States
    throw(DomainError("The game has already ended."))
  end

  if hg.state.remaining_guesses == 0
    hg.state.status = LOSE::States
    return
  end

  ixes = ch ∉ hg.state.letters ? findall(c -> c == ch, hg.word) : []
  push!(hg.state.letters, ch)
  if length(ixes) > 0
    update_masked_word!(hg, ch, ixes)
  else
    hg.state.remaining_guesses -= 1
  end
  return
end

get_masked_word(hg::Hangman)::String = hg.state.masked_word

get_status(hg::Hangman)::States = hg.state.status

get_remaining_guesses(hg::Hangman)::Integer = hg.state.remaining_guesses

function update_masked_word!(hg::Hangman, ch::Char, ixes::Vector{<:Integer})
  masked_word = hg.state.masked_word
  for ix ∈ ixes
    masked_word = string(
      masked_word[1:ix-1], ch, masked_word[ix+1:end]
    )
  end
  masked_word == hg.word && (hg.state.status = WIN::States)
  hg.state.masked_word = masked_word
end
