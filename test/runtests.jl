using Test
using Printf
using SparseArrays
using RecipesBase
using QUBOTools

const __TEST_PATH__ = @__DIR__

# Include assets
include("assets/comparison.jl")

# Include test functions
include("unit/unit.jl")

function test_main()
    @testset "◈ ◈ ◈ QUBOTools.jl Test Suite ◈ ◈ ◈" verbose = true begin
        test_unit()
    end
end

test_main() # Here we go!
