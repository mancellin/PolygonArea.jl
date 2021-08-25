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

```julia
julia> using PolygonArea

julia> r = rectangle(0.0, 0.0, 1.0, 1.0)
ConvexPolygon with 4 sides

julia> c = circle(0.9, 0.9, 0.6, 100)
ConvexPolygon with 100 sides

julia> area(r ∩ c)
0.41229971200585536

julia> using Plots
[ Info: Precompiling Plots [91a5bcdd-55d7-5caf-9e0b-520d859cae80]

julia> plot(r ∩ c)
```

## Alternative software

You might also be interested in more optimized and more tested packages of the [JuliaPolyhedra organization](https://juliapolyhedra.github.io/).

## Credits

MIT License, 2020-2021, Matthieu Ancellin.
