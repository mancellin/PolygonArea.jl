# PolygonArea

A minimalistic generic Julia package to compute the area of unions and intersections of polygons.

Features:
* Pure Julia with almost no dependancies,
* Generic types (coordinates can be floats, rational numbers or anything else),
* Compatible with ForwardDiff.jl,
* Non-convex polygons are supported as union of convex polygons,
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

julia> c = circle((0.9, 0.9), 0.6, 100)  # Actually, a regular 100-gon
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

### Autodiff

```julia
julia> A(r) = area(circle((0.0, 0.0), r, 100))
A (generic function with 1 method)

julia> (r=rand(); isapprox(A(r), π*r^2, atol=1e-2))
true

julia> using ForwardDiff

julia> p(r) = ForwardDiff.derivative(A, r)
p (generic function with 1 method)

julia> (r=rand(); isapprox(p(r), 2*π*r, atol=1e-2))
true
```

## Alternative software

You might also be interested in more optimized and more tested packages of the [JuliaPolyhedra organization](https://juliapolyhedra.github.io/).

## Credits

MIT License, 2020-2021, Matthieu Ancellin.
