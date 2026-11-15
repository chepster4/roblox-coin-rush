-- COIN RUSH — builds every on-screen element: arena, HUD, menus, touch pad.
-- The HUD stays clear of the top-left corner, where Roblox draws its own
-- menu buttons over the play view.

local Config = require(script.Parent.Config)

local Arena = {}

local function makeLabel(parent, name, text, size, position, anchor)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = size
	label.TextColor3 = Config.COLORS.Text
	label.BackgroundTransparency = 1
	label.AnchorPoint = anchor or Vector2.new(0.5, 0)
	label.Position = position
	label.Size = UDim2.fromOffset(420, size + 12)
	label.Parent = parent
	return label
end

local function roundFrame(parent, name, size, color)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.BackgroundColor3 = color
	frame.BorderSizePixel = 0
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = frame
	frame.Parent = parent
	return frame
end

function Arena.build(playerGui)
	local colors = Config.COLORS

	local gui = Instance.new("ScreenGui")
	gui.Name = "CoinRushGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 10
	gui.Parent = playerGui

	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = colors.Background
	background.BorderSizePixel = 0
	background.Parent = gui

	-- Title and HUD live at the top CENTRE, never the top-left corner.
	local title = makeLabel(background, "Title", "COIN RUSH", 36,
		UDim2.new(0.5, 0, 0, 4), Vector2.new(0.5, 0))
	title.TextColor3 = colors.Coin

	local scoreLabel = makeLabel(background, "ScoreLabel", "Skor: 0", 26,
		UDim2.new(0.5, 0, 0, 56), Vector2.new(0.5, 0))

	local timerLabel = makeLabel(background, "TimerLabel", "60", 26,
		UDim2.new(0.5, 0, 0, 88), Vector2.new(0.5, 0))

	-- Lives sit at the top-right, far from the Roblox menu buttons.
	local livesLabel = makeLabel(background, "LivesLabel", "❤❤❤", 26,
		UDim2.new(1, -16, 0, 12), Vector2.new(1, 0))
	livesLabel.Size = UDim2.fromOffset(160, 40)
	livesLabel.TextXAlignment = Enum.TextXAlignment.Right
	livesLabel.TextColor3 = colors.Spike

	local arena = Instance.new("Frame")
	arena.Name = "Arena"
	arena.AnchorPoint = Vector2.new(0.5, 0.5)
	arena.Position = UDim2.fromScale(0.5, 0.58)
	arena.Size = UDim2.fromOffset(Config.ARENA_WIDTH, Config.ARENA_HEIGHT)
	arena.BackgroundColor3 = colors.Arena
	arena.BorderColor3 = colors.ArenaBorder
	arena.BorderSizePixel = 3
	arena.Parent = background

	-- Player square, created once and moved by the main loop.
	local player = Instance.new("Frame")
	player.Name = "Player"
	player.Size = UDim2.fromOffset(Config.PLAYER_SIZE, Config.PLAYER_SIZE)
	player.BackgroundColor3 = colors.Player
	player.BorderColor3 = colors.PlayerBorder
	player.BorderSizePixel = 2
	player.Visible = false
	player.Parent = arena

	-- Start screen: title, how to play, best score, big Play button.
	local startScreen = Instance.new("Frame")
	startScreen.Name = "StartScreen"
	startScreen.Size = UDim2.fromScale(1, 1)
	startScreen.BackgroundColor3 = colors.Background
	startScreen.BackgroundTransparency = 0.25
	startScreen.BorderSizePixel = 0
	startScreen.Parent = gui

	makeLabel(startScreen, "StartTitle", "COIN RUSH", 56,
		UDim2.new(0.5, 0, 0.5, -150), Vector2.new(0.5, 0.5)).TextColor3 = colors.Coin
	local howTo = makeLabel(startScreen, "HowTo",
		"Kumpulkan koin emas, hindari bola berduri!\n60 detik, 3 nyawa. Gerak: WASD / panah / tombol layar.",
		20, UDim2.new(0.5, 0, 0.5, -60), Vector2.new(0.5, 0.5))
	howTo.Size = UDim2.fromOffset(560, 70)
	howTo.TextWrapped = true
	howTo.TextColor3 = colors.MutedText

	local bestLabel = makeLabel(startScreen, "BestLabel", "", 20,
		UDim2.new(0.5, 0, 0.5, 10), Vector2.new(0.5, 0.5))
	bestLabel.TextColor3 = colors.MutedText

	local playButton = Instance.new("TextButton")
	playButton.Name = "PlayButton"
	playButton.Text = "▶  MAIN"
	playButton.Font = Enum.Font.GothamBold
	playButton.TextSize = 30
	playButton.TextColor3 = colors.PlayButtonText
	playButton.BackgroundColor3 = colors.PlayButton
	playButton.AnchorPoint = Vector2.new(0.5, 0.5)
	playButton.Position = UDim2.new(0.5, 0, 0.5, 80)
	playButton.Size = UDim2.fromOffset(240, 70)
	playButton.Parent = startScreen
	local playCorner = Instance.new("UICorner")
	playCorner.CornerRadius = UDim.new(0, 14)
	playCorner.Parent = playButton

	-- End screen: final score, best score, Play Again.
	local endScreen = Instance.new("Frame")
	endScreen.Name = "EndScreen"
	endScreen.Size = UDim2.fromScale(1, 1)
	endScreen.BackgroundColor3 = colors.Background
	endScreen.BackgroundTransparency = 0.25
	endScreen.BorderSizePixel = 0
	endScreen.Visible = false
	endScreen.Parent = gui

	local endTitle = makeLabel(endScreen, "EndTitle", "WAKTU HABIS!", 44,
		UDim2.new(0.5, 0, 0.5, -120), Vector2.new(0.5, 0.5))
	endTitle.TextColor3 = colors.Coin
	local finalLabel = makeLabel(endScreen, "FinalLabel", "Skor: 0", 30,
		UDim2.new(0.5, 0, 0.5, -50), Vector2.new(0.5, 0.5))
	local endBestLabel = makeLabel(endScreen, "EndBestLabel", "", 20,
		UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5))
	endBestLabel.TextColor3 = colors.MutedText

	local againButton = Instance.new("TextButton")
	againButton.Name = "AgainButton"
	againButton.Text = "↻  MAIN LAGI"
	againButton.Font = Enum.Font.GothamBold
	againButton.TextSize = 26
	againButton.TextColor3 = colors.PlayButtonText
	againButton.BackgroundColor3 = colors.PlayButton
	againButton.AnchorPoint = Vector2.new(0.5, 0.5)
	againButton.Position = UDim2.new(0.5, 0, 0.5, 70)
	againButton.Size = UDim2.fromOffset(260, 64)
	againButton.Parent = endScreen
	local againCorner = Instance.new("UICorner")
	againCorner.CornerRadius = UDim.new(0, 14)
	againCorner.Parent = againButton

	-- Touch pad: four semi-transparent buttons at the bottom-right,
	-- shown only while playing, for phones without a keyboard.
	local touchPad = Instance.new("Frame")
	touchPad.Name = "TouchPad"
	touchPad.AnchorPoint = Vector2.new(1, 1)
	touchPad.Position = UDim2.new(1, -12, 1, -12)
	touchPad.Size = UDim2.fromOffset(200, 200)
	touchPad.BackgroundTransparency = 1
	touchPad.Visible = false
	touchPad.Parent = gui

	local function touchButton(name, text, position)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Text = text
		button.Font = Enum.Font.GothamBold
		button.TextSize = 28
		button.TextColor3 = colors.Text
		button.BackgroundColor3 = colors.TouchButton
		button.BackgroundTransparency = 0.35
		button.AnchorPoint = Vector2.new(0.5, 0.5)
		button.Position = position
		button.Size = UDim2.fromOffset(60, 60)
		button.Parent = touchPad
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent = button
		return button
	end

	local touchUp = touchButton("TouchUp", "▲", UDim2.new(0.5, 0, 0.25, 0))
	local touchLeft = touchButton("TouchLeft", "◀", UDim2.new(0.25, 0, 0.5, 0))
	local touchDown = touchButton("TouchDown", "▼", UDim2.new(0.5, 0, 0.75, 0))
	local touchRight = touchButton("TouchRight", "▶", UDim2.new(0.75, 0, 0.5, 0))

	return {
		gui = gui,
		arena = arena,
		player = player,
		scoreLabel = scoreLabel,
		timerLabel = timerLabel,
		livesLabel = livesLabel,
		startScreen = startScreen,
		bestLabel = bestLabel,
		playButton = playButton,
		endScreen = endScreen,
		endTitle = endTitle,
		finalLabel = finalLabel,
		endBestLabel = endBestLabel,
		againButton = againButton,
		touchPad = touchPad,
		touchUp = touchUp,
		touchLeft = touchLeft,
		touchDown = touchDown,
		touchRight = touchRight,
	}
