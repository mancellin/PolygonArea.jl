module PolygonArea

# IMPORT/EXPORT
using StaticArrays

import Base.==
import Base.in
import Base.isempty
import Base.show
import Base.isapprox

export HalfPlane, PolarHalfPlane
export invert, area
export rectangle, circle

# TYPES
abstract type Surface end

# CODE
include("points.jl")
include("half_planes.jl")
include("unions_and_intersections.jl")
include("polygons.jl")
include("example_polygons.jl")
include("plot_recipes.jl")

end # module
