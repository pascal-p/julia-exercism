"""
Bob is a lackadaisical teenager. In conversation, his responses are very limited.

Bob answers 'Sure.' if you ask him a question, such as "How are you?".
He answers 'Whoa, chill out!' if you YELL AT HIM (in all capitals).
He answers 'Calm down, I know what I'm doing!' if you yell a question at him.
He says 'Fine. Be that way!' if you address him without actually saying anything.
He answers 'Whatever.' to anything else.

Bob's conversational partner is a purist when it comes to written communication and always follows normal rules regarding sentence punctuation in English.
"""

# NOTE: punctuation ! ' # S % & ' ( ) * + , - . / : ; < = > ? @ [ / ] ^ _ { | } ~

const RESP = Dict{Symbol, String}(
  :question => "Sure.",
  :yelling => "Whoa, chill out!",
  :silence => "Fine. Be that way!",
  :misc => "Whatever.",
  :forceful_question => "Calm down, I know what I'm doing!",
)

function bob(stimulus::AbstractString)
  stimulus = stimulus |> strip

  if match(r"\A[\s\n\r]*\z", stimulus) !== nothing
    return RESP[:silence]

  elseif uppercase(stimulus) == stimulus && match(r"[A-Za-z]", stimulus) !== nothing
    return bob_uppercase(stimulus)

  else # no all uppercase
    match(r"\A[A-Z]?[\w\s!'#\$%&\(\)\*\+,\-./:;<=>@\[\]\^_\{\|\}~\"]+\?\z", stimulus) !== nothing && return RESP[:question]

    RESP[:misc]
  end
end

@inline function bob_uppercase(stimulus::AbstractString)
  if match(r"\?\z", stimulus) !== nothing
    return RESP[:forceful_question]

  elseif match(r"\A[^a-z]+\z", stimulus) !== nothing
    # all but lowercase char !
    return RESP[:yelling]
  end

  RESP[:misc]
end

# match(r"\A[A-Z0-9\s!'#\$%&\(\)\*\+\,\-\./:;<=>@\[\]\\^_\{\|\}~]+\?\z]+\z", stimulus) !== nothing
# !all(l -> uppercase(l) == l, stimulus)
# !all(l -> match(r"\A[!\?'#\$%&\(\)\*\+\,\-\./:;<=>@\[\]\\^_\{\|\}~]+\z", string(l)), stimulus) &&  # not punctuation only!
# !all(l -> match(r"\A[0-9!\?'#\$%&\(\)\*\+\,\-\./:;<=>@\[\]\\^_\{\|\}~]+\z", string(l)), stimulus) # not digit nor punctuation only
