const Allergies = Dict{Int, String}(
  1 => "eggs",
  2 => "peanuts",
  4 => "shellfish",
  8 => "strawberries",
  16 => "tomatoes",
  32 => "chocolate",
  64 => "pollen",
  128 => "cats"
)

const KEYS = keys(Allergies) |> collect |> sort
const N = length(KEYS)

allergic_to(score, allergen)::Bool = allergen ∈ allergy_list(score)

function allergy_list(score::Integer)
  z₀ = zero(typeof(score))
  score == z₀ && return Set{String}()

  ix = next_pow(score)
  s = Set{String}()
  while ix ≥ 1
    push!(s, Allergies[KEYS[ix]])
    score -= KEYS[ix]
    score ≤ z₀ && break
    ix = next_pow(score)
  end
  s
end

@inline function next_pow(score::Integer)
  ix = if score ∈ KEYS
    findfirst(s -> s == score, KEYS) # exact pow of 2
  else
    ceil(Int, log(score) / log(2))   # closest power of 2
  end
  ix > N ? N : ix
end

# to check for type stability
# @code_warntype  allergy_list(248)
