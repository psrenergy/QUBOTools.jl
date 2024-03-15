BQPIO.backend(model::StandardBQPModel) = model

BQPIO.getattr(model::StandardBQPModel, ::ATTR_OFFSET) = model.offset
BQPIO._defaultattr(::StandardBQPModel{<:Any,<:Any,T,<:Any}, ::ATTR_OFFSET) where {T} = zero(T)
BQPIO.getattr(model::StandardBQPModel, ::ATTR_SCALE) = model.scale
BQPIO._defaultattr(::StandardBQPModel{<:Any,<:Any,T,<:Any}, ::ATTR_SCALE) where {T} = one(T)
BQPIO.getattr(model::StandardBQPModel, ::ATTR_ID) = model.id
BQPIO._defaultattr(::StandardBQPModel, ::ATTR_ID) = 0
BQPIO.getattr(model::StandardBQPModel, ::ATTR_VERSION) = model.version
BQPIO._defaultattr(::StandardBQPModel, ::ATTR_VERSION) = v"1.0.0"
BQPIO.getattr(model::StandardBQPModel, ::ATTR_DESCRIPTION) = model.description
BQPIO._defaultattr(::StandardBQPModel, ::ATTR_DESCRIPTION) = ""
BQPIO.getattr(model::StandardBQPModel, ::ATTR_METADATA) = model.metadata
BQPIO._defaultattr(::StandardBQPModel, ::ATTR_METADATA) = Dict{String,Any}()
BQPIO.getattr(model::StandardBQPModel, ::ATTR_SAMPLESET) = model.sampleset
BQPIO._defaultattr(::StandardBQPModel{<:Any,U,T,<:Any}, ::ATTR_SAMPLESET) where {U,T} = SampleSet{U,T}()

BQPIO.linear_terms(model::StandardBQPModel) = model.linear_terms
BQPIO.quadratic_terms(model::StandardBQPModel) = model.quadratic_terms
BQPIO.variable_map(model::StandardBQPModel) = model.variable_map
BQPIO.variable_map(model::StandardBQPModel{V,<:Any,<:Any,<:Any}, v::V) where {V} = model.variable_map[v]
BQPIO.variable_inv(model::StandardBQPModel) = model.variable_inv
BQPIO.variable_inv(model::StandardBQPModel, i::Integer) = model.variable_inv[i]

function BQPIO.energy(state::Vector{U}, model::StandardBQPModel{<:Any,U,T,<:Any}) where {U,T}
    s = zero(T)

    for (i, l) in model.linear_terms
        s += state[i] * l
    end

    for ((i, j), q) in model.quadratic_terms
        s += state[i] * state[j] * q
    end

    return s
end