using Test

include("difference-of-squares.jl")

# Helper function
function test_diff(n::Integer)::String
  difference(n) |> n -> format_n(n)
end

@testset "Square the sum of the numbers up to the given number" begin
  @test square_of_sum(5)::Integer == 225
  @test square_of_sum(10)::Integer == 3025
  @test square_of_sum(100)::Integer == 25502500

  ## Addition
  @test square_of_sum(1_000)::Integer            ==            250500250000
  @test square_of_sum(5_000)::Integer            ==         156312506250000
  @test square_of_sum(10_000)::Integer           ==        2500500025000000
  @test square_of_sum(100_000)::Integer          ==    25000500002500000000 # 6553755928790448384
  @test square_of_sum(UInt128(500_000))::Integer == 15625062500062500000000

  ## overflow -8222430735553051648 !
  @test square_of_sum(1_000_000)::Integer       == 250000500000250000000000 # 0x8de40ecf711b4400
  @test square_of_sum(UInt(1_000_000))::Integer == 250000500000250000000000 # 0x8de40ecf711b4400


end

@testset "Sum the squares of the numbers up to the given number" begin
  @test sum_of_squares(5)::Integer == 55
  @test sum_of_squares(10)::Integer == 385
  @test sum_of_squares(100)::Integer == 338350

  @test sum_of_squares(1_000)::Integer   ==         333833500
  @test sum_of_squares(5_000)::Integer   ==       41679167500
  @test sum_of_squares(10_000)::Integer  ==      333383335000
  @test sum_of_squares(100_000)::Integer ==   333338333350000
  @test sum_of_squares(200_000)::Integer ==  2666686666700000
  @test sum_of_squares(500_000)::Integer == 41666791666750000

  @test sum_of_squares(1_000_000)::Integer == 333333833333500000

  @test sum_of_squares(  5_000_000) ==      41666679166667500000   # 0x17931d46a0b7ff35
  @test sum_of_squares( 10_000_000) ==     333333383333335000000   # 0x11ee1210d28be3c0
  @test sum_of_squares(100_000_000) ==  333333338333333350000000


  ## overflow: -8618545151510398080
  @test sum_of_squares(500_000_000)::Integer == 41666666791666666750000000  # 0x0864c6d9038ebb80

  ## here UInt64 (abbreviated as UInt)
  # @test sum_of_squares(UInt(500_000_000))::UInt == 0x0864c6d9038ebb80
  # @test sum_of_squares(UInt128(1_000_000_000))::UInt128 == 0x000000000113ba143c35db6e2af67700 # ==
  # @test sum_of_squares(UInt128(2_000_000_000))::UInt128 == 0x00000000089dd0a1c5ed6e09cd50ee00 # ==
end

