"""
  Atbash Cipher
  Assume only valid char (ascii)

  - Valid input set is given by regexp /[a-zA-Z0-9]+/
  - Ignoring punctuation (comprising space),
  - Ignoring any non ascii letter (but keep the 10 digit)
  - Ignoring case
  - Grouping by 5
"""

const GROUP_FACT = 5


function encode(plain::AbstractString; group::Bool = true)
    io = IOBuffer(; sizehint = ncodeunits(plain))  # or just: io = IOBuffer()
    count = 0

    for ch ∈ plain
        # 1. Decide whether `ch` is kept/mapped, or skip it with `continue`
        out =
            '0' ≤ ch ≤ '9' ? ch :
            (('a' ≤ ch ≤ 'z' || 'A' ≤ ch ≤ 'Z') ? 'z' - lowercase(ch) + 'a' : continue)

        # 2. Insert group separator *before* the next char (so never leading/trailing)
        if group && count > 0 && count % GROUP_FACT == 0
            write(io, ' ')
        end

        write(io, out)
        count += 1
    end

    String(take!(io))
end

decode(cipher::AbstractString)::AbstractString = encode(cipher; group = false)
