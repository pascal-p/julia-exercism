const VS = Vector{String}
const DIV = Dict{Integer, VS}

macro check_grade(fn::Expr)
  local _grade = if fn.args[1].args[1].args[3] isa Expr
    fn.args[1].args[1].args[3].args[1] # with type hint
  else
    fn.args[1].args[1].args[3]         # w/o type hint
  end

  ## replace body
  fn.args[2] = quote
    $(_grade) ≤ 0 && throw(ArgumentError("Expecting grade to be > 0"))

    $(fn.args[2])
  end

  return fn
end

mutable struct Student
  name::String
  grade::Integer

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
  # roster = DIV()
  # for (key, val) ∈ gr.roster # pairs(gr.roster)
  #   roster[key] = [val...]
  # end
  # roster

  foldl((d, (k, v)=pair) -> (d[k] = [v...]; d), gr.roster |> collect;
        init=DIV())
end

# grade ≤ 0 && throw(ArgumentError("Expecting grade to be > 0"))

@check_grade function students_in_grade(gr::GradeSchool, grade::Integer)::VS
  lst = get(gr.roster, grade, String[])
  [lst...]
end

# w/o type hints
# @check_grade function students_in_grade(gr, grade)::VS
#   lst = get(gr.roster, grade, String[])
#   [lst...]
# end

add_student!(gr::GradeSchool, name::String, grade::Integer) = add_student!(gr, grade, name)

@check_grade function add_student!(gr::GradeSchool, grade::Integer, name::String)::Nothing
  ix = findfirst(stu -> stu.name == name, gr.students)
  if ix === nothing
    ## create
    student = Student(name, grade)
    push!(gr.students, student)
    ix = gr.students |> length
    _update_roster!(gr, name, grade, ix)
  else
    ## update
    _update_roster!(gr, name, grade, ix)
    gr.students[ix].grade = grade
  end

  nothing
end

##
## internal
##

function _update_roster!(gr, name::String, grade::Integer, ix::Integer)
  ## remove student name at (original) grade from roster
  gradeₒ = gr.students[ix].grade
  v = get(gr.roster, gradeₒ, [])
  nv = filter(n -> n !== name, v)
  gr.roster[gradeₒ] = nv

  ## add student at grade in roster
  v = get(gr.roster, grade, [])
  push!(v, name)
  gr.roster[grade] = sort(v)
end
