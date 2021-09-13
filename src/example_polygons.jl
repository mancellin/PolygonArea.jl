# Initialization of some simple polygons

function rectangle(x0::T, y0::T, x1::T, y1::T) where T
    bottomleft_corner = Point{T}(x0, y0)
    bottomright_corner = Point{T}(x1, y0)
    topright_corner = Point{T}(x1, y1)
    topleft_corner = Point{T}(x0, y1)
    ConvexPolygon{T}([bottomleft_corner, topleft_corner, topright_corner, bottomright_corner])
end
rectangle(x0, y0, x1, y1) = rectangle(promote(x0, y0, x1, y1)...)
rectangle(bottom_left, top_right) = rectangle(bottom_left[1], bottom_left[2], top_right[1], top_right[2])
rectangle(; bottom_left, top_right) = rectangle(bottom_left, top_right)

square(bottom_left, side::Number) = rectangle(bottom_left[1], bottom_left[2], bottom_left[1] + side, bottom_left[2] + side)
square(; bottom_left, side) = square(bottom_left, side)


function circle(x0::T, y0::T, radius::T, nb_vertices::Int) where T
    vertices = [Point{T}(x0 + radius*cos(θ), y0 - radius*sin(θ)) for θ in LinRange(0.0, 2π, nb_vertices+1)[1:nb_vertices]]
    return ConvexPolygon(vertices)
end

circle(x0, y0, r, nb_vertices) = circle(promote(x0, y0, r)..., nb_vertices)
circle(center::Union{Point, Tuple}, r, nb_sides) = circle(center[1], center[2], r, nb_sides)

function circle(center::Point, point::Point, nb_vertices::Int)
    radius = sqrt((point1[1] - center[1])^2 + (point1[2] - center[2])^2)
    return circle(center, radius, nb_vertices)
end

function circle(point1::Point, point2::Point, curvature::Real, nb_vertices::Int)
    radius = 1.0/curvature
    distance_between_points = sqrt((point2[1] - point1[1])^2 + (point2[2] - point1[2])^2)
    n = (point2 - point1) / distance_between_points
    on_median = sqrt(radius^2 - (distance_between_points/2)^2)
    n_ortho = SVector(n[2], -n[1])
    center = point1 + distance_between_points/2 * n + on_median * n_ortho
    return circle(center, radius, nb_vertices)
end
