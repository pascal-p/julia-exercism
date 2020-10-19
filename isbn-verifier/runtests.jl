using Test

include("isbn-verifier.jl")

@test ISBN <: AbstractString
@test ISBN13 <: AbstractString

@testset "valid ISBN numbers" begin
  # ISBN number
  @test isvalid(ISBN, "3-598-21508-8")

  # ISBN number with a check digit of 10
  @test isvalid(ISBN, "3-598-21507-X")

  # ISBN without separating dashes
  @test isvalid(ISBN, "3598215088")

  # ISBN without separating dashes and X as check digit
  @test isvalid(ISBN, "359821507X")
end

@testset "valid ISBN13 numbers" begin
  # ISBN13 number
  @test isvalid(ISBN13, "9783598215087")

  # ISBN13 number with separation
  @test isvalid(ISBN13, "978-3-598-21508-7")

  @test isvalid(ISBN13, "978-0-306-40615-7")

  @test isvalid(ISBN13, "9780306406157")
end

@testset "invalid ISBN numbers" begin
  # invalid ISBN check digit
  @test !isvalid(ISBN, "3-598-21508-9")

  # check digit is a character other than X
  @test !isvalid(ISBN, "3-598-21507-A")

  # invalid character in ISBN
  @test !isvalid(ISBN, "3-598-2K507-0")

  # X is only valid as a check isdigit
  @test !isvalid(ISBN, "3-598-2X507-9")

  # ISBN without check digit and dashes
  @test !isvalid(ISBN, "359821507")

  # too long ISBN and no dashes
  @test !isvalid(ISBN, "3598215078X")

  # ISBN without check digit
  @test !isvalid(ISBN, "3-598-21507")

  # too long ISBN
  @test !isvalid(ISBN, "3-598-21507-XX")

  # check digit of X should not be used for 0
  @test !isvalid(ISBN, "3-598-21515-X")

  # empty ISBN
  @test !isvalid(ISBN, "")
end

@testset "invalid ISBN13 numbers" begin
  @test !isvalid(ISBN13, "978-3-598-21508-1")

  @test !isvalid(ISBN13, "978_3_598_21508_1")

  @test !isvalid(ISBN13, "978359821508X")

  @test !isvalid(ISBN13, "9780306406153")
end

@testset "constructing valid ISBN numbers" begin
  # ISBN number
  @test string(isbn"3-598-21508-8") == "3598215088"

  # ISBN number with a check digit of 10
  @test string(isbn"3-598-21507-X") == "359821507X"

  # ISBN without separating dashes
  @test string(isbn"3598215088") == "3598215088"

  # ISBN without separating dashes and X as check digit
  @test string(isbn"359821507X") == "359821507X"
end

@testset "constructing valid ISBN13 numbers" begin
  @test string(isbn13"978-1-56619-909-4") == "9781566199094"

  @test string(isbn13"9780140266900") == "9780140266900"

  # TODO... more
end

@testset "constructor with valid string for ISBN" begin
  @test ISBN("3598215088") == "3598215088"

  @test ISBN("3-598-21507-X") == "359821507X"
end

@testset "constructor with valid string for ISBN13" begin
  @test ISBN13("978-0-306-40615-7") == "9780306406157"

  @test ISBN13("978-1-4028-9462-6") == "9781402894626"

  @test ISBN13("978-1-56619-909-4") == "9781566199094"

  @test ISBN13("9780716703440") == "9780716703440"

  @test ISBN13("9780306406157") == "9780306406157"
end

@testset "constructing invalid ISBN numbers" begin
  # invalid ISBN check digit
  @test_throws ArgumentError ISBN("3-598-21508-9")

  # check digit is a character other than X
  @test_throws ArgumentError ISBN("3-598-21507-A")

  # invalid character in ISBN
  @test_throws ArgumentError ISBN("3-598-2K507-0")

  # X is only valid as a check isdigit
  @test_throws ArgumentError ISBN("3-598-2X507-9")

  # ISBN without check digit and dashes
  @test_throws ArgumentError ISBN("359821507")

  # too long ISBN and no dashes
  @test_throws ArgumentError ISBN("3598215078X")

  # ISBN without check digit
  @test_throws ArgumentError ISBN("3-598-21507")

  # too long ISBN
  @test_throws ArgumentError ISBN("3-598-21507-XX")

  # check digit of X should not be used for 0
  @test_throws ArgumentError ISBN("3-598-21515-X")

  # empty ISBN
  @test_throws ArgumentError ISBN("")

  # starting with -
  @test_throws ArgumentError ISBN("-1")
end

@testset "constructing invalid ISBN13 numbers" begin
  # invalid ISBN13 prefix
  @test_throws ArgumentError ISBN13("977-1-402-89462-6")

  # invalid ISBN13 check digit
  @test_throws ArgumentError ISBN13("978-1-402-89462-1")

  # too long ISBN13
  @test_throws ArgumentError ISBN("978-1-999-21507-102304")

  # invalid ISBN13 - character
  @test_throws ArgumentError ISBN13("978-1-402-89462-X")

  # empty ISBN13
  @test_throws ArgumentError ISBN13("")

  # starting with -
  @test_throws ArgumentError ISBN13("-1")
end

@testset "constructing ISBN numbers given a prefix" begin
  ## this is underterministic!

  @test isvalid(ISBN, build_isbn10_from_prefix("023145678")) # this one is deterministic because prefix is len. 9!

  @test isvalid(ISBN, build_isbn10_from_prefix("023145679"))

  try
    isbn = build_isbn10_from_prefix("02314567")
    @test isvalid(ISBN, isbn)
  catch _ex
    # @test_throws ArgumentError
  end

  try
    isbn = build_isbn10_from_prefix("023")
    @test isvalid(ISBN, isbn)
  catch _ex
    # @test_throws ArgumentError
  end

  # we cannot use X here (2nd pos.)
  @test_throws ArgumentError build_isbn10_from_prefix("0X")

  # we cannot use a len 10 prefix
  @test_throws ArgumentError build_isbn10_from_prefix("0123456789")

  # we cannot use a len 0 prefix
  @test_throws ArgumentError build_isbn10_from_prefix("")
end

@testset "constructing ISBN13 numbers given a prefix" begin
  # does not start with 978, but it can be prepend
  @test isvalid(ISBN13, build_isbn13_from_prefix("667678999"))

  # start with 978
  @test isvalid(ISBN13, build_isbn13_from_prefix("97800"))

  # we cannot use a len 13 prefix
  @test_throws ArgumentError build_isbn13_from_prefix("9780123456789")

  # we cannot use a len 0 prefix
  @test_throws ArgumentError build_isbn13_from_prefix("")

  # we cannot use X for ISBN13
  @test_throws ArgumentError build_isbn13_from_prefix("0X")
end
