### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

# ╔═╡ 555272c1-e494-40b2-a01b-702af7b6c0dc
using InteractiveUtils

# ╔═╡ cb14a767-31b0-4cec-a3d6-8d83a3c9d19c
begin
	using PlutoUI
	PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ 481c19ba-c146-4ecc-a613-05dd2bceda1a
md"""
## Macros in Julia
"""

# ╔═╡ 468ddd1a-6f26-4e6f-81b2-40e3d60b316f
html"""
<style>
  main {
    max-width: calc(1050px + 25px + 6px);
  }
</style>
"""

# ╔═╡ 776d65e7-49ab-47c9-83de-3aa928e1a2b0
md"""
### Example 1: score checker 

Context: define 3 basic functions taking a vector of integer (named `scores`) as an argument and returning the following:
  1. `latest(scores)` == latest added score (last element of the vector)
  2. `personal_best(scores)` == best (highest) score so far
  3. `personal_top_3(scores)`  == best three scores

Let's define a `Julia macro` which will take any of those previous functions as argument and inject code to check that the vector is indeed  a vector of unsigned values as _scores are positive integer values (Including 0)_ 

Using a macro here makes sense as it factors out the same piece of code (DRY) and make the whole code more declarative.
"""

# ╔═╡ 8d54423a-11dd-48bf-8ff9-1593c69e7140
md"""
In the following, we are interested in the argument pass to the macro, which is the target function we want to manipulate at compile time to inject the  "check instruction".

We have a few cases to take into account as far as the target function is declared:
 - with or without type hint
 - with or without explicit return type
 - with or without default value

Examples:
```
latest(scores::TScore = Unsigned[])::Unsigned    # full explicit signature with type hint + default value
latest(scores::TScore = Unsigned[])              # type hint + default value, no explicit return type
latest(scores::TScore)::Unsigned                 # type hint, no default value and explict return type
latest(scores)                                   # implicit
```

if the full function signature is such that `fn == latest(scores::TScore = Unsigned[])::Unsigned`, then

| Argument | Expansion | Comment |
|:----|:-----|:----|
| `fn.args[1]`  | `latest(scores::TScore = Unsigned[])::Unsigned` | |
|`fn.args[1].args` | `Any[:(latest(scores::TScore = Unsigned[])), :Unsigned]` | a vector |
| | | `length(args[1].args) == 2` |
| | | `typeof(args[1].args) == Vector{Any}` |
| | | |
| `fn.args[1].args[1]` | `latest(scores::TScore = Unsigned[])` | the function and its arguments |
| | | typeof(args[1].args[1]) == Expr |
| `fn.args[1].args[2]` | `Unsigned` | the type of the return value from the function |
| `fn.args[1].args[1].args` | Any[:latest, :($(Expr(:kw, :(scores::TScore), :(Unsigned[]))))] | aka vector of 3 elements | 
| | | |                       
| `fn.args[1].args[1].args[2]` | `$(Expr(:kw, :(scores::TScore), :(Unsigned[])))` | |
| `fn.args[1].args[1].args[2].args[1]` | `scores::TScore`  | |
| | | `typeof(fn.args[1].args[1].args[2].args[1]) == Expr` |
| `fn.args[1].args[1].args[2].args[1],args` | Any[:scores, :TScore]| |
| `fn.args[1].args[1].args[2].args[1].args[1]` | scores | this is what we want to manipulate |
| | | |

Which leads to the following code - abundantly commented. Noet the use of `local` to avoid polluting the target space in which the original function is defined. 
"""

# ╔═╡ ee0d244b-a819-4144-89ee-f159f3ba8112
macro check_scores(fn::Expr)
  local fn_sign = fn.args[1].args
  local scores = if typeof(fn_sign[1]) == Expr
    # case - has return type
    # fn_sign == Any[:(latest(scores::TScore)), :Unsigned] ||
    #            Any[:(latest(scores)), :Unsigned] ||
    #            Any[:(latest(scores::TScore = Unsigned[])), :Unsigned]
    local fn_sign_ext = fn_sign[1].args[2]
    typeof(fn_sign_ext) == Expr ?
      (typeof(fn_sign_ext.args[1]) == Symbol ? fn_sign_ext.args[1] : fn_sign_ext.args[1].args[1]) :
      fn_sign_ext # == no type hint
  elseif typeof(fn_sign[1]) == Symbol
    # case - no return type
    if typeof(fn_sign[end]) == Expr
      # fn_sign == Any[:latest, :(scores::TScore)] ||                              => fn_sign[2].args[1]
      #            Any[:latest, :($(Expr(:kw, :(scores::TScore), :(Unsigned[]))))] => fn_sign[2].args[1].args[1]
      typeof(fn_sign[2].args[1]) == Symbol ?
        fn_sign[2].args[1] : fn_sign[2].args[1].args[1] # because it is an Expression
    else
      fn_sign[2] # fn_sign = Any[:latest, :scores]
    end
  end
  ## replace body which is fn.args[2]
  fn.args[2] = quote
    # inject the check
    length($scores) == 0 && throw(ArgumentError("scores must be a non empty vector"))
    # copy back the original function body
    $(fn.args[2])
  end
  fn
