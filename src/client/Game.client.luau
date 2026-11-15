-- COIN RUSH — the client entry point: wires UI, input, state and spawner
-- together and runs the frame loop. One round: 60 seconds, 3 lives,
-- collect coins, dodge the spikes, beat your best score.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CoinRush = script.Parent.CoinRush
local Config = require(CoinRush.Config)
local Arena = require(CoinRush.Arena)
local Controls = require(CoinRush.Controls)
local GameState = require(CoinRush.GameState)
local Spawner = require(CoinRush.Spawner)

local player = Players.LocalPlayer

local recordScoreEvent = ReplicatedStorage:WaitForChild("RecordScore")

local ui = Arena.build(player:WaitForChild("PlayerGui"))
local controls = Controls.new(ui)
local state = GameState.new()
local spawner = Spawner.new(ui.arena)

-- Player position (top-left corner inside the arena), centred to start.
local playerX = (Config.ARENA_WIDTH - Config.PLAYER_SIZE) / 2
local playerY = (Config.ARENA_HEIGHT - Config.PLAYER_SIZE) / 2

local function placePlayer()
	ui.player.Position = UDim2.fromOffset(
		math.floor(playerX + 0.5), math.floor(playerY + 0.5))
	-- Flash while invulnerable so the hit feedback is visible.
	ui.player.BackgroundTransparency = state:isInvulnerable() and 0.5 or 0
end

local function updateHud()
	ui.scoreLabel.Text = string.format("Skor: %d  •  Combo x%d  •  Level %d",
		state.score, state.combo, state.level)
	ui.timerLabel.Text = string.format("%d detik", math.ceil(state.timeLeft))
	local hearts = ""
	for _ = 1, state.lives do
		hearts ..= "❤"
	end
	ui.livesLabel.Text = hearts
end

local function showMenu()
	state.phase = "menu"
	ui.startScreen.Visible = true
	ui.endScreen.Visible = false
	ui.touchPad.Visible = false
	ui.player.Visible = false
	if state.bestScore > 0 then
		ui.bestLabel.Text = string.format("Skor terbaik: %d", state.bestScore)
	else
		ui.bestLabel.Text = "Belum ada skor — jadilah yang pertama!"
	end
	updateHud()
end

local function startGame()
	state:reset()
	spawner:clearAll()
	controls:reset()
	playerX = (Config.ARENA_WIDTH - Config.PLAYER_SIZE) / 2
	playerY = (Config.ARENA_HEIGHT - Config.PLAYER_SIZE) / 2
	ui.startScreen.Visible = false
	ui.endScreen.Visible = false
	ui.touchPad.Visible = true
	ui.player.Visible = true
	placePlayer()
	updateHud()
end

local function endGame(reason)
	state.phase = "over"
	state.endReason = reason
	ui.touchPad.Visible = false
	ui.player.Visible = false
	spawner:clearAll()
	if state.score > state.bestScore then
		state.bestScore = state.score
	end
	ui.endTitle.Text = reason == "lives" and "GAME OVER!" or "WAKTU HABIS!"
	ui.finalLabel.Text = string.format("Skor akhir: %d  •  Koin: %d",
		state.score, state.coinsCollected)
	ui.endBestLabel.Text = string.format("Skor terbaik: %d", state.bestScore)
	ui.endScreen.Visible = true
	-- Tell the server so the leaderboard keeps the best score.
	local ok, err = pcall(function()
		recordScoreEvent:FireServer(state.score, state.coinsCollected)
	end)
	if not ok then
		warn("COIN RUSH: could not record score: " .. tostring(err))
	end
end

ui.playButton.MouseButton1Click:Connect(startGame)
ui.againButton.MouseButton1Click:Connect(startGame)

showMenu()

RunService.RenderStepped:Connect(function(dt)
	if state.phase ~= "playing" then
		return
	end

	local timeout = state:tick(dt)

	local dx, dy = controls:getMoveVector()
	playerX = math.clamp(playerX + dx * Config.PLAYER_SPEED * dt,
		0, Config.ARENA_WIDTH - Config.PLAYER_SIZE)
	playerY = math.clamp(playerY + dy * Config.PLAYER_SPEED * dt,
		0, Config.ARENA_HEIGHT - Config.PLAYER_SIZE)
	placePlayer()

	local collected, hit = spawner:update(dt, playerX, playerY, state.level)
	for _ in ipairs(collected) do
		state:addCoin()
	end
	if hit and state:loseLife() then
		updateHud()
		endGame("lives")
		return
	end

	updateHud()
	if timeout == "time" then
		endGame("time")
	end
end)
