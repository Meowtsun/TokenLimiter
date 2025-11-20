
export type TokenLimiter = {

	Queue: (self: TokenLimiter, callback: (...any) -> (), ...any) -> (RBXScriptSignal?),
	Try: (self: TokenLimiter, callback: (...any) -> (), ...any) -> (boolean, string?),
	Init: (self: TokenLimiter) -> (TokenLimiter),
	Process:(self: TokenLimiter) -> (),
	
}

export type TokenLimiterModule = {
	new: (requests: number?, window: number?) -> (TokenLimiter)
}


return nil