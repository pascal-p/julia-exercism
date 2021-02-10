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

function RestAPI(;db=Model.YA_users)
    # println("RestAPI/1")
    new(db)
  end

  function RestAPI(hdb::Dict{String, Vector{Model.User}})
    # println("RestAPI/2")
    for user ∈ hdb["users"]
      push!(Model.YA_users[].coll[:users], user)
    end
    new(Model.YA_users)
  end

  function RestAPI(hdb::Dict{Symbol, Vector{Model.User}})
    # println("RestAPI/3")
    for user ∈ hdb[:users]
      push!(Model.YA_users[].coll[:users], user)
    end
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
    ## 1 - parse payload
    hsh = JSON.parse(payload; dicttype=Dict{Symbol, String})

    ## 2 - Validation
    @assert haskey(hsh, :user) && !isempty(hsh[:user])

    ## 3 - query the DB - select user as specified by payload
    user = fetch_one(api; by_name=hsh[:user]) # users = fetch_many(api; exclude=hsh[:user])
    Response(user)

  else
    ## 1b - query the DB - select all users
    users = fetch_all(api)
    ## 4 - json-ify and return the response
    Response(users.coll)

  end
end

function post(api, endpoint::String, payload::String)::Response
  ## payload is JSON format
  @assert length(payload) > 0

  if endpoint == "/add"
    hsh = JSON.parse(payload; dicttype=Dict{Symbol, String})

    ## validation
    @assert haskey(hsh, :user) && !isempty(hsh[:user])

    ## Model creation
    user = Model.create_user(hsh[:user])

    ## assuming creation OK. - return newly created user
    Response(user; code=201)

  elseif endpoint == "/iou"
    ##
    ## TODO ...
    ##

  else
    throw(ArgumentError("Unknown route..."))
  end

end
