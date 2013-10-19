function DeltaAngle(radius, size)
	return Rad2Deg(math.asin(size / radius));
end

function ReduceAngle(angle)
	while (angle > 360) do
		angle = angle - 360;
	end
	while(angle < 0 ) do
		angle = angle + 360;
	end
	return angle;
end

function Deg2Rad(angle)
	return (angle * (math.pi / 180));
end

function Rad2Deg(angle)
	return (angle * (180 / math.pi));
end

function HUDXPos(angle, radius)
	if (HUD_Center[1] == nil) then HUD_Center[1] = 0; end
	return HUD_Center[1] + PolarXPos(angle, radius) * HUD_Scale;
end

function HUDYPos(angle, radius)
	if (HUD_Center[2] == nil) then HUD_Center[2] = 0; end
	return HUD_Center[2] - PolarYPos(angle, radius) * HUD_Scale;
end

function PolarXPos(angle, radius)
	return (radius * math.cos(Deg2Rad(ReduceAngle(-angle))));
end

function PolarYPos(angle, radius)
	return (radius * math.sin(Deg2Rad(ReduceAngle(-angle)))) * HUD_Scale;
end
