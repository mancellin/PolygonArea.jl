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

convert(::Type{Intersection{HalfPlane}}, c::ConvexPolygon) = Intersection{HalfPlane}([corner[1] for corner in c.data])
convert(::Type{Reunion{Intersection{HalfPlane}}}, c::ConvexPolygon) = Reunion{Intersection{HalfPlane}}([Intersection{HalfPlane}([corner[1] for corner in c.data])])

vertices(c::ConvexPolygon) = [corner[2] for corner in c.data]
center(c::ConvexPolygon) = (v = vertices(c); sum(v)/length(v))

isempty(c::ConvexPolygon) = length(c.data) == 0
_non_empty(l) = filter(c -> !(isempty(c)), l)

in(p::Point, c::ConvexPolygon) = in(p, convert(Intersection{HalfPlane}, c))

function cut(c::ConvexPolygon, h::HalfPlane)
	inside = map(p -> (p in h), vertices(c))
	if all(inside)  # The whole polygon is inside the half-space
        return (c, ConvexPolygon([]))
	elseif !(any(inside))  # The whole polygon is outside the half-space
        return (ConvexPolygon([]), c)
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
		return (
                ConvexPolygon(vcat(
								  data[1:first_out-1],
								  [
								   (data[first_out][1], new_corner_1, h),
								   (h, new_corner_2, data[last_out][3])
								   ],
								  data[last_out+1:end]
								  )),
                ConvexPolygon(vcat(
								  data[first_out:last_out],
								  [(data[last_out][1], new_corner_2, h),
                                   (h, new_corner_1, data[first_out][3])],
								  )),
               )
	end
end

intersect(c::ConvexPolygon, h::HalfPlane) = cut(c, h)[1]
intersect(c::ConvexPolygon, hs::Intersection{HalfPlane}) = foldl(intersect, hs.hs, init=c)

intersect(c1::ConvexPolygon, c2::ConvexPolygon) = intersect(c1, convert(Intersection{HalfPlane}, c2))

function intersect(c::ConvexPolygon, hs::Reunion{HalfPlane})
    inter, rest = cut(c, hs.hs[1])
	intersec = Reunion{ConvexPolygon}(inter)
	for h in hs.hs[2:end]
		if isempty(rest)
			break
		end
        inter, rest = cut(rest, h)
		push!(intersec.hs, inter)
	end
	return intersec
end

function intersect(c::ConvexPolygon, hs::Reunion{Intersection{HalfPlane}})
    error("not implemented")
end

intersect(hs::Surface, c::ConvexPolygon) = intersect(c, hs)

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
convert(::Type{Reunion{Intersection{HalfPlane}}}, c::Reunion{ConvexPolygon}) = Reunion{Intersection{HalfPlane}}(map(c -> convert(Intersection{HalfPlane}, c), c.hs))

promote_rule(::Type{ConvexPolygon}, ::Type{Reunion{ConvexPolygon}}) = Reunion{ConvexPolygon}

union(c1::ConvexPolygon, c2::ConvexPolygon) = Reunion{ConvexPolygon}([c1, c2])
union(c1::Reunion{ConvexPolygon}, c2::Reunion{ConvexPolygon}) = Reunion{ConvexPolygon}(vcat(c1.hs, c2.hs))

intersect(c1::Reunion{ConvexPolygon}, c2::ConvexPolygon) = intersect(c1, convert(Intersection{HalfPlane}, c2))
intersect(c1::Reunion{ConvexPolygon}, c2::Reunion{ConvexPolygon}) = intersect(c1, convert(Reunion{Intersection{HalfPlane}}, c2))
intersect(cs::Reunion{ConvexPolygon}, h::Surface) = Reunion{ConvexPolygon}(_non_empty([c ∩ h for c in cs.hs]))
intersect(h::Surface, cs::Reunion{ConvexPolygon}) = intersect(cs, h)

area(cs::Reunion{ConvexPolygon}) = sum(area(c) for c in cs.hs)
