function acronym(phrase::AbstractString)::AbstractString
  length(phrase) == 0 && (return "")

  split(phrase, r"[\s,\.:;\-_\"]") |>
    ws -> filter((w) -> w != "", ws) |>
    ws -> map((w) -> (w = uppercase(w); 'A' ≤ w[1] ≤ 'Z' ? w[1] : w[2]), ws) |>
    l -> join(l)
end
