using Unicode

function yareverse(str::String; with_graphemes=false)::String
  rstr = ""
  if with_graphemes
    for gr ∈ Unicode.graphemes(str)
      rstr = string(gr, rstr)
    end
  else
    for c ∈ str
      rstr = string(c, rstr)
    end
  end
  return rstr
end
