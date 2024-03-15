function Base.convert(::Type{<:StandardBQPModel{S,U,T,D}}, model::StandardBQPModel{S,U,T,D}) where {S,U,T,D}
    model # Short-circuit! Yeah!
end

function Base.convert(::Type{<:StandardBQPModel{S,U,T,B}}, model::StandardBQPModel{S,U,T,A}) where {S,U,T,A,B}
    _linear_terms, _quadratic_terms, offset = _swapdomain(
        A,
        B,
        model.linear_terms,
        model.quadratic_terms,
        model.offset,
    )

    linear_terms, quadratic_terms, _ = BQPIO._normal_form(
        _linear_terms,
        _quadratic_terms,
    )

    StandardBQPModel{S,U,T,B}(
        linear_terms,
        quadratic_terms,
        copy(model.variable_map),
        copy(model.variable_inv);
        sense=model.sense,
        scale=model.scale,
        offset=offset,
        id=model.id,
        version=model.version,
        description=model.description,
        metadata=deepcopy(model.metadata),
        sampleset=model.sampleset
    )
end

# function Base.read end
# function Base.write end

function Base.copy!(
    target::StandardBQPModel{S,U,T,D},
    source::StandardBQPModel{S,U,T,D},
) where {S,U,T,D<:VariableDomain}
    target.linear_terms = copy(source.linear_terms)
    target.quadratic_terms = copy(source.quadratic_terms)
    target.variable_map = copy(source.variable_map)
    target.variable_inv = copy(source.variable_inv)
    target.sense = source.sense
    target.scale = source.scale
    target.offset = source.offset
    target.id = source.id
    target.version = source.version
    target.description = source.description
    target.metadata = deepcopy(source.metadata)
    target.sampleset = source.sampleset

    target
end

function Base.copy!(
    target::StandardBQPModel{S,U,T,B},
    source::StandardBQPModel{S,U,T,A},
) where {S,U,T,A<:VariableDomain,B<:VariableDomain}
    copy!(target, convert(StandardBQPModel{S,U,T,B}, source))
end