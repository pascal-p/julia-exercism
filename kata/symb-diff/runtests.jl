using Test

include("symb-diff.jl")

# @testset "symbolic differentiation base cases" begin
#   @test differentiate("2") == 0
#   @test differentiate("(+ x 2)") == "x"

#   @test differentiate("(* (+ x 3) 5)") == 5
#   @test differentiate("(^ x 3)") ==  "(* 3 (^ x 2))"

#   @test differentiate("(cos x)") == "(* -1 (sin x))"
#   @test differentiate("(sin x)") == "(cos x)"
#   @test differentiate("(tan x)") == "(/ 1 (^ (cos x) 2)"

#   @test differentiate("e^x") == "e^x"
#   @test differentiate("(ln x)") == "(/ 1 x)"

# end

# @testset "symbolic differentiation beyond base  cases" begin

# end

# @testset "symbolic differentiation invalid expression" begin
#   # @test_throws ArgumentError foo()
# end


@testset "parser" begin
  @test parser("(+ x 2)") == D2Expr(:+, Atom(:x), Atom(2))
  @test parser("(+ x -2)") == D2Expr(:+, Atom(:x), Atom(-2))
  @test parser("(+ -x 2)") == D2Expr(:+, D2Expr(:*, Atom(-1), Atom(:x)), Atom(2)) ## wchih can be simplify/transform

  @test parser("(* 2 (+ y 5))") == D2Expr(:*, Atom(2), D2Expr(:+, Atom(:y), Atom(5)))
  @test parser("(* 3 (- -5 y))") == D2Expr(:*, Atom(3), D2Expr(:-, Atom(-5), Atom(:y)))
end
