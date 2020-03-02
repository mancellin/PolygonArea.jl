module PolygonArea

using StaticArrays

import Base.in, Base.intersect, Base.union

abstract type Surface end

struct Intersection{T} <: Surface
    hs::Vector{T}
end

struct Reunion{T} <: Surface
    hs::Vector{T}
end

include("half_planes.jl")
export HalfPlane
export intersect, union, invert

##############
#  Polygons  #
##############

struct ConvexPolygon <: Surface
    h::Intersection{HalfPlane}
    v::Vector{SVector{2, Float64}}
end

function rectangle(x0, y0, x1, y1)
    ConvexPolygon(
                  Intersection{HalfPlane}([HalfPlane(-1, 0, x0), HalfPlane(1, 0, -x1), 
                                           HalfPlane(0, -1, y0), HalfPlane(0, 1, -y1)]),
                  map(SVector{2, Float64}, [[x0, y0], [x1, y0], [x1, y1], [x0, y1]])
                 ) 
end

Base.in(p::Tuple, c::ConvexPolygon) = p in c.h

function Base.intersect(c::ConvexPolygon, h::HalfPlane)
    inout = map(p -> (p in h), c.v)
    println(inout)
    new_v = c.v
    return ConvexPolygon(intersect(c.h, h), new_v)
end

#= corners = Set(corner(h1, h2) for h1 in h.hs for h2 in h.hs) =#
#= corners = filter(is_finite, corners) =# 
#= corners = filter(p -> (p in h), corners) =#

#= is_finite(x::SVector) = (-Inf < x[1] < Inf) && (-Inf < x[2] < Inf) =#

function area(h::ConvexPolygon)
    x = [xy[1] for xy in h.v]
    y = [xy[2] for xy in h.v]
    return abs(  sum(x[1:end-1] .* y[2:end]) + x[end]*y[1]
               - sum(x[2:end] .* y[1:end-1]) - x[1]*y[end]
              )/2
end

export rectangle, area

end # module
