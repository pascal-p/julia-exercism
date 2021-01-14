const EARTH_YEAR = 365.25
const DAY_SEC = 86_400
const YEAR_DUR = Dict{String, Real}("earth" => EARTH_YEAR,    # in days
                                    "mercury" => 0.2408467 * EARTH_YEAR,
                                    "venus" => 0.61519726 * EARTH_YEAR,
                                    "mars" => 1.8808158 * EARTH_YEAR,
                                    "jupiter" => 11.862615 * EARTH_YEAR,
                                    "saturn" => 29.447498 * EARTH_YEAR,
                                    "uranus" =>  84.016846 * EARTH_YEAR,
                                    "neptune"=>  164.79132 * EARTH_YEAR)

for key ∈ keys(YEAR_DUR)
  fname = Symbol("space_age_on_$(key)")

  @eval begin
    function $(fname)(sec::Integer)::Real
      d = sec / DAY_SEC
      round(d / YEAR_DUR[$(key)]; digits=2)
    end

  end
end
