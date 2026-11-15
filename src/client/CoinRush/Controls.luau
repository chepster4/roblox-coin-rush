-- COIN RUSH — keyboard and touch input in one place.
-- Arrow keys are bound with ContextActionService: the default camera
-- scripts swallow Left/Right before an InputBegan handler ever sees them,
-- so InputBegan plus gameProcessedEvent is never used here.

local ContextActionService = game:GetService("ContextActionService")

local Controls = {}
Controls.__index = Controls

function Controls.new(ui)
	local self = setmetatable({}, Controls)
	-- Held directions; the main loop reads them every frame.
	self.up = false
	self.down = false
	self.left = false
	self.right = false
	self.ui = ui
	self:_bindKeys()
	self:_bindTouch()
	return self
end

function Controls:_setDirection(name, held)
	if name == "MoveUp" then
		self.up = held
	elseif name == "MoveDown" then
		self.down = held
	elseif name == "MoveLeft" then
		self.left = held
	elseif name == "MoveRight" then
		self.right = held
	end
end

function Controls:_bindKeys()
	local keys = {
		MoveUp = { Enum.KeyCode.W, Enum.KeyCode.Up },
		MoveDown = { Enum.KeyCode.S, Enum.KeyCode.Down },
		MoveLeft = { Enum.KeyCode.A, Enum.KeyCode.Left },
		MoveRight = { Enum.KeyCode.D, Enum.KeyCode.Right },
	}
	for actionName, keyCodes in pairs(keys) do
		ContextActionService:BindAction(actionName, function(_, inputState)
			self:_setDirection(actionName, inputState == Enum.UserInputState.Begin)
		end, false, table.unpack(keyCodes))
	end
end

function Controls:_bindTouch()
	local buttons = {
		{ button = self.ui.touchUp, action = "MoveUp" },
		{ button = self.ui.touchDown, action = "MoveDown" },
		{ button = self.ui.touchLeft, action = "MoveLeft" },
		{ button = self.ui.touchRight, action = "MoveRight" },
	}
	for _, entry in ipairs(buttons) do
		entry.button.MouseButton1Down:Connect(function()
			self:_setDirection(entry.action, true)
		end)
		entry.button.MouseButton1Up:Connect(function()
			self:_setDirection(entry.action, false)
		end)
		entry.button.MouseLeave:Connect(function()
			self:_setDirection(entry.action, false)
		end)
	end
end

-- Normalised movement vector from whatever is held right now.
function Controls:getMoveVector()
	local x = 0
	local y = 0
	if self.left then x -= 1 end
	if self.right then x += 1 end
	if self.up then y -= 1 end
	if self.down then y += 1 end
	if x ~= 0 and y ~= 0 then
		local inv = 1 / math.sqrt(2)
		x *= inv
		y *= inv
	end
	return x, y
end

function Controls:reset()
	self.up = false
	self.down = false
	self.left = false
	self.right = false
end

return Controls
