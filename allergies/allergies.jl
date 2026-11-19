const ALLERGENS::NTuple{8,String} = (
    "eggs",
    "peanuts",
    "shellfish",
    "strawberries",
    "tomatoes",
    "chocolate",
    "pollen",
    "cats",
)
# A Tuple is immutable, ordered, and stack-allocated.
# Position i (1..8) maps directly to bit i - 1, whose mask is 1 << (i - 1) (1, 2, 4, ..., 128).



"""
    allergy_list(score::Integer) -> Set{String}

Return the `Set{String}` of allergens encoded by the lower 8 bits of `score`.

- Type-stable: `Set{String}(...)` always returns `Set{String}`, even when empty (`score == 0` or `256`).
- Automatically ignores bits `≥ 256`: only bits `0..7` are tested, so `256`, `257`, and `509` work with no `% 256`, `log`, `ceil`, or `next_pow`.
"""
function allergy_list(score::Integer)
    score < 0 && throw(DomainError(score, "Expecting score ≥ 0"))
    allergy_list(UInt(score))
end

function allergy_list(score::UInt)
    Set{String}(
        allergen for (ix, allergen) in enumerate(ALLERGENS) # 1, 2, .., 8
        if !iszero(score & (1 << (ix - 1)))
    )
end

"""
    allergic_to(score::Integer, allergen::AbstractString) -> Bool

Return `true` if `score` encodes an allergy to `allergen`, `false` otherwise.

- `==(allergen)` is Julia's curried equality predicate (`x -> x == allergen`).
- Unknown allergen strings return `false` (`ix === nothing`).
- Zero heap allocations.
"""
function allergic_to(score::Integer, allergen::AbstractString)::Bool
    score < 0 && throw(DomainError("Expecting score ≥ 0"))
    allergen ∈ allergy_list(UInt(score))
end

function allergic_to(score::UInt, allergen::AbstractString)
    ix = findfirst(==(allergen), ALLERGENS)
    ix !== nothing && !iszero(score & (1 << (ix - 1)))
end
