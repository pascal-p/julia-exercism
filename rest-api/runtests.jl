using Test
import JSON

# include("./rest_api.jl")
push!(LOAD_PATH, "./src")

using RESTAPI


function pre_test()
  Model.YA_users[] = Model.Users()

  Model.User
end


@testset "no users" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(:users => TU[])
  api = RestAPI(yadb)

  resp = get(api, "/users")
  exp  = Dict{Symbol, Vector{TU}}(:users => TU[])

  @test resp.status == 200
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Vector{TU}}) == exp
end

@testset "get all users" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(
    :users => [TU("PasMas"), TU("Corto"), TU("Ayu")]
  )
  api = RestAPI(yadb)

  resp = get(api, "/users")
  exp  = Dict{Symbol, Any}(:users => Any[
    Dict{Symbol,Any}(:name => "PasMas",:balance => 0.0,:owes => Dict{Symbol,Any}(),:owed_by => Dict{Symbol,Any}()),
    Dict{Symbol,Any}(:name => "Corto",:balance => 0.0,:owes => Dict{Symbol,Any}(),:owed_by => Dict{Symbol,Any}()),
    Dict{Symbol,Any}(:name => "Ayu",:balance => 0.0,:owes => Dict{Symbol,Any}(),:owed_by => Dict{Symbol,Any}())
  ])

  @test resp.status == 200
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end

@testset "get one user" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(
    :users => [TU("PasMas"), TU("Corto"), TU("Ayu")]
  )
  api = RestAPI(yadb)
  payload = JSON.json(Dict{Symbol, String}(:user => "Ayu"))

  resp = get(api, "/users"; payload)
  exp = Dict{Symbol,Any}(:name => "Ayu",:balance => 0.0,:owes => Dict{Symbol,Any}(),:owed_by => Dict{Symbol,Any}())

  @test resp.status == 200
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end

@testset "add user" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(:users => TU[])
  api = RestAPI(yadb)
  payload = JSON.json(Dict{Symbol, String}(:user => "Adam"))

  exp = Dict{Symbol,Any}(:name => "Adam",:balance => 0.0,:owes => Dict{Symbol,Any}(),:owed_by => Dict{Symbol,Any}())
  resp = post(api, "/add", payload)

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end

@testset "single iou" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(:users => [TU("Adam"), TU("Bob")])
  api = RestAPI(yadb)

  payload = JSON.json(Dict{Symbol, Any}(:lender => "Adam", :borrower => "Bob", :amount => 5.5))
  resp = post(api, "/iou", payload)
  # NOTE: order of fieldname is fragile... Would need a more robust comparison
  exp  = Dict{Symbol, Any}(:users => Any[
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(:Bob => 5.5),:name => "Adam",:balance => 5.5,:owes => Dict{Symbol,Any}()),
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(),:name => "Bob",:balance => -5.5,:owes => Dict{Symbol,Any}(:Adam => 5.5))
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end

@testset "borrower has a negative balance" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(:users => [TU("Adam"),
                                             TU("Bob"; owes=Dict("Chuck" => 3.0)),
                                             TU("Chuck"; owed_by=Dict("Bob" => 3.0))])
  api = RestAPI(yadb)

  payload = JSON.json(Dict{Symbol, Any}(:lender => "Adam", :borrower => "Bob", :amount => 3.0))
  resp = post(api, "/iou", payload)

  # NOTE: order of fieldname is fragile... Would need a more robust comparison
  exp  = Dict{Symbol, Any}(:users => Any[
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(:Bob => 3.0),:name => "Adam",:balance => 3.0,:owes => Dict{Symbol,Any}()),
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(),:name => "Bob",:balance => -6.0,:owes => Dict{Symbol,Any}(:Adam => 3.0, :Chuck => 3.0))
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end

@testset "lender owes borrower" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(:users => [TU("Adam"; owes=Dict("Bob" => 3.0)),
                                             TU("Bob"; owed_by=Dict("Adam" => 3.0))])
  api = RestAPI(yadb)

  payload = JSON.json(Dict{Symbol, Any}(:lender => "Adam", :borrower => "Bob", :amount => 2.0))
  resp = post(api, "/iou", payload)
  # NOTE: order of fieldname is fragile... Would need a more robust comparison
  exp  = Dict{Symbol, Any}(:users => Any[
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(),:name => "Adam",:balance => -1.0,:owes => Dict{Symbol,Any}(:Bob => 1.0)),
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(:Adam => 1.0),:name => "Bob",:balance => 1.0,:owes => Dict{Symbol,Any}())
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end

##
## More test cases
##
@testset "lender owes borrower less than new loan" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(:users => [TU("Adam"; owes=Dict("Bob" => 3.0)),
                                             TU("Bob"; owed_by=Dict("Adam" => 3.0))])
  api = RestAPI(yadb)
  payload = JSON.json(Dict{Symbol, Any}(:lender => "Adam", :borrower => "Bob", :amount => 4.0))
  resp = post(api, "/iou", payload)

  exp  = Dict{Symbol, Any}(:users => Any[
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(:Bob => 1.0),:name => "Adam",:balance => 1.0,:owes => Dict{Symbol,Any}()),
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(),:name => "Bob",:balance => -1.0,:owes => Dict{Symbol,Any}(:Adam => 1.0))
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end

@testset "lender owes borrower same as new loan" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(:users => [TU("Adam"; owes=Dict("Bob" => 3.0)),
                                             TU("Bob"; owed_by=Dict("Adam" => 3.0))])
  api = RestAPI(yadb)
  payload = JSON.json(Dict{Symbol, Any}(:lender => "Adam", :borrower => "Bob", :amount => 3.0))
  resp = post(api, "/iou", payload)

  exp  = Dict{Symbol, Any}(:users => Any[
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(),:name => "Adam",:balance => 0.0,:owes => Dict{Symbol,Any}()),
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(),:name => "Bob",:balance => 0.0,:owes => Dict{Symbol,Any}())
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end

@testset "lender has negative balance" begin
  TU = pre_test()
  yadb = Dict{Symbol, Vector{TU}}(:users => [TU("Adam"),
                                             TU("Chuck"; owed_by=Dict("Bob" => 3.0)),
                                             TU("Bob"; owes=Dict("Chuck" => 3.0))])
  api = RestAPI(yadb)
  payload = JSON.json(Dict{Symbol, Any}(:lender => "Bob", :borrower => "Adam", :amount => 3.0))
  resp = post(api, "/iou", payload)

  exp  = Dict{Symbol, Any}(:users => Any[
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(),:name => "Adam",:balance => -3.0,:owes => Dict{Symbol,Any}(:Bob => 3.0)),
    Dict{Symbol,Any}(:owed_by => Dict{Symbol,Any}(:Adam => 3.0),:name => "Bob",:balance => 0.0,:owes => Dict{Symbol,Any}(:Chuck => 3.0))
  ])

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end
