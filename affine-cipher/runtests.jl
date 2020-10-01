# canonical data version: 1.2.0

using Test

include("affine-cipher.jl")

LongStr = """
Chor. Two households, both alike in dignity,
In fair Verona, where we lay our scene,
From ancient grudge break to new mutiny,
Where civil blood makes civil hands unclean.
From forth the fatal loins of these two foes
A pair of star-cross'd lovers take their life;
Whose misadventur'd piteous overthrows
Doth with their death bury their parents' strife,
The fearful passage of their death-mark'd love,
And the continuance of their parents' rage,
Which, but their children's end, naught could remove,
Is now the two hours' traffic of our stage;
The which if you with patient ears attend,
What here shall miss, our toil shall strive to mend.
"""

@testset "Encoding" begin
  @test encode("  ", 5, 3) == ""
  @test encode("yes", 5, 7) == "xbt"
  @test encode("Test", 5, 7) == "ybty"
  @test encode("no", 15, 18) == "fu"
  @test encode("OMG", 21, 3) == "lvz"
  @test encode("O M G", 25, 47) == "hjp"
  @test encode("mindblowingly", 11, 15) == "rzcwa gnxzc dgt"
  @test encode("Testing,1 2 3, testing.", 3, 4) == "jqgjc rw123 jqgjc rw"
  @test encode("Truth is fiction.", 5, 17) == "iynia fdqfb ifje"
  @test encode("Truthisfiction.", 5, 17) == "iynia fdqfb ifje"
  @test encode("Free Will is a delusion. Face it", 7, 17) == "agttp vqqvn rmtqb nvlea rftvu"
  @test encode("The quick brown fox jumps over the lazy dog.", 17, 33) == "swxtj npvyk lruol iejdc blaxk swxmh qzglf"
  @test encode("tgxknetbyjznxaejgtnejoozgrnexgj", 23, 31) == "anobs tacle isoft enast eppin gston e"

  @test (encode)(LongStr, 17, 19) == """bixwe dxixv njixy snkxe ityzh jzgsz rgzel zgatz wmjwx gtdij wjdjy tlxvw nbjgj awxpt gbzjg erwvs rjkwj thexg jdpve zgldi jwjbz mzyky xxspt hjnbz mzyit gsnvg byjtg awxpa xweie ijate tyyxz gnxae ijnje dxaxj ntotz wxane twbwx nnsyx mjwne thjei jzwyz ajdix njpzn tsmjg evwso zejxv nxmjw eiwxd nsxei dzeie ijzws jteik vwlei jzwot wjgen newza jeija jtwav yotnn trjxa eijzw sjtei ptwhs yxmjt gseij bxgez gvtgb jxaei jzwot wjgen wtrjd izbik veeij zwbiz yswjg njgsg tvrie bxvys wjpxm jzngx deije dxixv wnewt aazbx axvwn etrje ijdiz bizal xvdze iotez jgejt wntee jgsdi teijw jnity ypznn xvwex zynit yynew zmjex pjgs"""
end

@testset "Encoding error handling" begin
  @test_throws ArgumentError encode("This is a test.", 6, 17)     # not coprime
  @test_throws ArgumentError encode("Truth is fiction.", 13, 21)  # not coprime

end

@testset "Decoding" begin
  @test decode("tytgn fjr", 3, 7) == "exercism"

  @test decode("ybty", 5, 7) == "test"
  @test decode("qdwju nqcro muwhn odqun oppmd aunwd o", 19, 16) == "anobstacleisoftenasteppingstone"
  @test decode("odpoz ub123 odpoz ub", 25, 7) == "testing123testing"
  @test decode("swxtj npvyk lruol iejdc blaxk swxmh qzglf", 17, 33) == "thequickbrownfoxjumpsoverthelazydog"
  @test decode("kqlfd jzvgy tpaet icdhm rtwly kqlon ubstx", 19, 13) == "thequickbrownfoxjumpsoverthelazydog"
  @test decode("vszzm    cly   yd cg    qdp", 15, 16) == "jollygreengiant"
  @test decode("AnObstacleIsOftenASteppingStone", 23, 31) == "tgxknetbyjznxaejgtnejoozgrnexgj"
end

## Exceptions
@testset "Decoding error handling" begin
  @test_throws ArgumentError decode("Test", 13, 5)   # not coprime
  @test_throws ArgumentError decode("ybty", 18, 13)  # not coprime either
end

@testset "encoding ∘ decoding" begin
  for text in ["yes", "omg", "OMG", "mindblowingly",
               "I M A G I N E!",
               "Truth is fiction.",
               "The quick brown fox jumps over the lazy dog.",
               "Testing,1 2 3, testing.",
               "zmlyhgzxovrhlugvmzhgvkkrmthglmv",
               "anobstacleisoftenasteppingstone",
               "An obstacle is often a stepping stone",
               LongStr]
    @test encode(text, 21, 3) |>
      s -> decode(s, 21, 3) == replace(lowercase(text),
                                       r"\s+|\.|,|\?|!|;|;|\+|\*|\-|/|%|\$|\^|&|'|\"" => "")
  end
end
