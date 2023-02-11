using Test

include("str-mult.jl")

@testset "mult. base cases" begin
  for x ∈ 1:1000, y ∈ x:1000
    @test mul(string(x), string(y)) == string(x * y)
  end

  @test mul("123", "456") == "56088"
  @test mul("1234", "5678") == "7006652"
  @test mul("05678.", "1234") == "7006652"

  @test mul("123456789", "987654321") == "121932631112635269"
  @test mul("1234567890", "9870654321") == "12185992877996352690"

  @test mul("12185992877996352690", "1218599287799635269012185992877996352691") == "14849842242257783069811728116709601440708818289820866588790"

  @test mul("123456789012345678901234567890", "987654321098765432109876543219876543210") == "121932631137021795226185032734842249643485749122236092059011263526900"

  # 0.003633 seconds (17.74 k allocations: 944.555 KiB)
  @test mul("14849842242257783069811728116709601440708818289820866588790",
           "1484984224225778306981172811670960144070881828982086658879012345678912") ==
             "22051781461994366240279172246014824933434062154193060433240735730181916066612170720692732913081395555397466176743312790078596480"
end

@testset "mult special casses" begin
  @test mul("123456789012345678901234567890", "00000000000000000000000000001") == "123456789012345678901234567890"
  @test mul("0000000000000001", "123456789012345678901234567890") == "123456789012345678901234567890"

  @test mul("123456789012345678901234567890", "00000000000000000000000000000") == "0"
  @test mul("00000000000000000000000000000", "123456789012345678901234567890") == "0"
end

@testset "mult negative factors" begin
  @test mul("-123", "456") == "-56088"
  @test mul("-4567", "-1456") == "6649552"

  @test mul("-45.67", "-145.6") == "6649.552" # compund with decimal
  @test mul("-4.567", "-14.56") == "66.49552" # compund with decimal

  @test mul("-4.567", "0.0000") == "0"
  @test mul("-0.0", "0.0000") == "0"
  @test mul("-0.0", "-0.0000") == "0"
  @test mul("-0.", "0.00") == "0"

  @test mul("-0.", "1.00") == "0"
  @test mul("-1.", "1.00") == "-1"
  @test mul("-1.", "-1.00") == "1"

  @test mul("-1000", "-0.001") == "1"
  @test mul("-112", "-0.001") == "0.112"
  @test mul("-112", "0.000001") == "-0.000112"
end

@testset "mult. leading and trailing zeros" begin
  @test mul("0123", "0456") == "56088"
  @test mul("00000001234", "05678") == "7006652"
end

@testset "mult. with decimal value" begin
  for x ∈ 0.:0.1:10., y ∈ x:0.2:10.
    @test mul(string(x), string(y)) == string((x * 10) * (y * 10) / 100) |> s -> replace(s, r"(?:\.0+)?$" => "")
  end

  @test mul("1.23", "4.56") == "5.6088"

  @test mul("123.4", "0.5678") == "70.06652"
  @test mul("1.234567890", "9.870654321") == "12.18599287799635269"

  @test mul("1234.", "05678.") == "7006652"
  @test mul("1234", "05678.") == "7006652"
end

@testset "exception" begin
  # TBD...
end