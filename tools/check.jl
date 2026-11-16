#!/usr/bin/env julia
#=
Usage (from exercism-julia root):
  julia --project=. tools/check.jl <exercise> [--fmt] [--jet] [--no-test]

Runs:
  1. Syntax check (`Meta.parseall`) on all `.jl` files in `<exercise>/` (excluding `archive/`)
  2. Formatting check via `JuliaFormatter` (pass `--fmt` to format in-place)
  3. Static analysis via `JET.report_file` (when `--jet` is passed)
  4. Test suite (`<exercise>/runtests.jl`, unless `--no-test` is passed)
=#

using JuliaFormatter

function parse_args(args::Vector{String})
    flags = Set(a for a in args if startswith(a, "--"))
    pos = [a for a in args if !startswith(a, "--")]
    isempty(pos) && error("Usage: julia --project=. tools/check.jl <exercise> [--fmt] [--jet] [--no-test]")
    return (
        exercise = pos[1],
        fmt = "--fmt" in flags,
        jet = "--jet" in flags,
        test = !("--no-test" in flags),
    )
end

function collect_jl_files(ex_dir::String)
    files = String[]
    for (root, dirs, fnames) in walkdir(ex_dir)
        filter!(d -> d != "archive" && !startswith(d, "."), dirs)
        for f in sort(fnames)
            endswith(f, ".jl") && push!(files, joinpath(root, f))
        end
    end
    return files
end

function check_syntax(files::Vector{String})
    println("==> 1. Syntax check")
    for f in files
        Meta.parseall(read(f, String); filename = f)
        println("  OK: ", relpath(f))
    end
end

function check_format(files::Vector{String}; overwrite::Bool)
    println(overwrite ? "==> 2. Formatting in-place (JuliaFormatter)" : "==> 2. Format check (JuliaFormatter)")
    all_formatted = true
    for f in files
        ok = format_file(f; overwrite = overwrite, indent = 4)
        if !overwrite && !ok
            println("  NEEDS FORMAT: ", relpath(f))
            all_formatted = false
        else
            println("  OK: ", relpath(f))
        end
    end
    !overwrite && !all_formatted && println("  Tip: re-run with --fmt to format in-place.")
    return all_formatted
end

function run_jet_check(ex_dir::String, exercise::String)
    println("==> 3. Static analysis (JET)")
    @eval using JET
    main_file = joinpath(ex_dir, replace(exercise, "-" => "_") * ".jl")
    if !isfile(main_file)
        main_file = joinpath(ex_dir, exercise * ".jl")
    end
    if isfile(main_file)
        res = @eval JET.report_file($main_file; toplevel_logger = nothing)
        println("  Checked: ", relpath(main_file))
    else
        println("  Skipped (no main file found for $exercise)")
    end
end

function run_tests(ex_dir::String)
    test_file = joinpath(ex_dir, "runtests.jl")
    isfile(test_file) || error("Missing test file: $test_file")
    println("==> 4. Running tests: ", relpath(test_file))
    cd(ex_dir) do
        m = Module(:ExerciseTest)
        Base.eval(m, :(include(p::AbstractString) = Base.include($m, p)))
        Base.include(m, test_file)
    end
end

function main()
    opts = parse_args(ARGS)
    repo_root = dirname(@__DIR__)
    ex_dir = isdir(opts.exercise) ? abspath(opts.exercise) : joinpath(repo_root, opts.exercise)
    isdir(ex_dir) || error("Exercise directory not found: $ex_dir")

    files = collect_jl_files(ex_dir)
    isempty(files) && error("No .jl files found in $ex_dir")

    check_syntax(files)
    fmt_ok = check_format(files; overwrite = opts.fmt)
    opts.jet && run_jet_check(ex_dir, basename(ex_dir))
    opts.test && run_tests(ex_dir)

    if !opts.fmt && !fmt_ok
        exit(1)
    end
end

main()
