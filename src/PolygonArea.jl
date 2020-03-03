module PolygonArea

# DEPENDENCIES
using StaticArrays
import Base.in, Base.intersect, Base.union

# MAIN TYPES
abstract type Surface end

struct Intersection{T} <: Surface
    hs::Vector{T}
end

struct Reunion{T} <: Surface
    hs::Vector{T}
end

const Point = SVector{2, Float64}

# CODE
include("half_planes.jl")
include("polygons.jl")

export HalfPlane, invert
export rectangle, area

end # module
