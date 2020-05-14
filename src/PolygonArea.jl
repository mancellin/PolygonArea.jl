module PolygonArea

# IMPORT/EXPORT
using StaticArrays

import Base.in
import Base.isempty
import Base.show
import Base.isapprox

export HalfPlane, PolarHalfPlane
export invert, area
export rectangle, circle

# TYPES
abstract type Surface end

const Point = SVector{2, Float64}

# CODE
include("half_planes.jl")
include("unions_and_intersections.jl")
include("polygons.jl")
include("plot_recipes.jl")

end # module
