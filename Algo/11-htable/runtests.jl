using Test
using Random

# include("./src/htable.jl")
push!(LOAD_PATH, "./src")
using YAHT

@testset "HTable Basics" begin
  TInt = Tuple{Int, Int}
  ht = HTable{Int, TInt}(5)

  @test ht.size == 0
  @test isempty(ht)

  ## add
  sz = 0
  for (k, v) in [(10, 100), (90, 909), (55, 5557), (12, 200), (17,222) ]
    add!(ht, k, v)
    sz += 1
    @test ht.size == sz
    @test get(ht, k) == v
  end

  ## add element already present
  k, v = 12, 200
  add!(ht, k, v)
  @test ht.size == sz
  @test get(ht, k) == v

  ## remove existing element
  k = 55
  sz -= 1
  remove!(ht, k)
  @test ht.size == sz
  @test get(ht, k) == nothing

  ## remove non-existing element
  k = 117
  remove!(ht, k)
  @test ht.size == sz
  @test get(ht, k) == nothing
end

@testset "HTable additions key only" begin
  ht = HTable{Int, Int}(2)

  sz = 0
  @test ht.size == sz
  @test isempty(ht)

  for k in [10, -100, 90, -909, 55, 5557, -12, 200, 12, 17, 222]
    add!(ht, k)
    sz += 1
    @test size(ht) == sz
    @test get(ht, k) == k
  end

  @test size(ht) == sz
end

@testset "HTable add/remove 1_000_000 keys" begin
  ht = HTable{Int, Int}(10)

  sz = 0
  @test ht.size == sz
  @test isempty(ht)

  for k in 1:1_000_000
    add!(ht, k)
    sz += 1
    @test size(ht) == sz
    @test get(ht, k) == k
  end

  @test size(ht) == sz

  for k in shuffle(collect(1:1_000_000))
    remove!(ht, k)
    @test get(ht, k) == nothing
  end

  @test isempty(ht)
  @test size(ht) == 0
end
