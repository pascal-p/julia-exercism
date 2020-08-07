"""
    is_leap_year(year)

Return `true` if `year` is a leap year in the gregorian calendar.

"""
# function is_leap_year_v1(year)
#   if year % 400 == 0
#     return true
#   elseif year % 4 == 0 && year % 100 != 0
#     return true
#   else
#     return false
#   end
# end

function is_leap_year(year)
  return year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
end
