using Test
using Printf
using BQPIO

# ~*~ Include test functions ~*~
include("tools/tools.jl")
include("models/models.jl")
include("bridges/bridges.jl")

function test_main(path::String, n::Integer)
    @testset ":: ~*~ BQPIO.jl ~*~ ::" verbose = true begin
        test_tools()
        test_models(path, n)
        test_bridges(path, n)
    end
end

test_main(@__DIR__, 2) # Here we go!