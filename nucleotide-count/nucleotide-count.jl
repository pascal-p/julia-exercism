"""
    count_nucleotides(strand)

The frequency of each nucleotide within `strand` as a dictionary.

Invalid strands raise a `DomainError`.

"""
function count_nucleotides(strand)
  letters = ['A', 'C', 'G', 'T']
  hsh = Dict(l => 0 for l in letters)

  for ch in strand
    ch ∉ letters && throw(DomainError(strand, "all letters must be in $(letters)"))
    hsh[ch] += 1
  end

  return hsh
end
