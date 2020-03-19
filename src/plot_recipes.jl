using RecipesBase

@recipe function plot(h::Surface; xlims::NTuple{2, <:Number}, ylims::NTuple{2, <:Number})
    if !(xlims isa Tuple && ylims isa Tuple)
        error("Please provide 'xlims' and 'ylims' to plot an infinite surface.")
    end
    margin = 0.1
    h ∩ rectangle(xlims[1]-margin, ylims[1]-margin,
                  xlims[2]+margin, ylims[2]+margin)
end

@recipe function plot(c::ConvexPolygon)
	seriestype --> :shape
	linealpha --> 0.9
	fillalpha --> 0.3
	legend --> false
	showaxis --> false
	aspect_ratio --> :equal

	if isempty(c)
		[], []
	else
		v = vertices(c)
		push!(v, v[1])
		[p[1] for p in v], [p[2] for p in v]
	end
end

@recipe function plot(cs::Reunion{ConvexPolygon})
	seriestype --> :shape
	linealpha --> 0.9
	fillalpha --> 0.3
	legend --> false
	showaxis --> false
	aspect_ratio --> :equal

	v = []
	for c in cs.hs
		if !isempty(c)
			append!(v, vertices(c))
			push!(v, vertices(c)[1])
			push!(v, Point(NaN, NaN))
		end
	end
	if length(v) > 0
		push!(v, v[1])
		[p[1] for p in v], [p[2] for p in v]
	else
		[], []
	end
end
