"""
  to_rna(dna)

"""

const DNA_Nucleotides = ('A', 'C', 'G', 'T',)
const RNA_Nucleotides = ('U', 'G', 'C', 'A',)
const MAP_DNA_RNA = Dict{Char, Char}(d => r for (d, r) in zip(DNA_Nucleotides, RNA_Nucleotides))

function to_rna(dna::String)
  isempty(dna) && return ""
  
  rna::String = ""
  dna = uppercase(dna)  
  for ch in dna
    ch ∉ DNA_Nucleotides && throw(ErrorException("$(ch) ∉ $(DNA_Nucleotides)"))
  
    rna = string(rna, MAP_DNA_RNA[ch])
  end
  
  rna
end

