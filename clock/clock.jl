using Printf, Dates

import Base: +, -, show
import Dates: Hour, Minute, Second

struct Clock
  hour::Dates.Hour
  min::Dates.Minute
  sec::Dates.Second

  function Clock(h::Hour, m::Minute)
    new(h, m, Second(0))
  end

  function Clock(h::Integer, m::Integer)
    new(convert_hms(h,m))
  end

  function Clock(h::Integer, m::Integer, s::Integer=0)
    new(convert_hms(h, m, s)...)
  end
end


Base.show(io::IO, clock::Clock) = print(io, @sprintf("\"%02d:%02d\"", clock.hour.value, clock.min.value))


##
## Arithmetic ops
##

function +(clock::Clock, min::Minute)::Clock
  min_hour, min = divrem(clock.min + min, 60)
  Clock((clock.hour + Hour(min_hour * 60)) % 24, min)
end

function -(clock::Clock, min::Minute)::Clock
  (h_hour, m_min) = if clock.min < min
    # How many 60 minutes do we need ?
    nb_hour_to_min = ceil(Int, min.value / 60)
    hdiff = (clock.hour.value - nb_hour_to_min) % 24

    h_ = Hour(0 ≤ hdiff ≤ 23 ? hdiff : 24 + hdiff)
    m_ = Minute(nb_hour_to_min * 60 + clock.min.value - min.value)
    (h_, m_)
  else
    m_ = clock.min.value - min.value
    (clock.hour, Minute(m_))
  end

  Clock(h_hour, m_min)
end


##
##  Internal Helpers
##

function convert_hms(h::Integer, m::Integer, s::Integer=0)
  if m < 0
    count = abs(div(m, 60) - 1) ## number of time to decr. hour
    h -= count
    m = count * 60 + m          ## rest
  end

  h < 0 && (h = 24 + (h % 24))
  @assert h ≥ 0 && m ≥ 0 && s ≥ 0 "h: $h > 0, m: $m > 0, s $s > 0"

  rmin, sec = divrem(s, 60)
  rhour, min = divrem(m + rmin, 60)
  hour = (h + rhour) % 24

  return (Hour(hour), Minute(min), Second(sec))
end
