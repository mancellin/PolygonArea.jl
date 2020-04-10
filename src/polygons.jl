##############
#  Polygons  #
##############

const Corner = Tuple{HalfPlane, Point, HalfPlane}

struct ConvexPolygon <: Surface
	corners::Vector{Corner}
end

function rectangle(x0, y0, x1, y1)
	left = HalfPlane(-1, 0, x0)
	right = HalfPlane(1, 0, -x1)
	bottom = HalfPlane(0, -1, y0)
	top = HalfPlane(0, 1, -y1)
	bottomleft_corner = Point(x0, y0)
	bottomright_corner = Point(x1, y0)
	topright_corner = Point(x1, y1)
	topleft_corner = Point(x0, y1)
	ConvexPolygon([(left, bottomleft_corner, bottom), (bottom, bottomright_corner, right),
				   (right, topright_corner, top), (top, topleft_corner, left)])
end

function circle(center::Point, radius::Real, nb_sides::Int)
    sides = HalfPlane[]
    for θ in LinRange(0.0, 2π, nb_sides)
        push!(sides, PolarHalfPlane(-radius, θ, center=center))
    end
    polygon = Corner[]
    for i in 1:(nb_sides-1)
        push!(polygon, (sides[i], corner(sides[i], sides[i+1]), sides[i+1]))
    end
    push!(polygon, (sides[end], corner(sides[end], sides[1]), sides[1]))
    return ConvexPolygon(polygon)
end

circle(x0, y0, r, nb_sides) = circle(Point(x0, y0), r, nb_sides)

convert(::Type{Intersection{HalfPlane}}, p::ConvexPolygon) = Intersection{HalfPlane}([c[1] for c in p.corners])
convert(::Type{Reunion{Intersection{HalfPlane}}}, c::ConvexPolygon) = convert(Reunion{Intersection{HalfPlane}}, convert(Intersection{HalfPlane}, c))

show(io::IO, p::ConvexPolygon) = print(io, "ConvexPolygon with $(length(p.corners)) sides")

nb_vertices(p::ConvexPolygon) = length(p.corners)
nb_edges(p::ConvexPolygon) = length(p.corners)

vertices(p::ConvexPolygon) = [c[2] for c in p.corners]
edges(p::ConvexPolygon) = [c[1] for c in p.corners]
center(p::ConvexPolygon) = (v = vertices(p); sum(v)/length(v))

isempty(p::ConvexPolygon) = length(p.corners) <= 2

in(p::Point, c::ConvexPolygon) = in(p, convert(Intersection{HalfPlane}, c))

function cut(e::HalfPlane, h::HalfPlane)
	new_vertex = corner(e, h)
    return ((e, new_vertex, h), (invert(h), new_vertex, e))
end

"""Returns the couple of ConvexPolygon obtained by cutting c by the plane h."""
function cut(c::ConvexPolygon, h::HalfPlane)
	inside = map(v -> (v in h), vertices(c))
	if all(inside)  # The whole polygon is inside the half-space
        return (c, ConvexPolygon([]))
	elseif !(any(inside))  # The whole polygon is outside the half-space
        return (ConvexPolygon([]), c)
	else  # The half-space instersects the polygon
        corners = copy(c.corners)
		while !inside[1]
			inside = circshift(inside, 1)
			corners = circshift(corners, 1)
		end

		first_out = findfirst(.!inside)
        intersected_edge = corners[first_out][1]
		new_corner_in_1, new_corner_out_1 = cut(intersected_edge, h)

		last_out = findlast(.!inside)
        other_intersected_edge = corners[last_out][3]
        new_corner_out_2, new_corner_in_2 = cut(other_intersected_edge, invert(h))

        return (
                ConvexPolygon(vcat(
                                   corners[1:first_out-1],
                                   [new_corner_in_1, new_corner_in_2],
                                   corners[last_out+1:end]
                                   )),
                ConvexPolygon(vcat(
                                   corners[first_out:last_out],
                                   [new_corner_out_2, new_corner_out_1],
                                   )),
               )
    end
end

function cut(c::ConvexPolygon, i::Intersection)
	rests = []
	for h in i.content
		c, rest = cut(c, h)
		push!(rests, rest)
		if isempty(c)
			break
		end
	end
	return c, foldl(union, rests)
end

function cut(c::ConvexPolygon, u::Reunion)
    polys = []
    for h in u.content
        poly, c = cut(c, h)
		push!(polys, poly)
		if isempty(c)
			break
		end
    end
    return foldl(union, polys), c 
end

intersect(c::ConvexPolygon, h::HalfPlane) = cut(c, h)[1]
intersect(c::ConvexPolygon, i::Intersection{HalfPlane}) = cut(c, i)[1]
intersect(c1::ConvexPolygon, c2::ConvexPolygon) = intersect(c1, convert(Intersection{HalfPlane}, c2))

intersect(c::ConvexPolygon, u::Reunion{HalfPlane}) = cut(c, u)[1]
intersect(c::ConvexPolygon, ui::Reunion{Intersection{HalfPlane}}) = cut(c, ui)[1]

intersect(s::Surface, c::ConvexPolygon) = intersect(c, s)

function area(c::ConvexPolygon)
	if isempty(c)
		return 0.0
	else
		v = vertices(c)
		x = [xy[1] for xy in v]
		y = [xy[2] for xy in v]
		return abs(  sum(x[1:end-1] .* y[2:end]) + x[end]*y[1]
				   - sum(x[2:end] .* y[1:end-1]) - x[1]*y[end]
				  )/2
	end
end

# REUNION OF CONVEX POLYGONS

convert(::Type{Reunion{ConvexPolygon}}, c::ConvexPolygon) = Reunion{ConvexPolygon}([c])
convert(::Type{Reunion{Intersection{HalfPlane}}}, u::Reunion{ConvexPolygon}) = Reunion{Intersection{HalfPlane}}(map(c -> convert(Intersection{HalfPlane}, c), u.content))

promote_rule(::Type{ConvexPolygon}, ::Type{Reunion{ConvexPolygon}}) = Reunion{ConvexPolygon}

function cut(cs::Reunion{ConvexPolygon}, h)
    polys = ConvexPolygon([])
    rests = ConvexPolygon([])
    for c in cs.content
        poly, rest = cut(c, h)
        polys = polys ∪ poly
        rests = rests ∪ rest
    end
    return polys, rests
end

union(c1::ConvexPolygon, c2::ConvexPolygon) = Reunion{ConvexPolygon}([c1, c2])
union(u1::Reunion{ConvexPolygon}, u2::Reunion{ConvexPolygon}) = Reunion{ConvexPolygon}(vcat(u1.content, u2.content))

intersect(u::Reunion{ConvexPolygon}, c::ConvexPolygon) = intersect(u, convert(Intersection{HalfPlane}, c))
intersect(u1::Reunion{ConvexPolygon}, u2::Reunion{ConvexPolygon}) = intersect(u1, convert(Reunion{Intersection{HalfPlane}}, u2))
intersect(u::Reunion{ConvexPolygon}, h::Surface) = foldl(union, (p ∩ h for p in u.content))
intersect(h::Surface, u::Reunion{ConvexPolygon}) = intersect(u, h)

area(u::Reunion{ConvexPolygon}) = isempty(u) ? 0.0 : sum(area(c) for c in u.content)  # WARNING: suppose disjoint union!
