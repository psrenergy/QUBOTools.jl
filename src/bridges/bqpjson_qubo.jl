function Base.convert(::Type{BQPJSON{SpinDomain}}, model::QUBO)
    convert(BQPJSON{SpinDomain}, convert(BQPJSON{BoolDomain}, model))
end

function Base.convert(::Type{BQPJSON{BoolDomain}}, model::QUBO)
    backend = copy(model.backend)
    solutions = nothing

    BQPJSON{BoolDomain}(backend; solutions=solutions)
end

function BQPIO.__isvalidbridge(
    source::BQPJSON{BoolDomain},
    target::BQPJSON{BoolDomain},
    ::Type{<:QUBO{BoolDomain}};
    kws...
)
    BQPIO.__isvalidbridge(
        BQPIO.backend(source),
        BQPIO.backend(target);
        kws...
    )
end

function Base.convert(::Type{<:QUBO}, model::BQPJSON{SpinDomain})
    convert(QUBO{BoolDomain}, convert(BQPJSON{BoolDomain}, model))
end

function Base.convert(::Type{<:QUBO}, model::BQPJSON{BoolDomain})
    backend = copy(model.backend)
    max_index = if isempty(BQPIO.variable_map(backend))
        0
    else
        1 + maximum(keys(BQPIO.variable_map(backend)))
    end
    num_diagonals = length(BQPIO.linear_terms(backend))
    num_elements = length(BQPIO.quadratic_terms(backend))

    QUBO{BoolDomain}(
        backend;
        max_index=max_index,
        num_diagonals=num_diagonals,
        num_elements=num_elements
    )
end

function BQPIO.__isvalidbridge(
    source::QUBO{BoolDomain},
    target::QUBO{BoolDomain},
    ::Type{<:BQPJSON{BoolDomain}};
    kws...
)
    BQPIO.__isvalidbridge(
        BQPIO.backend(source),
        BQPIO.backend(target);
        kws...
    )
end