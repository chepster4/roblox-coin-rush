-- COIN RUSH — one place for all mutable round state.
-- The client owns the round; the server only records the final score.

local Config = require(script.Parent.Config)

local GameState = {}
GameState.__index = GameState

function GameState.new()
	local self = setmetatable({}, GameState)
	self.phase = "menu" -- "menu" | "playing" | "over"
	self.score = 0
	self.coinsCollected = 0
	self.lives = Config.MAX_LIVES
	self.combo = 0
	self.comboTimer = 0
	self.level = 1
	self.timeLeft = Config.GAME_TIME
	self.bestScore = 0
	self.invulnTimer = 0
	self.endReason = "" -- "time" | "lives"
	return self
end

function GameState:reset()
	self.phase = "playing"
	self.score = 0
	self.coinsCollected = 0
	self.lives = Config.MAX_LIVES
	self.combo = 0
	self.comboTimer = 0
	self.level = 1
	self.timeLeft = Config.GAME_TIME
	self.invulnTimer = 0
	self.endReason = ""
end

-- Call once per frame while playing. Returns "time" when the clock runs out.
function GameState:tick(dt)
	self.timeLeft -= dt
	if self.comboTimer > 0 then
		self.comboTimer -= dt
		if self.comboTimer <= 0 then
			self.combo = 0
		end
	end
	if self.invulnTimer > 0 then
		self.invulnTimer -= dt
	end
	local level = math.floor((Config.GAME_TIME - self.timeLeft) / Config.LEVEL_DURATION) + 1
	if level > self.level then
		self.level = level
	end
	if self.timeLeft <= 0 then
		self.timeLeft = 0
		return "time"
	end
	return nil
end

function GameState:addCoin()
	self.coinsCollected += 1
	self.combo += 1
	self.comboTimer = Config.COMBO_WINDOW
	local gained = Config.COIN_POINTS
	if self.combo > 0 and self.combo % Config.COMBO_BONUS_EVERY == 0 then
		gained += Config.COMBO_BONUS_POINTS
	end
	self.score += gained
	return gained
end

-- Returns true when the hit ends the round (no lives left).
function GameState:loseLife()
	if self.invulnTimer > 0 then
		return false
	end
	self.lives -= 1
	self.combo = 0
	self.comboTimer = 0
	self.invulnTimer = Config.INVULN_TIME
	if self.lives <= 0 then
		self.lives = 0
		return true
	end
	return false
end

function GameState:isInvulnerable()
	return self.invulnTimer > 0
end

return GameState
