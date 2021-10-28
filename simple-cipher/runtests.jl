using Test

include("simple_cipher.jl")

const LongStr = """
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


@testset "encode" begin
  @test encode("aaadefghij", "bxdeasd")  == "bxdhexhi5m"

  @test encode("identity", "aaaa") == "identity"

  @test encode("Iamapandabear", "qayaeaagaciai") == "yaaatanjadma7"

  @test encode("I am a panda bear", "qayaeaagaciai") == "yaaatanjadma7"

  key₁ = "gsorbyehnyqrstjjzsazmgbogwjehuaqyhsogutoasnxvzwdxvnqzyvetgndkuukapncsusudmepuvgrmhtryekvgqlcmnbgrzth"
  @test encode("Free Will is nothing but an Illusion", key₁) == "l9svx6psvg35b0rw5tuimtjzrg1mv7"

  key₂ = "wflwgxchlhskvglygcnmzfzffrupozorlwkcoywtfypeatwjslmgashstboccehlftrfmmgxsnqzwexaibbqxwyhmvujeansbqto"
  @test encode(LongStr, key₂) == "ymzdzjqoz1ao2uw1yd156fanpv22r7u4tf8k13w1wjtvo6w5zp3kwwsshp8tuglyjy8tymtz0r3i2vhdofc71w8008y5qu60oef30wpyoiksms6yysl8kupuknamf4x78cq2pwxh5c8ytf8lt00os4mrl6p5bptvjizpyf5k0qyx7nygajftisd7begkx9fnvs6sluc30n27o2g3svao7o3yjxrzizgiuzdt2j65601vvfafx13xhf42z4tki9kwtuvdwv54mxzw1mx1568hfv5fmuiu20yyrf5yes5shu71fmp4x0gh4o4kcqo9uxrmciimjt82771bl9mg23f0j66taa0wb33ggw3z1dvdwx0sj18htur09r3h0r0nivhxgyc1xybnqo8wj86aiys0zjqoz192exl3lkp04tjwxauvsivv73sev61htibmt0bjbtqttwh9bb7vgrk7mtamq3kfzn1a8mfswvs9b49ztv5uwt40wuca8jyz"

end

@testset "encode error handling" begin
  @test_throws ArgumentError encode("This is a test.", "aa") # key is too short
end


@testset "decode" begin
  @test decode("iamapandabear", "aaaa") == "iamapandabear"

  @test decode("irfhzimolsorwhjqjbvwdnjooutlrn", "dabc") == "freewillisnothingbutanillusion"
end

@testset "decode error handling" begin
  @test_throws ArgumentError decode("This is a test.", "-----") # key is not alphanum
end

@testset "decode ✪ encode" begin
  key = "gsorbyehnyqrstjjzsazmgbogwjehuaqyhsogutoasnxvzwdxvnqzyvetgndkuukapncsusudmepuvgrmhtryekvgqlcmnbgrzth"
  for txt ∈ [ "yes",
              "omg",
              "OMG",
              "mindblowingly",
              "I M A G I N E!",
              "Truth is fiction.",
              "The quick brown fox jumps over the lazy dog.",
              "Testing, 1 2 3, testing.",
              "zmlyhgzxovrhlugvmzhgvkkrmthglmv",
              "anobstacleisoftenasteppingstone",
              "An obstacle is often a stepping stone" ]
    @test decode(encode(txt, key), key) == replace(lowercase(txt), r"[^a-z0-9]" => "")
  end
end
