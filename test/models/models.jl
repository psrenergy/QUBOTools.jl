include("backend.jl")
include("bqpjson.jl")
include("minizinc.jl")
include("qubist.jl")
include("qubo.jl")

function test_models(path::String, n::Integer)
    @testset "-*- Models -*-" verbose = true begin
        test_backend(path, n)
        test_bqpjson(path, n)
        test_minizinc(path, n)
        test_qubist(path, n)
        test_qubo(path, n)
    end
end