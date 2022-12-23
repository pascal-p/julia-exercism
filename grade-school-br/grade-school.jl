const VS = Vector{String}
const DIV = Dict{Integer, VS}
const SUE = Union{Symbol, Expr}

extract_grade_arg(arg::SUE) = typeof(arg[end]) == Symbol ? arg[end] : arg[end].args[1]
extract_grade_arg(arg::Vector{Any}) = typeof(arg[end]) == Symbol ? arg[end] : arg[end].args[1]

macro check_grade(fn::Expr)
  ## fn == function with 2 arguments, interested only in the second argument
  local fn_sign = fn.args[1].args
  local _grade = length(fn_sign) ∈ [3, 4] ? extract_grade_arg(fn_sign) : extract_grade_arg(fn_sign[1].args)
  ## replace body
  fn.args[2] = quote
    $(_grade) ≤ 0 && throw(ArgumentError("Expecting grade to be > 0, got $($_grade)"))
    $(fn.args[2])
  end
  fn
end

mutable struct Student
  name::String
  grade::Integer

  # cannot use macro here...
  function Student(name::String, grade::Integer)
    grade ≤ 0 && throw(ArgumentError("Expecting grade to be > 0"))
    new(name, grade)
  end
end

struct GradeSchool
  students::Vector{Student}
  roster::DIV
end

GradeSchool()::GradeSchool = GradeSchool(Vector{Student}[], DIV())

function student_roster(gr::GradeSchool)::DIV
  println("gr.roster |> collect: ", gr.roster |> collect;)
  foldl(
    (d, pair) -> ((k, v) = pair;  d[k] = [v...]; d), # (d, ((k, v) = pair...)) -> (d[k] = [v...]; d),
    gr.roster |> collect;  # list of Pair{Integer, Vector{String}}
    init=DIV()
  )
end

@check_grade function students_in_grade(gr::GradeSchool, grade::Integer)::VS
  lst = get(gr.roster, grade, String[])
  [lst...]
end

@check_grade function add_student!(gr::GradeSchool, name::String, grade::Integer)::Nothing
  ix = findfirst(stu -> stu.name == name, gr.students)
  if ix === nothing
    ## create
    student = Student(name, grade)
    push!(gr.students, student)
    ix = gr.students |> length
    _update_roster!(gr, name, grade, ix)
    return nothing
  end
  ## update
  _update_roster!(gr, name, grade, ix)
  gr.students[ix].grade = grade
  nothing
end

##
## internal
##

function _update_roster!(gr, name::String, grade::Integer, ix::Integer)::Nothing
  ## remove student name at (original) grade from roster
  gradeₒ = gr.students[ix].grade
  v = get(gr.roster, gradeₒ, [])
  nv = filter(n -> n !== name, v)
  gr.roster[gradeₒ] = nv

  ## (re)add student at grade in roster
  v = get(gr.roster, grade, [])
  push!(v, name)
  gr.roster[grade] = sort(v)

  nothing
end
