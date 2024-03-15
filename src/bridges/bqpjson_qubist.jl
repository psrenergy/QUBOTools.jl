function Base.convert(::Type{<:Qubist}, model::BQPJSON{BoolDomain})
    convert(Qubist{SpinDomain}, convert(BQPJSON{SpinDomain}, model))
end

function Base.convert(::Type{<:Qubist}, model::BQPJSON{SpinDomain})
    backend = copy(BQPIO.backend(model))
    sites = if isempty(BQPIO.variable_map(backend))
        0
    else
        1 + maximum(keys(BQPIO.variable_map(backend)))
    end
    lines = length(BQPIO.linear_terms(backend)) + length(BQPIO.quadratic_terms(backend))

    Qubist{SpinDomain}(
        backend;
        sites=sites,
        lines=lines
    )
end

function BQPIO.__isvalidbridge(
    source::BQPJSON{SpinDomain},
    target::BQPJSON{SpinDomain},
    ::Type{<:Qubist};
    kws...
)
    BQPIO.__isvalidbridge(
        BQPIO.backend(source),
        BQPIO.backend(target);
        kws...
    )
end

function Base.convert(::Type{<:BQPJSON{BoolDomain}}, model::Qubist)
    convert(BQPJSON{BoolDomain}, convert(BQPJSON{SpinDomain}, model))
end

function Base.convert(::Type{<:BQPJSON{SpinDomain}}, model::Qubist)
    backend = copy(BQPIO.backend(model))
    solutions = nothing

    BQPJSON{SpinDomain}(backend; solutions=solutions)
end

function BQPIO.__isvalidbridge(
    source::Qubist{SpinDomain},
    target::Qubist{SpinDomain},
    ::Type{<:BQPJSON{SpinDomain}};
    kws...
)
    BQPIO.__isvalidbridge(
        BQPIO.backend(source),
        BQPIO.backend(target);
        kws...
    )
end