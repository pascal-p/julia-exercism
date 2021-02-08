using Test

include("./ocr_numbers.jl")

@testset "Recognize 0" begin
  @test convert([" _ ", "| |", "|_|", "   "]) == "0"
end

@testset "Recognize 1" begin
  @test convert(["   ", "  |", "  |", "   "]) == "1"
end

@testset "Recognize 2" begin
  @test convert([" _ ", " _|", "|_ ", "   "]) == "2"
end

@testset "Recognize 3" begin
  @test convert([" _ ", " _|", " _|", "   "]) == "3"
end

@testset "Recognize 4" begin
  @test convert(["   ", "|_|", "  |", "   "]) == "4"
end

@testset "Recognize 5" begin
  @test convert([" _ ", "|_ ", " _|", "   "]) == "5"
end

@testset "Recognize 6" begin
  @test convert([" _ ", "|_ ", "|_|", "   "]) == "6"
end

@testset "Recognize 7" begin
  @test convert([" _ ", "  |", "  |", "   "]) == "7"
end

@testset "Recognize 8" begin
  @test convert([" _ ", "|_|", "|_|", "   "]) == "8"
end

@testset "Recognize 9" begin
  @test convert([" _ ", "|_|", " _|", "   "]) == "9"
end

@testset "unreadable but correctly sized inputs return" begin
  @test convert(["   ", "  _", "  |", "   "]) == "?"
end

@testset "Detect correctly sized output which is garbbage" begin
  @test_throws ArgumentError convert([" _ ", "| |", "   "])
end

@testset "Input with a number of columns that is not a multiple of 3" begin
  @test_throws ArgumentError convert(["    ", "   |", "   |", "    "])
end

@testset "input with a number of lines that is not a multiple of 4" begin
  @test_throws ArgumentError  convert([" _ ", "| |", "   "])
end

@testset "recognizes sequence 110101100" begin
  @test convert(
                [
                    "       _     _        _  _ ",
                    "  |  || |  || |  |  || || |",
                    "  |  ||_|  ||_|  |  ||_||_|",
                    "                           ",
                ]
            ) == "110101100"
end


@testset "garbled numbers in a string" begin
  @test convert(
                [
                    "       _     _           _ ",
                    "  |  || |  || |     || || |",
                    "  |  | _|  ||_|  |  ||_||_|",
                    "                           ",
                ]
            ) == "11?10?1?0"
end

@testset "recognizes string of decimalnumbers" begin
  @test convert(
                [
                    "    _  _     _  _  _  _  _  _ ",
                    "  | _| _||_||_ |_   ||_||_|| |",
                    "  ||_  _|  | _||_|  ||_| _||_|",
                    "                              ",
                ]
            ) == "1234567890"
end


@testset "numbers separated by empty lines are recognized lines are joined by commas" begin
  @test convert(
                [
                    "    _  _ ",
                    "  | _| _|",
                    "  ||_  _|",
                    "         ",
                    "    _  _ ",
                    "|_||_ |_ ",
                    "  | _||_|",
                    "         ",
                    " _  _  _ ",
                    "  ||_||_|",
                    "  ||_| _|",
                    "         ",
                ]
               ) == "123,456,789"
end
