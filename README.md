# PolygonArea

A claimless Julia package to compute the area of unions and intersections of polygons.

Features:
* Pure Julia with no dependancies.
* Generic types (coordinates can be floats, rational numbers or anything else).
* Non-convex polygons are supported (as union of convex polygons).
* Plot the polygons with Plots.jl.

## Installation

```
] add https://github.com/mancellin/PolygonArea.jl
```

## Example

### Intersection of a square and a circle

```julia
julia> using PolygonArea

julia> r = rectangle((0.0, 0.0), (1.0, 1.0))
ConvexPolygon{Float64} with 4 vertices
[...]

julia> c = circle((0.9, 0.9), 0.6, 100)
ConvexPolygon{Float64} with 100 vertices
[...]

julia> area(r ∩ c)
0.41229971200585397

julia> using Plots

julia> plot(r ∩ c)
```

### Rational coordinates

```julia
julia> r2 = rectangle((0//1, 0//1), (1//1, 1//1))
ConvexPolygon{Rational{Int}} with 4 vertices
[...]

julia> r3 = rectangle((1//3, 1//3), (4//3, 4//3))
ConvexPolygon{Rational{Int}} with 4 vertices
[...]

julia> area(r2 ∩ r3)
4//9
```

## Alternative software

You might also be interested in more optimized and more tested packages of the [JuliaPolyhedra organization](https://juliapolyhedra.github.io/).

## Credits

MIT License, 2020-2021, Matthieu Ancellin.
