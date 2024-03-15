# ~*~ I/O ~*~ #
function Base.read(::IO, M::Type{<:AbstractBQPModel})
    bqpcodec_error("'Base.read' not implemented for model of type '$(M)'")
end

function Base.read(path::AbstractString, M::Type{<:AbstractBQPModel})
    open(path, "r") do io
        return read(io, M)
    end
end

function Base.write(::IO, model::AbstractBQPModel)
    bqpcodec_error("'Base.write' not implemented for model of type '$(typeof(model))'")
end

function Base.write(path::AbstractString, model::AbstractBQPModel)
    open(path, "w") do io
        return write(io, model)
    end
end

function Base.convert(M::Type{<:AbstractBQPModel}, model::AbstractBQPModel)
    bqpcodec_error("'Base.convert' not implemented for turning model of type '$(typeof(model))' into $(M)")
end

function Base.convert(::Type{M}, model::M) where {M<:AbstractBQPModel}
    model # Short-circuit! Yeah!
end

function Base.show(io::IO, model::AbstractBQPModel)
    print(
        io,
        """
        $(BQPIO.model_name(model)) Model:
        $(BQPIO.domain_size(model)) variables [$(BQPIO.domain_name(model))]

        Density:
        linear    ~ $(@sprintf("%0.2f", 100.0 * BQPIO.linear_density(model)))%
        quadratic ~ $(@sprintf("%0.2f", 100.0 * BQPIO.quadratic_density(model)))%
        total     ~ $(@sprintf("%0.2f", 100.0 * BQPIO.density(model)))%
        """
    )
end

function Base.copy!(::M, ::M) where {M<:AbstractBQPModel}
    bqpcodec_error("'Base.copy!' not implemented for copying '$M' in-place")
end

function Base.copy!(
    target::X,
    source::Y,
) where {X<:AbstractBQPModel,Y<:AbstractBQPModel}
    copy!(target, convert(typeof(target), source))
end