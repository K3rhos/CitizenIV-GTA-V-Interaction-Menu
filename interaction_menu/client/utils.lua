Utils = {}



function Utils.Round(_num, _numDecimalPlaces)

	local mult = 10 ^ (_numDecimalPlaces or 0)

	return math.floor(_num * mult + 0.5) / mult
end