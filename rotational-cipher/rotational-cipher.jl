const Punctuation = ['\'', ',', '.', '?', '!', '"', ';', ':']
const Digit_As_Char = map(x -> '0' + x, 0:9) # map integer 0..9 to char '0'..'9'
const N = 26

function rot_n_maker(n::Int)
  return function(pletter::Char)
    islowercase(pletter) && return transcode(pletter, n)
    isuppercase(pletter) && return transcode(pletter, n, orig = 'A')
    isnonletter(pletter) && return pletter
    throw(ArgumentError("$(pletter) is not a latin alphabet"))
  end
end

function rotate(n::Int, src::Union{String, Char})
  rot_fn = rot_n_maker(n)

  ===(typeof(src), Char) && return rot_fn(src)

  <<(s::String, l::Char) = string(s, l)

  return foldl((cipher, l) -> cipher << rot_fn(l), src, init="")
end

@inline islowercase(letter::Char)::Bool = 'a' ≤ letter ≤ 'z'
@inline isuppercase(letter::Char)::Bool  = 'A' ≤ letter ≤ 'Z'
@inline isnonletter(ch::Char)::Bool  = ch ∈ [' ', Punctuation..., Digit_As_Char...]

@inline transcode(letter::Char, n::Int; orig='a') = orig + (letter - orig + n) % N

# macro R13_str(s)
#   return rotate(13, s)
# end

## Code generation => generate the 27 macros
for ix ∈ 0:26
  @eval begin
     macro $(Symbol(string("R", ix, "_str")))(s::String)
       return rotate($ix, s)
     end
  end
end
