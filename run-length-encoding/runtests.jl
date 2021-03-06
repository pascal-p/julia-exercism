using Test

include("run-length-encoding.jl")


# Tests adapted from `problem-specifications//canonical-data.json` @ v1.0.0
# Encode and decode the strings under the given specifications.

@testset "encode strings" begin
    @test encode("") == ""
    @test encode("XYZ") == "XYZ"
    @test encode("AABBBCCCC") == "2A3B4C"
    @test encode("WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWB") == "12WB12W3B24WB"
    @test encode("aabbbcccc") == "2a3b4c"
    @test encode("  hsqq qww  ") == "2 hs2q q2w2 "
    @test encode("aaaAAAaaaaAAAA ") == "3a3A4a4A "
    @test encode("          ") == "10 "
end

@testset "decode strings" begin
    @test decode("") == ""
    @test decode("XYZ") == "XYZ"
    @test decode("2A3B4C") == "AABBBCCCC"
    @test decode("12WB12W3B24WB") == "WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWB"
    @test decode("2a3b4c") == "aabbbcccc"
    @test decode("2 hs2q q2w2 ") == "  hsqq qww  "
end

@testset "encode then decode" begin
    @test decode(encode("zzz ZZ  zZ")) == "zzz ZZ  zZ"
    @test decode(encode("Ooooops Salut le Monde")) == "Ooooops Salut le Monde"
end

@testset "error handling" begin
    @test_throws ArgumentError encode("XY@Z")
    @test_throws ArgumentError encode("XY Z1234aaa")
    @test_throws ArgumentError decode("XY@Z")
    @test_throws ArgumentError decode("XYZ2")
    @test_throws ArgumentError decode("abc3")
end
