"""
The goal of this exercise is to implement VLQ encoding/decoding.

In short, the goal of this encoding is to encode integer values in a way that would save bytes.
Only the first 7 bits of each byte is significant (right-justified; sort of like an ASCII byte).
So, if you have a 32-bit value, you have to unpack it into a series of 7-bit bytes.
Of course, you will have a variable number of bytes depending upon your integer.
To indicate which is the last byte of the series, you leave bit #7 clear. In all of the preceding bytes, you set bit #7.

So, if an integer is between 0-127, it can be represented as one byte.
Although VLQ can deal with numbers of arbitrary sizes, for this exercise we will restrict ourselves to only numbers that fit in a 32-bit unsigned integer.
Here are examples of integers as 32-bit values, and the variable length quantities that they translate to:

 NUMBER        VARIABLE QUANTITY
00000000              00
00000040              40
0000007F              7F
00000080             81 00
00002000             C0 00
00003FFF             FF 7F
00004000           81 80 00
00100000           C0 80 00
001FFFFF           FF FF 7F
00200000          81 80 80 00
08000000          C0 80 80 00
0FFFFFFF          FF FF FF 7F

"""

const SHIFT = 7
const MOD = 0x80
const KEEP1 = 0x7f


function encode(vnum::Vector{T})::Vector{<: Unsigned} where {T <: Unsigned}
  # < 0x7F ≡ 127
  length(vnum) == 1 && vnum[1] ≤ 0x7f && return vnum

  r_ary = UInt8[];
  for n ∈ vnum
    ary = UInt8[];
    low_part = n % MOD             # lower 8 byte (rightmost one) ==> zero-ed leftmost bit
    push!(ary, low_part)
    r = n >> SHIFT                 # divide until...
    while (r > 0x00)               # ... we reach 0
      push!(ary, r % MOD + MOD)    # set leftmost bit to 1
      r >>= SHIFT                  # next
    end

    push!(r_ary, reverse(ary)...)  # reverse byte order
  end

  r_ary
end

function encode(vnum::Vector{T})::Vector{<: Unsigned} where {T <: Signed}
  length(vnum) == 1 && vnum[1] == zero(T) && return [0x00]

  throw(ArgumentError("Expecting Unsigned Values"))
end

function decode(vnum::Vector{T})::Vector{UInt32} where {T <: Unsigned}
  """
  Result will be Vector{UInt32}, given the context (and constraints)

  Ex. [0xff, 0xff, 0x7f] .& 0x7f ≡ [0x7f, 0x7f, 0x7f]
      next init. sum with lower byte 07f (at pos 3 above)    ≡ 0x0000007f
      next start at pos and shift 2 byte: UInt32(0x7f) << 7  ≡ 0x00003f80
      next pos 1                          UInt32(0x7f) << 14 ≡ 0x001fc000

      Σ(0x0000007f, 0x00003f80, 0x001fc000) ≡ 0x0001fffff
  """
  rsum = Vector{UInt32}()

  # get index of byte whose leftmost bit is 0 - these are the boundaries
  ixes =  get_boundaries(vnum)
  length(ixes) == 0 && throw(ArgumentError("Incomplete sequence"))

  slices = extract_slices(vnum, ixes)

  # Now we can decode each slice
  for slice ∈ slices
    slice = slice .& KEEP1              # NOTE: broadcast

    # closure => side effect
    shift = -SHIFT
    λ(byte) = (shift += SHIFT; UInt32(byte) << shift)

    sum_ = map(λ, slice |> reverse) |>  # multiply
      sum                               # add

    push!(rsum, sum_)
  end

  rsum
end

function get_boundaries(vnum::Vector{T}) where {T <: Unsigned}
  filter(p -> (p[2] & MOD) >> SHIFT == 0x00,
         zip(1:length(vnum), vnum) |> collect) |>
    a -> map(p -> p[1], a)
end

function extract_slices(vnum::Vector{T}, ixes::Vector{<: Integer}) where {T <: Unsigned}
  slices = Vector{Vector{UInt8}}()
  s_ix = 1

  for ix ∈ ixes
    push!(slices, vnum[s_ix:ix])
    s_ix = ix + 1
  end

  slices
end
