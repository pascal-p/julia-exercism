const GROUP_SIZE = 5

"""
    encode(plain::AbstractString; group::Bool = true)

Encode `plain` using the Atbash cipher over ASCII Latin letters (`a` ↔ `z`,
`b` ↔ `y`, …). Digits `0`–`9` are preserved, case is normalized to lowercase,
and all punctuation, whitespace, and non-ASCII characters are ignored.

When `group` is `true` (default), output characters are separated into groups
of `5` with spaces. Returns a concrete `String`.
"""
function encode(plain::AbstractString; group::Bool = true)
    io = IOBuffer(; sizehint = ncodeunits(plain))
    count = 0

    for ch ∈ plain
        out =
            '0' ≤ ch ≤ '9' ? ch :
            (('a' ≤ ch ≤ 'z' || 'A' ≤ ch ≤ 'Z') ? 'z' - lowercase(ch) + 'a' : continue)

        if group && count > 0 && count % GROUP_SIZE == 0
            write(io, ' ')
        end

        write(io, out)
        count += 1
    end

    return String(take!(io))
end

"""
    decode(cipher::AbstractString)

Decode an Atbash-encoded string `cipher` back to lowercase ASCII letters and
digits with grouping spaces removed. Returns a concrete `String`.
"""
decode(cipher::AbstractString) = encode(cipher; group = false)
