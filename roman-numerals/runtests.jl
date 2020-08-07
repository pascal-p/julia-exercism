using Test

include("roman-numerals.jl")

# HINT: There is no need to be able to convert numbers larger than about 3000.
samples = Dict(
    1 => "I",
    2 => "II",
    3 => "III",
    4 => "IV",
    5 => "V",
    6 => "VI",
    9 => "IX",
    27 => "XXVII",
    42 => "XLII",
    48 => "XLVIII",
    59 => "LIX",
    93 => "XCIII",
    99 => "XCIX",
    141 => "CXLI",
    163 => "CLXIII",
    402 => "CDII",
    575 => "DLXXV",
    666 => "DCLXVI",
    911 => "CMXI",
    999 => "CMXCIX",
    1024 => "MXXIV",
    1703 => "MDCCIII",
    1970 => "MCMLXX",
    1991 => "MCMXCI",
    2000 => "MM",
    2001 => "MMI",
    2010 => "MMX",
    2017 => "MMXVII",
    2999 => "MMCMXCIX",
    3000 => "MMM"
)

@testset "convert $sample[1] to roman numeral" for sample in samples
    @test to_roman(sample[1]) == sample[2]
end

@testset "error handling" begin
    @test_throws ErrorException to_roman(0)
    @test_throws ErrorException to_roman(-2017)
end

@testset "convert 100 number" begin
  spec = [(100, "C"), (200, "CC"), (300, "CCC"), (400, "CD"), (500, "D"),
          (600, "DC"), (700, "DCC"), (800, "DCCC"), (900, "CM")]

  for (num, rom) in spec
    @test to_roman(num) == rom
  end
end

@testset "convert 10 to 20 number" begin
  spec = [(10, "X"), (11, "XI"), (12, "XII"), (13, "XIII"), (14, "XIV"),
          (15, "XV"), (16, "XVI"), (17, "XVII"), (18, "XVIII"), (19, "XIX")]

  for (num, rom) in spec
    @test to_roman(num) == rom
  end
end

@testset "convert all 10 number" begin
  spec = [(10, "X"), (20, "XX"), (30, "XXX"), (40, "XL"), (50, "L"),
          (60, "LX"), (70, "LXX"), (80, "LXXX"), (90, "XC")]

  for (num, rom) in spec
    @test to_roman(num) == rom
  end
end
