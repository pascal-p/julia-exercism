using Test

include("grade-school.jl")

@testset "A new school has an empty roster" begin
  grade_school = GradeSchool()

  @test student_roster(grade_school) |> length === 0
end


@testset "A student can't be in two different grades" begin
  grade_school = GradeSchool()
  add_student!(grade_school, "Aimee", 2)
  add_student!(grade_school, "Aimee", 1)
  empty_grade = students_in_grade(grade_school, 2)

  @test empty_grade == []
end

@testset "Adding a student adds them to the roster for the given grade" begin
  grade_school = GradeSchool()
  add_student!(grade_school, "Aimee", 2)

  @test student_roster(grade_school) == DIV(2 => [ "Aimee" ])
end

@testset "Adding more students to the same grade adds them to the roster" begin
  grade_school = GradeSchool()
  add_student!(grade_school, "Paul", 2)
  add_student!(grade_school, "Blair", 2)
  add_student!(grade_school, "James", 2)

  @test student_roster(grade_school) == DIV(2 => [ "Blair", "James", "Paul" ])
end

@testset "adding students to different grades adds them to the roster" begin
  grade_school = GradeSchool()
  add_student!(grade_school, "Chelsea", 3)
  add_student!(grade_school, "Logan", 7)

  @test student_roster(grade_school) == DIV(3 => [ "Chelsea" ], 7 => [ "Logan" ])
end

@testset "grade returns the students in that grade in alphabetical order" begin
  grade_school = GradeSchool()
  add_student!(grade_school, "Franklin", 5)
  add_student!(grade_school, "Bradley", 5)
  add_student!(grade_school, "Zoe", 1)
  add_student!(grade_school, "Jeff", 1)

  @test student_roster(grade_school) == DIV(1 => [ "Jeff", "Zoe" ], 5 => [ "Bradley", "Franklin" ])
end

@testset "grade returns an empty array if there are no students in that grade" begin
  grade_school = GradeSchool()

  @test students_in_grade(grade_school, 1) == []
end

@testset "the students names in each grade in the roster are sorted" begin
  grade_school = GradeSchool()
  add_student!(grade_school, "Jennifer", 4)
  add_student!(grade_school, "Kareem", 6)
  add_student!(grade_school, "Christopher", 4)
  add_student!(grade_school, "Kyle", 3)

  @test student_roster(grade_school) == DIV(3 => [ "Kyle" ], 4 => [ "Christopher", "Jennifer" ], 6 => [ "Kareem" ])
end

@testset "roster cannot be modified outside of module" begin
  grade_school = GradeSchool()
  add_student!(grade_school, "Aimee", 2)

  roster = student_roster(grade_school)
  result = get(roster, 2, [])
  push!(result, "Oops.")

  @test student_roster(grade_school) == DIV(2 => [ "Aimee" ])
end

@testset "roster cannot be modified outside of module using students_in_drade()" begin
  grade_school = GradeSchool()
  add_student!(grade_school, "Aimee", 2)
  push!(students_in_grade(grade_school, 2), "Ooops")

  @test student_roster(grade_school) == DIV(2 => [ "Aimee" ])
end


@testset "Exception /1" begin
  grade_school = GradeSchool()
  add_student!(grade_school, "Aimee", 2)

  @test_throws ArgumentError students_in_grade(grade_school, 0)
end

@testset "Exception /2" begin
  grade_school = GradeSchool()
  @test_throws ArgumentError add_student!(grade_school, "Aimee", -1)
end
