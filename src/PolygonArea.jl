module PolygonArea

# DEPENDENCIES
using StaticArrays
import Base.in

# MAIN TYPES
abstract type Surface end

const Point = SVector{2, Float64}

# CODE
include("half_planes.jl")
include("unions_and_intersections.jl")
include("polygons.jl")
include("plot_recipes.jl")

export HalfPlane, invert
export rectangle, area

end # module
