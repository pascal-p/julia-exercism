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

function cons_user(name::String;
                   owes::DSA = DSA(), owed_by::DSA = DSA(), bal::Model.Money = 0.0)
  DSA(
    :user => DSA(:owed_by => owed_by, :name => name, :owes => owes),
    :balance => bal
  )
end


@testset "no users" begin
  api, TU = prep_test([])
  resp = get(api, Path("/users"))
  exp  = Dict{Symbol, Vector{TU}}(:users => TU[])

  @test resp.status == 200
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Vector{TU}}) == exp
end

@testset "get all users" begin
  api, _ = prep_test([Model.NT("PasMas"), Model.NT("Corto"), Model.NT("Ayu")])
  resp = get(api, Path("/users"))
  exp = DSA(:users => Any[
    cons_user("PasMas"), cons_user("Corto"), cons_user("Ayu")
  ])
  act = JSON.parse(resp.body; dicttype=DSA)

  @test resp.status == 200
  @test act == exp
end

@testset "get one user" begin
  api, _ = prep_test([Model.NT("PasMas"), Model.NT("Corto"), Model.NT("Ayu")])
  payload = JSON.json(Dict{Symbol, String}(:user => "Ayu"))
  resp = get(api, Path("/users"); payload)
  exp = cons_user("Ayu")
  act = JSON.parse(resp.body; dicttype=DSA)

  @test resp.status == 200
  @test act == exp
end

@testset "add user" begin
  api, _ = prep_test([])
  payload = JSON.json(Dict{Symbol, String}(:user => "Adam"))
  exp = cons_user("Adam")
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
    cons_user("Adam"; owed_by = DSA(:Bob => 5.5), bal = 5.5),
    cons_user("Bob"; owes = DSA(:Adam => 5.5), bal = -5.5),
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
    cons_user("Adam"; owed_by = DSA(:Bob => 3.0), bal = 3.0),
    cons_user("Bob"; owes = DSA(:Adam => 3.0, :Chuck => 3.0), bal = -6.),
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
    cons_user("Adam"; owes = DSA(:Bob => 1.0), bal = -1.0),
    cons_user("Bob"; owed_by = DSA(:Adam => 1.0), bal = 1.),
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
    cons_user("Adam"; owed_by = DSA(:Bob => 1.0), bal = 1.0),
    cons_user("Bob"; owes = DSA(:Adam => 1.0), bal = -1.0),
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
    cons_user("Adam"  ),
    cons_user("Bob"),
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
    cons_user("Adam"; owes = DSA(:Bob => 3.0), bal = -3.0),
    cons_user("Bob"; owed_by = DSA(:Adam => 3.0), owes = DSA(:Chuck => 3.0), bal = 0.0),
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=DSA) == exp
end

@testset "NotFound" begin
  api, _TU = prep_test([])
  resp = post(api, Path("/foo"), "...")

  @test resp.status == 404 # NotFound
  @test JSON.parse(resp.body; dicttype=DSA) == Dict(:error => "Not Found")
end

@testset "post with no payload - problem" begin
  api, _TU = prep_test([])

  @test_throws  AssertionError post(api, Path("/iou"), "")
end
