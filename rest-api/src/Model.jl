module Model

import Base: ==   ## import Base: ==, show

const Str = String
const Money = Float64
const DSF = Dict{Str, Money}

##
## User
##

mutable struct User
  name::String
  owes::DSF
  owed_by::DSF
  balance::Money

  function User(name::String; owes::DSF=DSF(), owed_by::DSF=DSF())
    @assert calc_sum(owes) ≥ zero(Money)
    @assert calc_sum(owed_by) ≥ zero(Money)

    new(name, owes, owed_by, calc_balance(owes, owed_by))
  end

  function User(user::Dict{String,Any})
    new(user.name,
        DSF( k => v for (k, v) ∈ user["owes"]),
        DSF( k => v for (k, v) ∈ user["owed_by"]),
        Money(user.balance))
  end
end

function update!(u::User, lname::String, amt::Money; key=:lender)
  if key == :lender
    u.owed_by[lname] = get(u.owed_by, lname, zero(Money)) + amt
    u.balance = calc_balance(u.owes, u.owed_by) # += amt
    return

  elseif key == :borrower
    u.owes[lname] = get(u.owes, lname, zero(Money)) + amt
    u.balance = calc_balance(u.owes, u.owed_by) # -= amt
    return

  end

  throw(ArgumentError("lender xor borrower"))
end

function ==(u₁::User, u₂::User)::Bool
  ## relying on cmp of dict.
  u₁.name == u₂.name &&
    u₁.owes == u₂.owes &&
    u₁.owed_by == u₂.owed_by &&
    u₁.balance ≈ u₂.balance
end


##
## Users ≡ collection of User
##

struct Users
  coll::Dict{Symbol, Vector{User}}

  function Users()
    new(Dict{Symbol, Vector{User}}(:users => User[]))
  end

  function Users(users::Vector{User})
    new(Dict{Symbol, Vector{User}}(:users => users))
  end
end

coll(users::Users) = users.coll[:users]

function add_to_users!(users::Users, user::User)
  push!(users.coll[:users], user)
end

## The user collection
const YA_users = Ref{Users}(Users())


##
## Other public API functions
##

function create_user(name::String; owes::DSF=DSF(), owed_by::DSF=DSF())::User
  user = User(name; owes, owed_by)
  push!(YA_users[].coll[:users], user)
  user
end

function create_iou(borrower::User, lender::User, amt::Money)
  ## no limit for lender and no limit for borrower
  ## assume it is always possible
  @assert borrower.name != lender.name

  update!(borrower, lender.name, amt; key=:borrower)
  update!(lender, borrower.name, amt)
end


##
## Internal
##

function calc_sum(iou::DSF)::Money
  values(iou) |> sum
end

function calc_balance(owes::DSF, owed_by::DSF)::Money
  calc_sum(owed_by) - calc_sum(owes)
end

function stringify(user::User; attr=:owes)
  coll = join(["$(uname): $(uamt)" for (uname, uamt) ∈ getfield(user, attr)],
              ", ")
  if length(coll) > 0
    coll = string("{ ", coll, " }")
  end

  return coll
end

end  ## module
