""" /src/interface/data.jl @ BQPIO.jl

    This files contains methods for data access within BQPIO's format system.
"""

@doc raw"""
    backend

""" function backend end

abstract type BQPAttribute end

function getattr(model::AbstractBQPModel, attr::BQPAttribute)
    BQPIO.getattr(BQPIO.backend(model), attr)
end

function getdefaultattr(model::AbstractBQPModel, attr::BQPAttribute)
    value = BQPIO.getattr(BQPIO.backend(model), attr)
    
    if isnothing(value)
        BQPIO._defaultattr(BQPIO.backend(model), attr)
    else
        value
    end
end

_defaultattr(::AbstractBQPModel, ::BQPAttribute) = nothing

struct ATTR_OFFSET <: BQPAttribute end

function offset(model::AbstractBQPModel)
    getdefaultattr(model, ATTR_OFFSET())
end

struct ATTR_SCALE <: BQPAttribute end

function scale(model::AbstractBQPModel)
    getdefaultattr(model, ATTR_SCALE())
end

struct ATTR_ID <: BQPAttribute end

function id(model::AbstractBQPModel)
    getdefaultattr(model, ATTR_ID())
end

struct ATTR_VERSION <: BQPAttribute end

function version(model::AbstractBQPModel)
    getdefaultattr(model, ATTR_VERSION())
end

struct ATTR_DESCRIPTION <: BQPAttribute end

function description(model::AbstractBQPModel)
    getdefaultattr(model, ATTR_DESCRIPTION())
end

struct ATTR_METADATA <: BQPAttribute end

function metadata(model::AbstractBQPModel)
    getdefaultattr(model, ATTR_METADATA())
end

struct ATTR_SAMPLESET <: BQPAttribute end

@doc raw"""
""" function sampleset end

function sampleset(model::AbstractBQPModel)
    getdefaultattr(model, ATTR_SAMPLESET())
end

@doc raw"""
""" function linear_terms end

function linear_terms(model::AbstractBQPModel)
    BQPIO.linear_terms(BQPIO.backend(model))
end

@doc raw"""
""" function quadratic_terms end

function quadratic_terms(model::AbstractBQPModel)
    BQPIO.quadratic_terms(BQPIO.backend(model))
end

@doc raw"""
""" function variables end

function variables(model::AbstractBQPModel)
    sort(collect(keys(BQPIO.variable_map(model))))
end

@doc raw"""
""" function variable_map end

function variable_map(model::AbstractBQPModel)
    BQPIO.variable_map(BQPIO.backend(model))
end

function variable_map(model::AbstractBQPModel, i::Any)
    BQPIO.variable_map(BQPIO.backend(model), i)
end

@doc raw"""
""" function variable_inv end

function variable_inv(model::AbstractBQPModel)
    BQPIO.variable_inv(BQPIO.backend(model))
end

function variable_inv(model::AbstractBQPModel, i::Integer)
    BQPIO.variable_inv(BQPIO.backend(model), i)
end

@doc raw"""

# QUBO Normal Form

```math
f(\vec{x}) = \alpha \left[{ \vec{x}'\,Q\,\vec{x} + \beta }\right]
```

""" function qubo end

function qubo(::Type{<:Dict}, model::AbstractBQPModel{D}) where {D<:BoolDomain}
    x = BQPIO.variable_map(model)
    Q = merge(
        Dict{Tuple{Int,Int},Float64}((i, i) => l for (i, l) in BQPIO.linear_terms(model)),
        BQPIO.quadratic_terms(model),
    )
    α = BQPIO.scale(model, 0.0)
    β = BQPIO.offset(model, 0.0)

    return (x, Q, α, β)
end

function qubo(::Type{<:Dict}, model::AbstractBQPModel{D}) where {D<:BoolDomain}
    x = BQPIO.variable_map(model)
    n = length(x)
    Q = zeros(x, n, n)
    α = BQPIO.scale(model)
    β = BQPIO.offset(model)

    for (i, qᵢ) in BQPIO.linear_terms(model)
        Q[i, i] = qᵢ
    end

    for ((i, j), qᵢⱼ) in BQPIO.quadratic_terms(model)
        Q[i, j] = qᵢⱼ
    end

    return (x, Q, α, β)
end


@doc raw"""

# Ising Normal Form

```math
H(\vec{s}) = \alpha \left[{ \vec{s}'\,J\,\vec{s} + \vec{h}\,\vec{s} + \beta }\right]
```

""" function ising end

function ising(::Type{<:Dict}, model::AbstractBQPModel{D}) where {D<:SpinDomain}
    s = BQPIO.variable_map(model)
    h = BQPIO.linear_terms(model)
    J = BQPIO.quadratic_terms(model)
    α = BQPIO.scale(model)
    β = BQPIO.offset(model)

    return (s, h, J, α, β)
end

function ising(::Type{<:Array}, model::AbstractBQPModel{D}) where {D<:SpinDomain}
    s = BQPIO.variable_map(model)
    n = length(s)
    h = zeros(Float64, n)
    J = zeros(Float64, n, n)
    α = BQPIO.scale(model)
    β = BQPIO.offset(model)

    for (i, hᵢ) in BQPIO.linear_terms(model)
        h[i] = hᵢ
    end

    for ((i, j), Jᵢⱼ) in BQPIO.quadratic_terms(model)
        J[i, j] = Jᵢⱼ
    end

    return (s, h, J, α, β)
end

@doc raw"""
    energy(state::Any, model::AbstractBQPModel)

This function aims to evaluate the energy of a given state under some BQP Model.
Scale and offset factors **are assumed** to be taken into account.
""" function energy end

function energy(state, model::AbstractBQPModel)
    energy(state, BQPIO.backend(model))
end