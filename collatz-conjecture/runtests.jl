# canonical data version: 1.2.1

using Test

include("collatz-conjecture.jl")

# canonical data
@testset "Canonical data" begin
  @test collatz_steps(1) == 0
  @test collatz_steps(16) == 4
  @test collatz_steps(12) == 9
  @test collatz_steps(1000000) == 152

  # src: https://en.wikipedia.org/wiki/Collatz_conjecture
  #      http://www.ericr.nl/wondrous/delrecs.html
  for (n, exp) in [(19, 20), (27, 111), (97, 118), (871, 178),
                   (6171, 261), (77031, 350), (837_799, 524),
                   (8_400_511, 685), (63_728_127, 949), (670_617_279, 986),
                   (9_780_657_630, 1132), (75_128_138_247, 1228),
                   (989_345_275_647, 1348),
                   (7_887_663_552_367, 1563),
                   (80_867_137_596_217, 1662),
                   (134_345_724_286_089, 1823),
                   (530_149_921_398_649, 1856),
                   (942_488_749_153_153, 1862),
                   (1_675_535_554_050_049, 1868),
                   (3_586_720_916_237_671, 1895),
                   (4_320_515_538_764_287, 1903),
                   (4_861_718_551_722_727, 1916),
                   (12_769_884_180_266_527, 2039),
                   (17_026_512_240_355_369, 2042),
                   (7_579_309_213_675_935, 1958),
                   (93_571_393_692_802_302, 2091),
                   (372_975_273_994_315_489, 2261),
                   (931_386_509_544_713_451, 2283),
                   (1_339_302_163_616_345_727, 2330),
                   (1_278_775_404_785_934_855, 2286),
    ]
    @test collatz_steps(n) == exp
    #
    # @test collatz_steps(871) == 178 # Interesting
    #
  end
  @test collatz_steps(BigInt(1_278_775_404_785_934_855)) == 2286

  @test_throws DomainError collatz_steps(0)
  @test_throws DomainError collatz_steps(-15)
end
