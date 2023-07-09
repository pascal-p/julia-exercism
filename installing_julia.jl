### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ f923b9c8-88e9-4351-b2e2-b81d94e2d0c7
using PlutoUI

# ╔═╡ 2da81de9-8416-4b27-8861-4771882b8f4c
using HTTP

# ╔═╡ 5480b3fe-1dd9-11ee-0de6-f39bee5f8155
md"""
### Installing  a new version of `Julia` on a GNU/Linux distribution 

Assuming that the basic tools needed to install and check an archive in tar format are present in the `GNU/Linux` distribution.
"""

# ╔═╡ d06d3ab8-e162-477c-8326-e3ad652b181e
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ 4b279fc9-75f9-49f2-93d2-994548a5b534
md"""
### Plan

- _Download an verify_ \
  Need to download 3 artefacts in a local sub-directory:
  1. the `julia` archive itself
  1. the file checksum (`sha256`)
  1. the file signature (for `gpg` check)

  Then, need to verify the checksum of the downloaded language archive against the downloaded checksum, if equals continue. If not stop immediately.

  Need to check the gpg signature of downloaded language archive against the file signature (this assume the `julia` language public key is available locally).\

- _Unpack and install_
  - Unpack the language archive then move it to target directory and re-create symlink.
  - Optionally delete the oldest version (after confirmation it is OK to do so.)

- _`LSP` setup in `emacs`_
  - Optional for now

- _Finally_
  - Delete oldest related tar files (from previous version of Julia)

"""

# ╔═╡ 78f0c97d-6c56-4656-880a-a728bdcc8f6f
run(`echo $(ENV["HOME"])`)

# ╔═╡ 771d1f6c-1d69-404a-968c-4df46a24b127
begin

const URI_PREFIX = "https://julialang-s3.julialang.org/bin"
const MAJOR_VER = "1.9"
const FULL_VER = "$(MAJOR_VER).2"
const DIST = "linux"
const ARCH = "x64"
const CPU_ARCH = "x86_64"
const EXT = "tar.gz"
const CKSUM = "sha256"

const DOWNLOAD_DIR = """$(ENV["HOME"])/Downloads"""
const TARGT_DIR = """$(ENV["HOME"])/Projects"""
end;

# ╔═╡ 5b835119-31b9-4fec-af26-20adcf251870
md"""
#### Download and verify
"""

# ╔═╡ 78efbbe9-c402-4ce7-9322-b91924f7f9dd
julia_lang_archive = join(
	[URI_PREFIX, DIST, ARCH, MAJOR_VER, "julia-$(FULL_VER)-$(DIST)-$(CPU_ARCH).$(EXT)"], 
	"/"
)

# ╔═╡ 620a7adf-88c7-47dd-9b7b-ee3d48f7f585
@assert julia_lang_archive == "https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.2-linux-x86_64.tar.gz"

# ╔═╡ c8849b84-7dd9-4f10-8a8d-153ff19dda57
julia_cksum = join(
	[URI_PREFIX, "checksums", "julia-$(FULL_VER).$(CKSUM)"],
	"/"
)

# ╔═╡ 82535dfa-844b-44a2-90bb-4da22f394ddc
 @assert julia_cksum == "https://julialang-s3.julialang.org/bin/checksums/julia-1.9.2.sha256"

# ╔═╡ 6f4bfb1a-fc55-452d-a94e-2a57375eea74
julia_gpg = join(
	[URI_PREFIX, DIST, ARCH, MAJOR_VER, "julia-$(FULL_VER)-$(DIST)-$(CPU_ARCH).$(EXT).asc"],
	"/"
)

# ╔═╡ 24a8a72d-ba1a-4160-b40c-ea12ae08fd1c
@assert julia_gpg == "https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.2-linux-x86_64.tar.gz.asc"

# ╔═╡ 7c6cda6d-abe6-40b5-96fc-35d2360c1f7d
wd = pwd()

# ╔═╡ cf661c32-d93d-45ab-b0d8-31f9b873793d
function _download(file_list=[julia_lang_archive, julia_cksum, julia_gpg], force_download=false)
	for file_url ∈ file_list
		try
			target_filepath = join([DOWNLOAD_DIR, basename(file_url)], "/")
			if !isfile(target_filepath) || force_download
    			HTTP.download(file_url, target_filepath; update_period=5.1)
    			println("- file $(target_filepath) downloaded successfully.")
			else
				println("- file $(target_filepath) is already downloaded, nothing to do...")
			end
    		# create_symlink(target_filepath, target_linkpath)    
  		catch
    		println("Downloading file fromn url: $(file_url) failed")
    		exit(1)
  		end
	end
end

# ╔═╡ fc37491a-deb8-42b4-9a78-4868f991de28
"""
`_exec` a function that takes a command to execute an external process and returns the execution status
or exit on any error.
"""
function _exec(cmd::String, cmd_switches::Vector{String}, args::Vector{String})
	println("""About to exec $(join([cmd, cmd_switches..., (args .|> basename)...], " "))\n""")
	for _file ∈ args 
		if !isfile(_file)
			println("Problem with file $(_file) which may not exist or might not be defined or...")
			exit(2)
		end
	end
	fcmd = Cmd([cmd, cmd_switches..., (args .|> basename)...])
	try
		rc = run(Cmd(fcmd, dir=DOWNLOAD_DIR, detach=false)); 
		if rc.exitcode != 0
			println("The excution of command using $(cmd) failed")
			exit(3)
		end
		# propertynames(rc) == (:cmd, :handle, :in, :out, :err, :exitcode, :termsignal, :exitnotify)
		println("Verification with $(cmd) completed successfully")
	catch err
		println("There was an error while the $(cmd) verification was performed." , err)
		exit(4)
	end
