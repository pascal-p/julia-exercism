const VS = Vector{String}
const DIV = Dict{Integer, VS}

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

function students_in_grade(gr::GradeSchool, grade::Integer)::VS
  grade ≤ 0 && throw(ArgumentError("Expecting grade to be > 0"))

  lst = get(gr.roster, grade, String[])
  [lst...]
end

function add_student!(gr::GradeSchool, name::String, grade::Integer)
  grade ≤ 0 && throw(ArgumentError("Expecting grade to be > 0"))

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
