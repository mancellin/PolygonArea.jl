# Initialization of some simple polygons

function rectangle(x0::T, y0::T, x1::T, y1::T) where T
    left = HalfPlane(-one(T), zero(T), x0)
    right = HalfPlane(one(T), zero(T), -x1)
    bottom = HalfPlane(zero(T), -one(T), y0)
    top = HalfPlane(zero(T), one(T), -y1)
	bottomleft_corner = Point(x0, y0)
	bottomright_corner = Point(x1, y0)
	topright_corner = Point(x1, y1)
	topleft_corner = Point(x0, y1)
	ConvexPolygon([(left, bottomleft_corner, bottom), (bottom, bottomright_corner, right),
				   (right, topright_corner, top), (top, topleft_corner, left)])
end
rectangle(bottom_left, top_right) = rectangle(bottom_left[1], bottom_left[2], top_right[1], top_right[2])
rectangle(; bottom_left, top_right) = rectangle(bottom_left, top_right)

square(bottom_left, side::Number) = rectangle(bottom_left[1], bottom_left[2], bottom_left[1] + side, bottom_left[2] + side)
square(; bottom_left, side) = square(bottom_left, side)

function circle(center, radius::Real, nb_sides::Int)
    sides = HalfPlane{Float64}[]
    for θ in LinRange(0.0, 2π, nb_sides+1)[1:nb_sides]
        push!(sides, PolarHalfPlane(-radius, θ, center=center))
    end
    polygon = Corner{Float64}[]
    for i in 1:(nb_sides-1)
        push!(polygon, (sides[i], corner(sides[i], sides[i+1]), sides[i+1]))
    end
    push!(polygon, (sides[end], corner(sides[end], sides[1]), sides[1]))
    return ConvexPolygon{Float64}(polygon)
end

circle(x0, y0, r, nb_sides) = circle(Point(x0, y0), r, nb_sides)
