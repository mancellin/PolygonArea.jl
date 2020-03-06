module PolygonArea

# DEPENDENCIES
using StaticArrays
import Base.in, Base.intersect, Base.union

# MAIN TYPES
abstract type Surface end

const Point = SVector{2, Float64}

struct Intersection{T} <: Surface
    hs::Vector{T}
end

struct Reunion{T} <: Surface
    hs::Vector{T}
end

# CODE
include("half_planes.jl")
include("polygons.jl")
include("unions_and_intersections.jl")
include("plot_recipes.jl")

export HalfPlane, invert
export rectangle, area

end # module
