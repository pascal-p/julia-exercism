using Test

include("./job-scheduler.jl")

const TF_DIR = "./testfiles"


function read_sol(ifile)
  inputs = open(ifile) do f
    readlines(f)
  end

  map(x -> parse(Int, x), inputs)
end

function clone(vtasks::VTasks{Int, Int})
  tasks = VTasks{Int, Int}(undef, length(vtasks))
  copyto!(tasks, vtasks)
  tasks
end


@testset "basics" begin
  vtasks = VTasks{Int, Int}([Task{Int, Int}(3, 5), Task{Int, Int}(1, 2)])

  @test cost(vtasks; by=:diff) == 23
  @test cost(vtasks; by=:ratio) == 22
end

@testset "diff/ratio with tie" begin
  #                                         w, l                  w, l                  w, l
  vtasks = VTasks{Int, Int}([Task{Int, Int}(3, 5), Task{Int, Int}(1, 2), Task{Int, Int}(4, 6)])

  @test cost(vtasks; by=:diff) == 73
  @test cost(vtasks; by=:ratio) == 70
end


for file in filter((fs) -> occursin(r"\Ainput_random_\d+_\d+", fs),
                   cd(readdir, "$(TF_DIR)"))

  ifile = replace(file, r"\Ainput_" => s"output_")
  exp_values = read_sol("$(TF_DIR)/$(ifile)")
  vtasks = load_data("$(TF_DIR)/$(file)", Int)

  @testset "job scheduler (by diff) on: $(file)" begin
    tasks = clone(vtasks)

    @test cost(tasks, by=:diff) == exp_values[1]
  end

  @testset "job scheduler (by ratio) on: $(file)" begin
    tasks = clone(vtasks)

    @test cost(tasks, by=:ratio) == exp_values[2]
  end

end
