-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- WINDOW
local Window = Rayfield:CreateWindow({
	Name = "Yo Hub",
	LoadingTitle = "Yo Hub",
	LoadingSubtitle = "Hitbox + ESP",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "YoHub",
		FileName = "Config"
	}
})

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- HITBOX SETTINGS
--------------------------------------------------
local HitboxEnabled = false
local HitboxSize = 20
local HitboxColor = Color3.fromRGB(255,0,0)
local HitboxTransparency = 0.6
local OriginalSize = {}

--------------------------------------------------
-- ESP SETTINGS
--------------------------------------------------
local ESPEnabled = true
local ESPBox = true
local ESPName = true
local ESPHP = true
local ESPDistance = true
local TeamCheck = false

local BoxColor = Color3.fromRGB(0,255,0)
local NameColor = Color3.fromRGB(255,255,255)
local HPColor = Color3.fromRGB(0,255,0)

local ESPObjects = {}

--------------------------------------------------
-- ESP FUNCTIONS
--------------------------------------------------
local function newESP(p)
	local box = Drawing.new("Square")
	box.Filled = false
	box.Thickness = 1
	box.Visible = false

	local name = Drawing.new("Text")
	name.Size = 13
	name.Center = true
	name.Outline = true
	name.Visible = false

	local hp = Drawing.new("Line")
	hp.Thickness = 2
	hp.Visible = false

	local dist = Drawing.new("Text")
	dist.Size = 12
	dist.Center = true
	dist.Outline = true
	dist.Visible = false

	ESPObjects[p] = {
		Box = box,
		Name = name,
		HP = hp,
		Dist = dist
	}
end

local function removeESP(p)
	if ESPObjects[p] then
		for _,v in pairs(ESPObjects[p]) do
			v:Remove()
		end
		ESPObjects[p] = nil
	end
end

for _,p in pairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then
		newESP(p)
	end
end

Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then
		newESP(p)
	end
end)

Players.PlayerRemoving:Connect(removeESP)

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------
RunService.RenderStepped:Connect(function()
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			local esp = ESPObjects[p]

			-- TEAM CHECK
			if TeamCheck and p.Team == LocalPlayer.Team then
				if esp then
					for _,v in pairs(esp) do v.Visible = false end
				end
				continue
			end

			-- HITBOX
			if hrp then
				if not OriginalSize[hrp] then
					OriginalSize[hrp] = hrp.Size
				end

				if HitboxEnabled then
					hrp.Size = Vector3.new(HitboxSize,HitboxSize,HitboxSize)
					hrp.Color = HitboxColor
					hrp.Transparency = HitboxTransparency
					hrp.Material = Enum.Material.Neon
					hrp.CanCollide = false
				else
					hrp.Size = OriginalSize[hrp]
					hrp.Transparency = 1
				end
			end

			-- ESP
			if ESPEnabled and hrp and hum and hum.Health > 0 and esp then
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local h = math.clamp(1800 / pos.Z, 40, 260)
					local w = h / 2

					-- BOX
					if ESPBox then
						esp.Box.Size = Vector2.new(w, h)
						esp.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
						esp.Box.Color = BoxColor
						esp.Box.Visible = true
					else esp.Box.Visible = false end

					-- NAME
					if ESPName then
						esp.Name.Text = p.Name
						esp.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 14)
						esp.Name.Color = NameColor
						esp.Name.Visible = true
					else esp.Name.Visible = false end

					-- HP
					if ESPHP then
						local hpPct = hum.Health / hum.MaxHealth
						esp.HP.From = Vector2.new(pos.X - w/2 - 4, pos.Y + h/2)
						esp.HP.To = Vector2.new(pos.X - w/2 - 4, pos.Y + h/2 - (h * hpPct))
						esp.HP.Color = HPColor
						esp.HP.Visible = true
					else esp.HP.Visible = false end

					-- DISTANCE
					if ESPDistance then
						local d = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
						esp.Dist.Text = d .. "m"
						esp.Dist.Position = Vector2.new(pos.X, pos.Y + h/2 + 2)
						esp.Dist.Color = NameColor
						esp.Dist.Visible = true
					else esp.Dist.Visible = false end
				else
					for _,v in pairs(esp) do v.Visible = false end
				end
			elseif esp then
				for _,v in pairs(esp) do v.Visible = false end
			end
		end
	end
end)

--------------------------------------------------
-- GUI : HITBOX
--------------------------------------------------
local HitboxTab = Window:CreateTab("Hitbox", 4483362458)
HitboxTab:CreateToggle({
	Name = "Enable Hitbox",
	CurrentValue = false,
	Callback = function(v) HitboxEnabled = v end
})

HitboxTab:CreateSlider({
	Name = "Size",
	Range = {5,50},
	Increment = 1,
	CurrentValue = 20,
	Callback = function(v) HitboxSize = v end
})

HitboxTab:CreateSlider({
	Name = "Transparency",
	Range = {0,1},
	Increment = 0.05,
	CurrentValue = 0.6,
	Callback = function(v) HitboxTransparency = v end
})

HitboxTab:CreateColorPicker({
	Name = "Color",
	Color = HitboxColor,
	Callback = function(v) HitboxColor = v end
})

--------------------------------------------------
-- GUI : ESP
--------------------------------------------------
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
	Name = "Enable ESP",
	CurrentValue = true,
	Callback = function(v) ESPEnabled = v end
})

ESPTab:CreateToggle({
	Name = "Team Check",
	CurrentValue = false,
	Callback = function(v) TeamCheck = v end
})

ESPTab:CreateToggle({
	Name = "Box",
	CurrentValue = true,
	Callback = function(v) ESPBox = v end
})

ESPTab:CreateToggle({
	Name = "Name",
	CurrentValue = true,
	Callback = function(v) ESPName = v end
})

ESPTab:CreateToggle({
	Name = "HP",
	CurrentValue = true,
	Callback = function(v) ESPHP = v end
})

ESPTab:CreateToggle({
	Name = "Distance",
	CurrentValue = true,
	Callback = function(v) ESPDistance = v end
})

ESPTab:CreateColorPicker({
	Name = "Box Color",
	Color = BoxColor,
	Callback = function(v) BoxColor = v end
})

ESPTab:CreateColorPicker({
	Name = "Name Color",
	Color = NameColor,
	Callback = function(v) NameColor = v end
})

ESPTab:CreateColorPicker({
	Name = "HP Color",
	Color = HPColor,
	Callback = function(v) HPColor = v end
})