end

# ╔═╡ 32205c33-57cf-4633-b86b-3bda45ac3f47
"""
Example:

```julia
sha256sum --check --ignore-missing julia-1.9.2.sha256

julia-1.9.2-linux-x86_64.tar.gz: OK
Process(`sha256sum --check --ignore-missing julia-1.9.2.sha256`, ProcessExited(0))
```
"""
cksum_verify(checker="sha256sum", options=["--check", "--ignore-missing"], cksum_file=julia_cksum) = 
	_exec(checker, options, [cksum_file])

# ╔═╡ ae9a83bc-3cc0-4042-8876-b4d2905c35cf
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
gpg_verify(gpg_file=julia_gpg, src_file=julia_lang_archive, checker="gpg", options=["--verify"]) =
	_exec(checker, options, [gpg_file, src_file])

# ╔═╡ 679b4731-714e-47c7-a250-f606be41a15c
 _download()

# ╔═╡ b704b933-4e30-472d-b26c-86cdb5c7f70f
# cksum_verify()

# ╔═╡ 372a9114-e544-445a-84bb-6abd21244763
# gpg_verify()

# ╔═╡ 85a28180-62a3-4166-a252-b9bc6b56adc3
md"""
### Execution

1. Unpack the archive.
2. Move it to target directory
3. Create symlink

"""

# ╔═╡ 97280a46-535a-4c5a-b3c4-8aa5dcf42cad
unpack_archive(src_file=julia_lang_archive, cmd="tar", cmd_switches=["xzvf"]) = 
	_exec(cmd, cmd_switches, [src_file])

# ╔═╡ 4117d942-ff09-4e0c-b7ed-e4b8b2ae817e
# unpack_archive()

# ╔═╡ 30a2186e-bad0-462e-804d-ee38b6589860
if isdir("$(DOWNLOAD_DIR)/julia-$(FULL_VER)")
	mv("$(DOWNLOAD_DIR)/julia-$(FULL_VER)", "$(TARGT_DIR)/julia-$(FULL_VER)", force=true)
	islink("$(TARGT_DIR)/julia") && rm("$(TARGT_DIR)/julia", force=true)
	cd(TARGT_DIR); symlink("julia-$(FULL_VER)", "julia"; dir_target=false); cd(wd)
end

# ╔═╡ 005442ed-c527-424c-b2fc-f02ec2bafd9c
# TODO...

# ╔═╡ ea6fe551-0a13-4c71-ba63-3bc872f3d8ab
html"""
<style>
  main {
    max-width: calc(1000px + 25px + 6px);
  }
  .plutoui-toc.aside {
    background-color: black;
        color: linen;
  }
  h4, h5 {
        background-color: black;
    color: wheat;
        text-decoration: underline overline dotted darkred;
  }
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HTTP = "~1.9.8"
PlutoUI = "~0.7.51"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.1"
manifest_format = "2.0"
project_hash = "272a8c9d8818d495c0e90d4f3d37e0e4cd40730a"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "96d823b94ba8d187a6d8f0826e731195a74b90e9"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "7f5ef966a02a8fdf3df2ca03108a88447cb3c6f0"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.9.8"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cae3153c7f6cf3f069a853883fd1919a6e5bab5b"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.9+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "4b2e829ee66d4218e0cef22c0a64ee37cf258c29"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "b478a748be27bd2f2c73a7690da219d0844db305"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.51"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─5480b3fe-1dd9-11ee-0de6-f39bee5f8155
# ╠═f923b9c8-88e9-4351-b2e2-b81d94e2d0c7
# ╠═d06d3ab8-e162-477c-8326-e3ad652b181e
# ╠═2da81de9-8416-4b27-8861-4771882b8f4c
# ╟─4b279fc9-75f9-49f2-93d2-994548a5b534
# ╠═78f0c97d-6c56-4656-880a-a728bdcc8f6f
# ╠═771d1f6c-1d69-404a-968c-4df46a24b127
# ╟─5b835119-31b9-4fec-af26-20adcf251870
# ╠═78efbbe9-c402-4ce7-9322-b91924f7f9dd
# ╠═620a7adf-88c7-47dd-9b7b-ee3d48f7f585
# ╠═c8849b84-7dd9-4f10-8a8d-153ff19dda57
# ╠═82535dfa-844b-44a2-90bb-4da22f394ddc
# ╠═6f4bfb1a-fc55-452d-a94e-2a57375eea74
# ╠═24a8a72d-ba1a-4160-b40c-ea12ae08fd1c
# ╠═7c6cda6d-abe6-40b5-96fc-35d2360c1f7d
# ╠═cf661c32-d93d-45ab-b0d8-31f9b873793d
# ╠═fc37491a-deb8-42b4-9a78-4868f991de28
# ╠═32205c33-57cf-4633-b86b-3bda45ac3f47
# ╠═ae9a83bc-3cc0-4042-8876-b4d2905c35cf
# ╠═679b4731-714e-47c7-a250-f606be41a15c
# ╠═b704b933-4e30-472d-b26c-86cdb5c7f70f
# ╠═372a9114-e544-445a-84bb-6abd21244763
# ╟─85a28180-62a3-4166-a252-b9bc6b56adc3
# ╠═97280a46-535a-4c5a-b3c4-8aa5dcf42cad
# ╠═4117d942-ff09-4e0c-b7ed-e4b8b2ae817e
# ╠═30a2186e-bad0-462e-804d-ee38b6589860
# ╠═005442ed-c527-424c-b2fc-f02ec2bafd9c
# ╟─ea6fe551-0a13-4c71-ba63-3bc872f3d8ab
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
