using Test

include("regexp-parser.jl")

@testset "regexp_parser base cases" begin
  @test regexp_parser("a") == "Normal 'a'"
  @test regexp_parser("ab") == "Str [Normal 'a', Normal 'b']"
  @test regexp_parser("a.") == "Str [Normal 'a', Any]"

  @test regexp_parser("a?") == "Optional (Normal 'a')"
  @test regexp_parser("ab?") == "Str [Normal 'a', Optional (Normal 'b')]"
  @test regexp_parser("aa?") == "Str [Normal 'a', Optional (Normal 'a')]"
  @test regexp_parser("a.?") == "Str [Normal 'a', Optional Any]"

  @test regexp_parser("a.*") == "Str [Normal 'a', ZeroOrMore Any]"
  @test regexp_parser("(a.*)") == "Str [Normal 'a', ZeroOrMore Any]"

  @test regexp_parser("a.+") == "Str [Normal 'a', OneOrMore Any]"
  @test regexp_parser("(a.+)") == "Str [Normal 'a', OneOrMore Any]"

  @test regexp_parser("ab*") == "Str [Normal 'a', ZeroOrMore (Normal 'b')]"
  @test regexp_parser("a(bc)*") == "Str [Normal 'a', ZeroOrMore (Str [Normal 'b', Normal 'c'])]"
  @test regexp_parser("ab+") == "Str [Normal 'a', OneOrMore (Normal 'b')]"
  @test regexp_parser("a(bc)+") == "Str [Normal 'a', OneOrMore (Str [Normal 'b', Normal 'c'])]"

  @test regexp_parser("(abcd)") == "Str [Normal 'a', Normal 'b', Normal 'c', Normal 'd']"
  @test regexp_parser("a|b") == "Or (Normal 'a') (Normal 'b')"

  @test regexp_parser("(a|b)|c") == "Or (Or (Normal 'a') (Normal 'b')) (Normal 'c')"
  @test regexp_parser("a|(b|c)") == "Or (Normal 'a') (Or (Normal 'b') (Normal 'c'))"

  @test regexp_parser("(a|b)*") == "ZeroOrMore (Or (Normal 'a') (Normal 'b'))"
  @test regexp_parser("(a|b)+") == "OneOrMore (Or (Normal 'a') (Normal 'b'))"
end

@testset "regexp_parser beyond base  cases" begin
  @test regexp_parser("(a.*)|(bb)") == "Or (Str [Normal 'a', ZeroOrMore Any]) (Str [Normal 'b', Normal 'b'])"

  @test regexp_parser("(ab.*)|(cc)") == "Or (Str [Normal 'a', Normal 'b', ZeroOrMore Any]) (Str [Normal 'c', Normal 'c'])"

  @test regexp_parser("(ab.*)|(c*c)") == "Or (Str [Normal 'a', Normal 'b', ZeroOrMore Any]) (ZeroOrMore (Normal 'c'), Normal 'c')"
  @test regexp_parser("(ab.*)|(c*c.*)") == "Or (Str [Normal 'a', Normal 'b', ZeroOrMore Any]) (ZeroOrMore (Normal 'c'), Normal 'c', ZeroOrMore Any)"

  @test regexp_parser("(a.+)|(bb)") == "Or (Str [Normal 'a', OneOrMore Any]) (Str [Normal 'b', Normal 'b'])"

  @test regexp_parser("(ab.+)|(cc)") == "Or (Str [Normal 'a', Normal 'b', OneOrMore Any]) (Str [Normal 'c', Normal 'c'])"

  @test regexp_parser("(ab.+)|(c+c)") == "Or (Str [Normal 'a', Normal 'b', OneOrMore Any]) (OneOrMore (Normal 'c'), Normal 'c')"
  @test regexp_parser("(ab.+)|(c+c.+)") == "Or (Str [Normal 'a', Normal 'b', OneOrMore Any]) (OneOrMore (Normal 'c'), Normal 'c', OneOrMore Any)"

  @test regexp_parser("(ab.+)|(c*c)") == "Or (Str [Normal 'a', Normal 'b', OneOrMore Any]) (ZeroOrMore (Normal 'c'), Normal 'c')"

  # add mix with optional
end

@testset "regexp_parser invalid expression" begin
  # @test_throws ArgumentError foo()

  for inv_expr ∈ [ "", ")(", "*", "a(", "()", "a**", "a|a|a", "ab|", "a||b", "ab*+" ]
    @test regexp_parser(inv_expr) === nothing
  end
end
