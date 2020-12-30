##############
#  Polygons  #
##############

const Corner{T} = Tuple{HalfPlane{T}, Point{T}, HalfPlane{T}}

Corner(p1, p2, p3) = (HalfPlane(p1, p2), p2, HalfPlane(p2, p3))

struct ConvexPolygon{T} <: Surface
    corners::Vector{Corner{T}}
end

function ConvexPolygon(ps...)
    n = length(ps)
    corners = []
    for i in 1:n
        im1 = mod(i - 1, Base.OneTo(n))
        ip1 = mod(i + 1, Base.OneTo(n))
        push!(corners, Corner(ps[im1], ps[i], ps[ip1]))
    end
    return ConvexPolygon{eltype(ps[1])}(corners)
end

convert(::Type{Intersection{HalfPlane{T}}}, p::ConvexPolygon{T}) where T = Intersection{HalfPlane{T}}([c[1] for c in p.corners])
convert(::Type{Reunion{Intersection{HalfPlane{T}}}}, c::ConvexPolygon{T}) where T = convert(Reunion{Intersection{HalfPlane{T}}}, convert(Intersection{HalfPlane{T}}, c))

nb_vertices(p::ConvexPolygon) = length(p.corners)
nb_sides(p::ConvexPolygon) = length(p.corners)

==(c1::ConvexPolygon, c2::ConvexPolygon) = nb_sides(c1) == nb_sides(c2) && all(c1.corners .== c2.corners)

vertices(p::ConvexPolygon) = [c[2] for c in p.corners]
sides(p::ConvexPolygon) = [c[1] for c in p.corners]

isempty(p::ConvexPolygon) = length(p.corners) <= 2

in(p, c::ConvexPolygon{T}) where T = in(p, convert(Intersection{HalfPlane{T}}, c))

translate(c::Corner, v) = map(x -> translate(x, v), c)
translate(c::ConvexPolygon{T}, v) where T = ConvexPolygon{T}(map(x -> translate(x, v), c.corners))

rotate(c::Corner, ϕ; kw...) = map(x -> rotate(x, ϕ; kw...), c)
rotate(c::ConvexPolygon{T}, ϕ; kw...) where T = ConvexPolygon{T}(map(x -> rotate(x, ϕ; kw...), c.corners))

invert(c::ConvexPolygon{T}) where T = invert(convert(Intersection{HalfPlane{T}}, c))

"""Returns the couple of ConvexPolygon obtained by cutting c by the plane h."""
function cut(c::ConvexPolygon{T}, h::HalfPlane{T}) where T
    poly_in = ConvexPolygon{T}(Corner[])
    # sizehint!(poly_in.corners, nb_vertices(c) + 2)
    poly_out = ConvexPolygon{T}(Corner[])
    # sizehint!(poly_out.corners, nb_vertices(c) + 2)
    previous_corner = c.corners[end]
    for corner in c.corners
        if corner[2] in h
            if previous_corner[2] in h
                # Stay in
                push!(poly_in.corners, corner)
            else
                # Entering
                p = corner_point(corner[1], h)
                push!(poly_in.corners, (h, p, corner[3]))
                push!(poly_in.corners, corner)
                push!(poly_out.corners, (corner[1], p, h))
            end
        else
            if previous_corner[2] in h
                # Exiting
                p = corner_point(corner[1], h)
                push!(poly_in.corners, (corner[1], p, h))
                push!(poly_out.corners, (h, p, corner[3]))
                push!(poly_out.corners, corner)
            else
                # Stay out
                push!(poly_out.corners, corner)
            end
        end
        previous_corner = corner
    end
    poly_in, poly_out
end

function cut(c::ConvexPolygon{T}, i::Intersection{HalfPlane{T}}) where T
    rests = Reunion{ConvexPolygon{T}}([])
    cc = Reunion{ConvexPolygon{T}}([c])
	for h in i.content
		cc, rest = cut(cc, h)
		rests = rests ∪ rest
		if isempty(cc)
			break
		end
	end
    return cc, rests
