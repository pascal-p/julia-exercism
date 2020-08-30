"""
  count_nucleotides(strand)

The frequency of each nucleotide within `strand` as a dictionary.

Invalid strands raise a `DomainError`.
"""

const Nucleotides = ('A', 'C', 'G', 'T',)

function count_nucleotides(strand)
  hsh = Dict(l => 0 for l in Nucleotides)

  strand = uppercase(strand)
  for ch in strand
    ch ∉ Nucleotides && throw(DomainError(strand, "all letters must be in $(Nucleotides)"))
    hsh[ch] += 1
  end

  return hsh
end
