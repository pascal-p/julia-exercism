import Base: +, -, *, /, ^
import Base: ==, ≠, ≈
import Base: abs, show

struct ComplexNumber{T1 <: Number, T2 <: Number} <: Number
  real::T1
  imag::T2

  ComplexNumber(real::T1, imag::T2) where {T1 <: Number, T2 <: Number} = new{T1, T2}(real, imag)
  ComplexNumber(real::Integer, imag::Integer) = new{Integer, Integer}(real, imag)
  ComplexNumber(real::Real, imag::Real) = new{Real, Real}(real, imag)
end

const CompNum = ComplexNumber

CompNum(n::Integer) = CompNum(n, zero(n))
CompNum(x::T, y::T) where {T <: Number} = CompNum{T, T}(x, y)

real(c::CompNum) = c.real
imag(c::CompNum) = c.imag

+(c₁::CompNum, c₂::CompNum)::CompNum = CompNum(c₁.real + c₂.real, c₁.imag + c₂.imag)
-(c₁::CompNum, c₂::CompNum)::CompNum = CompNum(c₁.real - c₂.real, c₁.imag - c₂.imag)

*(c₁::CompNum, c₂::CompNum)::CompNum = CompNum(c₁.real * c₂.real - c₁.imag * c₂.imag, c₁.real * c₂.imag + c₁.imag * c₂.real)
function /(c₁::CompNum, c₂::CompNum)::CompNum
  c = *(c₁, conj(c₂))
  sn = squared_norm(c₂)
  CompNum(c.real / sn, c.imag / sn)
end

function ^(c::CompNum, n::Integer)
  if n == 2
    DT = typeof(c.real)
    return CompNum(c.real * c.real - c.imag * c.imag, DT(2) * c.real * c.imag)
  end
  throw(ArgumentError("Not yet fully Implemented"))
end
conj(c::CompNum) = CompNum(c.real, -c.imag)

abs(c::CompNum) = √(squared_norm(c))

squared_norm(c::CompNum) = c.real ^ 2 + c.imag ^ 2

==(c₁::CompNum, c₂::CompNum) = c₁.real == c₂.real && c₂.imag == c₂.imag
==(c::CompNum, x::Integer) = ==(c, CompNum(x))
==(x::Integer, c::CompNum) = ==(CompNum(x), c)

≠(c₁::CompNum, c₂::CompNum) = !(c₁ == c₂)
≠(c::CompNum, x::Integer) = !(c == x)
≠(x::Integer, c::CompNum) = !(c == x)

≈(c₁::CompNum, c₂::CompNum; atol=1e-7) = abs(squared_norm(c₁) - squared_norm(c₂)) ≤ atol

function Base.show(io::IO, c::CompNum{T}) where {T <: Number}
  if c.real == zero(typeof(c.real)) && c.imag == zero(typeof(c.imag))
    print(io, zero(c.real))

  elseif c.real == zero(typeof(c.real))
    print(io, "$(c.imag)jm")

  elseif c.imag == zero(typeof(c.imag))
    print(io, "$(c.real) + 0jm")

  else
    print(io, "$(c.real) + $(c.imag)jm")
  end
end
