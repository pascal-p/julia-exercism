using Base: show

const SEP = '.'
const V_REXP = r"\A\d+\.\d+\.\d+(?:\.\d+)*\Z"

import Base: show

mutable struct VM
  major::Int
  minor::Int
  patch::Int8

  function VM(init::Union{String, Nothing} = nothing)
    if init === nothing
      new(0, 0, 1)
    else
      @assert occursin(V_REXP, init)
      (smajor, sminor, spatch, _r...) = split(init, SEP)
      (smajor, sminor, spatch) |> t -> parse.(Int, t) |> t -> new(t...)
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
