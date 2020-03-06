##############
#  Polygons  #
##############

const Corner = Tuple{HalfPlane, Point, HalfPlane}

struct ConvexPolygon <: Surface
	data::Vector{Corner}
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

as_intersection_of_halfplanes(c::ConvexPolygon) = Intersection{HalfPlane}([corner[1] for corner in c.data])

vertices(c::ConvexPolygon) = [corner[2] for corner in c.data]
center(c::ConvexPolygon) = (v = vertices(c); sum(v)/length(v))

isempty(c::ConvexPolygon) = length(c.data) == 0

in(p::Point, c::ConvexPolygon) = p in as_intersection_of_halfplanes(c)

function intersect(c::ConvexPolygon, h::HalfPlane)
	inside = map(p -> (p in h), vertices(c))
	if all(inside)  # The whole polygon is inside the half-space
		return c
	elseif !(any(inside))  # The whole polygon is outside the half-space
		return ConvexPolygon([])
	else  # The half-space instersects the polygon
		data = c.data
		while !inside[1]
			inside = circshift(inside, 1)
			data = circshift(data, 1)
		end
		first_out = findfirst(.!inside)
		new_corner_1 = corner(data[first_out][1], h)
		last_out = findlast(.!inside)
		new_corner_2 = corner(h, data[last_out][3])
		return ConvexPolygon(vcat(
								  data[1:first_out-1],
								  [
								   (data[first_out][1], new_corner_1, h),
								   (h, new_corner_2, data[last_out][3])
								   ],
								  data[last_out+1:end]
								  ))
	end
end
intersect(h::HalfPlane, c::ConvexPolygon) = intersect(c, h)

function intersect(c::ConvexPolygon, hs::Intersection{<:Surface})
	for h in hs.hs
		c = c ∩ h
	end
	return c
end
intersect(hs::Intersection{<:Surface}, c::ConvexPolygon) = intersect(c, hs)

intersect(c1::ConvexPolygon, c2::ConvexPolygon) = intersect(c1, as_intersection_of_halfplanes(h2))
 
function intersect(c::ConvexPolygon, hs::Reunion{HalfPlane})
	intersec = Reunion{ConvexPolygon}([intersect(c, hs.hs[1])])
	rest = intersect(c, invert(hs.hs[1]))
	for h in hs.hs[2:end]
		if isempty(rest)
			break
		end
		push!(intersec.hs, intersect(rest, h))
		rest = intersect(rest, invert(h))
	end
	return intersec
end
intersect(hs::Reunion{HalfPlane}, c::ConvexPolygon) = intersect(c, hs)

intersect(c::Reunion{ConvexPolygon}, h::HalfPlane) = union([c ∩ h for c in c.hs]...)
intersect(c::Reunion{ConvexPolygon}, hs::Reunion{HalfPlane}) = union([c ∩ h for h in hs.hs]...)

union(c1::ConvexPolygon, c2::ConvexPolygon) = Reunion{ConvexPolygon}([c1, c2])

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

area(cs::Reunion{ConvexPolygon}) = sum(area(c) for c in cs.hs)
