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

function encode(vnum::Vector{T})::Vector{<: Unsigned} where {T <: Unsigned}
  # < 0x7F ≡ 127
  length(vnum) == 1 && vnum[1] ≤ 0x7f && return vnum

  r_ary = UInt8[];

  for n ∈ vnum
    ary = UInt8[];
    low_part = n % 0x80            # lower 8 byte (rightmost one) ==> zero-ed leftmost bit
    push!(ary, low_part)

    r = n >> 7                     # divide until...
    while (r > 0x00)               # ... we reach 0
      push!(ary, r % 0x80 + 0x80)  # set leftmost bit to 1
      r = r >> 7                   # 
    end

    push!(r_ary, reverse(ary)...)  # reverse byte order
  end

  r_ary
end

function encode(vnum::Vector{T})::Vector{<: Unsigned} where {T <: Signed}
  length(vnum) == 1 && vnum[1] == zero(T) && return [0x00]

  throw(ArgumentError("Expecting Unsigned Values"))
end

function decode(vnum::Vector{T}) where {T <: Unsigned}
end
