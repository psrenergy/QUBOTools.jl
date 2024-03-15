using Documenter
using BQPIO

# Set up to run docstrings with jldoctest
DocMeta.setdocmeta!(
    BQPIO, :DocTestSetup, :(using BQPIO); recursive=true
)

makedocs(;
    modules=[BQPIO],
    doctest=true,
    clean=true,
    format=Documenter.HTML(
        assets = ["assets/extra_styles.css", "assets/favicon.ico"],
        mathengine=Documenter.MathJax2(),
        sidebar_sitename=false,
    ), 
    sitename="BQPIO.jl",
    authors="Pedro Xavier and Tiago Andrade and Joaquim Garcia and David Bernal",
    pages=[
        "Home" => "index.md",
        "manual.md",
        "examples.md",
    ],
    workdir="."
)

# deploydocs(
#     repo=raw"github.com/psrenergy/BQPIO.jl.git",
#     push_preview = true
# )