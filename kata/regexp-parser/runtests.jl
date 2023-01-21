using Test

include("regexp-parser.jl")

@testset "regexp_parser base cases" begin
  @test regexp_parser("a") == "Normal 'a'"
  @test regexp_parser("ab") == "Str [ Normal 'a', Normal 'b']"
  @test regexp_parser("a.*") == "Str [ Normal 'a', ZeroOrMore Any ]"
  @test regexp_parser("(a.*)|(bb)") == "ZeroOrMore (Or (Normal 'a') (Normal 'b'))"
end

@testset "regexp_aprser invalid expression" begin
  # @test_throws ArgumentError foo()

  for invexpr ∈ [ "", ")(", "*", "a(", "()", "a**" ]
    @test regexp_parser(invexpr) === nothing
  end
end
