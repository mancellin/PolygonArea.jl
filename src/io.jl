
function show(io::IO, h::HalfPlane{T}) where T
    compact = get(io, :compact, false)
    !compact && print(io, "HalfPlane{$T}(")
    print(io, "$(h.a)x + $(h.b)y + $(h.c) ≤ 0")
    !compact && print(io, ")")
end

function show(io::IO, inter::Intersection{T}) where T
    padding = get(io, :padding, 0) + 2
    print(io, "Intersection{$T}\n")
    for (i, h) in enumerate(inter.content)
        print(io, " "^padding)
        print(Base.IOContext(io, :compact=>true, :padding=>padding), h)
        i != length(inter.content) && print(io, "\n")
    end
end

function show(io::IO, reunion::Reunion{T}) where T
    padding = get(io, :padding, 0) + 2
    print(io, "Reunion{$T}\n")
    for (i, h) in enumerate(reunion.content)
        print(io, " "^padding)
        print(Base.IOContext(io, :compact=>true, :padding=>padding), h)
        i != length(reunion.content) && print(io, "\n")
    end
end

function show(io::IO, p::ConvexPolygon{T}) where T
    padding = get(io, :padding, 0) + 2
    print(io, "ConvexPolygon{$T} with $(nb_vertices(p)) vertices\n")
    for (i, c) in enumerate(vertices(p))
        print(io, " "^padding)
        print(Base.IOContext(io, :compact=>true, :padding=>padding), c)
        i != nb_vertices(p) && print(io, "\n")
    end
end

