using Base: show

const SEP = '.'
const V_REXP = r"\A\d+\.\d+\.\d+(?:\.\d+)*\Z"

import Base: show

mutable struct VM
  major::Int
  minor::Int
  patch::Int
  previous::Tuple{Int, Int, Int} # for rollback

  function VM(init::Union{String, Nothing} = nothing)
    if init === nothing
      new(0, 0, 1, (0, 0, 0))
    else
      @assert occursin(V_REXP, init)
      (smajor, sminor, spatch, _r...) = split(init, SEP)
      (major, minor, patch) = (smajor, sminor, spatch) |> t -> parse.(Int, t)
      (major, minor, patch,  calc_prev(major, minor, patch)) |> t -> new(t...)
    end
  end
end

VM(::Any) = throw(ArgumentError("Expecting a string with format a.b.c, whare a,b,c are positive integers"))

Base.show(io::IO, vm::VM) = print(io, string(vm.major, SEP, vm.minor, SEP, vm.patch))

function major!(vm::VM)
  vm.major += 1
  vm
end

function minor!(vm::VM)
  vm.minor += 1
  vm
end

function patch!(vm::VM)
  vm.patch += 1
  vm
end

function rollback(vm::VM)
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


# julia> include("vm.jl")
# calc_prev (generic function with 2 methods)

# julia> vm = VM("10.2.3")
# ERROR: type #mv has no field minor
# Stacktrace:
#  [1] getproperty(x::Function, f::Symbol)
#    @ Base ./Base.jl:38
#  [2] calc_prev(major::Int64, minor::Int64, patch::Int64)
#    @ Main ~/Projects/Exercism/julia/vm-kata/vm.jl:0
#  [3] VM(init::String)
#    @ Main ~/Projects/Exercism/julia/vm-kata/vm.jl:21
#  [4] top-level scope
#    @ REPL[2]:1
