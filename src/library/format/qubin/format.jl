@doc raw"""
    QUBin()

HDF5-based reference format for storing QUBOTools models and solutions.
"""
struct QUBin <: AbstractFormat end

# Hints:
format(::Val{:hdf5}) = QUBin()
format(::Val{:h5})   = QUBin()
format(::Val{:qb})   = QUBin()

include("parser.jl")
include("printer.jl")
