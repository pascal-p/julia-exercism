"""Calculate the number of grains on square `square`."""
function on_square(square::Unsigned)
  UT = typeof(square)
  square > UT(64) && throw(DomainError("Should be > 0 and ≤ 64"))

  UT(2) ^ (square - one(UT))
end

function on_square(square::Integer)
  (square ≤ zero(typeof(square)) || square > 64) && throw(DomainError("Should be > 0 and ≤ 64"))
  on_square(Unsigned(square))
end

"""Calculate the total number of grains after square `square`."""
function total_after(square::Unsigned)
  UT = typeof(square)
  square > UT(64) && throw(DomainError("Should be > 0 and ≤ 64"))

  UT(2) ^ square - one(UT)
end

function total_after(square::Integer)
  (square ≤ zero(typeof(square)) || square > 64) && throw(DomainError("Should be > 0 and ≤ 64"))
  total_after(Unsigned(square))
end
