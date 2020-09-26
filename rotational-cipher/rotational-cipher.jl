const Punctuation = ['\'', ',', '.', '?', '!', '"', ';', ':']
const Digit_As_Char = map(x -> '0' + x, 0:9) # map integer 0..9 to char '0'..'9'

function rot_n_maker(n::Int)
  rot_fn = function(letter::Char)
    if 'a' ≤ letter ≤ 'z'
      return 'a' + (letter - 'a' + n) % 26
    elseif 'A' ≤ letter ≤ 'Z'
      return 'A' + (letter - 'A' + n) % 26
    elseif letter in [' ', Punctuation..., Digit_As_Char...]
      return letter
    else
      throw(ArgumentError("$(letter) is not a latin alphabet"))
    end
  end

  return rot_fn
end


function rotate(n::Int, src::Union{String, Char})
  rot_fn = rot_n_maker(n)

  ===(typeof(src), Char) && return rot_fn(src)

  <<(s::String, l::Char) = string(s, l)

  return foldl((cipher, l) -> cipher << rot_fn(l), src, init="")
end

# macro R13_str(s)
#   return rotate(13, s)
# end

## Code generation => generate the 27 macros
for ix in 0:26
  @eval begin
     macro $(Symbol(string("R", ix, "_str")))(s::String)
       return rotate($ix, s)
     end
  end
end
