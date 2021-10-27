using Test

include("simple_cipher.jl")

@testset "encode" begin
  @test encode("aaadefghij", "bxdeasd")  == "bxdhexhi5m"

  @test encode("identity", "aaaa") == "identity"

  # TODO: more
end


@testset "encode error handling" begin
  @test_throws ArgumentError encode("This is a test.", "aa") # key is too short
end
