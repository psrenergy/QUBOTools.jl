# -*- :: Domains :: -*- #
abstract type VariableDomain end

@doc raw"""
""" struct SpinDomain <: VariableDomain end
@doc raw"""
""" struct BoolDomain <: VariableDomain end

# -*- :: Models :: -*- #
abstract type AbstractBQPModel{D <: VariableDomain} end

# -*- :: Functions :: -*- #
@doc raw"""
""" function domain end

domain(::AbstractBQPModel{D})         where D <: VariableDomain = D
domain(::Type{<:AbstractBQPModel{D}}) where D <: VariableDomain = D

# -*- :: Interface :: -*- #
function Base.isvalid(::AbstractBQPModel)
    false
end

function Base.isapprox(::AbstractBQPModel, ::AbstractBQPModel; kw...)
    false
end

function Base.:(==)(::AbstractBQPModel, ::AbstractBQPModel)
    false
end

function Base.read(::IO, M::Type{<:AbstractBQPModel})
    error("'Base.read' not implemented for model of type '$(M)'")
end

function Base.write(::IO, m::AbstractBQPModel)
    error("'Base.write' not implemented for model of type '$(typeof(m))'")
end

function Base.convert(M::Type{<:AbstractBQPModel}, m::AbstractBQPModel)
    error("'Base.convert' not implemented for turning model of type '$(typeof(m))' into $(M)")
end

function Base.read(path::AbstractString, M::Type{<:AbstractBQPModel})
    open(path, "r") do io
        return read(io, M)
    end
end

function Base.write(path::AbstractString, M::Type{<:AbstractBQPModel})
    open(path, "w") do io
        return write(io, M)
    end
end