const NON_CHAR_REGEXP = r"""[\s+\.,;:!?'"_\-=\*\/]"""

function isisogram(str::AbstractString)::Bool
  "Support unicode string"
  isempty(str) && return true

  hsh = Dict{AbstractChar, Integer}()
  for ch in str
    occursin(NON_CHAR_REGEXP, string(ch)) && continue

    ch = lowercase(ch)
    get(hsh, ch, 0)> 0 && return false
    hsh[ch] = 1
  end

  return true
end
