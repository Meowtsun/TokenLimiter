# TokenLimiter `v0.1.0`

---

Token-based utility for Roblox Lua, able to both queue and execute immediately

> `TokenLimiter` currently does **not use promises**. Callbacks are executed via `pcall` and `task.defer`.  
> Because of this, it is suitable for **frequent, lightweight operations**, like rate-limiting HTTP requests or small tasks.  
> Heavy or long-running tasks may block the Roblox scheduler slightly.  
> The API may change in future releases if promise-based execution is added. 

---

### Installation

##### Creator Store
you can get the model directly from [Creator Store](https://create.roblox.com/store/asset/133082881826656/TokenLimiter)

#### Releases
if you need specific versions you can look into [Releases](https://github.com/Meowtsun/TokenLimiter/releases)

---

### Usage
```lua
local TokenLimiter = require(...)
local requestLimit = TokenLimiter.new(5, 30):Init()

--[[ 
    - using Init() so it automatically processed
    - 5 requests per 30 seconds
]]


local OnTokenProcessed = requestLimit:Queue(function()
    print('Task processed!')
end)

-- This is Stravant's GoodSignal (as of now)
if OnTokenProcessed then
    OnTokenProcessed:Once(function(success, log)
        if not success then
            print('Error!:', log)
        end
    end)
end

-- If OnTokenProcessed is nil, this mean It's being processed
```

---

### APIs
- [TokenLimiterModule](#tokenlimitermodulenew)
  - [`new()`](#tokenlimitermodulenew)
- [TokenLimiter](#tokenlimiterqueue)
  - [`Queue()`](#tokenlimiterqueue)
  - [`Try()`](#tokenlimitertry)
  - [`Init()`](#tokenlimiterinit)
  - [`Process()`](#tokenlimiterprocess)
  - [`HasToken()`](#tokenlimiterhastoken)
- [OnTokenProcessed](#ontokenprocessed)

---

#### TokenLimiterModule.new(requests: number?, window: number?): [TokenLimiter](#tokenlimiterqueue)

`requests: number?` = maximum operations in the window. (default is 3)
`window: number?` = time window in seconds. (default is 10)
Returns [TokenLimiter](#tokenlimiterqueue) back.
<br>

#### TokenLimiter:Queue(callback: (...A) -> (), ...A): [OnTokenProcessed](#ontokenprocessed)

`callback: function` = function to run when queue is being processed.
any extra parameters will be passed into the callback.
Returns a signal [OnTokenProcessed](#ontokenprocessed) back.
<br>

#### TokenLimiter:Try(callback: (...A) -> (), ...A): boolean, string?

`callback: function` = function to run when queue is being processed.
any extra parameters will be passed into the callback.
This will skip any queued tasks and attempt to run immediately.
Returns state and log
`state: boolean` = `true` if the callback succeeded, `false` if it raised an error.
`log: string?` = error message, otherwise `nil`.
<br>

#### TokenLimiter:Init(): [TokenLimiter](#tokenlimiterqueue)

Can be called to allow [TokenLimiter](#tokenlimiterqueue) to automatically process itself. 
Returns itself for convenient chaining.
<br>

#### TokenLimiter:Process()

Can be called to manually process the token.
<br>

#### TokenLimiter:HasToken(): boolean

Returns a boolean
`boolean` = `true` if a token is available, otherwise `false`.
<br>

#### OnTokenProcessed

uses [Stravant's GoodSignal](https://github.com/stravant/goodsignal). Fires when tokens are processed, returning state and log in the callback.
`state: boolean` = `true` if the callback succeeded, `false` if it raised an error. 
`log: string?` = error message, otherwise `nil`.
