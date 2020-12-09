using Test
using Random

push!(LOAD_PATH, "./src")
using YAQ

@testset "empty list" begin
  q = Q{Int}(10)

  @test length(q) == 0
  @test isempty(q)
end

@testset "full list" begin
  v = rand(1:100, 10)   ## 10 randomly chosen int
  q = Q{eltype(v)}(v)

  @test isfull(q)
  @test length(q) == length(v)

  @test_throws ArgumentError enqueue!(q, 10)
end

@testset "enqueue/dequeue several times - Int" begin
  n = 10_000
  v = rand(1:n, n)
  q = Q{eltype(v)}(v)

  lim = n ÷ 2
  for ix in 1:lim
    x = dequeue!(q)
    @test x == v[ix]
  end
  @assert q._h == lim + 1 "Expected head to be $(lim+1) got: $(q._h) => [$(q)]"        ## Extra - internal

  for ix in 1:lim
    x = v[ix] * 10
    enqueue!(q, x)
    @test last(q) == x
  end

  # Q full
  @test_throws ArgumentError enqueue!(q, 10)

  for ix in 1:n
    x = dequeue!(q)
    exp_x = ix ≤ lim ? v[ix + lim] : v[ix - lim] * 10
    @test x == exp_x
  end

  # Q empty
  @test isempty(q)
  @test_throws ArgumentError dequeue!(q)
end

@testset "iterate over q element" begin
  n = 500
  v = rand(1:n, n)
  q = Q{eltype(v)}(v)

  for (ix, e) in enumerate(q)
    @test e == v[ix]
  end
end


@testset "enqueue/reset several times" begin
  n = 10_000
  v = rand(1:n, n)
  q = Q{eltype(v)}(n)

  for ix in 1:n
    enqueue!(q, v[ix])
    @test last(q) == v[ix]
  end
  @test first(q) == v[1]

  @test isfull(q)
  @test length(q) == length(v)

  @test_throws ArgumentError enqueue!(q, 10)

  reset!(q)
  @test isempty(q)
  @test length(q) == 0

  n ÷=10
  for ix in n:-1:1
    enqueue!(q, v[ix])
    @test last(q) == v[ix]
  end
  @test first(q) == v[n]

  reset!(q)
  @test isempty(q)
  @test length(q) == 0
end


@testset "enqueue/dequeue several times - Float" begin
  n = 10_000
  v = rand(n)
  q = Q{eltype(v)}(v)

  lim = n ÷ 2
  for ix in 1:lim
    x = dequeue!(q)
    @test x == v[ix]
  end
  @assert q._h == lim + 1 "Expected head to be $(lim+1) got: $(q._h) => [$(q)]"        ## Extra - internal

  for ix in 1:lim
    x = v[ix] * 10.
    enqueue!(q, x)
    @test last(q) ≈ x
  end

  # Q full
  @test_throws ArgumentError enqueue!(q, 10.)

  for ix in 1:n
    x = dequeue!(q)
    exp_x = ix ≤ lim ? v[ix + lim] : v[ix - lim] * 10.
    @test x ≈ exp_x
  end

  # Q empty
  @test isempty(q)
  @test_throws ArgumentError dequeue!(q)
end

@testset "iterate over q element" begin
  n = 500
  v = rand(1:n, n)
  q = Q{eltype(v)}(v)

  for (ix, e) in enumerate(q)
    @test e == v[ix]
  end
end
