# canonical data version: 1.2.0

using Test

include("atbash-cipher.jl")

long_str = """
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

@testset "encoding from English to atbash" begin
  @test encode("  ") == ""
  @test encode("yes") == "bvh"
  @test encode("no") == "ml"
  @test encode("OMG") == "lnt"
  @test encode("O M G") == "lnt"
  @test encode("mindblowingly") == "nrmwy oldrm tob"
  @test encode("Testing,1 2 3, testing.") == "gvhgr mt123 gvhgr mt"
  @test encode("Truth is fiction.") == "gifgs rhurx grlm"
  @test encode("Truthisfiction.") == "gifgs rhurx grlm"
  @test encode("Free Will is a delusion. Face it") == "uivvd roorh zwvof hrlmu zxvrg"
  @test encode("The quick brown fox jumps over the lazy dog.") == "gsvjf rxpyi ldmul cqfnk hlevi gsvoz abwlt"

  @test (encode ∘ string)(long_str) == "xslig dlslf hvslo whylg szorp vrmwr tmrgb rmuzr ievil mzdsv ivdvo zblfi hxvmv uilnz mxrvm gtifw tvyiv zpglm vdnfg rmbds vivxr eroyo llwnz pvhxr erosz mwhfm xovzm uilnu ligsg svuzg zoolr mhlug svhvg dlulv hzkzr iluhg zixil hhwol evihg zpvgs vrior uvdsl hvnrh zwevm gfiwk rgvlf hlevi gsild hwlgs drgsg svriw vzgsy fibgs vrikz ivmgh hgiru vgsvu vziuf okzhh ztvlu gsvri wvzgs nzipw olevz mwgsv xlmgr mfzmx vlugs vrikz ivmgh iztvd srxsy fggsv rixsr owivm hvmwm zftsg xlfow ivnle vrhml dgsvg dlslf ihgiz uurxl ulfih gztvg svdsr xsrub lfdrg skzgr vmgvz ihzgg vmwds zgsvi vhszo onrhh lfigl rohsz oohgi revgl nvmw"
end

@testset "decoding from atbash to English" begin
  @test decode("vcvix rhn") == "exercism"
  @test decode("zmlyh gzxov rhlug vmzhg vkkrm thglm v") == "anobstacleisoftenasteppingstone"
  @test decode("gvhgr mt123 gvhgr mt") == "testing123testing"
  @test decode("gsvjf rxpyi ldmul cqfnk hlevi gsvoz abwlt") == "thequickbrownfoxjumpsoverthelazydog"
  @test decode("vc vix    r hn") == "exercism"
  @test decode("zmlyhgzxovrhlugvmzhgvkkrmthglmv") == "anobstacleisoftenasteppingstone"
  @test decode("zmlyh gzxov rhlug vmzh gvkkr mthgl mv") == "anobstacleisoftenasteppingstone"
  @test decode("AnObstacleIsOftenASteppingStone") == "zmlyhgzxovrhlugvmzhgvkkrmthglmv"
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
               long_str]
    @test (decode ∘ encode)(text) == replace(lowercase(text), r"\s+|\.|,|\?|!|;|;|\+|\*|\-|/|%|\$|\^|&|'|\"" => "")
  end
end
