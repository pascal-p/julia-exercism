const N = 26

function rot_n_maker(n::Integer)
    n = mod(n, N)

    return function (pletter::AbstractChar)
        isasciilower(pletter) && return shift_letter(pletter, n)
        isasciupper(pletter) && return shift_letter(pletter, n, base = 'A')
        pletter
    end
end

function rotate(n::Integer, src::AbstractChar)
    rot_fn = rot_n_maker(n)
    rot_fn(src)
end

rotate(n::Integer, src::AbstractString) = map(rot_n_maker(n), src)

@inline isasciilower(letter::AbstractChar)::Bool = 'a' ≤ letter ≤ 'z'
@inline isasciupper(letter::AbstractChar)::Bool = 'A' ≤ letter ≤ 'Z'

@inline function shift_letter(letter::AbstractChar, shift::Integer; base = 'a')
    @assert 0 ≤ shift < N "Expecting 0 ≤ $(shift) < $(N)"
    base + mod((letter - base + shift), N)
end

# macro R13_str(s)
#   return rotate(13, s)
# end

## Code generation => generate the 27 macros
for ix ∈ 0:N
    @eval begin
        macro $(Symbol(string("R", ix, "_str")))(s::AbstractString)
            return rotate($ix, s)
        end
    end
end