end

# ╔═╡ 071e115f-8604-4aba-837f-81652fd417fe
TScore = Vector{<: Unsigned}

# ╔═╡ 1d7c0a3d-af72-4960-a964-c07b0ae6d5c6
@check_scores latest(scores::TScore)::Unsigned = scores[end]

# ╔═╡ 11d7a210-16bd-41c7-8a4d-a704bb951626
begin
	## working as expected:
	
	@check_scores latest(scores::TScore = Unsigned[])::Unsigned  = scores[end]
	@check_scores latest(scores)::Unsigned = scores[end]
	@check_scores latest(scores::TScore) = scores[end]
	@check_scores latest(scores) = scores[end]
	@check_scores latest(scores::TScore = Unsigned[]) = scores[end]
	@check_scores latest(scores = Unsigned[])::Unsigned = scores[end]
	@check_scores latest(scores = Unsigned[]) = scores[end]
end

# ╔═╡ e35649a8-6fc0-420f-b206-bfcb2c51618b
md"""
### Example 2: check for undefined form
"""

# ╔═╡ b556af00-e40b-4d46-8a5b-5634c642ebd1
function resolve(arg1, arg2)
  if typeof(arg1) == Expr && typeof(arg2) == Expr
    println("** Args are: ", arg1.args[1], " , ", arg2.args[1])
    (arg1.args[1], arg2.args[1])
    #
  elseif typeof(arg1) == Expr && typeof(arg2) == Symbol
    println("** Args are: ", arg1.args[1], " , ", arg2)
    (arg1.args[1], arg2)
    #
  elseif typeof(arg1) == Symbol && typeof(arg2) == Expr
    println("** Args are: ", arg1, " , ", arg2.args[1])
    (arg1, arg2.args[1])

  elseif typeof(arg1) == Symbol && typeof(arg2) == Symbol
    println("** Args are: ", arg1, " , ", arg2)
    (arg1, arg2)
  else
    # NO-OP
    (0, 0)
  end
end

# ╔═╡ e0b295de-66bc-4774-b07d-204b6aa6d0ea
macro check_undefined_form(fn::Expr)
  local fn_sign = fn.args[1].args
  local r, x = if typeof(fn_sign[1]) == Expr && typeof(fn_sign[end]) == Expr
    local arg1, arg2 = fn_sign[1].args[1].args[2], fn_sign[1].args[1].args[3]
    resolve(arg1, arg2)
    #
  elseif typeof(fn_sign[1]) == Expr
    local arg1, arg2 = fn_sign[1].args[2], fn_sign[1].args[3]
    resolve(arg1, arg2)
    #
  elseif typeof(fn_sign[1]) == Symbol
    local arg1, arg2 = fn_sign[2], fn_sign[3]
    resolve(arg1, arg2)
  else
    throw(ArgumentError("We should not end up here"))
  end
  # println("== function: ", fn.args[2])
  fn.args[2] = quote
    iszero(r) && iszero(x) && throw(ArgumentError("Undefined form 0^0"))
    $(fn.args[2])
  end
  fn
end

# ╔═╡ 9e25ec4a-beed-4305-b65d-39a9114d5945
# with Parametric type T
@check_undefined_form function yapower(r::Rational, x::Int64)::Rational where { T <: Integer }
	iszero(x) && return one(Rational)
	Rational(r.num ^ (x), r.den ^ (x))
end

# ╔═╡ 59c6558a-ed88-4d00-b555-b0e4adc233e8
@check_undefined_form function yapower(r::Rational, x::Int64)::Rational
	iszero(x) && return one(Rational)
	Rational(r.num ^ (x), r.den ^ (x))
end

# ╔═╡ d9e959e8-210e-4f2e-9a8e-374bb9f4c928
@check_undefined_form function yapower(r::Rational, x)::Rational
end

# ╔═╡ f6cf92f6-c845-4889-863d-33c9bffbdb12
@check_undefined_form function yapower(r::Rational, x)
end

