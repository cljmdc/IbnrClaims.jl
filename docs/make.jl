using Documenter
using IbnrClaims

makedocs(
    sitename = "IbnrClaims",
    format = Documenter.HTML(),
    modules = [IbnrClaims],
    pages=[
        "Home" => "index.md",
    ],
    authors="Jose Diaz"
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#

deploydocs(
    repo = "github.com/cljmdc/IbnrClaims.jl.git"
)