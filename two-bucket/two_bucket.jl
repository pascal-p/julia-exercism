"""
Since this mathematical problem is fairly subject to interpretation / individual approach, the tests have been written specifically to expect one overarching solution.

To help, the tests provide you with which bucket to fill first. That means, when starting with the larger bucket full, you are NOT allowed at any point to have the smaller bucket full and the larger bucket empty (aka, the opposite starting point); that would defeat the purpose of comparing both approaches!

Your program will take as input:
   - the size of bucket one
   - the size of bucket two
   - the desired number of liters to reach
   - which bucket to fill first, either bucket one or bucket two

More assumptions
   - assume we start with both buckets empty
   - assume size of bucket is an integer
   - assume the desired number of litre is an integer

Valid moves:
   - pouring from one bucket to another                  (transfer)
   - emptying one bucket and doing nothing to the other  (emptying)
   - filling one bucket and doing nothing to the other   (filling)

Ref.
  How not to Die Hard with Math (https://www.youtube.com/watch?v=0Oef3MHYEC0) - May 29, 2015

"""

struct Bucket
  content::Vector{Int}
  cap::Vector{Int}

  function Bucket(cap::Int)
    @assert cap > 0 "Expecting capacity to be greater than 0"

    new([0], [cap])
  end
end

capacity(b::Bucket) = b.cap[1]

content(b::Bucket) = b.content[1]

is_full(b::Bucket) = b.content[1] == b.cap[1]

is_empty(b::Bucket) = b.content[1] == 0

Base.show(io::IO, b::Bucket) = print(io, "<content: $(b.content[1]), capacity: $(b.cap[1])>")

function filling(b::Bucket)
  if is_full(b)
    println("Bucket already full!")
  else
    b.content[1] = b.cap[1]
  end
  b
end

function emptying(b::Bucket)
  if is_empty(b)
    println("Bucket already empty!")
  else
    b.content[1] = 0
  end
  b
end

function transfer(bsrc::Bucket, bdst::Bucket)::Tuple{Bucket, Bucket}
  if is_full(bdst)
    println("bucket $(bdst) is already full!")

  elseif is_empty(bsrc)
    println("bucket $(bsrc) source is empty!")

  else
    t_units = capacity(bdst) - content(bdst)
    t_units =  t_units > content(bsrc) ? content(bsrc) : t_units

    bdst.content[1] += t_units
    bsrc.content[1] -= t_units
  end

  (bsrc, bdst)
end


"""
  2 bucket B (big) S (Small)
  Starting with biggest bucket (B), transitions are:

  Case 1. Starting from biggest bucket B
  FB ≡ Fill B
  TB ≡ Transfer B (-> S)
  ES ≡ Empty Small

  Transitions are typically:
   1     2         3            4
  FB -> TB -> is S full? yes:  ES -> back to 2
              is S full?  no:     -> back to 1

  Case 2. Starting from smallest bucket S
  FS ≡ Fill $
  TS ≡ Transfer S (-> B)
  EB ≡ Empty Big

  Transitions are typically:
   1     2         3           4
  FS -> TS -> is B full? yes: EB -> back to 2
              is B full?  no:    -> back to 1

  Therefore same transition in both cases

  is the problem possible?
  - 1 ≤ goal ≤ capacity(b1) + capacity(b2)
  - gcd(B, S) != 1 only multiples of GCD reachable

"""
struct Problem
  b1::Bucket
  b2::Bucket
  goal::Int
  move::Vector{Int}

  function Problem(b1::Bucket, b2::Bucket, goal::Int)
    @assert 1 ≤ goal ≤ capacity(b1) + capacity(b2) "goal should satisfy: 1 $(goal) <= $(b1.cap + b2.cap)"
    @assert capacity(b1) != capacity(b2) "the two buckets should have different capacity"

    new(b1, b2, goal, [0])
  end
end

function solve(pb::Problem, start::Symbol)
  @assert start ∈ (:one, :two) "$(start) should be either :one or :two"

  b1, b2 = pb.b1, pb.b2
  gcd_ = gcd(capacity(b1), capacity(b2))
  gcd_ != 1 && pb.goal % gcd_ != 0 && throw(ArgumentError("goal $(pb.goal) cannot be achieved"))

  if pb.goal == capacity(b1) || pb.goal == capacity(b2)
    return (1, start, 0)

  elseif pb.goal ==  capacity(b1) + capacity(b2)
    return (2, :both, pb.goal)
  end

  start == :one && return strategy(pb, b2)
  start == :two && return strategy(pb, b1)
end


"""
   1     2                            3
  Fb -> Tb(o_b) -> is o_b full? yes: E(o_b) -> back to 2
                                no: -> back to 1
"""
function strategy(pb::Problem, b::Bucket)
  o_b = b == pb.b1 ? pb.b2 : pb.b1

  nextop = :filling
  while !goal_reached(pb)
    if nextop == :filling
      filling(o_b)
      pb.move[1] += 1
      nextop = :transfer
    end

    if nextop == :transfer
      transfer(o_b, b)
      pb.move[1] += 1
    end

    goal_reached(pb) && break

    if is_full(b)
      emptying(b)
      pb.move[1] += 1
      nextop = :transfer
    else
      nextop = :filling
    end
  end

  solution(pb)
end

function goal_reached(pb::Problem)::Bool
  b1, b2, goal = pb.b1, pb.b2, pb.goal
  content(b1) == goal || content(b2) == goal || content(b1) + content(b2) == goal
end

function solution(pb::Problem)
  b1, b2 = pb.b1, pb.b2
  content(b1) == pb.goal ? (pb.move[1], :one, content(b2)) : (pb.move[1], :two, content(b1))
end


function gcd(x::Int, y::Int)::Int
  """
  assume x > 0 and y > 0
  """
  x, y = x < y ? (y, x) : (x, y)
  y == 0 && return x
  r = x
  while r > 1
    r = x % y
    x, y = y, r
  end
  r == 0 ? x : r
end

function measure(b1::Int, b2::Int, goal::Int, start::Symbol)
  @assert start ∈ (:one, :two) "$(start) should be either :one or :two"
  @assert b1 > 0 && b2 > 0 && b1 != b2

  b1 = Bucket(b1)
  b2 = Bucket(b2)
  pb = Problem(b1, b2, goal)
  solve(pb, start)
end
