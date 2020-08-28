using Documenter, FilesLH

makedocs(
    modules = [FilesLH],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "hendri54",
    sitename = "FilesLH",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

pkgDir = rstrip(normpath(@__DIR__, ".."), '/');
@assert endswith(pkgDir, "FilesLH")
deploy_docs(pkgDir);

# deploydocs(
#     repo = "github.com/hendri54/FilesLH.jl.git",
# )
