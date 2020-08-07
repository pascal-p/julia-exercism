using Test

include("rotational-cipher.jl")

@testset "rotate function" begin
    @testset "rotate by n" begin
        @testset "no wrap" begin
            @test rotate(1, "a") == "b"
            @test rotate(1, 'a') == 'b'
            @test rotate(13, "m") == "z"
            @test rotate(13, 'm') == 'z'
        end
        @testset "wrap around" begin
            @test rotate(13, "n") == "a"
            @test rotate(13, 'n') == 'a'
        end
    end

  @testset "full rotation" begin
        @test rotate(26, "a") == "a"
        @test rotate(26, 'a') == 'a'
        @test rotate(0, "a") == "a"
        @test rotate(0, 'a') == 'a'
        @test rotate(0, 'z') == 'z'
        @test rotate(26, "Z") == "Z"
    end

    @testset "full strings" begin
        @test rotate(5, "OMG") == "TRL"
        @test rotate(5, "O M G") == "T R L"
        @test rotate(4, "Testing 1 2 3 testing") == "Xiwxmrk 1 2 3 xiwxmrk"
        @test rotate(21, "Let's eat, Grandma!") == "Gzo'n zvo, Bmviyhv!"
        @test rotate(0, "Let's talk, GrandPa!") == "Let's talk, GrandPa!"
        @test rotate(26, "Let's talk, GrandPa!") == "Let's talk, GrandPa!"
        @test rotate(1, "Let's talk, GrandPa!") == rotate(27, "Let's talk, GrandPa!")
        @test rotate(13, "The quick brown fox jumps over the lazy dog.") == "Gur dhvpx oebja sbk whzcf bire gur ynml qbt."
    end
end

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Additional exercises                                                        #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Bonus A
if isdefined(Main, Symbol("@R13_str"))
    @eval @testset "Bonus A: string literal R13" begin
        @test R13"The quick brown fox jumps over the lazy dog." == "Gur dhvpx oebja sbk whzcf bire gur ynml qbt."
    end
end

# Bonus B
if isdefined(Main, Symbol("@R1_str"))
    @eval @testset "Bonus B: string literals" begin
        @test R5"OMG" == "TRL"
        @test R4"Testing 1 2 3 testing" == "Xiwxmrk 1 2 3 xiwxmrk"
        @test R21"Let's eat, Grandma!" == "Gzo'n zvo, Bmviyhv!"
        @test R13"The quick brown fox jumps over the lazy dog." == "Gur dhvpx oebja sbk whzcf bire gur ynml qbt."
        @test R0"I'm so Meta, Even This Acronym" == R26"I'm so Meta, Even This Acronym"
        @test R2"I'm so Meta, Even This Acronym" == "K'o uq Ogvc, Gxgp Vjku Cetqpao"
        @test R10"I'm so Meta, Even This Acronym" == "S'w cy Wodk, Ofox Drsc Kmbyxiw"
        @test R17"I'm so Meta, Even This Acronym" == "Z'd jf Dvkr, Vmve Kyzj Rtifepd"
        @test R19"I'm so Meta, Even This Acronym" == "B'f lh Fxmt, Xoxg Mabl Tvkhgrf"
    end
end
