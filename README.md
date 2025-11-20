# TokenLimiter `v0.1.0`

---

Token-based utility for Roblox Lua, able to both queue and execute immediately

> `TokenLimiter` currently does **not use promises**. Callbacks are executed via `pcall` and `task.defer`.  
> It is suitable for operations, like rate-limiting HTTP requests.  
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

<h4 id="tokenlimitermodulenew">TokenLimiterModule.new(requests: number?, window: number?): [TokenLimiter](#tokenlimiterqueue)</h4>

`requests: number?` = maximum operations in the window. (default is 3)
`window: number?` = time window in seconds. (default is 10)
Returns [TokenLimiter](#tokenlimiterqueue) back.
<br><br>

<h4 id="tokenlimiterqueue">TokenLimiter:Queue(callback: (...A) -> (), ...A): [OnTokenProcessed](#ontokenprocessed)</h4>

`callback: function` = function to run when queue is being processed.
any extra parameters will be passed into the callback.
Returns a signal [OnTokenProcessed](#ontokenprocessed) back.
<br><br>

<h4 id="tokenlimitertry">TokenLimiter:Try(callback: (...A) -> (), ...A): boolean, string?</h4>

`callback: function` = function to run when queue is being processed.
any extra parameters will be passed into the callback.
This will skip any queued tasks and attempt to run immediately.
Returns state and log
`state: boolean` = `true` if the callback succeeded, `false` if it raised an error.
`log: string?` = error message, otherwise `nil`.
<br><br>

<h4 id="tokenlimiterinit">TokenLimiter:Init(): [TokenLimiter](#tokenlimiterqueue)</h4>

Can be called to allow [TokenLimiter](#tokenlimiterqueue) to automatically process itself. 
Returns itself for convenient chaining.
<br><br>

<h4 id="tokenlimiterprocess">TokenLimiter:Process()</h4>

Can be called to manually process the token.
<br><br>

<h4 id="tokenlimiterhastoken">TokenLimiter:HasToken(): boolean</h4>

Returns a boolean
`boolean` = `true` if a token is available, otherwise `false`.
<br><br>

<h4 id="ontokenprocessed">OnTokenProcessed</h4>

uses [Stravant's GoodSignal](https://github.com/stravant/goodsignal). Fires when tokens are processed, returning state and log in the callback.
`state: boolean` = `true` if the callback succeeded, `false` if it raised an error. 
`log: string?` = error message, otherwise `nil`.




