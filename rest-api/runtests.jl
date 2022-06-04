using Test
import JSON

push!(LOAD_PATH, "./src")
using RESTAPI

const DSA = Dict{Symbol, Any}


function prep_test(ary)
  Model.YA_users[] = Model.Users()
  MU = Model.User
  yadb = Dict{Symbol, Vector{MU}}(
    :users => length(ary) == 0 ? MU[] : [MU(nt) for nt ∈ ary]
  )
  RestAPI(yadb), MU
end


@testset "no users" begin
  api, TU = prep_test([])
  resp = get(api, "/users")
  exp  = Dict{Symbol, Vector{TU}}(:users => TU[])

  @test resp.status == 200
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Vector{TU}}) == exp
end

@testset "get all users" begin
  api, _ = prep_test([Model.NT("PasMas"), Model.NT("Corto"), Model.NT("Ayu")])
  resp = get(api, "/users")

  exp = DSA(:users => Any[
    DSA(:user => DSA(:owed_by => DSA(), :name => "PasMas", :owes => DSA()), :balance => 0.0),
    DSA(:user => DSA(:owed_by => DSA(), :name => "Corto", :owes => DSA()), :balance => 0.0),
    DSA(:user => DSA(:owed_by => DSA(), :name => "Ayu", :owes => DSA()), :balance => 0.0)
  ])
  act = JSON.parse(resp.body; dicttype=DSA)

  @test resp.status == 200
  @test act == exp
end

@testset "get one user" begin
  api, _ = prep_test([Model.NT("PasMas"), Model.NT("Corto"), Model.NT("Ayu")])
  payload = JSON.json(Dict{Symbol, String}(:user => "Ayu"))

  resp = get(api, "/users"; payload)
  exp = DSA(
    :user => DSA(
      :name => "Ayu",
      :owes => DSA(),
      :owed_by => DSA()
    ),
    :balance => 0.0
  )
  act = JSON.parse(resp.body; dicttype=DSA)

  @test resp.status == 200
  @test act == exp
end

@testset "add user" begin
  api, _ = prep_test([])
  payload = JSON.json(Dict{Symbol, String}(:user => "Adam"))
  exp = DSA(
    :user => DSA(:name => "Adam", :owes => DSA(), :owed_by => DSA()),
    :balance => 0.0
  )
  resp = post(api, Path("/add"), payload)
  act = JSON.parse(resp.body; dicttype=DSA)

  @test resp.status == 201 # created
  @test act == exp
end

@testset "single iou" begin
  api, _ = prep_test([Model.NT("Adam"), Model.NT("Bob")])
  payload = JSON.json(DSA(:lender => "Adam", :borrower => "Bob", :amount => 5.5))
  resp = post(api, Path("/iou"), payload)

  exp  = DSA(:users => Any[
    DSA(:user => DSA(:owed_by => DSA(:Bob => 5.5), :name => "Adam", :owes => DSA()),
        :balance => 5.5),
    DSA(:user => DSA(:owed_by => DSA(), :name => "Bob", :owes => DSA(:Adam => 5.5)),
        :balance => -5.5),
  ])
  act = JSON.parse(resp.body; dicttype=DSA)

  @test resp.status == 201 # created
  @test act == exp
end

@testset "borrower has a negative balance" begin
  api, _ = prep_test([
    Model.NT("Adam"),
    Model.NT("Bob", owes=Dict("Chuck" => 3.0)),
    Model.NT("Chuck", owed_by=Dict("Bob" => 3.0))
  ])
  payload = JSON.json(DSA(:lender => "Adam", :borrower => "Bob", :amount => 3.0))
  resp = post(api, Path("/iou"), payload)
  exp  = DSA(:users => Any[
    DSA(:user => DSA(:owed_by => DSA(:Bob => 3.0), :name => "Adam", :owes => DSA()),
        :balance => 3.0)
    DSA(:user => DSA(:owed_by => DSA(),:name => "Bob", :owes => DSA(:Adam => 3.0, :Chuck => 3.0)),
        :balance => -6.0)
  ])
  act = JSON.parse(resp.body; dicttype=DSA)

  @test resp.status == 201 # created
  @test act == exp
end

@testset "lender owes borrower" begin
  api, _ = prep_test([
    Model.NT("Adam", owes=Dict("Bob" => 3.0)),
    Model.NT("Bob", owed_by=Dict("Adam" => 3.0))
  ])
  payload = JSON.json(DSA(:lender => "Adam", :borrower => "Bob", :amount => 2.0))
  resp = post(api, Path("/iou"), payload)
  exp  = DSA(:users => Any[
    DSA(:user => DSA(:owed_by => DSA(),:name => "Adam", :owes => DSA(:Bob => 1.0)),
        :balance => -1.0),
    DSA(:user =>  DSA(:owed_by => DSA(:Adam => 1.0),:name => "Bob",:owes => DSA()),
        :balance => 1.0)
  ])
  act = JSON.parse(resp.body; dicttype=DSA)

  @test resp.status == 201 # created
  @test act == exp
end

##
## More test cases
##
@testset "lender owes borrower less than new loan" begin
  api, _ = prep_test([
    Model.NT("Adam", owes=Dict("Bob" => 3.0)),
    Model.NT("Bob", owed_by=Dict("Adam" => 3.0))
  ])
  payload = JSON.json(DSA(:lender => "Adam", :borrower => "Bob", :amount => 4.0))
  resp = post(api, Path("/iou"), payload)

  exp = DSA(:users => Any[
    DSA(:user => DSA(:owed_by => DSA(:Bob => 1.0), :name => "Adam", :owes => DSA()),
        :balance => 1.0),
    DSA(:user => DSA(:owed_by => DSA(),:name => "Bob", :owes => DSA(:Adam => 1.0)),
        :balance => -1.0)
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=DSA) == exp
end

@testset "lender owes borrower same as new loan" begin
  api, _ = prep_test([
    Model.NT("Adam", owes=Dict("Bob" => 3.0)),
    Model.NT("Bob", owed_by=Dict("Adam" => 3.0))
  ])
  payload = JSON.json(DSA(:lender => "Adam", :borrower => "Bob", :amount => 3.0))
  resp = post(api, Path("/iou"), payload)
  exp = DSA(:users => Any[
    DSA(:user => DSA(:owed_by => DSA(),:name => "Adam", :owes => DSA()),
        :balance => 0.0),
    DSA(:user => DSA(:owed_by => DSA(),:name => "Bob", :owes => DSA()),
        :balance => 0.0)
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=DSA) == exp
end

@testset "lender has negative balance" begin
  api, _TU = prep_test([
    Model.NT("Adam"),
    Model.NT("Bob", owes=Dict("Chuck" => 3.0)),
    Model.NT("Chuck", owed_by=Dict("Bob" => 3.0))
  ])
  payload = JSON.json(DSA(:lender => "Bob", :borrower => "Adam", :amount => 3.0))
  resp = post(api, Path("/iou"), payload)
  exp = DSA(:users => Any[
    DSA(:user => DSA(:owed_by => DSA(),:name => "Adam",:owes => DSA(:Bob => 3.0)),
        :balance => -3.0),
    DSA(:user => DSA(:owed_by => DSA(:Adam => 3.0),:name => "Bob", :owes => DSA(:Chuck => 3.0)),
        :balance => 0.0)
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=DSA) == exp
end

@testset "NotFound" begin
  api, _TU = prep_test([])
  resp = post(api, Path("/foo"), "")

  @test resp.status == 404 # NotFound
  @test JSON.parse(resp.body; dicttype=DSA) == Dict(:error => "Not Found")
end
