using Test

include("symb-diff.jl")

@testset "symbolic differentiation base cases" begin
  @test differentiate("2") == Atom(0)
  @test differentiate("(+ x 2)") == Atom(1)

  @test differentiate("(+ y 2)") == Atom(0)  # because default is to differentiate wrt :x
  @test differentiate("(+ y 2)"; wrt=:y) == Atom(1; wrt=:y)

  @test differentiate("(* 0 x)") == Atom(0)
  @test differentiate("(* x 0)") == Atom(0)
  @test differentiate("(* x 1)") == Atom(1)
  @test differentiate("(* 1 x)") == Atom(1)

  @test differentiate("(* (+ x 3) 5)") == Atom(5)
  @test differentiate("(+ (* x 3) 5)") == Atom(3)
  @test differentiate("(- (* x 3) 5)") == Atom(3)
  @test differentiate("(- 5 (* x 3))") == Atom(-3)
  @test differentiate("(* (- -x 3) 5)") == Atom(-5)

  @test differentiate("(+ (* x 3) (+ y 2))") == Atom(3)
  @test differentiate("(- (+ y 2) (* x 3))") == Atom(-3)

  @test differentiate("(* (+ x 2) (* x 3))") == D2Expr( # == D2Expr(:*, Atom(6), Atom(:x))
    :+,
    D2Expr(:*, Atom(:x), Atom(3)),
    D2Expr(:*, D2Expr(:+, Atom(:x), Atom(2)), Atom(3))
  )
  # \=> more simplification is required

  @test differentiate("(/ (* x 3) 2)") == D2Expr(:/, Atom(3), Atom(2))

  @test differentiate("(^ x 2)") == D2Expr(
    :*,
    Atom(2),
    Atom(:x)
  )

  @test differentiate("(^ x 3)") == D2Expr(
    :*,
    Atom(3),
    D2Expr(:^, Atom(:x), Atom(2)),
  ) # == "(* 3 (^ x 2))"

  @test differentiate("(/ 1 x)") == D2Expr(
    :/,
    Atom(-1),
    D2Expr(:^, Atom(:x), Atom(2))
  )

  @test differentiate("(/ 2 x)") == D2Expr(
    :/,
    Atom(-2),
    D2Expr(:^, Atom(:x), Atom(2))
  )

  @test differentiate("(cos x)") == D2Expr(
    :*,
    Atom(-1),
    D2Expr(:sin, Atom(:x))
  ) # == "(* -1 (sin x))"

  # more simplification: (* (* -1 (sin (+ (* 2 x) 1))) 2)
  # @test differentiate("(cos (+ (* 2 x) 1))") == D2Expr(
  #   :*,
  #   Atom(-2),
  #   D2Expr(
  #     :sin,
  #     D2Expr(:+,  Atom(1), D2Expr(:*, Atom(2), Atom(:x)))
  #   )
  # ) # == "(* -2 (sin (+ (* 2 x) 1)))"

  @test differentiate("(sin x)") == D2Expr(:cos, Atom(:x)) # == "(cos x)"

  @test differentiate("(tan x)") == D2Expr(
    :/,
    Atom(1),
    D2Expr(
      :^,
      D2Expr(
        :cos,
        Atom(:x)
      ),
      Atom(2)
    ),
  ) # == "(/ 1 (^ (cos x) 2)"

  @test differentiate("(exp x)") == D2Expr(
    :exp,
    Atom(:x)
  ) # == "(exp x)"

  @test differentiate("(exp (* 2 x))") == D2Expr(
    :*,
    D2Expr(
       :exp,
       D2Expr(
         :*,
         Atom(2),
         Atom(:x)
       )
     ),
     Atom(2),
  ) # == "(exp x)"

  @test differentiate("(exp (* 2 y))"; wrt=:y) == D2Expr(
    :*,
    D2Expr(
       :exp,
       D2Expr(
         :*,
         Atom(2; wrt=:y),
         Atom(:y; wrt=:y);
         wrt=:y
       );
       wrt=:y
     ),
    Atom(2; wrt=:y);
    wrt=:y
  ) # == "(exp x)"

  @test differentiate("(ln y)"; wrt=:y) == D2Expr(
    :/,
    Atom(1; wrt=:y),
    Atom(:y; wrt=:y);
    wrt=:y
  ) # == "(/ 1 y)"

  @test differentiate("(ln x)") == D2Expr(
    :/,
    Atom(1),
    Atom(:x)
  ) # == "(/ 1 x)"