# ╔═╡ 2107d19a-0fa4-422b-84b8-456a00a575ff
@check_undefined_form function yapower(r, x::Int64)::Rational
end

# ╔═╡ 6a95d757-24b0-49f1-9d31-22b7710b1a94
@check_undefined_form function yapower(r, x)::Rational
end

# ╔═╡ 7f902ee4-8a32-4425-bd45-2493a61503f9
@check_undefined_form function yapower(r, x::Int64)
end

# ╔═╡ a5880efc-7836-49c2-ad92-9638df9c720d
@check_undefined_form function yapower(r, x)
end

# ╔═╡ 70869412-b16d-40b4-9040-a6c2dc003f56
@check_undefined_form function yapower(r::Rational, x)
end

# ╔═╡ a1e270fd-9d0d-4268-aab8-6e550339f112
md"""
### Example 3 - Co-prime checker
"""

# ╔═╡ f2fd3d36-7062-4df1-896e-4bb81b6f6e5b
"""
  Aim: inject oneliner to check whether the given α (2nd arg of encode/decode function) is co-prime with M

With: @coprime_checker function encode(plain::AbstractString, α::Integer, β::Integer)::AbstractString
We have the following:

  fn.args[1]                         == encode(plain::AbstractString, α::Integer, β::Integer)::AbstractString
  fn.args[1].args[1]                 == encode(plain::AbstractString, α::Integer, β::Integer)
  fn.args[1].args[2]                 == AbstractString
  fn.args[1].args[1].args[1]         == encode
  fn.args[1].args[1].args[2]         == plain::AbstractString
  fn.args[1].args[1].args[3]         == α::Integer
  fn.args[1].args[1].args[3].args[1] == α
  fn.args[2]                         == whole body of fn
"""
macro coprime_checker(fn)
  if typeof(fn) == Expr
    ## extract var and build checker
    # local var = expr.args[1].args[3] # w/o any type annotation
    local var = fn.args[1].args[1].args[3].args[1]                            # access α
    local check = :(!iscoprime($(var)) && throw(ArgumentError("$($(var)) and M=$(M) not coprime")))

    fn.args[2] = :(begin
      $(check)       # Inject check as first line in the body of the target function
      $(fn.args[2])  # Copy original function body unchanged
    end)
  end

  fn
end

# ╔═╡ 8bd5e851-659c-4fe8-9903-7c678d7c9bfd
Base.isinteractive()

# ╔═╡ e897f4c5-2c51-4d98-a7db-ce4d49a94884
@macroexpand @coprime_checker function encode(plain::AbstractString, α::Integer, β::Integer)::AbstractString
  |(plain, α, β, +) |>
    ary -> reduce((s, c) -> grouping(s, c), ary, init=" ") |>
    s -> strip(s)
end

# ╔═╡ e29c68d8-e5f8-443c-bbec-a857d7dba5a2
md"""
The macro expansion:
```Julia
function Main.encode(plain::AbstractString, α::.Integer, β::.Integer)::AbstractString
  !(iscoprime(α)) && throw(ArgumentError("$(α) and M=$(M) not coprime"))	     
  begin
	|(plain, α, β, :+) |> ((ary) -> begin
	  reduce(((s, c) -> begin
	    grouping(s, c)
	  end), ary, init = " ") |> 
	    ((s)->begin
	      strip(s)
	    end)
	end)
  end
end
```
"""

# ╔═╡ e3e0b34a-d538-4e6e-9080-55e89006e2ee
md"""
### Example 4: Checking grade
"""

# ╔═╡ c1d2d888-c2cf-4b46-a169-caedffd59d0c
const SUE = Union{Symbol, Expr}

# ╔═╡ f6f5f2f4-c294-421c-8a25-5d3242447058
extract_grade_arg(arg::SUE) = typeof(arg[end]) == Symbol ? arg[end] : arg[end].args[1]

# ╔═╡ 9f052122-e838-4d17-9a67-fc0370ecf2e3
extract_grade_arg(arg::Vector{Any}) = typeof(arg[end]) == Symbol ? arg[end] : arg[end].args[1]

# ╔═╡ f9636c42-13df-4131-a210-fec10aae1fbd
macro check_grade(fn::Expr)
  # fn == function with 2 or 3 arguments, interested only in the last argument (grade, pos 3 or 4)
  local fn_sign = fn.args[1].args
  println(">> Expr fn.args[1].args: ", fn_sign)
  local _grade = length(fn_sign) ∈ [3, 4] ? extract_grade_arg(fn_sign) : extract_grade_arg(fn_sign[1].args)
  
  println("Found var: ", _grade)
  ## replace body
  fn.args[2] = quote
    $(_grade) ≤ 0 && throw(ArgumentError("Expecting grade to be > 0, got \$($(_grade))"))
    $(fn.args[2])
  end
  fn
