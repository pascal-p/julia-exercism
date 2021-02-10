import JSON
import Base: show

using .Model

##
## Response
##

struct Response
  status::Int
  body::String

  function Response(dt::Dict{Symbol, Vector{Model.User}}; code=200)
    ## dt == collection of users
    new(code, JSON.json(dt))
  end

  function Response(dt::Model.User; code=200)
    new(code, JSON.json(dt))
  end
end

function show(io::IO, resp::Response)
  status, body = (resp.status, resp.body)
  show(io, (;status, body))
end

##
## API
##

struct RestAPI
  db::Ref{Model.Users}

  RestAPI(;db=Model.YA_users) = new(db)

  function RestAPI(hdb::Dict{String, Vector{Model.User}})
    add_to_users!(hdb, "users")
    new(Model.YA_users)
  end

  function RestAPI(hdb::Dict{Symbol, Vector{Model.User}})
    add_to_users!(hdb, :users)
    new(Model.YA_users)
  end
end

db(api::RestAPI) = Model.coll(api.db[])

##
## fetch methods (User model)
##

fetch_all(api::RestAPI) = api.db[] # db(api)

function fetch_many(api::RestAPI;
                    exclude::Vector{Model.User}=Model.User[])
  filter(u -> u ∉ exclude, db(api))
end

"""
Assuming name is unique
"""
function fetch_one(api::RestAPI;
                   by_name::String="foo")
  res = filter(u -> u.name == by_name, db(api))
  return res == nothing || length(res) == 0 ? nothing : res[1]
end

## find (User model)
function find_by(api::RestAPI; by_name::String="foo")
  res = filter(u -> u.name == by_name, db(api))
  length(res) == 0 ? nothing : res[1]
end


##
## Public API
##

function get(api, endpoint::String; payload::String="")::Response
  ## payload is JSON format
  @assert endpoint == "/users"

  local users
  if length(payload) > 0
    ## 1 - parse payload / validate
    hsh = convert_user_payload(payload) |>
      validate_user

    ## 2 - select user as specified by payload
    user = fetch_one(api; by_name=hsh[:user])

    ## 3 - json-ify and return response
    return Response(user)

  end

  ## No payload
  ## 1 - query the DB - select all users
  users = fetch_all(api)

  ## 2 - json-ify and return response
  Response(users.coll)
end

function post(api, endpoint::String, payload::String)::Response
  ## payload is JSON format
  @assert length(payload) > 0

  if endpoint == "/add"
    hsh = convert_user_payload(payload) |>
      validate_user

    ## User Model create
    user = Model.create_user(hsh[:user])

    ## Assuming creation OK. - return newly created user
    return Response(user; code=201)

  elseif endpoint == "/iou"
    hsh = convert_iou_payload(payload) |>
      validate_iou

    users = Vector{Model.User}(undef, 2)
    for (ix, key) in enumerate([:lender, :borrower])
      u = find_by(api, by_name=hsh[key])
      @assert u != nothing
      users[ix] = u
    end

    ## update User Model
    Model.update!(;borrower=users[2], lender=users[1], amt=Model.Money(hsh[:amount]))

    husers = Dict{Symbol, Vector{Model.User}}(
      :users => sort(users, by=u -> u.name, rev=false)
    )
    return Response(husers; code=201)
  end

  throw(ArgumentError("Unknown route..."))
end


##
## Internals
##

function add_to_users!(hdb::Dict{Symbol, Vector{Model.User}}, key::Union{String, Symbol})
  for user ∈ hdb[key]
    push!(Model.YA_users[].coll[:users], user)
  end
end

function convert_user_payload(json_payload::String)::Dict{Symbol, String}
  JSON.parse(json_payload; dicttype=Dict{Symbol, String})
end

function convert_iou_payload(json_payload::String)::Dict{Symbol, Any}
  JSON.parse(json_payload; dicttype=Dict{Symbol, Any})
end

function validate_user(hsh::Dict{Symbol, String})::Dict{Symbol, String}
  @assert haskey(hsh, :user) && !isempty(hsh[:user])
  hsh
end

function validate_iou(hsh::Dict{Symbol, Any})::Dict{Symbol, Any}
  for key  ∈ [:lender, :borrower]
    @assert haskey(hsh, key) && !isempty(hsh[key])
  end

  @assert hsh[:lender] != hsh[:borrower]
  @assert haskey(hsh, :amount) && hsh[:amount] > zero(Model.Money)

  hsh
end
