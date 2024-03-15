module BQPIO

using Printf
using JSON
using JSONSchema

export BoolDomain, SpinDomain
export StandardBQPModel
export BQPJSON
export Qubist
export QUBO
export MiniZinc

include("error.jl")
include("interface/model.jl")
include("interface/data.jl")
include("interface/io.jl")
include("tools.jl")

include("backend/sampleset.jl")
include("backend/model/model.jl")
include("backend/model/data.jl")
include("backend/model/io.jl")

include("models/bqpjson/model.jl")
include("models/bqpjson/data.jl")
include("models/bqpjson/io.jl")
include("models/hfs/model.jl")
include("models/hfs/data.jl")
include("models/hfs/io.jl")
include("models/minizinc/model.jl")
include("models/minizinc/data.jl")
include("models/minizinc/io.jl")
include("models/qubist/model.jl")
include("models/qubist/data.jl")
include("models/qubist/io.jl")
include("models/qubo/model.jl")
include("models/qubo/data.jl")
include("models/qubo/io.jl")

include("bridges/bqpjson_minizinc.jl")
include("bridges/bqpjson_qubist.jl")
include("bridges/bqpjson_qubo.jl")

end # module