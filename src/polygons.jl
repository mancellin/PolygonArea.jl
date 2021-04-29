##############
#  Polygons  #
##############

struct ConvexPolygon{T} <: Surface
    vertices::Vector{SVector{2, T}}
end

ConvexPolygon(v::Vector{Tuple{T, T}}) where T = ConvexPolygon{T}([SVector(i1, i2) for (i1, i2) in v])

nb_vertices(p::ConvexPolygon) = length(p.vertices)
nb_sides(p::ConvexPolygon) = length(p.vertices)

==(p1::ConvexPolygon, p2::ConvexPolygon) = nb_sides(p1) == nb_sides(p2) && all(p1.vertices .== p2.vertices)

vertices(p::ConvexPolygon) = p.vertices
sides(p::ConvexPolygon) = [c[1] for c in p.corners]

isempty(p::ConvexPolygon) = length(p.vertices) <= 2

translate(c::ConvexPolygon{T}, v) where T = ConvexPolygon{T}(map(x -> translate(x, v), c.vertices))
rotate(c::ConvexPolygon{T}, ϕ; kw...) where T = ConvexPolygon{T}(map(x -> rotate(x, ϕ; kw...), c.vertices))
scale(c::ConvexPolygon{T}, λ, center=Point(0.0, 0.0)) where T = ConvexPolygon{T}(map(x -> λ*(x.-center) .+ center, c.vertices))

function area(c::ConvexPolygon{T}) where T
	if isempty(c)
        return zero(T)*zero(T)
	else
        # Shoelace formula
        a = zero(T)*zero(T)
        last_vertex = c.vertices[end]
        for vertex in c.vertices
            a += last_vertex[1] * vertex[2] - last_vertex[2] * vertex[1]
            last_vertex = vertex
        end
        return abs(a)/2
	end
end

# REPRESENTATION AS INTERSECTION OF HALF-PLANES

function convert(::Type{Intersection{HalfPlane{T}}}, p::ConvexPolygon{T}) where T
    if isempty(p); return Intersection{HalfPlane{T}}(HalfPlane{T}[]); end
    half_planes = Intersection{HalfPlane{T}}(Vector{HalfPlane{T}}(undef, nb_sides(p)))
    last_i = nb_vertices(p)
    for i in 1:nb_vertices(p)
        half_planes.content[i] = HalfPlane{T}(p.vertices[last_i], p.vertices[i], :right)
        last_i = i
    end
    return half_planes
end
convert(::Type{Reunion{Intersection{HalfPlane{T}}}}, c::ConvexPolygon{T}) where T = convert(Reunion{Intersection{HalfPlane{T}}}, convert(Intersection{HalfPlane{T}}, c))

in(p, c::ConvexPolygon{T}) where T = in(p, convert(Intersection{HalfPlane{T}}, c))
invert(c::ConvexPolygon{T}) where T = invert(convert(Intersection{HalfPlane{T}}, c))

# INTERSECTIONS BETWEEN CONVEX POLYGONS

# Basically Sutherland-Hodgeman algorithm
function intersect(c::ConvexPolygon{T}, h::HalfPlane{T}) where T
    if isempty(c); return c; end
    poly_in = ConvexPolygon{T}(Point{T}[])
    previous_corner = c.vertices[end]
    for corner in c.vertices
        if corner in h
            if previous_corner in h
                # Stay in
                push!(poly_in.vertices, corner)
            else
                # Entering
                push!(poly_in.vertices, corner_point(HalfPlane{T}(previous_corner, corner, :right), h))
                push!(poly_in.vertices, corner)
            end
        elseif previous_corner in h
                # Exiting
                push!(poly_in.vertices, corner_point(HalfPlane{T}(previous_corner, corner, :right), h))
        end
        previous_corner = corner
    end
    return poly_in
end
intersect(h::HalfPlane{T}, c::ConvexPolygon{T}) where T = intersect(c, h)

function intersect(c::ConvexPolygon{T}, ih::Intersection{HalfPlane{T}}) where T
	for h in ih.content
		c = c ∩ h
		if isempty(c)
			break
		end
	end
    return c
end
intersect(ih::Intersection{HalfPlane{T}}, c::ConvexPolygon{T}) where T = intersect(c, ih)

