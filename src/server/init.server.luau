-- COIN RUSH — server side: keeps a leaderboard and records each round's
-- final score. The client owns the round; the server only trusts a
-- score that fits inside sane bounds and keeps the player's best.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MAX_SCORE = 100000
local MAX_COINS = 10000

local recordScoreEvent = ReplicatedStorage:WaitForChild("RecordScore")

local function setupLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local bestScore = Instance.new("IntValue")
	bestScore.Name = "Best Score"
	bestScore.Value = 0
	bestScore.Parent = leaderstats

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats
end

local function onRecordScore(player, score, coinsCollected)
	if typeof(score) ~= "number" or typeof(coinsCollected) ~= "number" then
		return
	end
	score = math.floor(score)
	coinsCollected = math.floor(coinsCollected)
	if score < 0 or score > MAX_SCORE then
		return
	end
	if coinsCollected < 0 or coinsCollected > MAX_COINS then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end
	local bestScore = leaderstats:FindFirstChild("Best Score")
	local coins = leaderstats:FindFirstChild("Coins")
	if bestScore and score > bestScore.Value then
		bestScore.Value = score
	end
	if coins then
		coins.Value += coinsCollected
	end
end

Players.PlayerAdded:Connect(setupLeaderstats)
for _, player in ipairs(Players:GetPlayers()) do
	setupLeaderstats(player)
end

recordScoreEvent.OnServerEvent:Connect(onRecordScore)
