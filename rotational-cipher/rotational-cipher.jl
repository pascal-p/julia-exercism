const N = 26

function rot_n_maker(n::Integer)
    n = mod(n, N)

    return function (pletter::AbstractChar)
        isasciilower(pletter) && return shift_letter(pletter, n)
        isasciiupper(pletter) && return shift_letter(pletter, n, base = 'A')
        pletter
    end
end

"""
    rotate(n::Integer, src::AbstractChar)
    rotate(n::Integer, src::AbstractString)

Apply a Caesar (rotational) cipher with shift `n` to an ASCII Latin letter or
string. Non-ASCII letters, digits, whitespace, and punctuation are preserved
unchanged. Any `Integer` key (including negative values and values `≥ 26`) is
reduced modulo 26 before shifting.
"""
function rotate(n::Integer, src::AbstractChar)
    rot_fn = rot_n_maker(n)
    rot_fn(src)
end

rotate(n::Integer, src::AbstractString) = map(rot_n_maker(n), src)

@inline isasciilower(letter::AbstractChar)::Bool = 'a' ≤ letter ≤ 'z'
@inline isasciiupper(letter::AbstractChar)::Bool = 'A' ≤ letter ≤ 'Z'

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
