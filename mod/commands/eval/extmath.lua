---------------------------------------------------------------------------------------------------------------------------------------
-- Extmath - Extented Mathematical Library
---------------------------------------------------------------------------------------------------------------------------------------
extmath = setmetatable({},{__index = math})

---------------------------------------------------------------------------------------------------------------------------------------
-- Mathematical Functions
---------------------------------------------------------------------------------------------------------------------------------------
extmath = math
extmath.tau = math.pi*2
extmath.e = 2.718281828459
function extmath.fact(num)
	for i = 2,num-1 do
		num = num * i
	end
	return num
end
extmath.split = extmath.modf
function extmath.modf(x)
	local i,f = cmatch.split(x)
	return f
end
function extmath.modi(x)
	return ( split(x) )
end
function extmath.rand(x,y)
	extmath.randomseed(os.time())
	return random(x,y)
end
function extmath.dacos (x) return extmath.deg(math.acos(x)) end
function extmath.dasin (x) return extmath.deg(math.asin(x)) end
function extmath.datan (x) return extmath.deg(math.atan(x)) end
function extmath.dcos (x) return extmath.cos(math.rad(x)) end
function extmath.dsin (x) return extmath.sin(math.rad(x)) end
function extmath.dtan (x) return extmath.tan(math.rad(x)) end
function extmath.abcp(a,b,c)
	return ( -(b)+math.sqrt( (b)^2 - 4*a*c ) ) / ( 2*a )
end
function extmath.abcm(a,b,c)
	return ( -(b)-math.sqrt( (b)^2 - 4*a*c ) ) / ( 2*a )
end
function extmath.lsin(A,a,b)
	return ( math.dsin(A)*b ) / (a)
end
function extmath.ilsin(A,a,B)
	return ( math.dsin(B)*a ) / (math.dsin(A))
end
function extmath.lcos(a,b,C)
	return a^2 + b^2 - 2*a*b*math.dcos(C)
end
function extmath.ilcos(a,b,c)
	return ( a^2 + b^2 - c^2 ) / ( 2*a*b )
end

---------------------------------------------------------------------------------------------------------------------------------------
return extmath