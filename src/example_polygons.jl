# Initialization of some simple polygons

function rectangle(x0::T, y0::T, x1::T, y1::T) where T
    bottomleft_corner = Point{T}(x0, y0)
    bottomright_corner = Point{T}(x1, y0)
    topright_corner = Point{T}(x1, y1)
    topleft_corner = Point{T}(x0, y1)
    ConvexPolygon{T}([bottomleft_corner, topleft_corner, topright_corner, bottomright_corner])
end
rectangle(bottom_left, top_right) = rectangle(bottom_left[1], bottom_left[2], top_right[1], top_right[2])
rectangle(; bottom_left, top_right) = rectangle(bottom_left, top_right)

square(bottom_left, side::Number) = rectangle(bottom_left[1], bottom_left[2], bottom_left[1] + side, bottom_left[2] + side)
square(; bottom_left, side) = square(bottom_left, side)

function circle(center, radius::Real, nb_sides::Int)
    sides = HalfPlane{Float64}[]
    for θ in reverse(LinRange(0.0, 2π, nb_sides+1)[1:nb_sides])
        push!(sides, PolarHalfPlane(-radius, θ, center=center))
    end
    polygon = ConvexPolygon{Float64}(Point{Float64}[])
    for i in 1:(nb_sides-1)
        push!(polygon.vertices, corner_point(sides[i], sides[i+1]))
    end
    push!(polygon.vertices, corner_point(sides[end], sides[1]))
    return polygon
end

circle(x0, y0, r, nb_sides) = circle(Point(x0, y0), r, nb_sides)
