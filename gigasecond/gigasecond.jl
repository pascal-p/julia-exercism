using Dates

const GIGA_SEC = 10^12 # expressed in ms

function add_gigasecond(date::DateTime)
  Millisecond(Dates.value(date) + GIGA_SEC) |> Dates.UTInstant{Millisecond} |> DateTime
end
