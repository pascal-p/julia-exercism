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

"""
  update!(borrower, lender, amount)
"""
function update!(; borrower::User, lender::User, amt::Money)
  b_owed_by = get(borrower.owed_by, lender.name, zero(Money))
  if b_owed_by > zero(Money)
    borrower.owed_by[lender.name] = b_owed_by - amt
  else
    borrower.owes[lender.name] = get(borrower.owes, lender.name, zero(Money)) + amt
  end
  borrower.balance = calc_balance(borrower.owes, borrower.owed_by)
  #
  #
  l_owes = get(lender.owes, borrower.name, zero(Money))
  if l_owes > zero(Money)
    lender.owes[borrower.name] = l_owes - amt
  else
    lender.owed_by[borrower.name] = get(lender.owed_by, borrower.name, zero(Money)) + amt
  end
  lender.balance = calc_balance(lender.owes, lender.owed_by)
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

# function find_user(users::Users; name::String="bar")::Union{Nothing, User}
#   res = filter(u -> u.name == name, users.coll[:users])
#   length(res) == ? nothing : res[1]
# end

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
