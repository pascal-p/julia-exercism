function cipher_text(plain_txt::AbstractString; sep::Char=' ')::AbstractString
  """
    cipher_text("If man was meant to stay on the ground, nature would have given us roots.")

    == 'imtgtdes fearuhn  mayorau  anouevs  ntnnwer  wttdogo  aohnuio  ssealvt '
  """
  length(plain_txt) == 0 && (return "")

  norm_txt, n = normalize_src(plain_txt)
  r, c = square_coeff(n)

  segment_txt(norm_txt, c, r, n; sep=sep) |>
    chunks -> cipher_txt(chunks, c; sep=sep)
end

function normalize_src(plain_txt::AbstractString)::Tuple{AbstractString, Int}
  norm_txt = lowercase(plain_txt) |>
    s -> replace(s, r"[^a-z0-9]+" => "")
  n = length(norm_txt)

  (norm_txt, n)
end

function square_coeff(n::Int)::Tuple{Int, Int}
  r = floor(Int, (1. + √(1 + 4n)) / 2.)
  c = r * r ≥ n ? r : r + 1

  @assert c * r ≥ n
  (r, c)
end

function segment_txt(norm_txt::AbstractString, c::Int, r::Int, n::Int;
                     sep::Char=' ')::Vector{AbstractString}
  ## Alt: allocate array first... then fill
  # chunks, jx = Vector{AbstractString}(undef, r), 1
  # for ix in 1:c:n
  #   chunks[jx] = norm_txt[ix:min(ix + r, n)]
  #   jx += 1
  # end
  chunks = [norm_txt[ix:min(ix + r, n)] for ix in 1:c:n]

  if length(sep) > 0
    llc = length(chunks[end])
    chunks[end] = string(chunks[end], sep ^ (c - llc))
  end

  chunks
end

function cipher_txt(chunks::Vector{AbstractString}, c::Int; sep::Char=' ')::AbstractString
  [foldl((str, s) -> string(str, s[ix]), chunks, init="") for ix in 1:c] |>
    a -> join(a, sep)
end
