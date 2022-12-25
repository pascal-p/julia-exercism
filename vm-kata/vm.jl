using Base: show

const SEP = '.'
const V_REXP = r"\A\d+(?:\.\d+){0,}\Z"
const N = 20 # 20 last version for rollback
import Base: show

mutable struct VM
  major::Int
  minor::Int
  patch::Int

  previous::Tuple{Int, Int, Int} # for rollback
  history::Vector{Tuple{Int, Int, Int}} # (a bounded one - like last 20) for rollback

  function VM(init::Union{String, Nothing} = nothing)
    history =  Vector{Tuple{Int, Int, Int}}()
    if init === nothing
      new(0, 0, 1, (0, 0, 0), history)
    else
      @assert occursin(V_REXP, init)

      n = split(init, SEP) |> length
      (smajor, sminor, spatch) = if n == 1
        (split(init, SEP)..., "0", "0")
      elseif n == 2
        (split(init, SEP)..., "0")
      else
        # (smajor, sminor, spatch, _r...) =
        split(init, SEP)
      end

      (major, minor, patch) = (smajor, sminor, spatch) |> t -> parse.(Int, t)
      (major, minor, patch,  calc_prev(major, minor, patch), history) |> t -> new(t...)
    end
  end
end

VM(::Any) = throw(ArgumentError("Expecting a string with format a.b.c, whare a,b,c are positive integers"))

Base.show(io::IO, vm::VM) = print(io, string(vm.major, SEP, vm.minor, SEP, vm.patch))

function major!(vm::VM)
  vm.previous = (vm.major, vm.minor, vm.patch)
  update_history!(vm)
  vm.major += 1
  vm.minor = vm.patch = 0
  vm
end

function minor!(vm::VM)
  vm.previous = (vm.major, vm.minor, vm.patch)
  update_history!(vm)
  vm.minor += 1
  vm.patch = 0
  vm
end

function patch!(vm::VM)
  vm.previous = (vm.major, vm.minor, vm.patch)
  update_history!(vm)
  vm.patch += 1
  vm
end

release(vm::VM) = string(vm.major, SEP, vm.minor, SEP, vm.patch)

#
# Another way to do the rollback is to keep all the versions and just return the previous
# version of the current one. (space consiming)
# Here I am assuming that if I am on
#  - 10.3.2 then there is a 10.3.1 (ok fine),
#  - 10.2.0, then there is 10.1.0 which may be incorrect as it could be 10.1.99 or 10.1.999
#
# OK, need to decide on a valid format and enforce it (but not all the possible values might be used
# as I can decide that after 10.3.2 I am going to use 10.4.0, which means we need to memorize up to
# a certain limit
#
function rollback_prev(vm::VM)
  (pmajor, pminor, ppatch) = vm.previous # get previous version

  # check
  (major, minor, patch) = vm.major, vm.minor, vm.patch
  major == pmajor && minor == pminor && patch == ppatch && throw(ArgumentError("Cannot rollback"))

  # OK, now calc prev. version
  (vm.major, vm.minor, vm.patch) = (pmajor, pminor, ppatch)
  vm.previous = calc_prev(pmajor, pminor, ppatch)

  # return
  vm
end

function rollback(vm::VM)
  length(vm.history) == 0 && throw(ArgumentError("Cannot rollback"))

  (vm.major, vm.minor, vm.patch) = vm.history[end]
  vm.history =  vm.history[1:end-1]
  vm
end
#
# Internals
#

calc_prev(vm::VM) = calc_prev(vm.major, vm.minor, vm.patch)

function calc_prev(major::Int, minor::Int, patch::Int)
  (pmajor, pminor, ppatch) = (major, minor, patch)
  ppatch = patch > 0 ? patch - 1 : patch

  if ppatch == patch
    # check previous minor
    pminor = minor > 0 ? minor - 1 : minor
  end

  if pminor == minor && ppatch == patch
    # check previous major
    pmajor = major > 0 ? major - 1 : major
  end

  (pmajor, pminor, ppatch)
end

function update_history!(vm::VM)
  if length(vm.history) > N
    vm.history = vm.history[2:end]
  end
  push!(vm.history, (vm.major, vm.minor, vm.patch))
end
