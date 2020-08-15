using Test

include("transpose.jl")

for fn_2_test in [transpose_strings_alt, transpose_strings]
  println("==== $(fn_2_test) implementation")

  @testset "empty string" begin
    s = []
    @test fn_2_test(s) == s
    @test (fn_2_test ∘ fn_2_test)(s) == s
  end

  @testset "string with special chars" begin
    s = ["aaaa\1", "bbb"]
    @test fn_2_test(s) == ["ab", "ab", "ab", "a", "\x01"]
    @test (fn_2_test ∘ fn_2_test)(s) == s
  end

  @testset "string with unicode chars/1" begin
    s = ["α β ∘π", "A B OP"]
    @test fn_2_test(s) == ["αA", "  ",  "βB", "  ", "∘O", "πP"]
    @test (fn_2_test ∘ fn_2_test)(s) == s
  end

  @testset "string with unicode chars/2" begin
    s = ["αβγδϵηρϕψℵ π ∘", "ABCDEFHIJ12345", "    &%\$ζΩμ"]
    @test fn_2_test(s) == ["αA ", "βB ", "γC ", "δD ", "ϵE&", "ηF%", "ρH\$", "ϕIζ", "ψJΩ", "ℵ1μ", " 2", "π3", " 4", "∘5"]
    @test (fn_2_test ∘ fn_2_test)(s) == s
  end

  @testset "two characters in a row" begin
    a = ["A1"]
    @test fn_2_test(a) == ["A", "1"]
    @test (fn_2_test ∘ fn_2_test)(a) == a
  end

  @testset "two characters in a column" begin
    a = ["A", "1"]
    @test fn_2_test(a) == ["A1"]
    @test (fn_2_test ∘ fn_2_test)(a) == a
  end

  @testset "simple" begin
    a = ["ABC", "123"]
    @test fn_2_test(a) == [
          "A1",
          "B2",
          "C3"
        ]
    @test (fn_2_test ∘ fn_2_test)(a) == a
  end

  @testset "with spaces 1" begin
    a = ["ABCDEF", "123"]
    @test fn_2_test(a) == [
          "A1",
          "B2",
          "C3",
          "D", "E", "F"
        ]
    @test (fn_2_test ∘ fn_2_test)(a) == a
  end

  @testset "with spaces 1" begin
    a = ["ABCDEF", "123", "abcdef"]
    @test fn_2_test(a) == [
          "A1a",
          "B2b",
          "C3c",
          "D d", "E e", "F f"
        ]
  end

  @testset "single line" begin
    a = ["Single line."]
    @test fn_2_test(a) == [
          "S",
          "i",
          "n",
          "g",
          "l",
          "e",
          " ",
          "l",
          "i",
          "n",
          "e",
          "."
        ]
    @test (fn_2_test ∘ fn_2_test)(a) == a
  end

  @testset "first line longer than second line" begin
    a = ["The fourth line.",
         "The fifth line."]
    @test fn_2_test(a) == [
          "TT",
          "hh",
          "ee",
          "  ",
          "ff",
          "oi",
          "uf",
          "rt",
          "th",
          "h ",
          " l",
          "li",
          "in",
          "ne",
          "e.",
          "."
        ]
    @test (fn_2_test ∘ fn_2_test)(a) == a
  end

  @testset "second line longer than first line" begin
    a = ["The first line.",
         "The second line."]
    @test fn_2_test(a) == [
          "TT",
          "hh",
          "ee",
          "  ",
          "fs",
          "ie",
          "rc",
          "so",
          "tn",
          " d",
          "l ",
          "il",
          "ni",
          "en",
          ".e",
          " ."
        ]
    # @test (fn_2_test ∘ fn_2_test)(a) == a  ## violated
  end

  @testset "3rd line longer than 1st line and 2nd line" begin
    a = ["The first line.",
         "The second line.",
         "And the third line is even longer!"]
    @test fn_2_test(a) == [
               "TTA",
               "hhn",
               "eed",
               "   ",
               "fst",
               "ieh",
               "rce",
               "so ",
               "tnt",
               " dh",
               "l i",
               "ilr",
               "nid",
               "en ",
               ".el",
               " .i",
               "  n",
               "  e",
               "   ",
               "  i",
               "  s",
               "   ",
               "  e",
               "  v",
               "  e",
               "  n",
               "   ",
               "  l",
               "  o",
               "  n",
               "  g",
               "  e",
               "  r",
               "  !"
        ]
    # @test (fn_2_test ∘ fn_2_test)(a) == a  ## violated
  end

  @testset "3rd line longer than 1st line and 2nd line" begin
    a = ["The first line",
         "The second line is longer",
         "The third line here"]
    @test fn_2_test(a) == [
          "TTT",
          "hhh",
          "eee",
          "   ",
          "fst",
          "ieh",
          "rci",
          "sor",
          "tnd",
          " d ",
          "l l",
          "ili",
          "nin",
          "ene",
          " e ",
          "  h",
          " ie",
          " sr",
          "  e",
          " l",
          " o",
          " n",
          " g",
          " e",
          " r"
        ]
    # @test (fn_2_test ∘ fn_2_test)(a) == a  ## violated
  end

  @testset "square" begin
    a = ["HEART",
         "EMBER",
         "ABUSE",
         "RESIN",
         "TREND"]
    @test fn_2_test(a) == [
          "HEART",
          "EMBER",
          "ABUSE",
          "RESIN",
          "TREND"
        ]
    @test (fn_2_test ∘ fn_2_test)(a) == a
  end

  @testset "rectangle" begin
    a = ["FRACTURE",
         "OUTLINED",
         "BLOOMING",
         "SEPTETTE"]
    @test fn_2_test(a) == [
          "FOBS",
          "RULE",
          "ATOP",
          "CLOT",
          "TIME",
          "UNIT",
          "RENT",
          "EDGE"
        ]
    @test (fn_2_test ∘ fn_2_test)(a) == a
  end

  @testset "triangle1" begin
    a = [
          "T",
          "EE",
          "AAA",
          "SSSS",
          "EEEEE",
          "RRRRRR"
        ]
    @test fn_2_test(a) == [
          "TEASER",
          " EASER",
          "  ASER",
          "   SER",
          "    ER",
          "     R"
        ]
    # @test (fn_2_test ∘ fn_2_test)(a) == a  ## violated
  end

  @testset "triangle2" begin
    a = [
          "TTTTTT",
          "EEEEE",
          "AAAA",
          "SSS",
          "EE",
          "R"
        ]
    @test fn_2_test(a) == [
          "TEASER",
          "TEASE",
          "TEAS",
          "TEA",
          "TE",
          "T",
    ]
    @test (fn_2_test ∘ fn_2_test)(a) == a
  end

  @testset "pseudo triangle" begin
    a = [
          "T     ",
          "EE    ",
          "AAA   ",
          "SSSS  ",
          "EEEEE ",
          "RRRRRR"
        ]
    @test fn_2_test(a) == [
          "TEASER",
          " EASER",
          "  ASER",
          "   SER",
          "    ER",
          "     R"
        ]
    @test (fn_2_test ∘ fn_2_test)(a) == a  ## violated
  end

  @testset "many lines" begin
    a = [
          "Chor. Two households, both alike in dignity,",
          "In fair Verona, where we lay our scene,",
          "From ancient grudge break to new mutiny,",
          "Where civil blood makes civil hands unclean.",
          "From forth the fatal loins of these two foes",
          "A pair of star-cross'd lovers take their life;",
          "Whose misadventur'd piteous overthrows",
          "Doth with their death bury their parents' strife.",
          "The fearful passage of their death-mark'd love,",
          "And the continuance of their parents' rage,",
          "Which, but their children's end, naught could remove,",
          "Is now the two hours' traffic of our stage;",
          "The which if you with patient ears attend,",
          "What here shall miss, our toil shall strive to mend."
        ]
    @test fn_2_test(a) == [
          "CIFWFAWDTAWITW",
          "hnrhr hohnhshh",
          "o oeopotedi ea",
          "rfmrmash  cn t",
          ".a e ie fthow ",
          " ia fr weh,whh",
          "Trnco miae  ie",
          "w ciroitr btcr",
          "oVivtfshfcuhhe",
          " eeih a uote  ",
          "hrnl sdtln  is",
          "oot ttvh tttfh",
          "un bhaeepihw a",
          "saglernianeoyl",
          "e,ro -trsui ol",
          "h uofcu sarhu ",
          "owddarrdan o m",
          "lhg to'egccuwi",
          "deemasdaeehris",
          "sr als t  ists",
          ",ebk 'phool'h,",
          "  reldi ffd   ",
          "bweso tb  rtpo",
          "oea ileutterau",
          "t kcnoorhhnatr",
          "hl isvuyee'fi ",
          " atv es iisfet",
          "ayoior trr ino",
          "l  lfsoh  ecti",
          "ion   vedpn  l",
          "kuehtteieadoe ",
          "erwaharrar,fas",
          "   nekt te  rh",
          "ismdsehphnnosa",
          "ncuse ra-tau l",
          " et  tormsural",
          "dniuthwea'g t ",
          "iennwesnr hsts",
          "g,ycoi tkrttet",
          "n ,l r s'a anr",
          "i  ef  'dgcgdi",
          "t  aol   eoe,v",
          "y  nei sl,u; e",
          ",  .sf to l   ",
          "     e rv d  t",
          "     ; ie    o",
          "       f, r   ",
          "       e  e  m",
          "       .  m  e",
          "          o  n",
          "          v  d",
          "          e  .",
          "          ,"]
    # @test (fn_2_test ∘ fn_2_test)(a) == a  # violated
  end

println(" ----------------------------- \n\n")
end
