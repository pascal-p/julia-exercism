import JSON
import Base: show

using .Model

##
## Response
##

struct Response
  status::Int
  body::String

  function Response(dt::Dict{Symbol, Vector{Model.User}};
                    code=200)
    new(code, JSON.json(dt)) ## dt == collection of users
  end

  Response(dt::Model.User; code=200) = new(code, JSON.json(dt))

  Response(error::Dict; code=404) = new(code, JSON.json(error))
end

struct Path{x} end
Path(x) = Path{Symbol(x)}() # constructor

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

fetch_all(api::RestAPI) = api.db[]

function fetch_many(api::RestAPI;
                    exclude::Vector{Model.User}=Model.User[])
  filter(u -> u ∉ exclude, db(api))
end

"""
Assuming name is unique
"""
function fetch_one(api::RestAPI; by_name::String="foo")::Union{Model.User, Nothing}
  res = filter(u -> u.user.name == by_name, db(api))
  return res === nothing || length(res) == 0 ? nothing : res[1]
end

## find (User model)
function find_by(api::RestAPI; by_name::String="foo")::Union{Model.User, Nothing}
  res = filter(u -> u.user.name == by_name, db(api))
  length(res) == 0 ? nothing : res[1]
end


##
## Public API
##

function get(api::RestAPI, endpoint::String; payload::String="")::Response
  ## payload is JSON format
  @assert endpoint == "/users"

  local users
  if length(payload) > 0
    ## 1 - parse payload / validate
    hsh = convert_user_payload(payload) |> validate_user

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

function post(::RestAPI, ::Path{Symbol("/add")}, payload::String)::Response
  ## payload is JSON format
  @assert length(payload) > 0

  hsh = convert_user_payload(payload) |> validate_user

  ## User Model create
  user = Model.create_user(hsh[:user])

  ## Assuming creation OK. - return newly created user
  Response(user; code=201)
end

function post(api::RestAPI, ::Path{Symbol("/iou")}, payload::String)::Response
  ## payload is JSON format
  @assert length(payload) > 0

  hsh = convert_iou_payload(payload) |> validate_iou
  users = Vector{Model.User}(undef, 2)
  for (ix, key) ∈ enumerate([:lender, :borrower])
    u = find_by(api, by_name=hsh[key])
    @assert u !== nothing && typeof(u) == Model.User
    users[ix] = u
  end

  ## update User Model
  Model.update!(;borrower=users[2], lender=users[1], amt=Model.Money(hsh[:amount]))
  husers = Dict{Symbol, Vector{Model.User}}(
    :users => sort(users, by=u -> u.user.name, rev=false)
    )
  Response(husers; code=201)
end

post(::RestAPI, ::Path, ::String) = Response(Dict(:error => "Not Found"); code=404)


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
