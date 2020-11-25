using Test

push!(LOAD_PATH, "./src")
using YASLL

@testset "SLList" begin

  @testset "basic tests - list of int" begin
    sl = list(2, 3, 1)

    @test length(sl) == 3
    @test eltype(sl) == Int
    @test eltype(typeof(sl)) == Int
  end

  @testset "nil list" begin
    lnil = nil()
    @test length(lnil) == 0
    @test lnil == nil()
    @test lnil == nil(Int)

    @test sprint(show, lnil) == "nil()"
    @test typeof(list()) === typeof(lnil)
    @test copy(lnil) == lnil

    @test map((x) -> x*2, lnil) == lnil
  end

  @testset "singleton list" begin
    sl = nil()
    sl = cons(1, sl)

    @test length(sl) == 1
    @test car(sl) == 1
    @test cdr(sl) == nil()

    @test sl == cons(1, nil())
    @test sl == list(1)
    @test sprint(show, sl) == "list(1)"
    @test cat(sl) == sl
  end

  @testset "l4" begin
    l1 = nil()
    l2 = cons(1, l1)
    l3 = list(2, 3, 4)
    l4 = cat(l1, l2, l3)

    @test length(l4) == 4
    @test l4 == list(1, 2, 3, 4)

    @test collect(l4) == [1; 2; 3; 4]
    @test collect(copy(l4)) == [1; 2; 3; 4]
    @test collect(reverse(l4)) == [4; 3; 2; 1]

    @test sprint(show,l4) == "list(1, 2, 3, 4)"
  end

  @testset "filter list" begin
    l = filter((x) -> x % 2 == 0,
               list(2, 1, 4, 3, 6, 5))

    @test length(l) == 3
    @test l.car == 2
    @test l.cdr.car == 4
    @test l.cdr.cdr.car == 6
    @test collect(l) == [2, 4, 6]
  end

  @testset "cat lists" begin
    l = cat(list(1, 2),
            list(3.0, 4.0),
            list('a', 'b', 'c'))

    @test collect(l) == [1; 2; 3.0; 4.0; 'a'; 'b'; 'c']

    l = cat(list(1, 2),
            list(3.0, 4.0))
    @test isa(l, Cons{Real})  ## "super" type
    @test collect(l) == [1; 2; 3.0; 4.0]
  end

  @testset "test identity map" begin
    ex = :(a+b+2 * 2 + foo(2))
    l = list(ex.args...)

    @test collect(map(x -> x, l)) == collect(l)
  end

  @testset "test delete" begin
    lst = list(collect(1:2:25)...)
    @test length(lst) == 13  # [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25]

    for elt ∈ filter(x -> x ≥ 15, lst)
      lst = delete(lst, elt)
    end
    @test length(lst) == 7
  end

end
