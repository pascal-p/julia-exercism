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
  # attr_changed =
  _update!(borrower, lender.name, amt, :owed_by) |>
    attr_changed -> _post_update!(borrower, lender.name, attr_changed)

  _update!(lender, borrower.name, amt, :owes) |>
    attr_changed -> _post_update!(lender, borrower.name, attr_changed)
end

# function update!(; borrower::User, lender::User, amt::Money)
#   ## borrower part
#   b_owed_by = get(borrower.owed_by, lender.name, zero(Money))
#   changed = if b_owed_by > zero(Money)
#     borrower.owed_by[lender.name] = b_owed_by - amt
#     :owed_by
#   else
#     borrower.owes[lender.name] = get(borrower.owes, lender.name, zero(Money)) + amt
#     :owes
#   end
#   borrower.balance = calc_balance(borrower.owes, borrower.owed_by)
#   _post_update!(borrower, lender.name, changed)
#   ##
#   ## lender part
#   l_owes = get(lender.owes, borrower.name, zero(Money))
#   changed = if l_owes > zero(Money)
#     lender.owes[borrower.name] = l_owes - amt
#     :owes
#   else
#     lender.owed_by[borrower.name] = get(lender.owed_by, borrower.name, zero(Money)) + amt
#     :owed_by
#   end
#   lender.balance = calc_balance(lender.owes, lender.owed_by)
#   _post_update!(lender, borrower.name, changed)
# end

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


function _update!(user::User, name::String, amt::Money, attr::Symbol)::Symbol
  val = get(getfield(user, attr), name, zero(Money))

  changed = if val > zero(Money)
    hsh = getfield(user, attr)
    hsh[name] = val - amt
    setfield!(user, attr, hsh)
    attr
  else
    o_attr = attr == :owed_by ? :owes : :owed_by
    hsh = getfield(user, o_attr)
    val = get(hsh, name, zero(Money))
    hsh[name] = val + amt
    setfield!(user, o_attr, hsh)
    o_attr
  end
  user.balance = calc_balance(user.owes, user.owed_by)
  changed
end

"""
  if field :owed_by becomes < 0. => it becomes a > 0 :owes filed (and conversely)
  if field :owed_by becomes ≈ 0. => remove it from dictionary (same for :owes)
"""
function _post_update!(user::User, name::String, attr::Symbol)
  hsh₁ = getfield(user, attr) # ex. :owed_by

  if length(hsh₁) > 0 && haskey(hsh₁, name)

    if hsh₁[name] < zero(Money)
      o_attr = attr == :owed_by ? :owes : :owed_by
      hsh₂ = getfield(user, o_attr)
      hsh₂[name] = -hsh₁[name]

      delete!(hsh₁, name)

      setfield!(user, attr, hsh₁) ## update attr as key name wasremove from it
      setfield!(user, o_attr, hsh₂)

    elseif hsh₁[name] ≈ zero(Money)
      delete!(hsh₁, name)
      setfield!(user, attr, hsh₁)
    end
  end
end

end  ## module