end

# @testset "symbolic differentiation beyond base  cases" begin
#end

@testset "symbolic differentiation invalid expression" begin
  @test_throws ArgumentError differentiate("(tanh x)")
  @test_throws ArgumentError differentiate("(÷ x 2)")
  @test_throws ArgumentError differentiate("(% x 2)")

  @test_throws ArgumentError differentiate("(+ x)")
  @test_throws ArgumentError differentiate("(+ x (* 2))")

  # @test_throws ArgumentError differentiate("(+ x 1 2 3)") # no error thrown
end

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
  @test parser("ln(+ 1 exp(x))") == D2Expr(:ln, D2Expr(:+, Atom(1), D2Expr(:exp, Atom(:x))))
  @test parser("ln(+ 1 exp(-x))") == D2Expr(:ln, D2Expr(:+, Atom(1), D2Expr(:exp, D2Expr(:*, Atom(-1), Atom(:x)))))

  @test parser("(/ sin(x) cos(x)") == D2Expr(:/, D2Expr(:sin, Atom(:x)), D2Expr(:cos, Atom(:x)))
  @test parser("(/ (^ sin(x) 2) (^ cos(x) 2)") == D2Expr(:/, D2Expr(:^, D2Expr(:sin, Atom(:x)), Atom(2)), D2Expr(:^, D2Expr(:cos, Atom(:x)), Atom(2)))
end

# function diff_on_op(dexpr::D2Expr; wrt=:x)
#   D2Expr(dexpr.op, (simplify ∘ DISPATCH_MAP[dexpr.op])(dexpr.lhs, dexpr.rhs; wrt))

#   # dexpr.op == :+ && return D2Expr(dexpr.op, (simplify ∘ diffsum)(dexpr.lhs, dexpr.rhs; wrt))
#   # dexpr.op == :- && return D2Expr(dexpr.op, (simplify ∘ diffsub)(dexpr.lhs, dexpr.rhs; wrt))
#   # TODO ...

#   ## DOES NOT WORK:
#   # for (key, op) ∈ [(:diffsub, :-), (:diffsum, :+)]
#   #   @eval begin
#   #     dexpr.op == Symbol($(op)) && return D2Expr(dexpr.op, (simplify ∘ ($(key)))(dexpr.lhs, dexpr.rhs; wrt))
#   #   end
#   # end
# end

# function simplify(dexpr::D2Expr)::Union{D2Expr, Atom}
#   r = if dexpr.op == :+
#     simplify_add(dexpr.lhs, dexpr.rhs)

#   elseif dexpr.op == :-
#     simplify_sub(dexpr.lhs, dexpr.rhs)

#   elseif dexpr.op == :*
#     simplify_mul(dexpr.lhs, dexpr.rhs)

#   elseif dexpr.op == :/
#     # simplify_div(dexpr.lhs, dexpr.rhs)
#     dexpr
#   end

#   r === nothing ? dexpr : r
# end


# ERROR: MethodError: objects of type Bool are not callable
# Maybe you forgot to use an operator such as *, ^, %, / etc. ?
# Stacktrace:
#  [1] (::var"#5#8"{Bool})(e::D2Expr)
#    @ Main ~/Projects/Exercism/julia/kata/symb-diff/symb-diff.jl:42
#  [2] |>(x::D2Expr, f::var"#5#8"{Bool})
#    @ Base ./operators.jl:911
#  [3] D2Expr(op::Symbol, lhs::Atom, rhs::Atom; wrt::Symbol, simplify::Bool)
#    @ Main ~/Projects/Exercism/julia/kata/symb-diff/symb-diff.jl:42
#  [4] (::var"#build_expr!#14"{Symbol, Vector{Union{Nothing, Atom, D2Expr}}, Vector{Symbol}})()
#    @ Main ~/Projects/Exercism/julia/kata/symb-diff/symb-diff.jl:118
#  [5] parser(expr::String; wrt::Symbol)
#    @ Main ~/Projects/Exercism/julia/kata/symb-diff/symb-diff.jl:176
#  [6] differentiate(expr::String; wrt::Symbol)
#    @ Main ~/Projects/Exercism/julia/kata/symb-diff/symb-diff.jl:92
#  [7] differentiate(expr::String)
#    @ Main ~/Projects/Exercism/julia/kata/symb-diff/symb-diff.jl:91
#  [8] top-level scope
#    @ REPL[2]:1
