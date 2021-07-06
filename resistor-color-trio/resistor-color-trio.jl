"""
  Each resistor has a resistance value.
  Resistors are small - so small in fact that if you printed the resistance value on them, it would be hard to read. To get around this problem, manufacturers print color-coded bands onto the resistors to denote their resistance values.
  Each band acts as a digit of a number. For example, if they printed a brown band (value 1) followed by a green band (value 5), it would translate to the number 15.

  The color bands are encoded as follows:
    Black: 0
    Brown: 1
    Red: 2
    Orange: 3
    Yellow: 4
    Green: 5
    Blue: 6
    Violet: 7
    Grey: 8
    White: 9

  In resistor-color duo you decoded the first two colors. For instance: orange-orange got the main value 33.
  The third color stands for how many zeros need to be added to the main value.
  The main value plus the zeros gives us a value in ohms.
  The program will take 3 colors as input,

   For example:
   - orange-orange-black would be 33 and no zeros, which becomes 33 ohms.
   - orange-orange-red would be 33 and 2 zeros, which becomes 3300 ohms.
   - orange-orange-orange would be 33 and 3 zeros, which becomes 33000 ohms.

  This exercise is about translating the colors into a label:
    "... ohms"

  So an input of "orange", "orange", "black" should return:
    "33 ohms"

  When we get more than a thousand ohms, we say "kiloohms". So an input of "orange", "orange", "orange" should return:
    "33 kiloohms"

"""

const NCOLORS = 3

const UNIT = "ohm"

const COLOR_MAP = Dict{Symbol, Integer}(
  :Black => 0,
  :Brown => 1,
  :Red => 2,
  :Orange => 3,
  :Yellow => 4,
  :Green => 5,
  :Blue => 6,
  :Violet => 7,
  :Grey => 8,
  :White => 9
)

const PREFIXES = Dict{Integer, String}(
  1000 => "kilo",
  1000000 => "mega" #?
)

function label(colors)
  @assert length(colors) == NCOLORS

  x, y, z = colors
  ans = (get_value(x) * 10 + get_value(y)) * 10 ^ get_value(z)
  prefix = ""

  for fact ∈ keys(PREFIXES) |> collect |> a -> sort(a; rev=true)
    if ans % fact == 0
      ans ÷= fact
      prefix = PREFIXES[fact]
      break
    end
  end

  return string(ans, " ",
                length(prefix) > 0 ? prefix : "",
                ans > 1 ? string(UNIT, "s") : UNIT)
end

@inline function get_value(color::String)
  get(COLOR_MAP, titlecase(color) |> Symbol, 0)
end