intersect(c1::ConvexPolygon{T}, c2::ConvexPolygon{T})  where T = intersect(c1, convert(Intersection{HalfPlane{T}}, c2))

# REUNION OF CONVEX POLYGONS

convert(::Type{Reunion{ConvexPolygon{T}}}, c::ConvexPolygon{T}) where T = Reunion{ConvexPolygon{T}}([c])
convert(::Type{Reunion{Intersection{HalfPlane{T}}}}, u::Reunion{ConvexPolygon{T}}) where T = Reunion{Intersection{HalfPlane{T}}}(map(c -> convert(Intersection{HalfPlane{T}}, c), u.content))

promote_rule(::Type{ConvexPolygon{T}}, ::Type{Reunion{ConvexPolygon{T}}}) where T = Reunion{ConvexPolygon{T}}

invert(c::Reunion{ConvexPolygon{T}}) where T = invert(convert(Reunion{Intersection{HalfPlane{T}}}, c))

# _cut(c::ConvexPolygon{T}, h::HalfPlane{T}) where T = (c ∩ h, c ∩ invert(h))
# function _cut(c::ConvexPolygon{T}, ih::Intersection{HalfPlane{T}}) where T
# 	for h in ih.content
#         c, rest = _cut(c, h)
# 		if isempty(c)
# 			break
# 		end
# 	end
#     return c
#     (c ∩ h, c ∩ invert(h))
# end

function intersect(c::ConvexPolygon{T}, uh::Reunion{HalfPlane{T}}) where T
    u_poly = Reunion{ConvexPolygon{T}}(ConvexPolygon{T}[])
    rest = c
	for h in uh.content
        ci = rest ∩ h
        rest = rest ∩ invert(h)
        if !isempty(ci)
            push!(u_poly.content, ci)
        end
	end
    return u_poly
end
intersect(uh::Reunion{HalfPlane{T}}, c::ConvexPolygon{T}) where T = intersect(c, uh)

function intersect(c::ConvexPolygon{T}, uih::Reunion{Intersection{HalfPlane{T}}}) where T
    u_poly = Reunion{ConvexPolygon{T}}(ConvexPolygon{T}[])
    rest = c
	for ih in uih.content
        ci = rest ∩ ih
        rest = rest ∩ invert(ih)
        if !isempty(ci)
            u_poly = u_poly ∪ ci
        end
	end
    return u_poly
end
intersect(uih::Reunion{Intersection{HalfPlane{T}}}, c::ConvexPolygon{T}) where T = intersect(c, uih)

function intersect(uc::Reunion{ConvexPolygon{T}}, s::Surface) where T
    u_poly = Reunion{ConvexPolygon{T}}(ConvexPolygon{T}[])
    for ci in uc.content
        cii = ci ∩ s
		if !isempty(cii)
            u_poly = u_poly ∪ cii
		end
    end
    return u_poly
end
intersect(s::Surface, uc::Reunion{ConvexPolygon{T}}) where T = intersect(uc, s)
intersect(uc1::Reunion{ConvexPolygon{T}}, uc2::Reunion{ConvexPolygon{T}}) where T = intersect(uc1, convert(Reunion{Intersection{HalfPlane{T}}}, uc2))

union(c1::ConvexPolygon{T}, c2::ConvexPolygon{T}) where T = Reunion{ConvexPolygon{T}}([c1, c2])
union(u1::Reunion{ConvexPolygon{T}}, u2::Reunion{ConvexPolygon{T}}) where T = Reunion{ConvexPolygon{T}}(vcat(u1.content, u2.content))


# AREA OF REUNION OF CONVEX POLYGON
disjoint(c::ConvexPolygon) = c
function disjoint(u::Reunion{ConvexPolygon{T}}) where T
    isempty(u) && return u
    l = Reunion{ConvexPolygon{T}}(ConvexPolygon{T}[u.content[1]])
    for c in u.content[2:end]
        rest = c \ l
        if !isempty(rest)
            l = l ∪ rest
        end
    end
    return l
end
area(u::Reunion{ConvexPolygon{T}}) where T = isempty(u) ? zero(T)*zero(T) : sum(area(c) for c in u.content)

