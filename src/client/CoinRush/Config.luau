-- COIN RUSH — shared tuning numbers for the whole game.
-- One place for every magic number so the other modules stay readable.

local Config = {}

-- Arena (pixels, drawn centred on the screen by Arena.luau).
Config.ARENA_WIDTH = 640
Config.ARENA_HEIGHT = 480

-- Player.
Config.PLAYER_SIZE = 40
Config.PLAYER_SPEED = 340 -- pixels per second

-- Round rules.
Config.GAME_TIME = 60 -- seconds
Config.MAX_LIVES = 3
Config.LEVEL_DURATION = 15 -- seconds per level
Config.INVULN_TIME = 1.2 -- seconds of safety after taking a hit

-- Coins.
Config.COIN_SIZE = 28
Config.COIN_SPAWN_INTERVAL = 0.9 -- seconds
Config.COIN_LIFETIME = 6 -- seconds before a coin fades away
Config.COIN_POINTS = 10
Config.COMBO_WINDOW = 3 -- seconds allowed between coins to keep the streak
Config.COMBO_BONUS_EVERY = 5 -- every 5th coin in a streak pays a bonus
Config.COMBO_BONUS_POINTS = 25

-- Spikes (the moving hazards).
Config.SPIKE_SIZE = 34
Config.SPIKE_SPAWN_INTERVAL = 1.7 -- seconds, shrinks as the level rises
Config.SPIKE_SPAWN_MIN = 0.9
Config.SPIKE_BASE_SPEED = 120 -- pixels per second
Config.SPIKE_SPEED_PER_LEVEL = 45
Config.SPIKE_MAX_COUNT = 9

-- Palette: a night-market gold on deep navy.
Config.COLORS = {
	Background = Color3.fromRGB(16, 22, 44),
	Arena = Color3.fromRGB(36, 46, 74),
	ArenaBorder = Color3.fromRGB(90, 110, 160),
	Player = Color3.fromRGB(255, 200, 40),
	PlayerBorder = Color3.fromRGB(140, 90, 0),
	Coin = Color3.fromRGB(255, 214, 64),
	CoinInner = Color3.fromRGB(255, 240, 160),
	Spike = Color3.fromRGB(235, 60, 60),
	SpikeInner = Color3.fromRGB(120, 10, 10),
	Text = Color3.fromRGB(240, 244, 255),
	MutedText = Color3.fromRGB(170, 185, 220),
	PlayButton = Color3.fromRGB(46, 180, 90),
	PlayButtonText = Color3.fromRGB(255, 255, 255),
	TouchButton = Color3.fromRGB(120, 140, 200),
}

return Config
