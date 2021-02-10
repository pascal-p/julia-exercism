using Test
import JSON

# include("./rest_api.jl")
push!(LOAD_PATH, "./src")

using RESTAPI

@testset "no users" begin
  TU = Model.User
  yadb = Dict{Symbol, Vector{TU}}(:users => TU[])
  api = RestAPI(yadb)

  resp = get(api, "/users")
  exp  = Dict{Symbol, Vector{TU}}(:users => TU[])

  @test resp.status == 200
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Vector{TU}}) == exp
end

@testset "get all users" begin
  TU = Model.User
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
  TU = Model.User
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
  TU = Model.User
  yadb = Dict{Symbol, Vector{TU}}(:users => TU[])
  api = RestAPI(yadb)
  payload = JSON.json(Dict{Symbol, String}(:user => "Adam"))

  exp = Dict{Symbol,Any}(:name => "Adam",:balance => 0.0,:owes => Dict{Symbol,Any}(),:owed_by => Dict{Symbol,Any}())
  resp = post(api, "/add", payload)

  @test resp.status == 201 # created
  @test JSON.parse(resp.body; dicttype=Dict{Symbol, Any}) == exp
end

@testset "" begin
end

@testset "" begin
end

@testset "" begin
end

@testset "" begin
end

@testset "" begin
end

@testset "" begin
end
