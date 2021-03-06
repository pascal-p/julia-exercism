using Test

include("karatsuba-int-mult.jl")

@testset "Minimum tests" begin

  @test karatsuba(1, 0) == 0
  @test karatsuba(9, 2) == 18
  @test karatsuba(2, 9) == 18

  @test karatsuba(21, 32) == 672
  @test karatsuba(32, 21) == 672

  @test karatsuba(1234, 5678) == 7006652
  @test karatsuba(5678, 1234) == 7006652
  @test karatsuba(0, 12345678) == 0

  for (pair, exp) in [ ((1233, 54637), 67367421),
                       ((12334, 564637), 6964232758),
                       ((10304, 560037), 5770621248),
                       ((1099, 5637), 6195063),
                       ((560037, 10304), 5770621248),
                       ((99999999999999999, 8888888888888888888888888), 888888888888888879999999911111111111111112) ]
    act = karatsuba(pair...)
    @test act == exp # "for $(pair[0]) \times $(pair[1]) expect $(exp) got $(act)!"
  end

  @test karatsuba(3141592653589793238462643383279502884197169399375105820974944592,
                  2718281828459045235360287471352662497757247093699959574966967627) == 8539734222673567065463550869546574495034888535765114961879601127067743044893204848617875072216249073013374895871952806582723184

end
