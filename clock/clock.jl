using Printf, Dates

import Base: +, -, show
import Dates: Hour, Minute, Second

struct Clock
  hour::Dates.Hour
  min::Dates.Minute
  sec::Dates.Second

  function Clock(h::Hour, m::Minute)
    h_v, m_v, _ = convert_hms(h.value, m.value, 0)
    new(Hour(h_v), Minute(m_v), Second(0))
  end

  function Clock(h::Hour, m::Minute, s::Second)
    h_v, m_v, s_v = convert_hms(h.value, m.value, s.value)
    new(Hour(h_v), Minute(m_v), Second(s_v))
  end

  function Clock(h::Integer, m::Integer)
    new(convert_hms(h, m)...)
  end

  function Clock(h::Integer, m::Integer, s::Integer=0)
    new(convert_hms(h, m, s)...)
  end
end


function Base.show(io::IO, clock::Clock)
  if clock.sec.value == 0
    print(io, @sprintf("\"%02d:%02d\"", clock.hour.value, clock.min.value))
  else
    print(io, @sprintf("\"%02d:%02d:%02d\"", clock.hour.value, clock.min.value, clock.sec.value))
  end
end


##
## Arithmetic ops
##

function +(clock::Clock, min::Minute)::Clock
  min_hour, min = divrem(clock.min + min, 60)
  Clock((clock.hour + Hour(min_hour * 60)) % 24, min)
end

+(min::Minute, clock::Clock)::Clock = +(clock::Clock, min::Minute)::Clock

+(clock::Clock, sec::Second)::Clock = +(clock::Clock, Minute(0), sec::Second)::Clock
+(sec::Second, clock::Clock)::Clock = +(clock::Clock, Minute(0), sec::Second)::Clock


function +(clock::Clock, min::Minute, sec::Second)::Clock
  sec_min, sec = divrem(clock.sec + sec, 60)
  min = Minute(min.value + sec_min.value)

  min_hour, min = divrem(clock.min + min, 60)

  Clock((clock.hour + Hour(min_hour * 60)) % 24, min, sec)
end

+(clock::Clock, sec::Second, min::Minute)::Clock = +(clock::Clock, min::Minute, sec::Second)::Clock

+(min::Minute, clock::Clock, sec::Second)::Clock = +(clock::Clock, min::Minute, sec::Second)::Clock
+(min::Minute, sec::Second, clock::Clock)::Clock = +(clock::Clock, min::Minute, sec::Second)::Clock

+(sec::Second, clock::Clock, min::Minute)::Clock = +(clock::Clock, min::Minute, sec::Second)::Clock
+(sec::Second, min::Minute, clock::Clock)::Clock = +(clock::Clock, min::Minute, sec::Second)::Clock


function -(clock::Clock, min::Minute)::Clock
  cl_h_v, cl_m_v = clock.hour.value, clock.min.value

  (h_hour, m_min) = if clock.min < min
    ## Adjust hour and minute
    nb_hour_to_min = ceil(Int, min.value / 60)
    cl_h = adjust_hour(cl_h_v, nb_hour_to_min)
    cl_m = Minute(nb_hour_to_min * 60 + cl_m_v - min.value)
    (cl_h, cl_m)
  else
    cl_m = Minute(cl_m_v - min.value)
    (Hour(cl_h_v), cl_m)
  end

  Clock(h_hour, m_min, clock.sec)
end


function -(clock::Clock, min::Minute, sec::Second)::Clock
  cl_h_v, cl_m_v, cl_s_v = clock.hour.value, clock.min.value, clock.sec.value

  (h_hour, m_min, s_sec) = if cl_s_v < sec.value
    nb_min_to_sec = ceil(Int, sec.value / 60)
    cl_h = Hour(cl_h_v)

    ## Adjust hour and minute
    if cl_m_v < nb_min_to_sec
      if nb_min_to_sec > 60
        nb_hour_to_min = round(Int, sec.value / 3600)
        cl_h = adjust_hour(cl_h_v, nb_hour_to_min)
      else
        cl_h_v -= 1
        cl_h = Hour(0 ≤ cl_h_v ≤ 23 ? cl_h_v : 24 + cl_h_v)
        cl_m_v += 60
      end
    end

    ## Adjust minute and second
    mdiff = (cl_m_v - nb_min_to_sec) % 60
    cl_m_v = 0 ≤ mdiff ≤ 59 ? mdiff : 60 + mdiff
    cl_s_v = nb_min_to_sec * 60 + cl_s_v - sec.value
    if cl_s_v ≥ 60
      cl_m_v += 1
      cl_s_v -= 60
    end

    (cl_h, Minute(cl_m_v), Second(cl_s_v))
  else
    ## Adjust second
    cl_s_v -= sec.value
    (Hour(cl_h_v), Minute(cl_m_v), Second(cl_s_v))
  end

  Clock(h_hour, m_min, s_sec)
end

-(clock::Clock, sec::Second)::Clock = -(clock::Clock, Minute(0), sec::Second)::Clock


##
##  Internal Helpers
##

function convert_hms(h::Integer, m::Integer, s::Integer=0)
  if s < 0
    count = abs(s ÷ 60 - 1) ## number of time to decr. min
    m -= count
    s = count * 60 + s      ## rest
  end

  if m < 0
    count = abs(m ÷ 60 - 1) ## number of time to decr. hour
    h -= count
    m = count * 60 + m      ## rest
  end

  h < 0 && (h = 24 + (h % 24))
  @assert h ≥ 0 && m ≥ 0 && s ≥ 0 "h: $h > 0, m: $m > 0, s $s > 0"

  δmin, sec = divrem(s, 60)
  δhour, min = divrem(m + δmin, 60)
  hour = (h + δhour) % 24

  return (Hour(hour), Minute(min), Second(sec))
end

function adjust_hour(cl_h, nb_hour_to_min)::Hour
  hdiff = (cl_h - nb_hour_to_min) % 24
  cl_h = Hour(0 ≤ hdiff ≤ 23 ? hdiff : 24 + hdiff) # return
end
