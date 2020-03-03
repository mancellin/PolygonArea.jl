import Base.==
import Base.isapprox


const center = (0.5, 0.5)

struct PolarLine
    r::Float64
    θ::Float64
    xc::Float64
    yc::Float64
end

PolarLine(r, θ) = PolarLine(r, θ, center...)
PolarLine(θ) = PolarLine(0.0, θ, center...)

equation(line::PolarLine) = (x, y) -> cos(line.θ)*(x - line.xc) + sin(line.θ)*(y - line.yc) - line.r

distance_to_point(line::PolarLine, (x, y)) = equation(line)(x, y)
normalize(line::PolarLine) = PolarLine(-distance_to_point(line, center), mod(line.θ, 2π), center...)

function ==(line1::PolarLine, line2::PolarLine)
	l1 = normalize(line1)
    l2 = normalize(line2)
	return (l1.r == l2.r) && (l1.θ == l2.θ)
end

function isapprox(line1::PolarLine, line2::PolarLine; kwargs...)
	l1 = normalize(line1)
    l2 = normalize(line2)
	return isapprox(l1.r, l2.r; kwargs...) && isapprox(l1.θ, l2.θ; kwargs...)
end

intersection_with_horizontal_line(line::PolarLine, y0) = [line.xc + (line.r - sin(line.θ)*(y0 - line.yc))/cos(line.θ), y0]
intersection_with_vertical_line(line::PolarLine, x0) = [x0, line.yc + (line.r - cos(line.θ)*(x0 - line.xc))/sin(line.θ)]

translate(line::PolarLine, v) = PolarLine(line.r, line.θ, line.xc + v[1], line.yc + v[2])
invert(line::PolarLine) = PolarLine(-line.r, line.θ + π, line.xc, line.yc)

rotate(xy::Vector, ϕ) = [center[1] + (xy[1] - center[1])*cos(ϕ) - (xy[2] - center[2])*sin(ϕ),
						 center[2] + (xy[1] - center[1])*sin(ϕ) + (xy[2] - center[2])*cos(ϕ)]
rotate(line::PolarLine, ϕ) = PolarLine(line.r, line.θ + ϕ, rotate([line.xc, line.yc], ϕ)...)

invert_x_and_y(line::PolarLine) = PolarLine(line.r, π/2 - line.θ, line.yc, line.xc)