end

# ╔═╡ 6b1778bb-17f2-4749-96c5-5ad03637ff55


# ╔═╡ 02c87928-31b0-4e68-987d-df0adb77b1d3
begin
	const VS = Vector{String}
	const DIV = Dict{Integer, VS}
end

# ╔═╡ ac00a149-6157-41c0-9b9d-8029376c1805
mutable struct Student
  # does not matter for the purpose of the macro
end

# ╔═╡ 47f18735-b489-482a-91a8-ecf552ac1d3b
struct GradeSchool
  students::Vector{Student}
  roster::DIV
end

# ╔═╡ 99e6445b-e858-482d-a9a7-8dfac2703ea4
@check_grade function students_in_grade(gr::GradeSchool, grade::Integer)::VS; end

# ╔═╡ c36e2643-1464-49c2-9039-877e4ab3d01f
@check_grade function students_in_grade(gr, grade::Integer); end

# ╔═╡ 3ebf5774-1d94-4c4e-bcec-ea55f4323ca2
@check_grade function students_in_grade(gr::GradeSchool, grade::Integer); end

# ╔═╡ b7a357ee-7375-4237-9697-30c0f60d47f6
@check_grade function students_in_grade(gr::GradeSchool, grade); end

# ╔═╡ a96da069-095c-49af-8b86-d2699f35d699
@check_grade function students_in_grade(gr, grade); end

# ╔═╡ 5d8bfb95-208a-4d19-9185-3b2710132d39
@check_grade function students_in_grade(gr, grade)::VS; end

# ╔═╡ 5bc5fe78-28d5-4d82-be4c-30bafb8a6bc0
@check_grade function students_in_grade(gr, grade::Integer)::VS; end

# ╔═╡ 6d1d0bb3-c406-4557-9d90-83dcc95b346f
@check_grade function students_in_grade(gr::GradeSchool, grade)::VS; end

# ╔═╡ 6c5b2021-7912-423b-9daf-f512d33b8854
@check_grade function add_student!(gr::GradeSchool, name::String, grade::Integer)::Nothing; end

# ╔═╡ b6dc3770-1fc4-4740-aa36-dd01f386c3e0
@check_grade function add_student!(gr::GradeSchool, name::String, grade)::Nothing; end

# ╔═╡ a5d7558b-1d48-4c17-8e9e-0c3708bcf28f
@check_grade function add_student!(gr::GradeSchool, name::String, grade); end

# ╔═╡ 44268771-432b-42be-96a1-7ac08a8e74ca
typeof(:Nothing), typeof(Nothing)

# ╔═╡ f3c148ff-22d3-4bdb-a7bc-c02e16bef3ee
md"""
### Example 5: Checking type and limits 
"""

# ╔═╡ 15bc7d93-5b81-4baa-b4ca-ecac918e814f
extract_arg(arg) = typeof(arg[2]) == Symbol ? arg[2] : arg[2].args[1]

