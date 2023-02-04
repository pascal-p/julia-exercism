using Test

include("symb-diff.jl")

@testset "symbolic differentiation base cases" begin
  @test differentiate("2") == Atom(0)
  @test differentiate("(+ x 2)") == Atom(1)

  @test differentiate("(+ y 2)") == Atom(0)  # because default is to differentiate wrt :x
  @test differentiate("(+ y 2)"; wrt=:y) == Atom(1)

  @test differentiate("(* (+ x 3) 5)") == Atom(5)
  # @test differentiate("(^ x 3)") ==  "(* 3 (^ x 2))"

  # @test differentiate("(cos x)") == "(* -1 (sin x))"
  # @test differentiate("(sin x)") == "(cos x)"
  # @test differentiate("(tan x)") == "(/ 1 (^ (cos x) 2)"

  # @test differentiate("e^x") == "e^x"
  # @test differentiate("(ln x)") == "(/ 1 x)"
end

# @testset "symbolic differentiation beyond base  cases" begin
# end

# @testset "symbolic differentiation invalid expression" begin
#   # @test_throws ArgumentError foo()
# end

@testset "parser" begin
  @test parser("2") == Atom(2)
  @test parser("x") == Atom(:x)

  @test parser("(+ x 2)") == D2Expr(:+, Atom(:x), Atom(2))
  @test parser("(+ x -2)") == D2Expr(:+, Atom(:x), Atom(-2))
  @test parser("(+ -x 2)") == D2Expr(:+, D2Expr(:*, Atom(-1), Atom(:x)), Atom(2)) ## which can be further simplify/transform
  @test parser("(/ x -2)") == D2Expr(:/, Atom(:x), Atom(-2))
  @test parser("(/ -1 y)") == D2Expr(:/, Atom(-1), Atom(:y))
  @test parser("(+ (+ x y) z)") ==  D2Expr(:+, D2Expr(:+, Atom(:x), Atom(:y)), Atom(:z))

  @test parser("(* 2 (+ y 5))") == D2Expr(:*, Atom(2), D2Expr(:+, Atom(:y), Atom(5)))
  @test parser("(* 3 (- -5 y))") == D2Expr(:*, Atom(3), D2Expr(:-, Atom(-5), Atom(:y)))

  @test parser("(- (+ (^ x 2) (* 2 x)) 5)") == D2Expr(:-, D2Expr(:+, D2Expr(:^, Atom(:x), Atom(2)), D2Expr(:*, Atom(2), Atom(:x))), Atom(5))

  @test parser("cos(+ (* 2 x) 1)") === D2Expr(:cos, D2Expr(:+, D2Expr(:*, Atom(2), Atom(:x)), Atom(1)))
  @test parser("ln(+ 1 e(x))") == D2Expr(:ln, D2Expr(:+, Atom(1), D2Expr(:e, Atom(:x))))
  @test parser("ln(+ 1 e(-x))") == D2Expr(:ln, D2Expr(:+, Atom(1), D2Expr(:e, D2Expr(:*, Atom(-1), Atom(:x)))))

  @test parser("(/ sin(x) cos(x)") == D2Expr(:/, D2Expr(:sin, Atom(:x)), D2Expr(:cos, Atom(:x)))
  @test parser("(/ (^ sin(x) 2) (^ cos(x) 2)") == D2Expr(:/, D2Expr(:^, D2Expr(:sin, Atom(:x)), Atom(2)), D2Expr(:^, D2Expr(:cos, Atom(:x)), Atom(2)))
end
