using Test
# using Random

include("./job-scheduler.jl")

const TF_DIR = "./testfiles"

function clone(vtasks::VTasks{Int, Int})
  tasks = VTasks{Int, Int}(undef, length(vtasks))
  copyto!(tasks, vtasks)
  tasks
end

@testset "challenge/scheduling 10_000 jobs" begin
  vtasks = load_data("$(TF_DIR)/jobs.txt", Int)

  @testset "10000 jobs / by :diff" begin
    tasks = clone(vtasks)

    @test cost(tasks, by=:diff) == 69_119_377_652
  end

  @testset "10000 jobs / by :ratio" begin
    tasks = clone(vtasks)

    @test cost(tasks, by=:ratio) == 67_311_454_237
  end
end
