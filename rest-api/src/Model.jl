module Model

using Parameters
import Base: ==

const Str = String
const Money = Float64
const DSF = Dict{Str, Money}

@with_kw mutable struct NT
  name::String = ""
  owes::DSF = DSF()
  owed_by::DSF = DSF()

  function NT(name::String; owes::DSF=DSF(), owed_by::DSF=DSF())
    @assert calc_sum(owes) ≥ zero(Money) && calc_sum(owed_by) ≥ zero(Money)
    if length(owes) > 0 && length(owed_by) > 0
      new(name, owes, owed_by)
    elseif length(owes) > 0
      new(name, owes, DSF())
    else
      new(name, DSF(), owed_by)
    end
  end
end

##
## User
##

mutable struct User
  user::NT
  balance::Money

  User(user::NT) = new(user, calc_balance(user.owes, user.owed_by))

  function User(name::String)
    user = NT(name)
    balance = Money(0.0)
    new(user, balance)
  end

  function User(duser::Dict{String, Any})
    user = NT(
      duser.name,
      DSF(k => v for (k, v) ∈ duser["owes"]),
      DSF(k => v for (k, v) ∈ duser["owed_by"])
    )
    new(user, Money(0.0))
  end
end

name(u::User) = u.user.name
owes(u::User) = u.user.owes
owed_by(u::User) = u.user.owed_by

"""
  update!(borrower, lender, amount)
"""
function update!(; borrower::User, lender::User, amt::Money)
  _update!(borrower, name(lender), amt, :owed_by) |>
    attr_changed -> _post_update!(borrower, name(lender), attr_changed)

  _update!(lender, name(borrower), amt, :owes) |>
    attr_changed -> _post_update!(lender, name(borrower), attr_changed)
end

function ==(u₁::User, u₂::User)::Bool
  ## relying on cmp of dict.
  name(u₁) == name(u₂) && owes(u₁) == owes(u₂) &&
    owed_by(u₁) == owed_by(u₂) && u₁.balance ≈ u₂.balance
end


##
## Users ≡ collection of User
##

struct Users
  coll::Dict{Symbol, Vector{User}}

  Users() = new(Dict{Symbol, Vector{User}}(:users => User[]))
  Users(users::Vector{User}) = new(Dict{Symbol, Vector{User}}(:users => users))
end

coll(users::Users) = users.coll[:users]

add_to_users!(users::Users, user::User) = push!(users.coll[:users], user)


## The user collection
const YA_users = Ref{Users}(Users())


##
## Other public API functions
##

function create_user(name::String; owes::DSF=DSF(), owed_by::DSF=DSF())::User
  nt_user = NT(name; owes, owed_by)
  user = User(nt_user)# User(name; owes, owed_by)
  push!(YA_users[].coll[:users], user)
  user
end

function create_iou(borrower::User, lender::User, amt::Money)
  ## no limit for lender and no limit for borrower
  ## assume it is always possible
  @assert borrower.user.name != lender.user.name

  update!(borrower, lender.user.name, amt, key=:borrower)
  update!(lender, borrower.user.name, amt)
end


##
## Internal
##

function calc_sum(iou::DSF)::Money
  Money(values(iou) |> sum)
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

function _update!(tuser::User, name::String, amt::Money, attr::Symbol)::Symbol
  val = get(getfield(tuser.user, attr), name, zero(Money))

  changed = if val > zero(Money)
    hsh = getfield(tuser.user, attr)
    hsh[name] = val - amt
    setfield!(tuser.user, attr, hsh)
    attr
  else
    o_attr = (attr == :owed_by) ? :owes : :owed_by
    hsh = getfield(tuser.user, o_attr)
    val = get(hsh, name, zero(Money))
    hsh[name] = val + amt
    setfield!(tuser.user, o_attr, hsh)
    o_attr
  end

  tuser.balance = calc_balance(tuser |> owes, tuser |> owed_by)
  changed
end

"""
  if field :owed_by becomes < 0. => it becomes a > 0 :owes field (and conversely)
  if field :owed_by becomes ≈ 0. => remove it from dictionary (same for :owes)
"""
function _post_update!(tuser::User, name::String, attr::Symbol)
  hsh₁ = getfield(tuser.user, attr) # ex. :owed_by

  if length(hsh₁) > 0 && haskey(hsh₁, name)
    if hsh₁[name] < zero(Money)
      o_attr = attr == :owed_by ? :owes : :owed_by
      hsh₂ = getfield(tuser.user, o_attr)
      hsh₂[name] = -hsh₁[name]
      delete!(hsh₁, name)
      setfield!(tuser.user, attr, hsh₁) ## update attr as key name was removed from it
      setfield!(tuser.user, o_attr, hsh₂)
    elseif hsh₁[name] ≈ zero(Money)
      delete!(hsh₁, name)
      setfield!(tuser.user, attr, hsh₁)
    end
  end
end

end  ## module