@testset "Subtract sum of squares from square of sums" begin
  @test difference(0)::Integer == 0
  @test difference(5)::Integer == 170
  @test difference(10)::Integer == 2640
  @test difference(100)::Integer == 25164150
  @test difference(1000)::Integer == 250166416500    # == 0x0000003a3f149474
  @test difference(5000)::Integer == 156270827082500 # == 0x00008e20a3231304

  ##
  @test difference(UInt(1_000_000))::Integer == 250000166666416666500000
  @test difference(4_000_000)::Integer == 64000010666662666666000000
  @test difference(UInt128(4_000_000))::Integer == 0x000000000034f08787bad496918c3e80

  @test difference(9_000_000_000)::Integer == 1640250000121499999979749999998500000000
  @test difference(9_000_000_000_000_000)::Integer == 1640250000000000121499999999999979749999999999998500000000000000

  # typeof(90_000_000_000_000_000_000) == Int128
  @test test_diff(90_000_000_000_000_000_000::Integer) == "16_402_500_000_000_000_000_121_499_999_999_999_999_997_974_999_999_999_999_999_985_000_000_000_000_000_000"
  @test test_diff(900_000_000_000_000_000_000::Integer) == "164_025_000_000_000_000_000_121_499_999_999_999_999_999_797_499_999_999_999_999_999_850_000_000_000_000_000_000"
  @test test_diff(9_000_000_000_000_000_000_000::Integer) == "1_640_250_000_000_000_000_000_121_499_999_999_999_999_999_979_749_999_999_999_999_999_998_500_000_000_000_000_000_000"
  @test test_diff(9_000_000_000_000_000_000_000_000::Integer) == "1_640_250_000_000_000_000_000_000_121_499_999_999_999_999_999_999_979_749_999_999_999_999_999_999_998_500_000_000_000_000_000_000_000"
  @test test_diff(9_000_000_000_000_000_000_000_000_000::Integer) == "1_640_250_000_000_000_000_000_000_000_121_499_999_999_999_999_999_999_999_979_749_999_999_999_999_999_999_999_998_500_000_000_000_000_000_000_000_000"
  @test test_diff(9_000_000_000_000_000_000_000_000_000_000::Integer) == "1_640_250_000_000_000_000_000_000_000_000_121_499_999_999_999_999_999_999_999_999_979_749_999_999_999_999_999_999_999_999_998_500_000_000_000_000_000_000_000_000_000"
  @test test_diff(9_000_000_000_000_000_000_000_000_000_000_000::Integer) == "1_640_250_000_000_000_000_000_000_000_000_000_121_499_999_999_999_999_999_999_999_999_999_979_749_999_999_999_999_999_999_999_999_999_998_500_000_000_000_000_000_000_000_000_000_000"

  @test test_diff(100_000_000_000_000_000_000_000_000_000_000_000_000::Integer) =="25_000_000_000_000_000_000_000_000_000_000_000_000_166_666_666_666_666_666_666_666_666_666_666_666_664_166_666_666_666_666_666_666_666_666_666_666_666_650_000_000_000_000_000_000_000_000_000_000_000_000" == "25_000_000_000_000_000_000_000_000_000_000_000_000_166_666_666_666_666_666_666_666_666_666_666_666_664_166_666_666_666_666_666_666_666_666_666_666_666_650_000_000_000_000_000_000_000_000_000_000_000_000" == "25_000_000_000_000_000_000_000_000_000_000_000_000_166_666_666_666_666_666_666_666_666_666_666_666_664_166_666_666_666_666_666_666_666_666_666_666_666_650_000_000_000_000_000_000_000_000_000_000_000_000"

  @test test_diff(150_000_000_000_000_000_000_000_000_000_000_000_000::Integer) == "126_562_500_000_000_000_000_000_000_000_000_000_000_562_499_999_999_999_999_999_999_999_999_999_999_994_374_999_999_999_999_999_999_999_999_999_999_999_975_000_000_000_000_000_000_000_000_000_000_000_000" == "126_562_500_000_000_000_000_000_000_000_000_000_000_562_499_999_999_999_999_999_999_999_999_999_999_994_374_999_999_999_999_999_999_999_999_999_999_999_975_000_000_000_000_000_000_000_000_000_000_000_000"

  # over 170_141_183_460_469_231_731_687_303_715_884_105_727 => BigInt...
  @test test_diff(200_000_000_000_000_000_000_000_000_000_000_000_000::Integer) == "400_000_000_000_000_000_000_000_000_000_000_000_001_333_333_333_333_333_333_333_333_333_333_333_333_323_333_333_333_333_333_333_333_333_333_333_333_333_300_000_000_000_000_000_000_000_000_000_000_000_000"

  ## Performance
  # for cand in [9_000_000_000_000_000_000_000_000_000, 9_000_000_000_000_000_000_000_000_000_000_000, 100_000_000_000_000_000_000_000_000_000_000_000_000,
  #              150_000_000_000_000_000_000_000_000_000_000_000_000, 200_000_000_000_000_000_000_000_000_000_000_000_000 ]
  #   @time x = difference(cand)
  #   @show cand, x
  # end
end
