-- https://devforum.roblox.com/u/Krystaltinan

return function(Number)
	local Suffixes = {"","K","M","B","T","Q","QN","S","SP","O","N","D","UD","DD"}
	
	local Index = math.floor(math.log10(Number))
	Index = Index - (Index % 3)

	local Suffix = Suffixes[(Index / 3) + 1] or ""
	local NearestMultiple = 10 ^ Index
	local PrecisionMultiple = 10 ^ 2
	
	return math.floor((Number / NearestMultiple) * PrecisionMultiple) / PrecisionMultiple .. Suffix
end
