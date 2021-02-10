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
## fetch methods
##

fetch_all(api::RestAPI) = api.db[] # db(api)

function fetch_many(api::RestAPI;
                    exclude::Vector{Model.User}=Model.User[])
  filter(u -> u ∉ exclude, db(api)) ## api.db[]
end

"""
Assuming name is unique
"""
function fetch_one(api::RestAPI;
                   by_name::String="foo")
  res = filter(u -> u.name == by_name, db(api)) ## api.db[]
  return res == nothing || length(res) == 0 ? nothing : res[1]
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
    hsh = convert_payload(payload) |>
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
    hsh = convert_payload(payload) |>
      validate_user

    ## Model creation
    user = Model.create_user(hsh[:user])

    ## Assuming creation OK. - return newly created user
    return Response(user; code=201)

  elseif endpoint == "/iou"
    ##
    ## TODO ...
    ##

    return # response...
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

function convert_payload(json_payload::String)::Dict{Symbol, String}
  JSON.parse(json_payload; dicttype=Dict{Symbol, String})
end

function validate_user(hsh::Dict{Symbol, String})::Dict{Symbol, String}
  @assert haskey(hsh, :user) && !isempty(hsh[:user])
  hsh
end
