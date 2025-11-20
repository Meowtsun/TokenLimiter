
local GoodSignal = require(script.Packages.GoodSignal)
local Annotation = require(script.Annotation)

local TokenLimiter = {}
TokenLimiter.__index = TokenLimiter



local function repeatCallback(window, callback, ...)
	while true do
		local deltaTime = task.wait(window)
		callback(...)
	end
end



function TokenLimiter.new(limit, window)
	
	local seconds = window or 10
	local maxLimit = limit or 3
	
	-- normalizing
	seconds = seconds / maxLimit
	maxLimit = maxLimit / maxLimit
	
	return setmetatable({
		SecondsPerToken = seconds / maxLimit,
		LastRefill = os.clock(),
		
		Token = maxLimit,
		Limit = maxLimit,
		Window = seconds,
		Initialized = false,
		
		TokenQueues = {
			--[[
				{
					OnTokenProcessed: GoodSignal,
					Parameters: {...},
					Callback: (...) -> (),
				},
				...
			]]
		},
		
	}, TokenLimiter)
end



function TokenLimiter:HasToken()
	local now = os.clock()
	local deltaTime = now - self.LastRefill
	self.Token = math.min(self.Limit, self.Token + deltaTime / self.SecondsPerToken)
	self.LastRefill = now
	return self.Token >= 1
end



function TokenLimiter:Try(callback, ...)
	
	if #self.TokenQueues > 0 then
		return false
	end
	
	local token = self:HasToken()
	if not token then
		return false, 'No avaliable token'
	end
	
	self.Token -= 1
	return pcall(callback, ...)
end



function TokenLimiter:Queue(callback, ...)
	
	if #self.TokenQueues == 0 then
		local token = self:HasToken()
		if token then
			self.Token -= 1
			task.defer(callback, ...)
			return
		end
	end
	
	local onTokenProcessed = GoodSignal.new()
	
	table.insert(self.TokenQueues, {
		OnTokenProcessed = onTokenProcessed,
		Parameters = {...},
		Callback = callback,
	})
	
	return onTokenProcessed
end



function TokenLimiter:Process()
	
	if #self.TokenQueues == 0 then
		return -- no queue
	end
	
	local token = self:HasToken()
	if not token then
		return 
	end
	
	local queued = self.TokenQueues[1]
	self.Token -= 1
	
	task.defer(function()
		local ok, log = pcall(queued.Callback, table.unpack(queued.Parameters))
		queued.OnTokenProcessed:Fire(ok, log)
	end)
	
	table.remove(self.TokenQueues, 1)
	table.clear(queued.Parameters)
end



function TokenLimiter:Init()
	if not self.Initialized then
		task.defer(repeatCallback, self.SecondsPerToken, TokenLimiter.Process, self)
		self.Initialized = true
	end
	return self
end



return TokenLimiter :: Annotation.TokenLimiterModule