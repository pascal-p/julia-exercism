const DICE_NB_FACES = 6
const VALID_RANGE = (lower=3, upper=18) # (3 * 1, 3 * 6)


mutable struct DNDCharacter
  strength::Integer
  dexterity::Integer
  constitution::Integer
  intelligence::Integer
  wisdom::Integer
  charisma::Integer

  hitpoints::Integer  ## Calculated

  function DNDCharacter(s::Integer, d::Integer, c::Integer, i::Integer, w::Integer, ch::Integer)
    valid_fv(s, d, c, i, w, ch)

    hitpoints::Integer = 10 + modifier(c)
    new(s, d, c, i, w, ch, hitpoints)
  end

  function DNDCharacter(;strength=3, dexterity=3, constitution=3,
                        intelligence=3, wisdom=3, charisma=3)

    valid_fv(strength, dexterity, constitution, intelligence,
             wisdom, charisma)

    hitpoints::Integer = 10 + modifier(constitution)

    new(strength, dexterity, constitution,
        intelligence, wisdom, charisma, hitpoints)
  end
end


## outer-constructor
function DNDCharacter()
  n = length(fieldnames(DNDCharacter)) - 1 ## hipoints is calculated

  ary::Vector{Integer} = fill(0, n)
  for ix in 1:n
    ary[ix] = ability()
  end

  DNDCharacter(ary...)
end


function valid_fv(fva::Vararg{Integer, 6})
  ## 6 fields required, the 7th (hitpoints) is calculated
  for fv in fva; valid_fv(fv); end
end

function valid_fv(fv::Integer)
  "Valid field value"
  VALID_RANGE.lower ≤ fv ≤ VALID_RANGE.upper ||
    throw(DomainError("field value must be in the $(VALID_RANGE), got $(fv)"))
end


function modifier(ability)
  "Constitution modifier"
  floor(Int, (ability - 10) / 2)
end


function ability()
  sort(rand(1:DICE_NB_FACES, 4), rev=true)[1:end-1] |> sum
end
