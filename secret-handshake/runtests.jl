using Test

include("secret-handshake.jl")

@testset "wink for 1" begin
  exp = ["wink"]

  @test secret_handshake(1) == exp
  @test secret_handshake(33) == exp
  @test secret_handshake(65) == exp
end

@testset "double blink for 10" begin
  @test secret_handshake(2) == ["double blink"]
  @test secret_handshake(34) == ["double blink"]
end

@testset "close your eyes for 100" begin
  @test secret_handshake(4) == ["close your eyes"]
end

@testset "jump for 1000" begin
  @test secret_handshake(8) == ["jump"]
end

@testset "combine two actions" begin
  @test secret_handshake(3) == ["wink", "double blink"]
end

@testset "reverse two actions" begin
  @test secret_handshake(19) == ["double blink", "wink"]
end

@testset "reversing one action gives the same action" begin
  @test secret_handshake(24) == ["jump"]
end

@testset "reversing no actions still gives no actions" begin
  for ix in [16, 32, 64, 128, 256]
    @test secret_handshake(ix) == []
  end
end

@testset "all possible actions" begin
  exp = ["wink", "double blink", "close your eyes", "jump"]

  @test secret_handshake(15) == exp
  @test secret_handshake(47) == exp
end

@testset "several possible actions" begin
  exp = ["double blink", "close your eyes", "jump"]

  @test secret_handshake(46) == exp
end

@testset "reverse all possible actions" begin
  exp = ["jump", "close your eyes", "double blink", "wink"]

  @test secret_handshake(31) == exp
  @test secret_handshake(63) == exp
end

@testset "do nothing for zero" begin
  @test secret_handshake(0) == []
end

@testset "do nothing if lower 5 bits not set" begin
  @test secret_handshake(32) == []
end

@testset "errors" begin
  @test_throws ArgumentError secret_handshake(-1)

  @test_throws ArgumentError secret_handshake(:foo)

  @test_throws ArgumentError secret_handshake(π)
end
