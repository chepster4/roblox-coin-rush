-- COIN RUSH — spawns coins and spikes, moves the spikes, and checks
-- every overlap with the player. The spawner owns no score or lives;
-- it reports events and the main loop applies them to GameState.

local Config = require(script.Parent.Config)
local Arena = require(script.Parent.Arena)

local Spawner = {}
Spawner.__index = Spawner

function Spawner.new(arenaFrame)
	local self = setmetatable({}, Spawner)
	self.arenaFrame = arenaFrame
	self.coins = {} -- { frame, x, y, born }
	self.spikes = {} -- { frame, x, y, vx, vy }
	self.coinTimer = 0
	self.spikeTimer = 0
	self.elapsed = 0
	return self
end

local function randomPosition(size)
	return math.random(0, Config.ARENA_WIDTH - size),
		math.random(0, Config.ARENA_HEIGHT - size)
end

local function overlaps(ax, ay, aSize, bx, by, bSize)
	return ax < bx + bSize and ax + aSize > bx
		and ay < by + bSize and ay + aSize > by
end

function Spawner:spawnCoin()
	local frame = Arena.makeCoin(self.arenaFrame)
	local x, y = randomPosition(Config.COIN_SIZE)
	frame.Position = UDim2.fromOffset(x, y)
	table.insert(self.coins, { frame = frame, x = x, y = y, born = self.elapsed })
end

function Spawner:spawnSpike(level)
	local frame = Arena.makeSpike(self.arenaFrame)
	local x, y = randomPosition(Config.SPIKE_SIZE)
	-- Spikes never spawn on top of the player start (arena centre).
	local cx = (Config.ARENA_WIDTH - Config.PLAYER_SIZE) / 2
	local cy = (Config.ARENA_HEIGHT - Config.PLAYER_SIZE) / 2
	if overlaps(x, y, Config.SPIKE_SIZE, cx - 60, cy - 60, Config.PLAYER_SIZE + 120) then
		x = 0
		y = 0
	end
	local speed = Config.SPIKE_BASE_SPEED + (level - 1) * Config.SPIKE_SPEED_PER_LEVEL
	local angle = math.random() * math.pi * 2
	local vx = math.cos(angle) * speed
	local vy = math.sin(angle) * speed
	frame.Position = UDim2.fromOffset(x, y)
	table.insert(self.spikes, { frame = frame, x = x, y = y, vx = vx, vy = vy })
end

function Spawner:clearAll()
	for _, coin in ipairs(self.coins) do
		coin.frame:Destroy()
	end
	for _, spike in ipairs(self.spikes) do
		spike.frame:Destroy()
	end
	self.coins = {}
	self.spikes = {}
	self.coinTimer = 0
	self.spikeTimer = 0
	self.elapsed = 0
end

-- Advances spawns, spike motion and coin expiry. Returns two lists:
-- collected coin indices and whether any spike touched the player.
function Spawner:update(dt, playerX, playerY, level)
	self.elapsed += dt

	self.coinTimer -= dt
	if self.coinTimer <= 0 then
		self.coinTimer = Config.COIN_SPAWN_INTERVAL
		self:spawnCoin()
	end

	self.spikeTimer -= dt
	if self.spikeTimer <= 0 then
		local interval = math.max(
			Config.SPIKE_SPAWN_MIN,
			Config.SPIKE_SPAWN_INTERVAL - (level - 1) * 0.15
		)
		self.spikeTimer = interval
		if #self.spikes < Config.SPIKE_MAX_COUNT then
			self:spawnSpike(level)
		end
	end

	-- Coins fade out after their lifetime.
	for i = #self.coins, 1, -1 do
		local coin = self.coins[i]
		if self.elapsed - coin.born > Config.COIN_LIFETIME then
			coin.frame:Destroy()
			table.remove(self.coins, i)
		end
	end

	-- Spikes drift and bounce off the arena walls.
	for _, spike in ipairs(self.spikes) do
		spike.x += spike.vx * dt
		spike.y += spike.vy * dt
		if spike.x < 0 then
			spike.x = 0
			spike.vx = math.abs(spike.vx)
		elseif spike.x > Config.ARENA_WIDTH - Config.SPIKE_SIZE then
			spike.x = Config.ARENA_WIDTH - Config.SPIKE_SIZE
			spike.vx = -math.abs(spike.vx)
		end
		if spike.y < 0 then
			spike.y = 0
			spike.vy = math.abs(spike.vy)
		elseif spike.y > Config.ARENA_HEIGHT - Config.SPIKE_SIZE then
			spike.y = Config.ARENA_HEIGHT - Config.SPIKE_SIZE
			spike.vy = -math.abs(spike.vy)
		end
		spike.frame.Position = UDim2.fromOffset(
			math.floor(spike.x + 0.5), math.floor(spike.y + 0.5))
	end

	-- Coins the player touched.
	local collected = {}
	for i = #self.coins, 1, -1 do
		local coin = self.coins[i]
		if overlaps(playerX, playerY, Config.PLAYER_SIZE,
			coin.x, coin.y, Config.COIN_SIZE) then
			coin.frame:Destroy()
			table.remove(self.coins, i)
			table.insert(collected, coin)
		end
	end

	-- Any spike touching the player?
	local hit = false
	for _, spike in ipairs(self.spikes) do
		if overlaps(playerX, playerY, Config.PLAYER_SIZE,
			spike.x, spike.y, Config.SPIKE_SIZE) then
			hit = true
			break
		end
	end

	return collected, hit
end

return Spawner
