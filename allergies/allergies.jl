const ALLERGIES = Dict{UInt, Symbol}(
  1 => :eggs,
  2 => :peanuts,
  4 => :shellfish,
  8 =>  :strawberries,
  16 => :tomatoes,
  32 =>  :chocolate,
  64 =>  :pollen,
  128 =>  :cats
)

const KEYS = keys(ALLERGIES) |> collect |> a -> sort(a, rev=true)

const MAXVAL = 256;

struct Allergies
  names::Set{Symbol}
  indexes::Vector{UInt}

  function Allergies(val::T) where {T <: Unsigned}
    val %= MAXVAL
    ary, allergies = (Vector{T}(), Set{Symbol}())
    for k ∈ KEYS
      if val ≥ k
        pushfirst!(ary, k)
        push!(allergies, ALLERGIES[k])
        val -= k
      end
      val < 0 && break
    end
    new(allergies, ary)
  end
end

# Other constructors
Allergies(val::T) where {T <: Integer} = val ≥ zero(T) ? Allergies(UInt(val)) :
  throw(ArgumentError("Expecting a natural integer"))

#
# Convert float => int, works only for floats ending with .0
# Any other value will throw an Exception
#
Allergies(val::T) where {T <: Real} = convert(UInt, val) |> Allergies

Allergies(_::Any) = throw(ArgumentError("Expecting a natural integer"))


allergic_to(self::Allergies, allergy::Symbol) = allergy ∈ self.names

allergic_to(self::Allergies, allergy::String) = allergic_to(self, allergy |> Symbol)


list(self::Allergies) = map(ix -> ALLERGIES[ix], self.indexes)