# ╔═╡ c736370c-39e3-46a2-8d33-c5ec7402c154
#
# convenience macro whose aim is to inject the following 'guard' condition:
#   ($x ≤ zero(typeof($x)) || $x > LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
# into the target function body
macro check_int_arg(fn::Expr)
  local x = extract_arg(fn.args[1].args)
  # replace body
  fn.args[2] = quote
    ($x ≤ zero(typeof($x)) || $x > LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
    $(fn.args[2])
  end
  fn
end

# ╔═╡ c1388360-4a21-49ea-9f31-f6f05c282fc0
#
# convenience macro whose aim is to inject the following 'guard' condition:
#   $(x) > typeof($(x))(LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
# into the target function body
#
macro check_uint_arg(fn::Expr)
  local x = extract_arg(fn.args[1].args)
  # replace body
  fn.args[2] = quote
    $(x) > typeof($(x))(LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
    $(fn.args[2])
  end
  fn
end

# ╔═╡ 35384000-dbe1-4b18-b616-2ce0493ff6b2
@check_uint_arg on_square(square::Unsigned) = (typeof(square))(2) ^ (square - one(typeof(square)))

# ╔═╡ 17407d62-d960-47c4-b034-6aac3f612ad8
@check_int_arg on_square(square::Integer) = on_square(Unsigned(square))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.49"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "a5c8c4e2723c4aeae0704f668327e21c5f9df6b3"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6466e524967496866901a78fca3f2e9ea445a559"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─481c19ba-c146-4ecc-a613-05dd2bceda1a
# ╠═555272c1-e494-40b2-a01b-702af7b6c0dc
# ╠═cb14a767-31b0-4cec-a3d6-8d83a3c9d19c
# ╟─468ddd1a-6f26-4e6f-81b2-40e3d60b316f
# ╟─776d65e7-49ab-47c9-83de-3aa928e1a2b0
# ╟─8d54423a-11dd-48bf-8ff9-1593c69e7140
# ╠═ee0d244b-a819-4144-89ee-f159f3ba8112
# ╠═071e115f-8604-4aba-837f-81652fd417fe
# ╠═1d7c0a3d-af72-4960-a964-c07b0ae6d5c6
# ╠═11d7a210-16bd-41c7-8a4d-a704bb951626
# ╟─e35649a8-6fc0-420f-b206-bfcb2c51618b
# ╠═b556af00-e40b-4d46-8a5b-5634c642ebd1
# ╠═e0b295de-66bc-4774-b07d-204b6aa6d0ea
# ╠═9e25ec4a-beed-4305-b65d-39a9114d5945
# ╠═59c6558a-ed88-4d00-b555-b0e4adc233e8
# ╠═d9e959e8-210e-4f2e-9a8e-374bb9f4c928
# ╠═f6cf92f6-c845-4889-863d-33c9bffbdb12
# ╠═2107d19a-0fa4-422b-84b8-456a00a575ff
# ╠═6a95d757-24b0-49f1-9d31-22b7710b1a94
# ╠═7f902ee4-8a32-4425-bd45-2493a61503f9
# ╠═a5880efc-7836-49c2-ad92-9638df9c720d
# ╠═70869412-b16d-40b4-9040-a6c2dc003f56
# ╟─a1e270fd-9d0d-4268-aab8-6e550339f112
# ╠═f2fd3d36-7062-4df1-896e-4bb81b6f6e5b
# ╠═8bd5e851-659c-4fe8-9903-7c678d7c9bfd
# ╠═e897f4c5-2c51-4d98-a7db-ce4d49a94884
# ╟─e29c68d8-e5f8-443c-bbec-a857d7dba5a2
# ╟─e3e0b34a-d538-4e6e-9080-55e89006e2ee
# ╠═c1d2d888-c2cf-4b46-a169-caedffd59d0c
# ╠═f6f5f2f4-c294-421c-8a25-5d3242447058
# ╠═9f052122-e838-4d17-9a67-fc0370ecf2e3
# ╠═f9636c42-13df-4131-a210-fec10aae1fbd
# ╠═6b1778bb-17f2-4749-96c5-5ad03637ff55
# ╠═02c87928-31b0-4e68-987d-df0adb77b1d3
# ╠═ac00a149-6157-41c0-9b9d-8029376c1805
# ╠═47f18735-b489-482a-91a8-ecf552ac1d3b
# ╠═99e6445b-e858-482d-a9a7-8dfac2703ea4
# ╠═c36e2643-1464-49c2-9039-877e4ab3d01f
# ╠═3ebf5774-1d94-4c4e-bcec-ea55f4323ca2
# ╠═b7a357ee-7375-4237-9697-30c0f60d47f6
# ╠═a96da069-095c-49af-8b86-d2699f35d699
# ╠═5d8bfb95-208a-4d19-9185-3b2710132d39
# ╠═5bc5fe78-28d5-4d82-be4c-30bafb8a6bc0
# ╠═6d1d0bb3-c406-4557-9d90-83dcc95b346f
# ╠═6c5b2021-7912-423b-9daf-f512d33b8854
# ╠═b6dc3770-1fc4-4740-aa36-dd01f386c3e0
# ╠═a5d7558b-1d48-4c17-8e9e-0c3708bcf28f
# ╠═44268771-432b-42be-96a1-7ac08a8e74ca
# ╟─f3c148ff-22d3-4bdb-a7bc-c02e16bef3ee
# ╠═15bc7d93-5b81-4baa-b4ca-ecac918e814f
# ╠═c736370c-39e3-46a2-8d33-c5ec7402c154
# ╠═c1388360-4a21-49ea-9f31-f6f05c282fc0
# ╠═35384000-dbe1-4b18-b616-2ce0493ff6b2
# ╠═17407d62-d960-47c4-b034-6aac3f612ad8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
