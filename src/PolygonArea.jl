module PolygonArea

# IMPORT/EXPORT
using StaticArrays

import Base.==, Base.isapprox
import Base.in, Base.isempty
import Base.union, Base.intersect, Base.\
import Base.convert, Base.promote_rule
import Base.show

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

include("io.jl")
include("plot_recipes.jl")

rotate(ϕ::Number; kw...) = x -> rotate(x, ϕ; kw...)
translate(v::SVector{2, Float64}) = x -> translate(x, v)

end # module
