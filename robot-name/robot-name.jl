"""
Manage robot factory settings.

When a robot comes off the factory floor, it has no name.

The first time you turn on a robot, a random name is generated in the format of two uppercase letters followed by three digits, such as RX837 or BC811.

Every once in a while we need to reset a robot to its factory settings, which means that its name gets wiped. The next time you ask, that robot will respond with a new random name.

The names must be random: they should not follow a predictable sequence. Using random names means a risk of collisions.
=> Your solution must ensure that every existing robot has a unique name.

The test suite only generates ~100 names by default. There are ~700k valid names, so it will only give a small chance of collisions. Consider testing your solution for collisions in some other way in addition to the test suite.

This exercise continues our exploration of Julia's type system, this time with mutable types, and introduces us to random number generation.

We will imagine that resetting the robot to the factory settings is like a surgery: it makes changes to the subject, but doesn't replace it. We could also have modeled the problem such that resetting a robot creates a new robot, but not every problem can be modeled solely with immutable data structures (even purely functional languages deal with mutability inside their runtimes!).

You will need to define
  - a method for generating unique names,
  - a structure to describe robots,
  - a method for resetting a robot, and
  - a method for getting the name of a robot.

You might find it helpful to design your program first to just emit a random name for a robot (without worrying about collisions) and then later to think about and design a scheme that will avoid ever issuing duplicate names. In your design, be thoughtful about how the run time of name generation changes as names run out. What guarantees do you want to offer the caller?
"""

using Random

const N = 3
const RETRIES = 7  ## with the tests, setting up this to 5 => a failure (out of all tests)
#                  ## 7 looks ok...

History = Set{String}() # global history

mutable struct Robot
  name::String

  Robot() = new(gen_rand_name(seed=rand(UInt)))
end

function reset!(instance::Robot)
  oldname = instance.name
  instance.name = gen_rand_name(seed=abs(rand(Int)))
  instance
end

name(instance::Robot) = instance.name

function gen_rand_name(;seed=42)
  """
  Here we just retry, when a collision is detected...

  Problem there is no guarantee that the retry will be successful...
  ... How many retry before failure?
  ...
  """
  local name
  retries = RETRIES

  while true
    prefix = randstring(MersenneTwister(seed), 'A':'Z', 2)
    suffix = rand(0:10^N - 1) |> string

    if length(suffix) < N
      for ix ∈ length(suffix)+1:N
        suffix = string("0", suffix)
      end
    end

    name = string(prefix, suffix)
    # @assert(occursin(r"\A[A-Z]{2}[0-9]{3}\z", name),
    #         "Expecting name 2Char 3 digits, got: $(name)")
    name ∉ History && break
    retries -= 1
    retries == 0 && throw(ArgumentError("Exhausted all retries (set to $(RETRIES))"))
    seed=rand(UInt)
  end
  push!(History, name)

  name
end

##
## Going the other way?
## Using a generator - select a name, remove name from generator...
##
