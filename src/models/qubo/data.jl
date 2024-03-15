BQPIO.backend(model::QUBO) = model.backend
BQPIO.model_name(model::AbstractBQPModel{<:BoolDomain}) = "QUBO"