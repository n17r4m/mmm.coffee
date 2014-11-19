
axis = (letter, size = 3) ->
	if letter.constructor is Number then return letter
	unknown = new RangeError("Unknown axis")
	switch size
		when 1 then 0
		when 2
			switch letter
				when 'a', 'x', 'u', 'p' then 0
				when 'b', 'y', 'v', 'q' then 1
				else throw unknown
		when 3
			switch letter
				when 'a', 'x', 'u', 'p' then 0
				when 'b', 'y', 'v', 'q' then 1
				when 'c', 'z', 'w', 'r' then 2
				else throw unknown
		when 4
			switch letter
				when 'a', 'w', 'p' then 0
				when 'b', 'x', 'q' then 1
				when 'c', 'y', 'r' then 2
				when 'd', 'z', 's' then 3
				else throw unknown
		when 5
			switch letter
				when 'a', 'v', 'p' then 0
				when 'b', 'w', 'q' then 1
				when 'c', 'x', 'r' then 2
				when 'd', 'y', 's' then 3
				when 'e', 'z', 't' then 4
				else throw unknown
		when 6
			switch letter
				when 'a', 'u' then 0
				when 'b', 'v' then 1
				when 'c', 'w' then 2
				when 'd', 'x' then 3
				when 'e', 'y' then 4
				when 'f', 'z' then 4
				else throw unknown
		else
			n = letter.charCodeAt(0)
			if n > 90 then n-= 32
			n - 65

if typeof define is 'function' and define.amd then define -> axis
else if typeof module is 'object' and module.exports then module.exports = axis
else @axis = axis
