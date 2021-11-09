module PolygonArea

# IMPORT/EXPORT
using StaticArrays

import Base.==, Base.isapprox
import Base.in, Base.isempty
import Base.union, Base.intersect, Base.\
import Base.convert, Base.promote_rule
import Base.show

export HalfPlane, ConvexPolygon
export rectangle, circle, area

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

# Curried functions
rotate(ϕ::Number; kw...) = x -> rotate(x, ϕ; kw...)

const _VectorLike = Union{SVector{2, T}, Vector{T}} where T
translate(v::_VectorLike) = x -> translate(x, v)
scale(v::Union{Real, _VectorLike}) = x -> scale(x, v)

end # module