end

function cut(c::ConvexPolygon{T}, u::Reunion{HalfPlane{T}}) where T
    cut(c, convert(Reunion{Intersection{HalfPlane{T}}}, u))
end

function cut(c::ConvexPolygon{T}, u::Reunion{Intersection{HalfPlane{T}}}) where T
    polys = Reunion{ConvexPolygon{T}}([])
    cc = Reunion{ConvexPolygon{T}}([c])
    for i in u.content
        poly, cc = cut(cc, i)
		polys = polys ∪ poly
		if isempty(c)
			break
		end
    end
    return polys, cc
end

intersect(c::ConvexPolygon{T}, h::HalfPlane{T}) where T = cut(c, h)[1]
intersect(c::ConvexPolygon{T}, i::Intersection{HalfPlane{T}}) where T = cut(c, i)[1]
intersect(c1::ConvexPolygon{T}, c2::ConvexPolygon{T})  where T = intersect(c1, convert(Intersection{HalfPlane{T}}, c2))

intersect(c::ConvexPolygon{T}, u::Reunion{HalfPlane{T}})  where T = cut(c, u)[1]
intersect(c::ConvexPolygon{T}, ui::Reunion{Intersection{HalfPlane{T}}}) where T = cut(c, ui)[1]

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

convert(::Type{Reunion{ConvexPolygon{T}}}, c::ConvexPolygon{T}) where T = Reunion{ConvexPolygon{T}}([c])
convert(::Type{Reunion{Intersection{HalfPlane{T}}}}, u::Reunion{ConvexPolygon{T}}) where T = Reunion{Intersection{HalfPlane{T}}}(map(c -> convert(Intersection{HalfPlane{T}}, c), u.content))

promote_rule(::Type{ConvexPolygon{T}}, ::Type{Reunion{ConvexPolygon{T}}}) where T = Reunion{ConvexPolygon{T}}

function cut(cs::Reunion{ConvexPolygon{T}}, h) where T
    polys = Reunion{ConvexPolygon{T}}([])
    rests = Reunion{ConvexPolygon{T}}([])
    for c in cs.content
        poly, rest = cut(c, h)
        polys = polys ∪ poly
        rests = rests ∪ rest
    end
    return polys, rests
end

union(c1::ConvexPolygon{T}, c2::ConvexPolygon{T}) where T = Reunion{ConvexPolygon{T}}([c1, c2])
union(u1::Reunion{ConvexPolygon{T}}, u2::Reunion{ConvexPolygon{T}}) where T = Reunion{ConvexPolygon{T}}(vcat(u1.content, u2.content))

intersect(u::Reunion{ConvexPolygon{T}}, c::ConvexPolygon{T}) where T = intersect(u, convert(Intersection{HalfPlane{T}}, c))
intersect(u1::Reunion{ConvexPolygon{T}}, u2::Reunion{ConvexPolygon{T}}) where T = intersect(u1, convert(Reunion{Intersection{HalfPlane{T}}}, u2))
intersect(u::Reunion{ConvexPolygon{T}}, h::Surface) where T = foldl(union, (p ∩ h for p in u.content))
intersect(h::Surface, u::Reunion{ConvexPolygon{T}}) where T = intersect(u, h)

invert(c::Reunion{ConvexPolygon{T}}) where T = invert(convert(Reunion{Intersection{HalfPlane{T}}}, c))

const Polygons{T} = Union{ConvexPolygon{T}, Reunion{ConvexPolygon{T}}}
\(c1::Polygons{T}, c2::Polygons{T}) where T = c1 ∩ invert(c2)

disjoint(c::ConvexPolygon) = c
function disjoint(u::Reunion{ConvexPolygon{T}}) where T
    isempty(u) && return u
    l = u.content[1]
    for c in u.content[2:end]
        l = l ∪ (c \ l)
    end
    return l
end
area(u::Reunion{ConvexPolygon{T}}) where T = isempty(u) ? 0.0 : sum(area(c) for c in u.content)

