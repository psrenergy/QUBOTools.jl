struct CHIMERA_CELL_SIZE <: BQPAttribute end

BQPIO._defaultattr(::HFS, ::CHIMERA_CELL_SIZE) = 8

struct CHIMERA_PRECISION <: BQPAttribute end

BQPIO._defaultattr(::HFS, ::CHIMERA_PRECISION) = 5