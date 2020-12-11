"""
  Sequence Alignment (Needleman and Wunsch)

  Ex.  A G G G C T
       A G G _ C A


  case (i) of reccurence - if compared letters are the same => no mismatch,
    otherwise apply αm
"""

function nw(x::String, y::String; αg::Int=1, αm::Int=1)
  lx, ly = length(x) + 1, length(y) + 1

  mat = Matrix{Int}(undef, lx, ly)

  for ix in 1:lx; mat[ix, 1] = (ix - 1) * αg; end
  for jx in 1:ly; mat[1, jx] = (jx - 1) * αg; end

  for ix in 2:lx, jx in 2:ly
    mat[ix, jx] = min(
                      mat[ix - 1, jx - 1] + αm * (x[ix - 1] == y[jx - 1] ? 0 : 1),
                      mat[ix - 1, jx] + αg,
                      mat[ix, jx - 1] + αg,
                      )
  end

  return (mat[lx, ly], recons_seq(x, y, mat, αg, αm))
end

function recons_seq(x::String, y::String, mat::Matrix{Int}, αg::Int, αm::Int)
  lx, ly = length(x), length(y)
  ix, jx = lx + 1, ly + 1
  nx, ny = "", ""

  while ix > 1 && jx > 1
    c1 = mat[ix - 1, jx - 1] + αm * (x[ix - 1] == y[jx - 1] ? 0 : 1)
    c2 = mat[ix - 1, jx] + αg
    c3 = mat[ix, jx - 1] + αg

    if c1 ≤ min(c2, c3)      ## case 1
      nx = string(x[ix - 1], nx)
      ny = string(y[jx - 1], ny)
      ix -= 1
      jx -= 1

    elseif c2 < min(c1, c3)  ## case 2
      nx = string(x[ix - 1], nx)
      ny = string('_', ny)
      ix -= 1
    else                     ## case 3
      ny = string(y[jx - 1], ny)
      nx = string('_', nx)
      jx -= 1
    end
  end

  if ix == 1 && jx > 1
    while jx > 1
      ny = string(y[jx], ny)
      jx -= 1
    end
    length(nx) < length(ny) && (nx = string("_" ^ length(ny) - length(nx), nx))

  elseif jx == 1 && ix > 1
    while ix > 1
      nx = string(x[ix], nx)
      ix -= 1
    end
    length(ny) < length(nx) && (ny = string("_" ^ length(nx) - length(ny), ny))

  else
    # NOOP
  end
  (nx, ny)
end

# CACAATGCATCATGACTATGCATGCATGACTGACTGCATGCATGCATCCATCATGCATGCATCGATGCATG__CATGAC_CACCTGTG_TGACA_CATGCATGCGTGTGACATGCGA_GAC_TCACTAGCGATGCATGC_ATGCATGCATGCATGC
# ____ATG_ATCATG_C_ATGCATGCATCAC__ACTG__TGCAT_CAGAGA_GA_GC_T_C_TC_A_GCA_GACCA_CACACACGTGTGCAGAGAGCATGCATGC__ATG_CATGC_ATG_CAT_GGTAGC__TGCATGCTATG_A_GCATGCA_G_


##
## Helpers
##
file_to_str(fh::IOStream) = (strip ∘ readline)(fh) |> s -> string(s)


function from_file(infile::String)
  try
    local lx, ly, x, y, αg, αm

    open(infile, "r") do fh
      for line in eachline(fh)
        ## read only first line, where we expect 2 Integers ≡ (len. string X, len. string Y)
        a = split(strip(line), r"\s+")
        (lx, ly) = map(s -> parse(Int, strip(s)), a)
        break
      end

      for line in eachline(fh)
        a = split(strip(line), r"\s+")
        αg, αm = map(s -> parse(Int, strip(s)), a)
        break
      end

      x, y =  file_to_str(fh), file_to_str(fh)
      @assert length(x) == lx
      @assert length(y) == ly
    end
    return (x, y, αg, αm)

  catch err
    println("Intercepted error: $(err)")
    exit(1)
  end
end
