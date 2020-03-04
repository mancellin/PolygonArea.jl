using RecipesBase

@recipe function recipe(c::ConvexPolygon)
	seriestype --> :shape
	linealpha --> 0.9
	fillalpha --> 0.3
	legend --> false

	v = vertices(c)
	if length(v) > 0
		push!(v, v[1])
		[p[1] for p in v], [p[2] for p in v]
	else
		[], []
	end
end
