using Test

include("difference-of-squares.jl")

@testset "Square the sum of the numbers up to the given number" begin
  @test square_of_sum(5)::Integer == 225
  @test square_of_sum(10)::Integer == 3025
  @test square_of_sum(100)::Integer == 25502500

  ## Addition
  @test square_of_sum(1_000)::Integer == 250500250000
  @test square_of_sum(10_000)::Integer == 2500500025000000
  @test square_of_sum(100_000)::Integer == 6553755928790448384

  ## overflow -8222430735553051648 !
  @test square_of_sum(1_000_000)::Integer == 0x8de40ecf711b4400 # == 10224313338156499968
  @test square_of_sum(UInt(1_000_000))::Integer == 0x8de40ecf711b4400
end

@testset "Sum the squares of the numbers up to the given number" begin
  @test sum_of_squares(5)::Integer == 55
  @test sum_of_squares(10)::Integer == 385
  @test sum_of_squares(100)::Integer == 338350

  @test sum_of_squares(1_000)::Integer == 333833500
  @test sum_of_squares(10_000)::Integer == 333383335000
  @test sum_of_squares(100_000)::Integer == 333338333350000
  @test sum_of_squares(200_000)::Integer == 2666686666700000
  @test sum_of_squares(500_000)::Integer == 41666791666750000

  @test sum_of_squares(1_000_000)::Integer == 333333833333500000

  @test sum_of_squares(  5_000_000) == 0x17931d46a0b7ff35 # == 4773191019248396768
  @test sum_of_squares( 10_000_000) == 0x11ee1210d28be3c0 # == 1291990006563070912
  @test sum_of_squares(100_000_000) == 0x0956b27319342580 # == 672921401752298880

  ## overflow: -8618545151510398080
  @test sum_of_squares(500_000_000)::Integer == 0x0864c6d9038ebb80

  ## here UInt64 (abbreviated as UInt)
  @test sum_of_squares(UInt(500_000_000))::UInt == 0x0864c6d9038ebb80
  @test sum_of_squares(UInt128(1_000_000_000))::UInt128 == 0x000000000113ba143c35db6e2af67700 # ==
  @test sum_of_squares(UInt128(2_000_000_000))::UInt128 == 0x00000000089dd0a1c5ed6e09cd50ee00 # ==
end

@testset "Subtract sum of squares from square of sums" begin
  @test difference(0)::Integer == 0
  @test difference(5)::Integer == 170
  @test difference(10)::Integer == 2640
  @test difference(100)::Integer == 25164150
  @test difference(1000)::Integer == 250166416500    # == 0x0000003a3f149474
  @test difference(5000)::Integer == 156270827082500 # == 0x00008e20a3231304

  ##
  @test difference(UInt(1_000_000))::UInt == 0x8943d17479a4dba0
  @test difference(4_000_000)::Integer == 0x87bad496918c3e80 # 0x000000000034f08787bad496918c3e80
  @test difference(UInt128(4_000_000))::Integer == 0x000000000034f08787bad496918c3e80

  @test difference(9_000_000_000)::Integer == 0x9f09a4cb1a442656
  @test difference(9_000_000_000_000_000)::Integer == 0x24d474a52380eaab

  # typeof(90_000_000_000_000_000_000) == Int128
  @test difference(90_000_000_000_000_000_000)::Integer == 0x0a6501dde806c3fce2fd6b3e86795556
  @test difference(900_000_000_000_000_000_000)::Integer == 0x00c5f01a124455a780ac067beb680000
  @test difference(9_000_000_000_000_000_000_000)::Integer == 0x523634fddc2a06327955325732100000
  @test difference(9_000_000_000_000_000_000_000_000)::Integer == 0x3984232cb3ad882c05658c9b8e800000
  @test difference(9_000_000_000_000_000_000_000_000_000)::Integer == 0x29d9b5cf6faad08b940c94f9f9555556
  @test difference(9_000_000_000_000_000_000_000_000_000_000)::Integer == 0xa494dadcdf89b4f167a5f075f5555556
  @test difference(9_000_000_000_000_000_000_000_000_000_000_000)::Integer == 0x12923f63e2d49764d588a21baaaaaaab

  @test difference(100_000_000_000_000_000_000_000_000_000_000_000_000)::Integer == 0xb87eb467948445eba913a4f555555556
  @test difference(150_000_000_000_000_000_000_000_000_000_000_000_000)::Integer == 0xcfc73f7e197a75e17d9d777000000000

  # over 170_141_183_460_469_231_731_687_303_715_884_105_727 => BigInt...
  @test difference(200_000_000_000_000_000_000_000_000_000_000_000_000)::Integer == 400000000000000000000000000000000000001333333333333333333333333333333333333323333333333333333333333333333333333333300000000000000000000000000000000000000

  ## Performance
  # for cand in [9_000_000_000_000_000_000_000_000_000, 9_000_000_000_000_000_000_000_000_000_000_000, 100_000_000_000_000_000_000_000_000_000_000_000_000,
  #              150_000_000_000_000_000_000_000_000_000_000_000_000, 200_000_000_000_000_000_000_000_000_000_000_000_000 ]
  #   @time x = difference(cand)
  #   @show cand, x
  # end
end
