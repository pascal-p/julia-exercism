"""
Aim installing a new version of `Julia` programming language on GNU/Linux (could be a BSD system)

Assumptions - the pre-required tools are part of the GNU/Linux or BSD flavor, namely:
- `tar`
- `sha256sum` (GNU/Linux), sha (BSD)
- `gpg`

"""

using HTTP
using ArgParse


const URI_PREFIX = "https://julialang-s3.julialang.org/bin"
const MAJOR_VER = "1.9"
const FULL_VER = "$(MAJOR_VER).2"
const DIST = "linux"
const ARCH = "x64"
const CPU_ARCH = "x86_64"
const EXT = "tar.gz"
const CKSUM = "sha256"
const DOWNLOAD_DIR = """$(ENV["HOME"])/Downloads"""
const TARGET_DIR = """$(ENV["HOME"])/Projects"""


cwd = pwd()


function _download(file_list; download_dir = DOWNLOAD_DIR, force_download = false)
  for file_url ∈ file_list
    try
      target_filepath = join([download_dir, basename(file_url)], "/")

      if !isfile(target_filepath) || force_download
    	HTTP.download(file_url, target_filepath; update_period=5.1)
    	println("- file $(target_filepath) downloaded successfully.")
      else
	println("- file $(target_filepath) is already downloaded, nothing to do...")
      end
    catch
      println("Downloading file fromn url: $(file_url) failed")
      exit(1)
    end
  end
end


"""
`_exec` a function that takes a command to execute an external process and returns the execution status
or exit on any error.
"""
function _exec(
  cmd::String, cmd_switches::Vector{String}, args::Vector{String};
  download_dir = DOWNLOAD_DIR
  )
  println("""About to exec $(join([cmd, cmd_switches..., (args .|> basename)...], " "))\n""")

  for _file ∈ args
    _bfile = string(download_dir, "/", basename(_file))
    if !isfile(_bfile)
      println("Problem with file $(_bfile) which may not exist or might not be defined or...")
      exit(2)
    end
  end
  fcmd = Cmd([cmd, cmd_switches..., (args .|> basename)...])
  try
    rc = run(Cmd(fcmd, dir=download_dir, detach=false));
    if rc.exitcode != 0
      println("The execution of command using $(cmd) failed")
      exit(3)
    end
    # propertynames(rc) == (:cmd, :handle, :in, :out, :err, :exitcode, :termsignal, :exitnotify)
    println("Execution $(cmd) completed successfully")
  catch err
    println("There was an error while the $(cmd) verification was performed." , err)
    exit(4)
  end
end


"""
Example:

```julia
sha256sum --check --ignore-missing julia-1.9.2.sha256

julia-1.9.2-linux-x86_64.tar.gz: OK
Process(`sha256sum --check --ignore-missing julia-1.9.2.sha256`, ProcessExited(0))
```
"""
cksum_verify(file::String, checker="sha256sum", options=["--check", "--ignore-missing"]) =
  _exec(checker, options, [file])


"""
```julia
gpg --verify julia-1.9.2-linux-x86_64.tar.gz.asc julia-1.9.2-linux-x86_64.tar.gz

gpg: Signature made Wed 05 Jul 2023 23:32:43 NZST
gpg:                using RSA key 3673DF529D9049477F76B37566E3C7DC03D6E495
gpg: Good signature from "Julia (Binary signing key) <buildbot@julialang.org>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 3673 DF52 9D90 4947 7F76  B375 66E3 C7DC 03D6 E495
```
"""
gpg_verify(gpg_file::String, src_file::String; checker="gpg", options=["--verify"]) =
  _exec(checker, options, [gpg_file, src_file])


unpack_archive(src_file::String; cmd="tar", cmd_switches=["xzvf"]) =
  _exec(cmd, cmd_switches, [src_file])

function mv_and_symlink(version;
                        download_dir = DOWNLOAD_DIR,
                        install_dir = TARGET_DIR,
                        cwd=cwd)
  if isdir("$(download_dir)/julia-$(version)")
    mv("$(download_dir)/julia-$(version)", "$(install_dir)/julia-$(version)", force=true)
    islink("$(install_dir)/julia") && rm("$(install_dir)/julia", force=true)
    cd(install_dir); symlink("julia-$(version)", "julia"; dir_target=false); cd(cwd)
  end
end

function _pipeline(;version = FULL_VER,
                   download_dir = DOWNLOAD_DIR,
                   install_dir = TARGET_DIR,
                   force = false)
  julia_lang_archive = join(
    [URI_PREFIX, DIST, ARCH, MAJOR_VER, "julia-$(version)-$(DIST)-$(CPU_ARCH).$(EXT)"],
    "/"
  )
  julia_cksum = join(
    [URI_PREFIX, "checksums", "julia-$(version).$(CKSUM)"],
    "/"
  )
  julia_gpg = join(
    [URI_PREFIX, DIST, ARCH, MAJOR_VER, "julia-$(version)-$(DIST)-$(CPU_ARCH).$(EXT).asc"],
    "/"
  )

  _download([julia_lang_archive, julia_cksum, julia_gpg];
            download_dir = download_dir,
            force_download = force)
  cksum_verify(julia_cksum)                  # "sha256sum", ["--check", "--ignore-missing"],
  gpg_verify(julia_gpg, julia_lang_archive)  # "gpg", ["--verify"],
  unpack_archive(julia_lang_archive)         # "tar", [ "xzvf" ],

  mv_and_symlink(version; download_dir, install_dir)
end


function cli()
  """
  cf. https://carlobaldassi.github.io/ArgParse.jl/stable/arg_table/
  """
  s = ArgParseSettings(
    description = "This program downloads, checks and installs a new julia language version on GNU/Linux system",
    version = "1.0",
    add_version = true,
    autofix_names = true
  )

  @add_arg_table! s begin
    "--new_version", "-v"
      help = "the Julia version to install"
      arg_type = String
      required = true
      action = :store_arg
      default = nothing
    "--prev_version", "-p"
      help = "the Julia previous version to remove (if present)"
      arg_type = String
      required = false
      action = :store_arg
      default = nothing
    "--force", "-f"
      help = "force download even if file(s) already present on the filesystem"
      action = :store_true
      required = false
    "--download_dir", "-D"
      help = "the directory were to store the artefacts"
      arg_type = String
      required = false
      action = :store_arg
      default = DOWNLOAD_DIR
    "--install_dir", "-I"
      help = "The location were Julia will be installed"
      arg_type = String
      required = false
      action = :store_arg
      default = TARGET_DIR
  end

  parse_args(s)
end


function main()
  parsed_args = cli()
  println("ARGS: ", parsed_args)

  _pipeline(
    version = parsed_args["new_version"],
    download_dir = parsed_args["download_dir"],
    install_dir = parsed_args["install_dir"],
    force = parsed_args["force"] || false
  )

  if parsed_args["prev_version"] !== nothing
    rm(
      """$(parsed_args["install_dir"])/julia-$(parsed_args["prev_version"])""",
      force=true,
      recursive=true
    )
  end
end

main()

# julia --project=. install_julia/installing_julia.jl --new-version 1.9.2 --prev-version 1.9.0
