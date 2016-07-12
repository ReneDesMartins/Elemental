--Takes any number of tables, and merges them indiscriminately.
function table.merge(...)
	local out = {}
	for _,tables in ipairs(arg) do
		for key,value in pairs(tables) do
			if type(value) == "table" and out[key] then
				out[key] = table.merge(out[key],value)
			else
				out[key] = value
			end
		end
	end
	return out
end

--Returns a table containing all the values from 'b' to 'e' of the original table.
function table.slice(t,b,e)
	local out = {}
	for i = b,e or #t do
		out[#out+1] = t[i]
	end
	return out
end

--Return a table containin all arguments.
function pack ( ... )
	return arg
end

--Iterative string.find - keep returning string indices for every match.
function string.gfind (str,pat)
	local previous_end,start = -1
	return function ()
		while true do
			start,previous_end = str:find(pat,previous_end+1)
			return start,previous_end
		end
	end
end

--Recursive table-content printing. Useful for debugging.
function table.rprint(tbl,tab)
	tab = tab or 0
	for k,v in pairs(tbl) do
		print(
			("%s %s : %s"):format(
				("\t"):rep(tab),
				tostring(k),
				tostring(v)
			)
		)
		if type(v) == "table" then
			table.rprint(v,tab+1)
		end
	end
end
