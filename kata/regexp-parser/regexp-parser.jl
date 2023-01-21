using Base: collect_preferences

const Symbols = Set(['*', '|', '.', '(', ')'])
const Tokens = vcat('a':'z' |> collect, 'A':'Z' |> collect)
const Priority = Dict{String, Integer}(
  "*" => 3, # unary op
  "|" => 2, # binary
  "(" => 1,
  ")" => 1,
  "." => 1,
  # sequence is implicit
)

const All_Valid_Symbols = vcat(Tokens, Char.(Symbols))

## map?
# "|" => Or
# "." => Any
# "*" => ZeroOrMore


function regexp_parser(regexp::String)::Union{String, Nothing}
  expr_ary = String[]

  for ch ∈ regexp
    ch ∉ All_Valid_Symbols && return nothing

    istoken(ch) && (push!(expr_ary, normal_expr(ch)); continue)

    if isop(ch)
      # TODO
    end
  end

  if length(expr_ary) == 1
    join(expr_ary, "")
  elseif startswith(expr_ary[1], "Normal")
    string("Str [", join(expr_ary, ", "), "]")
  else
    join(expr_ary, "")
  end
end

istoken(ch::Char)::Bool = ch ∈ Tokens

isop(ch::Char)::Bool = ch ∈ Symbol

normal_expr(ch::Char)::String = "Normal '$(ch)'"
