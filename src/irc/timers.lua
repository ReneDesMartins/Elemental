---------------------------------------------------------------------------------------------------------------------------------------
-- Timers
---------------------------------------------------------------------------------------------------------------------------------------
-- Timers are functions that activate every x amount of seconds. Timers can be in either one of two states: primed, and unprimed.
-- Unprimed timers remain in the register, but are not triggered. Primed timers, on the contrary, are.
-- The socket objects' timeout period is changed in accordance with the shortest timers' interval. If no primed timers remain, 
-- then the sockect is set to not timeout.
--
-- A timers' anatomy: table {
--	[1] - Time    - Specified interval.
--	[2] - Func    - The function to be executed.
--	[3] - Single  - Whether the timer should be unprimed upon execution.
--	[4] - Primed  - Whether the timer is primed or not.
--	[5] - Last    - The timestamp of the last execution.
-- }
---------------------------------------------------------------------------------------------------------------------------------------

local Timer  = {}
local Timers = {}

---------------------------------------------------------------------------------------------------------------------------------------
-- Timer Methods
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Timer:add_timer()
-- Adds (and primes!) a timer.
--
-- Parameters:
-- string:  name                 The name that will be used to refer to the timer.
-- number:  time                 The timers' interval.
-- function:func                 The function that will be executed once the timer runs out.
-- bool:    single               Whether the timer should unprime itself upon execution.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Timer:remove_timer()
-- Removes a timer from the list.
--
-- Parameters:
-- string:  name                 The name of the timer to be removed.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Timer:prime()
-- Primes a timer, so it gets executed when it's interval reaches 0.
--
-- Parameters:
-- string:  name                 The timer to be primed.
-- bool:    exec                 Whether the timer should be executed upon priming.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Timer:unprime()
-- Unprimes a timer, so it doesn't get executed when it's interval reaches 0.
--
-- Parameter:
-- string:  name                 The timer to be unprimed.
-- bool:    exec                 Whether it should be executed once before unpriming.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Timer:lowest_primed_interval()
-- Returns the lowest primed timers' interval.
---------------------------------------------------------------------------------------------------------------------------------------

function Timer:lowest_primed_interval()
	local highest = -1
	for _,timer in pairs( Timers ) do
		highest = (
			( timer[1] > highest ) and timer[1]
		) or highest
	end
	return highest
end

function Timer:add_timer ( name , time , func , single )
	assert( type(name) == "string" , "timer name must be a string." )
	assert( type(time) == "number" , "timer interval must be a number." )
	assert( time > 0 , "timer interval must be non-zero, and non-negative." )
	assert( type(func) == "function" , "func must be a function." )
	
	Timers[ name ] = { time , func , single , true , os.time() }
	Timer:prime( name )
end

function Timer:remove_timer ( name )
	Timers[ name ] = nil
	self.__parent:settimeout( Timer:lowest_primed_interval() )
end

function Timer:prime( name , exec )
	assert(
		Timers[ name or "" ],
		("no such timer: %q"):format( name or "" )
	)
	Timers[ name ][4] = true
	self.__parent:settimeout( Timer:lowest_primed_interval() )
	if (exec) then
		Timers[ name ][2](self.__parent)
	end
end

function Timer:unprime( name , exec )
	assert(
		Timers[ name or "" ],
		("no such timer: %q"):format( name or "" )
	)
	Timers[ name ][4] = false
	self.__parent:settimeout( Timer:lowest_primed_interval() )
	if (exec) then
		Timers[ name ][2](self.__parent)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Timer:evaluate()
-- Iterates through all timers, and executes the primed timers whose interval has been passed.
---------------------------------------------------------------------------------------------------------------------------------------

function Timer:evaluate ()
	local current_time = os.time()
	for name,timer in pairs( Timers ) do
		if (timer[4]) and ( os.difftime( current_time , timer[5] ) > timer[1] ) then
			timer[2](self.__parent)
			timer[5] = current_time
			if (timer[3]) then
				Timer:unprime( name )
			end
		end
	end
end

return Timer