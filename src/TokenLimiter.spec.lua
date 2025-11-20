local TokenLimiter = require(script.Parent)


local function waitFor(condition, timeout)
	timeout = timeout or 2
	local start = os.clock()
	while not condition() do
		if os.clock() - start > timeout then
			error("Condition not met in time")
		end
		task.wait(0.01)
	end
end


return function()
	describe("TokenLimiter", function()
		it("Try() executes callback if token available", function()
			local executed = false
			local limiter = TokenLimiter.new(1, 1)
			local result = limiter:Try(function()
				executed = true
			end)
			waitFor(function() return executed end)
			assert(result == true)
			assert(executed == true)
		end)

		it("Try() returns false if token unavailable", function()
			local limiter = TokenLimiter.new(1, 10)
			
			assert(limiter:Try(function() end) == true)
			
			local executed = false
			local result = limiter:Try(function()
				executed = true
			end)
			
			task.wait(0.05)
			assert(result == false)
			assert(executed == false)
		end)

		it("Queue() returns signal if queued, nil if immediate", function()
			local limiter = TokenLimiter.new(1, 10)
			local executed1 = false
			local executed2 = false

			local sig1 = limiter:Queue(function() executed1 = true end)
			waitFor(function() return executed1 end)
			assert(sig1 == nil)

			local sig2 = limiter:Queue(function() executed2 = true end)
			assert(typeof(sig2) == "table")

			limiter.Token = 1
			limiter:Process()
			waitFor(function() return executed2 end)
			assert(executed2 == true)
		end)

		it("Tokens refill over time", function()
			local limiter = TokenLimiter.new(1, 0.1)
			assert(limiter:Try(function() end) == true)
			assert(limiter:Try(function() end) == false)
			task.wait(0.15)
			local executed = false
			assert(limiter:Try(function() executed = true end) == true) -- <--
			waitFor(function() return executed end)
		end)

		it("Init() automatically processes queued tasks", function()
			local limiter = TokenLimiter.new(1, 0.1)
			local executed1 = false
			local executed2 = false

			limiter:Init()

			-- first task consumes token
			local sig1 = limiter:Queue(function() executed1 = true end)
			waitFor(function() return executed1 end)
			assert(sig1 == nil)

			-- second task should queue
			local sig2 = limiter:Queue(function() executed2 = true end)
			assert(typeof(sig2) == "table")

			-- wait enough for automatic processing
			task.wait(0.2)
			assert(executed2 == true)
		end)
	end)
end