end

-- A gold coin: outer disc, bright inner disc, "C" stamped in the middle.
function Arena.makeCoin(parent)
	local coin = roundFrame(parent, "Coin",
		UDim2.fromOffset(Config.COIN_SIZE, Config.COIN_SIZE), Config.COLORS.Coin)
	local inner = roundFrame(coin, "Inner",
		UDim2.fromOffset(Config.COIN_SIZE - 10, Config.COIN_SIZE - 10), Config.COLORS.CoinInner)
	inner.AnchorPoint = Vector2.new(0.5, 0.5)
	inner.Position = UDim2.fromScale(0.5, 0.5)
	local mark = Instance.new("TextLabel")
	mark.Name = "Mark"
	mark.Text = "C"
	mark.Font = Enum.Font.GothamBold
	mark.TextSize = 16
	mark.TextColor3 = Color3.fromRGB(150, 100, 0)
	mark.BackgroundTransparency = 1
	mark.Size = UDim2.fromScale(1, 1)
	mark.Parent = coin
	return coin
end

-- A spiky ball: red disc, dark core, white X so it reads at a glance.
function Arena.makeSpike(parent)
	local spike = roundFrame(parent, "Spike",
		UDim2.fromOffset(Config.SPIKE_SIZE, Config.SPIKE_SIZE), Config.COLORS.Spike)
	local core = roundFrame(spike, "Core",
		UDim2.fromOffset(Config.SPIKE_SIZE - 14, Config.SPIKE_SIZE - 14), Config.COLORS.SpikeInner)
	core.AnchorPoint = Vector2.new(0.5, 0.5)
	core.Position = UDim2.fromScale(0.5, 0.5)
	local mark = Instance.new("TextLabel")
	mark.Name = "Mark"
	mark.Text = "✕"
	mark.Font = Enum.Font.GothamBold
	mark.TextSize = 18
	mark.TextColor3 = Color3.fromRGB(255, 255, 255)
	mark.BackgroundTransparency = 1
	mark.Size = UDim2.fromScale(1, 1)
	mark.Parent = spike
	return spike
end

return Arena
