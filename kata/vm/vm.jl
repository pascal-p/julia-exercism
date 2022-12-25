using Base: show

const SEP = '.'
const V_REXP = r"\A\d+(?:\.\d+){0,}\Z"
const N = 20 # 20 last version for rollback
import Base: show

mutable struct VM
  major::Int
  minor::Int
  patch::Int

  history::Vector{Tuple{Int, Int, Int}} # (a bounded one - like last 20) for rollback

  function VM(init::Union{String, Nothing} = nothing)
    history =  Vector{Tuple{Int, Int, Int}}()

    if init === nothing
      new(0, 0, 1, history)
    else
      @assert occursin(V_REXP, init)
      n = split(init, SEP) |> length
      (smajor, sminor, spatch) = if n == 1
        (split(init, SEP)..., "0", "0")
      elseif n == 2
        (split(init, SEP)..., "0")
      else
        split(init, SEP)
      end
      (major, minor, patch) = (smajor, sminor, spatch) |> t -> parse.(Int, t)
      (major, minor, patch, history) |> t -> new(t...)
    end
  end
end

VM(::Any) = throw(ArgumentError("Expecting a string with format a.b.c, whare a,b,c are positive integers"))

Base.show(io::IO, vm::VM) = print(io, string(vm.major, SEP, vm.minor, SEP, vm.patch))

function major!(vm::VM)
  update_history!(vm)
  vm.major += 1
  vm.minor = vm.patch = 0
  vm
end

function minor!(vm::VM)
  update_history!(vm)
  vm.minor += 1
  vm.patch = 0
  vm
end

function patch!(vm::VM)
  update_history!(vm)
  vm.patch += 1
  vm
end

release(vm::VM) = string(vm.major, SEP, vm.minor, SEP, vm.patch)

function rollback(vm::VM)
  length(vm.history) == 0 && throw(ArgumentError("Cannot rollback"))
  (vm.major, vm.minor, vm.patch) = vm.history[end]
  vm.history =  vm.history[1:end-1]
  vm
end

#
# Internals
#

function update_history!(vm::VM)
  length(vm.history) > N && (vm.history = vm.history[2:end])
  push!(vm.history, (vm.major, vm.minor, vm.patch))
end
