--[[
	SlickUI — Dark, glassy UI library for Roblox
	Styled like Speed Hub X
	
	USAGE:
		local SlickUI = loadstring(game:HttpGet("YOUR_URL_HERE"))()
		local Window = SlickUI:CreateWindow('SILENT HUB', {
			Logo = 'image_url',
			Fullscreen = true,
			Version = '4.0.4'
		})
		local Tab = Window:CreateTab('Home')
		Tab:CreateSection('Main')
		Tab:CreateButton('Button', function() end)
		Tab:CreateToggle('Toggle', function(state) end)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ===================== THEME =====================

local Theme = {
	Blue      = Color3.fromRGB(0, 120, 255),
	BlueHover = Color3.fromRGB(30, 150, 255),
	BlueDark  = Color3.fromRGB(0, 80, 200),
	Bg        = Color3.fromRGB(12, 8, 9),
	Panel     = Color3.fromRGB(22, 14, 15),
	Panel2    = Color3.fromRGB(30, 17, 18),
	Panel3    = Color3.fromRGB(40, 20, 21),
	Ink       = Color3.fromRGB(255, 255, 255),
	Muted     = Color3.fromRGB(190, 160, 162),
	Dim       = Color3.fromRGB(130, 100, 102),
	Line      = Color3.fromRGB(80, 35, 38),
	Green     = Color3.fromRGB(0, 220, 120),
	Red       = Color3.fromRGB(255, 60, 60),
	Orange    = Color3.fromRGB(255, 160, 0),
	Accent      = Color3.fromRGB(220, 30, 45),
	AccentHover = Color3.fromRGB(250, 50, 65),
	AccentDark  = Color3.fromRGB(160, 15, 28),
}

-- ===================== THEME PRESETS =====================
-- Named presets people can switch to. "Bg/Panel/Panel2/Panel3/Line" are
-- dark neutral tones tinted toward the accent hue; "White" is the one
-- light-mode preset and flips Ink/Muted so text stays readable.
local ThemePresets = {
	Red = {
		Bg = Color3.fromRGB(12, 8, 9), Panel = Color3.fromRGB(22, 14, 15),
		Panel2 = Color3.fromRGB(30, 17, 18), Panel3 = Color3.fromRGB(40, 20, 21),
		Line = Color3.fromRGB(80, 35, 38), Muted = Color3.fromRGB(190, 160, 162),
		Dim = Color3.fromRGB(130, 100, 102), Ink = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(220, 30, 45), AccentHover = Color3.fromRGB(250, 50, 65),
		AccentDark = Color3.fromRGB(160, 15, 28),
	},
	Purple = {
		Bg = Color3.fromRGB(10, 8, 14), Panel = Color3.fromRGB(19, 15, 26),
		Panel2 = Color3.fromRGB(25, 19, 34), Panel3 = Color3.fromRGB(33, 24, 45),
		Line = Color3.fromRGB(65, 45, 90), Muted = Color3.fromRGB(175, 160, 195),
		Dim = Color3.fromRGB(115, 100, 140), Ink = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(140, 60, 230), AccentHover = Color3.fromRGB(165, 90, 245),
		AccentDark = Color3.fromRGB(95, 35, 165),
	},
	Blue = {
		Bg = Color3.fromRGB(8, 10, 14), Panel = Color3.fromRGB(15, 18, 26),
		Panel2 = Color3.fromRGB(20, 24, 34), Panel3 = Color3.fromRGB(27, 32, 45),
		Line = Color3.fromRGB(40, 55, 90), Muted = Color3.fromRGB(160, 175, 195),
		Dim = Color3.fromRGB(100, 115, 140), Ink = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(0, 130, 255), AccentHover = Color3.fromRGB(40, 160, 255),
		AccentDark = Color3.fromRGB(0, 85, 190),
	},
	Green = {
		Bg = Color3.fromRGB(8, 12, 10), Panel = Color3.fromRGB(15, 22, 18),
		Panel2 = Color3.fromRGB(19, 29, 23), Panel3 = Color3.fromRGB(25, 38, 30),
		Line = Color3.fromRGB(35, 80, 50), Muted = Color3.fromRGB(160, 190, 170),
		Dim = Color3.fromRGB(100, 130, 110), Ink = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(0, 200, 110), AccentHover = Color3.fromRGB(30, 225, 135),
		AccentDark = Color3.fromRGB(0, 140, 75),
	},
	Black = {
		Bg = Color3.fromRGB(8, 8, 8), Panel = Color3.fromRGB(15, 15, 15),
		Panel2 = Color3.fromRGB(20, 20, 20), Panel3 = Color3.fromRGB(28, 28, 28),
		Line = Color3.fromRGB(50, 50, 50), Muted = Color3.fromRGB(170, 170, 170),
		Dim = Color3.fromRGB(110, 110, 110), Ink = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(255, 255, 255), AccentHover = Color3.fromRGB(220, 220, 220),
		AccentDark = Color3.fromRGB(150, 150, 150),
	},
	White = {
		Bg = Color3.fromRGB(245, 245, 248), Panel = Color3.fromRGB(255, 255, 255),
		Panel2 = Color3.fromRGB(238, 238, 242), Panel3 = Color3.fromRGB(225, 225, 230),
		Line = Color3.fromRGB(210, 210, 216), Muted = Color3.fromRGB(90, 90, 100),
		Dim = Color3.fromRGB(140, 140, 150), Ink = Color3.fromRGB(20, 20, 25),
		Accent = Color3.fromRGB(30, 30, 30), AccentHover = Color3.fromRGB(60, 60, 60),
		AccentDark = Color3.fromRGB(0, 0, 0),
	},
}

-- Given any accent Color3, derive a full dark-mode palette around it.
-- Used when someone passes a raw color instead of a preset name.
local function deriveThemeFromColor(accent)
	local h, s, v = accent:ToHSV()
	local function hsv(hh, ss, vv)
		return Color3.fromHSV(hh % 1, math.clamp(ss, 0, 1), math.clamp(vv, 0, 1))
	end
	return {
		Bg = hsv(h, math.min(s, 0.25), 0.04),
		Panel = hsv(h, math.min(s, 0.3), 0.08),
		Panel2 = hsv(h, math.min(s, 0.3), 0.11),
		Panel3 = hsv(h, math.min(s, 0.3), 0.15),
		Line = hsv(h, math.min(s, 0.55), 0.32),
		Muted = hsv(h, math.min(s, 0.15), 0.72),
		Dim = hsv(h, math.min(s, 0.15), 0.5),
		Ink = Color3.fromRGB(255, 255, 255),
		Accent = accent,
		AccentHover = hsv(h, s, math.min(v + 0.15, 1)),
		AccentDark = hsv(h, s, math.max(v - 0.25, 0)),
	}
end


-- Exposed so users can extend/replace it, e.g.:
--   for k, v in pairs(myIconPack) do SlickUI.Icons[k] = v end
-- This built-in table is intentionally small — it's just a starter set.
-- Anything not found here falls back to being rendered as raw text,
-- which is exactly what you want for emoji icons like "🏠" or "⚙️" anyway.
local Icons = {
	home        = "rbxassetid://10723407389",
	settings    = "rbxassetid://10734950309",
	box         = "rbxassetid://10723407587",
	search      = "rbxassetid://10734943158",
	star        = "rbxassetid://10734949864",
	heart       = "rbxassetid://10734896206",
	user        = "rbxassetid://10734953705",
	folder      = "rbxassetid://10734923687",
	trash       = "rbxassetid://10747370946",
	info        = "rbxassetid://10734884756",
	bell        = "rbxassetid://10723347607",
	lock        = "rbxassetid://10723420531",
	shield      = "rbxassetid://10734945216",
	crystal     = "rbxassetid://10734855444",
	rebirth     = "rbxassetid://10734953705",
	killer      = "rbxassetid://11337391309",
	misc        = "rbxassetid://10723365810",
}

-- Returns "image", assetIdString  OR  "text", rawString  OR  nil if no icon given
local function resolveIcon(icon)
	if type(icon) ~= "string" or icon == "" then
		return nil, nil
	end
	-- Direct asset reference
	if icon:match("^rbxassetid://") or icon:match("^rbxthumb://") or icon:match("^https?://") then
		return "image", icon
	end
	-- Named lookup (case-insensitive). Supports both the shorthand form
	-- ("box") and the full Lucide-style key ("lucide-box") so you can
	-- merge in a big icon pack and call it either way.
	local key = icon:lower()
	local lookup = Icons[key] or Icons["lucide-" .. key]
	if lookup then
		return "image", lookup
	end
	-- Fall back to raw text — this is what makes emoji ("🏠") just work
	return "text", icon
end

-- ===================== HELPERS =====================

local function new(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	return inst
end

local function corner(radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function stroke(color, thickness, transparency)
	return new("UIStroke", {
		Color = color or Theme.Line,
		Thickness = thickness or 1,
		Transparency = transparency == nil and 0.7 or transparency,
	})
end

local function pad(l, t, r, b)
	return new("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or l or 0),
		PaddingBottom = UDim.new(0, b or t or 0),
	})
end

local function tween(inst, props, time, style, dir)
	local tweenInfo = TweenInfo.new(
		time or 0.2,
		style or Enum.EasingStyle.Quad,
		dir or Enum.EasingDirection.Out
	)
	local tweenObj = TweenService:Create(inst, tweenInfo, props)
	tweenObj:Play()
	return tweenObj
end

-- Adds a subtle hover glow to a row: the row's background gets slightly
-- more opaque and its border brightens toward the accent color. Pass the
-- element that should listen for the mouse (often the row itself, or an
-- invisible click-catcher button layered over it) and the row + its
-- UIStroke to animate.
local function addRowHover(listener, row, strokeInst, baseTransparency)
	baseTransparency = baseTransparency or 0.3
	listener.MouseEnter:Connect(function()
		tween(row, { BackgroundTransparency = math.max(baseTransparency - 0.15, 0) }, 0.15)
		if strokeInst then
			tween(strokeInst, { Transparency = 0.35, Color = Theme.Accent }, 0.15)
		end
	end)
	listener.MouseLeave:Connect(function()
		tween(row, { BackgroundTransparency = baseTransparency }, 0.15)
		if strokeInst then
			tween(strokeInst, { Transparency = 0.7, Color = Theme.Line }, 0.15)
		end
	end)
end

local function makeDraggable(handle, target)
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ===================== ROOT =====================

local SlickUI = {}
SlickUI.Icons = Icons
SlickUI.ThemePresets = ThemePresets

-- Change the color theme. Accepts:
--   A preset name:  SlickUI:SetTheme("Purple")   -- "Red","Purple","Blue","Green","Black","White"
--   A raw color:    SlickUI:SetTheme(Color3.fromRGB(255, 140, 0))  -- full palette auto-derived
--   A table:        SlickUI:SetTheme({ Accent = Color3.fromRGB(...), Bg = Color3.fromRGB(...) })
-- Mutates the shared Theme table in place, so call this BEFORE CreateWindow
-- (or pass Theme = "..." / Theme = Color3... directly into CreateWindow's
-- options table, which calls this for you at the right time).
function SlickUI:SetTheme(themeInput)
	local resolved
	if typeof(themeInput) == "Color3" then
		resolved = deriveThemeFromColor(themeInput)
	elseif type(themeInput) == "string" then
		resolved = ThemePresets[themeInput]
		if not resolved then
			-- Case-insensitive fallback match
			for name, preset in pairs(ThemePresets) do
				if name:lower() == themeInput:lower() then
					resolved = preset
					break
				end
			end
		end
		if not resolved then
			warn("SlickUI:SetTheme - unknown preset '" .. themeInput .. "'. Available: Red, Purple, Blue, Green, Black, White")
			return false
		end
	elseif type(themeInput) == "table" then
		resolved = themeInput
	else
		warn("SlickUI:SetTheme expected a preset name, Color3, or table")
		return false
	end

	for k, v in pairs(resolved) do
		Theme[k] = v
	end
	return true
end

-- Merge an external icon pack (a plain table of name -> rbxassetid) into
-- the built-in Icons table. Works with a table you already loaded:
--   local pack = loadstring(game:HttpGet("URL_TO/asset.lua"))()
--   SlickUI:LoadIconPack(pack)
-- or pass a URL directly and let this fetch + merge it for you:
--   SlickUI:LoadIconPack("https://raw.githubusercontent.com/you/repo/main/asset.lua")
function SlickUI:LoadIconPack(packOrUrl)
	local pack = packOrUrl
	if type(packOrUrl) == "string" then
		local ok, result = pcall(function()
			return loadstring(game:HttpGet(packOrUrl))()
		end)
		if not ok then
			warn("SlickUI:LoadIconPack failed to fetch/parse:", result)
			return false
		end
		pack = result
	end
	if type(pack) ~= "table" then
		warn("SlickUI:LoadIconPack expected a table, got:", type(pack))
		return false
	end
	-- Some packs wrap their table like { assets = {...} } — unwrap if so
	if type(pack.assets) == "table" then
		pack = pack.assets
	end
	local count = 0
	for k, v in pairs(pack) do
		if type(k) == "string" and type(v) == "string" then
			Icons[k:lower()] = v
			count = count + 1
		end
	end
	return true, count
end

local ScreenGui = new("ScreenGui", {
	Name = "SlickUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = PlayerGui,
})

local NotifHolder = new("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -20, 1, -20),
	Size = UDim2.new(0, 320, 1, -40),
	Parent = ScreenGui,
}, {
	new("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

-- Auto-load the built-in icon pack (1055+ Lucide icons) in the background.
-- IMPORTANT: this runs in its own thread via task.spawn, AFTER the
-- ScreenGui/NotifHolder above already exist. game:HttpGet() is a
-- blocking, synchronous call — if it were left at the top level of this
-- module (before any UI got created) a slow response, a rate limit, or
-- pastefy.app being briefly unreachable would silently stall the entire
-- script before CreateWindow ever ran, with no error printed. Wrapping
-- it in task.spawn guarantees CreateWindow/CreateTab/etc. always run
-- immediately; icons just merge in a moment later whenever the request
-- finishes (or the built-in fallback set above stays in effect if it
-- fails).
task.spawn(function()
	local ok, count = SlickUI:LoadIconPack("https://pastefy.app/e86T5YXs/raw")
	if ok then
		print("[SlickUI] Icon pack loaded:", count, "icons")
	end
end)

function SlickUI:Notify(opts)
	opts = opts or {}
	local card = new("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.1,
		Parent = NotifHolder,
	}, {
		corner(10),
		stroke(Theme.Accent, 1, 0.5),
		pad(16, 14, 16, 14),
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
		new("Frame", {
			BackgroundColor3 = Theme.Accent,
			Size = UDim2.new(0, 3, 1, 0),
			Parent = card,
		}, { corner(2) }),
		new("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Title or "Notification",
			TextColor3 = Theme.Ink,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 18),
			AutomaticSize = Enum.AutomaticSize.Y,
		}),
		new("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Content or "",
			TextColor3 = Theme.Muted,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}),
	})

	card.BackgroundTransparency = 1
	for _, d in ipairs(card:GetDescendants()) do
		if d:IsA("TextLabel") then
			d.TextTransparency = 1
		end
	end
	
	tween(card, { BackgroundTransparency = 0.1 }, 0.25)

	task.delay(opts.Duration or 3.5, function()
		tween(card, { BackgroundTransparency = 1 }, 0.25)
		task.wait(0.25)
		card:Destroy()
	end)
end

-- ===================== WINDOW =====================

function SlickUI:CreateWindow(title, options)
	options = options or {}
	if options.Theme then
		SlickUI:SetTheme(options.Theme)
	end
	local isFullscreen = options.Fullscreen or false
	local logoUrl = options.Logo or ""
	local version = options.Version or "1.0.0"

	local Window = {}
	Window.Tabs = {}
	Window.TabObjects = {}
	Window.IsFullscreen = isFullscreen
	Window.LogoUrl = logoUrl

	-- Window sizes
	local windowSize = isFullscreen and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 650, 0, 420)
	local windowPosition = isFullscreen and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, -325, 0.5, -210)
	local sidebarWidth = isFullscreen and 200 or 180
	local cornerRadius = isFullscreen and 0 or 12

	local Main = new("Frame", {
		Name = "Main",
		BackgroundColor3 = Theme.Bg,
		BackgroundTransparency = 0.05,
		Position = windowPosition,
		Size = windowSize,
		Parent = ScreenGui,
	}, {
		corner(cornerRadius),
		stroke(Theme.Line, 1, 0.5),
		new("UIGradient", {
			Color = ColorSequence.new(Theme.Bg, Theme.Panel),
			Rotation = 135,
		}),
	})

	-- Top bar
	local TopBar = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 56),
		Parent = Main,
	}, { pad(16, 0, 16, 0) })

	-- Logo + Title + Version auto-flow left to right, no manual offset math
	local HeaderGroup = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, -90, 1, 0),
		Parent = TopBar,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- Logo
	local LogoContainer = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 36, 0, 36),
		LayoutOrder = 1,
		Parent = HeaderGroup,
	})

	local LogoImage = new("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Image = logoUrl,
		ScaleType = Enum.ScaleType.Fit,
		Parent = LogoContainer,
	}, { corner(8) })

	if logoUrl == "" then
		LogoImage.Image = "rbxassetid://0"
		LogoImage.BackgroundColor3 = Theme.Accent
		LogoImage.BackgroundTransparency = 0
	end

	-- Title + Version stack vertically together, sized to their text
	local TitleGroup = new("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 2,
		Parent = HeaderGroup,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local TitleLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Text = title or "SlickUI",
		Font = Enum.Font.GothamBold,
		TextSize = isFullscreen and 20 or 18,
		TextColor3 = Theme.Ink,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 1,
		Parent = TitleGroup,
	})

	local VersionLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Text = "Version : " .. version,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 2,
		Parent = TitleGroup,
	})

	-- Control buttons
	local ButtonContainer = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 80, 1, 0),
		Parent = TopBar,
	})

	local CollapseBtn = new("TextButton", {
		Text = "−",
		Font = Enum.Font.GothamBold,
		TextSize = isFullscreen and 20 or 18,
		TextColor3 = Theme.Muted,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(0.3, 0, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		Parent = ButtonContainer,
	})
	CollapseBtn.MouseEnter:Connect(function() tween(CollapseBtn, { TextColor3 = Theme.Ink }, 0.12) end)
	CollapseBtn.MouseLeave:Connect(function() tween(CollapseBtn, { TextColor3 = Theme.Muted }, 0.12) end)

	local FullscreenBtn = new("TextButton", {
		Text = "⛶",
		Font = Enum.Font.GothamBold,
		TextSize = isFullscreen and 16 or 14,
		TextColor3 = Theme.Muted,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(0.65, 0, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		Parent = ButtonContainer,
	})
	FullscreenBtn.MouseEnter:Connect(function() tween(FullscreenBtn, { TextColor3 = Theme.Ink }, 0.12) end)
	FullscreenBtn.MouseLeave:Connect(function() tween(FullscreenBtn, { TextColor3 = Theme.Muted }, 0.12) end)

	local CloseBtn = new("TextButton", {
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = isFullscreen and 22 or 20,
		TextColor3 = Theme.Muted,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		Parent = ButtonContainer,
	})
	CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, { TextColor3 = Theme.Red }, 0.12) end)
	CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, { TextColor3 = Theme.Muted }, 0.12) end)
	CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

	-- State tracking
	local isCollapsed = false
	local isFullscreenState = isFullscreen

	-- Collapse function
	local function toggleCollapse()
		isCollapsed = not isCollapsed
		if isCollapsed then
			local targetSize = UDim2.new(0, 220, 0, 50)
			local targetPos = UDim2.new(0.5, -110, 0.5, -25)
			tween(Main, { Size = targetSize, Position = targetPos }, 0.3)
			CollapseBtn.Text = "+"
			for _, child in ipairs(Main:GetChildren()) do
				if child ~= TopBar then
					tween(child, { BackgroundTransparency = 1 }, 0.2)
					task.wait(0.05)
					child.Visible = false
				end
			end
		else
			local targetSize = isFullscreenState and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 650, 0, 420)
			local targetPos = isFullscreenState and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, -325, 0.5, -210)
			tween(Main, { Size = targetSize, Position = targetPos }, 0.3)
			CollapseBtn.Text = "−"
			for _, child in ipairs(Main:GetChildren()) do
				if child ~= TopBar then
					child.Visible = true
					tween(child, { BackgroundTransparency = 0 }, 0.2)
				end
			end
		end
	end

	CollapseBtn.MouseButton1Click:Connect(toggleCollapse)

	-- Fullscreen toggle function
	local function toggleFullscreen()
		isFullscreenState = not isFullscreenState
		if isFullscreenState then
			tween(Main, { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0) }, 0.3)
			FullscreenBtn.Text = "⛶"
		else
			tween(Main, { Size = UDim2.new(0, 650, 0, 420), Position = UDim2.new(0.5, -325, 0.5, -210) }, 0.3)
			FullscreenBtn.Text = "⛶"
		end
	end

	FullscreenBtn.MouseButton1Click:Connect(toggleFullscreen)

	makeDraggable(TopBar, Main)

	-- Separator line
	new("Frame", {
		BackgroundColor3 = Theme.Line,
		BackgroundTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 56),
		Parent = Main,
	})

	-- Sidebar
	local Sidebar = new("Frame", {
		BackgroundColor3 = Theme.Panel2,
		BackgroundTransparency = 0.3,
		Position = UDim2.new(0, 0, 0, 57),
		Size = UDim2.new(0, sidebarWidth, 1, -57),
		Parent = Main,
	}, {
		corner(0),
		pad(8, 8, 8, 8),
		new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	new("Frame", {
		BackgroundColor3 = Theme.Line,
		BackgroundTransparency = 0.5,
		Size = UDim2.new(0, 1, 1, -57),
		Position = UDim2.new(0, sidebarWidth, 0, 57),
		Parent = Main,
	})

	-- Content area
	local ContentHolder = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, sidebarWidth + 1, 0, 57),
		Size = UDim2.new(1, -(sidebarWidth + 1), 1, -57),
		Parent = Main,
	})

	Window.Main = Main
	Window.Sidebar = Sidebar
	Window.ContentHolder = ContentHolder
	Window.TopBar = TopBar
	Window.ScreenGui = ScreenGui

	function Window:SetLogo(url)
		LogoImage.Image = url
		if url == "" then
			LogoImage.Image = "rbxassetid://0"
			LogoImage.BackgroundColor3 = Theme.Accent
			LogoImage.BackgroundTransparency = 0
		end
	end

	function Window:CreateTab(name, icon)
		local Tab = {}
		Tab.Name = name

		local iconKind, iconValue = resolveIcon(icon)
		local textOffset = iconKind and 30 or 0

		local TabBtn = new("TextButton", {
			Text = "",
			BackgroundColor3 = Theme.Panel3,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 36),
			Parent = Sidebar,
		}, { 
			corner(6), 
			new("UIStroke", {
				Color = Theme.Line,
				Thickness = 1,
				Transparency = 1,
			}),
			new("Frame", {
				Name = "AccentBar",
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0, 3, 0, 16),
			}, { corner(2) }),
		})

		if iconKind == "image" then
			new("ImageLabel", {
				Name = "Icon",
				BackgroundTransparency = 1,
				Image = iconValue,
				ImageColor3 = Theme.Muted,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				Parent = TabBtn,
			})
		elseif iconKind == "text" then
			-- Covers emoji ("🏠") and any unrecognized name string
			new("TextLabel", {
				Name = "Icon",
				BackgroundTransparency = 1,
				Text = iconValue,
				Font = Enum.Font.GothamBold,
				TextSize = 15,
				TextColor3 = Theme.Muted,
				TextXAlignment = Enum.TextXAlignment.Center,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.new(0, 18, 0, 18),
				Parent = TabBtn,
			})
		end

		local TabLabel = new("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Text = name,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12 + textOffset, 0.5, 0),
			Size = UDim2.new(1, -(24 + textOffset), 1, 0),
			Parent = TabBtn,
		})

		local Page = new("ScrollingFrame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent,
			ScrollBarImageTransparency = 0.3,
			Visible = false,
			Parent = ContentHolder,
		}, {
			pad(20, 16, 20, 16),
			new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		})

		Tab.Page = Page
		Tab.Button = TabBtn

		local function select()
			for _, t in pairs(Window.TabObjects) do
				t.Page.Visible = false
				tween(t.Button, { 
					BackgroundTransparency = 1, 
					BackgroundColor3 = Theme.Panel3
				}, 0.12)
				local strokeObj = t.Button:FindFirstChild("UIStroke")
				if strokeObj then
					tween(strokeObj, { Transparency = 1 }, 0.12)
				end
				local bar = t.Button:FindFirstChild("AccentBar")
				if bar then
					tween(bar, { BackgroundTransparency = 1 }, 0.12)
				end
				local label = t.Button:FindFirstChild("Label")
				if label then
					tween(label, { TextColor3 = Theme.Muted }, 0.12)
				end
				local iconEl = t.Button:FindFirstChild("Icon")
				if iconEl then
					if iconEl:IsA("ImageLabel") then
						tween(iconEl, { ImageColor3 = Theme.Muted }, 0.12)
					else
						tween(iconEl, { TextColor3 = Theme.Muted }, 0.12)
					end
				end
			end
			Page.Visible = true
			tween(TabBtn, { 
				BackgroundTransparency = 0.4,
				BackgroundColor3 = Theme.AccentDark
			}, 0.12)
			local strokeObj = TabBtn:FindFirstChild("UIStroke")
			if strokeObj then
				tween(strokeObj, { Transparency = 0.7, Color = Theme.Accent }, 0.12)
			end
			local bar = TabBtn:FindFirstChild("AccentBar")
			if bar then
				tween(bar, { BackgroundTransparency = 0 }, 0.12)
			end
			tween(TabLabel, { TextColor3 = Theme.Ink }, 0.12)
			local iconEl = TabBtn:FindFirstChild("Icon")
			if iconEl then
				if iconEl:IsA("ImageLabel") then
					tween(iconEl, { ImageColor3 = Theme.Ink }, 0.12)
				else
					tween(iconEl, { TextColor3 = Theme.Ink }, 0.12)
				end
			end
		end

		TabBtn.MouseButton1Click:Connect(select)
		table.insert(Window.TabObjects, Tab)

		if #Window.TabObjects == 1 then select() end

		-- ============ COMPONENTS ============

		function Tab:CreateSection(text)
			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = text,
				Font = Enum.Font.GothamBold,
				TextSize = 15,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 24),
				Parent = Page,
			})
		end

		function Tab:CreateLabel(text)
			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Muted,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = Page,
			})
		end

		function Tab:CreateButton(text, callback)
			local Btn = new("TextButton", {
				Text = text or "Button",
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 0.2,
				Size = UDim2.new(1, 0, 0, 38),
				Parent = Page,
			}, { 
				corner(8),
				new("UIStroke", {
					Color = Theme.Accent,
					Thickness = 1,
					Transparency = 0.3,
				})
			})
			Btn.MouseEnter:Connect(function() 
				tween(Btn, { 
					BackgroundTransparency = 0.05,
					BackgroundColor3 = Theme.Accent
				}, 0.12) 
			end)
			Btn.MouseLeave:Connect(function() 
				tween(Btn, { 
					BackgroundTransparency = 0.2,
					BackgroundColor3 = Theme.Accent
				}, 0.12) 
			end)
			Btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
			return Btn
		end

		function Tab:CreateToggle(text, callback)
			local state = false
			local isUpdating = false

			local RowStroke = stroke(Theme.Line, 1, 0.7)
			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 0, 42),
				Parent = Page,
			}, { 
				corner(8), 
				RowStroke,
				pad(14, 0, 14, 0) 
			})

			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = text or "Toggle",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -60, 1, 0),
				Parent = Row,
			})

			local Track = new("Frame", {
				BackgroundColor3 = Theme.Panel3,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 44, 0, 22),
				Parent = Row,
			}, { 
				corner(11),
				stroke(Theme.Line, 1, 0.5)
			})

			local Knob = new("Frame", {
				BackgroundColor3 = Theme.Muted,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 3, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				Parent = Track,
			}, { corner(8) })

			local function updateToggle(newState)
				if isUpdating then return end
				isUpdating = true
				
				state = newState
				if state then
					tween(Track, { BackgroundColor3 = Theme.Accent }, 0.15)
					tween(Knob, { 
						Position = UDim2.new(1, -19, 0.5, 0),
						BackgroundColor3 = Theme.Ink
					}, 0.15)
				else
					tween(Track, { BackgroundColor3 = Theme.Panel3 }, 0.15)
					tween(Knob, { 
						Position = UDim2.new(0, 3, 0.5, 0),
						BackgroundColor3 = Theme.Muted
					}, 0.15)
				end
				
				if callback then callback(state) end
				isUpdating = false
			end

			local click = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				Parent = Row,
			})

			click.MouseButton1Click:Connect(function()
				updateToggle(not state)
			end)

			addRowHover(click, Row, RowStroke)

			return { 
				Set = function(v) 
					updateToggle(v)
				end,
				Get = function() return state end,
				Toggle = function()
					updateToggle(not state)
				end
			}
		end

		function Tab:CreateSlider(text, min, max, callback)
			min = min or 0
			max = max or 100
			local value = min

			local RowStroke = stroke(Theme.Line, 1, 0.7)
			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 0, 52),
				Parent = Page,
			}, { 
				corner(8), 
				RowStroke,
				pad(14, 8, 14, 8) 
			})
			addRowHover(Row, Row, RowStroke)

			local TitleLabel = new("TextLabel", {
				BackgroundTransparency = 1,
				Text = text or "Slider",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -60, 0, 18),
				Parent = Row,
			})

			local ValLabel = new("TextLabel", {
				BackgroundTransparency = 1,
				Text = tostring(value),
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextColor3 = Theme.Accent,
				TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 50, 0, 18),
				Parent = Row,
			})

			local Bar = new("Frame", {
				BackgroundColor3 = Theme.Panel3,
				Position = UDim2.new(0, 0, 0, 26),
				Size = UDim2.new(1, 0, 0, 6),
				Parent = Row,
			}, { corner(3) })

			local Fill = new("Frame", {
				BackgroundColor3 = Theme.Accent,
				Size = UDim2.new(0, 0, 1, 0),
				Parent = Bar,
			}, { corner(3) })

			local dragging = false
			local function updateFromX(x)
				local pct = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				value = math.floor(min + (max - min) * pct)
				Fill.Size = UDim2.new(pct, 0, 1, 0)
				ValLabel.Text = tostring(value)
				if callback then callback(value) end
			end

			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateFromX(input.Position.X)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromX(input.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			return { 
				Set = function(v) 
					value = math.clamp(v, min, max)
					local pct = (value - min) / (max - min)
					Fill.Size = UDim2.new(pct, 0, 1, 0)
					ValLabel.Text = tostring(value)
					if callback then callback(value) end
				end,
				Get = function() return value end
			}
		end

		function Tab:CreateBox(text, callback)
			local RowStroke = stroke(Theme.Line, 1, 0.7)
			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 0, 42),
				Parent = Page,
			}, { 
				corner(8), 
				RowStroke,
				pad(14, 0, 14, 0) 
			})
			addRowHover(Row, Row, RowStroke)

			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = text or "Input",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.4, 0, 1, 0),
				Parent = Row,
			})

			local BoxStroke = stroke(Theme.Line, 1, 0.5)
			local Box = new("TextBox", {
				BackgroundColor3 = Theme.Panel3,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				Text = "",
				PlaceholderText = "Enter value...",
				PlaceholderColor3 = Theme.Dim,
				TextXAlignment = Enum.TextXAlignment.Left,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0.55, 0, 0.7, 0),
				Parent = Row,
			}, { 
				corner(6), 
				pad(10, 0, 10, 0),
				BoxStroke
			})

			Box.Focused:Connect(function()
				tween(BoxStroke, { Transparency = 0, Color = Theme.Accent }, 0.15)
			end)

			Box.FocusLost:Connect(function()
				tween(BoxStroke, { Transparency = 0.5, Color = Theme.Line }, 0.15)
				if callback then callback(Box.Text) end
			end)

			return { 
				Set = function(v) Box.Text = tostring(v) end,
				Get = function() return Box.Text end
			}
		end

		function Tab:CreateDropdown(text, options, callback)
			local open = false
			local selected = options[1] or ""

			-- Cap the visible list to 6 rows; anything beyond scrolls internally
			local visibleRows = math.min(#options, 6)
			local listHeight = visibleRows * 28

			local RowStroke = stroke(Theme.Line, 1, 0.7)
			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				BackgroundTransparency = 0.3,
				ClipsDescendants = true,
				Size = UDim2.new(1, 0, 0, 42),
				Parent = Page,
			}, { 
				corner(8), 
				RowStroke,
			})

			local Head = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 0, 42),
				Parent = Row,
			}, { pad(14, 0, 14, 0) })
			addRowHover(Head, Row, RowStroke)

			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = text or "Dropdown",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.5, 0, 1, 0),
				Parent = Head,
			})

			local SelLabel = new("TextLabel", {
				BackgroundTransparency = 1,
				Text = tostring(selected),
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = Theme.Muted,
				TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				Parent = Head,
			})

			local Arrow = new("TextLabel", {
				BackgroundTransparency = 1,
				Text = "▼",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = Theme.Dim,
				TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.new(0, 20, 1, 0),
				Parent = Head,
			})

			local List = new("ScrollingFrame", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 42),
				Size = UDim2.new(1, 0, 0, listHeight),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Theme.Accent,
				ScrollBarImageTransparency = 0.3,
				Parent = Row,
			}, {
				pad(14, 4, 14, 8),
				new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
			})

			for _, opt in ipairs(options) do
				local OptBtn = new("TextButton", {
					Text = tostring(opt),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = Theme.Muted,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 24),
					Parent = List,
				})
				OptBtn.MouseButton1Click:Connect(function()
					selected = opt
					SelLabel.Text = tostring(opt)
					open = false
					tween(Row, { Size = UDim2.new(1, 0, 0, 42) }, 0.15)
					tween(Arrow, { Text = "▼" }, 0.15)
					if callback then callback(opt) end
				end)
				OptBtn.MouseEnter:Connect(function() tween(OptBtn, { TextColor3 = Theme.Ink }, 0.1) end)
				OptBtn.MouseLeave:Connect(function() tween(OptBtn, { TextColor3 = Theme.Muted }, 0.1) end)
			end

			Head.MouseButton1Click:Connect(function()
				open = not open
				tween(Row, { Size = UDim2.new(1, 0, 0, open and (42 + #options * 28) or 42) }, 0.15)
				tween(Arrow, { Text = open and "▲" or "▼" }, 0.15)
			end)

			return { 
				Set = function(v) 
					selected = v
					SelLabel.Text = tostring(v)
					if callback then callback(v) end
				end,
				Get = function() return selected end
			}
		end

		function Tab:CreateColorPicker(text, callback)
			local state = Color3.fromRGB(0, 120, 255)

			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 0, 42),
				Parent = Page,
			}, { 
				corner(8), 
				stroke(Theme.Line, 1, 0.7),
				pad(14, 0, 14, 0) 
			})

			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = text or "Color Picker",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -50, 1, 0),
				Parent = Row,
			})

			local ColorDisplay = new("Frame", {
				BackgroundColor3 = state,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 30, 0, 30),
				Parent = Row,
			}, { 
				corner(8), 
				stroke(Theme.Line, 1, 0.5) 
			})

			local pickerBtn = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				Parent = Row,
			})

			local colors = {
				Color3.fromRGB(0, 120, 255),
				Color3.fromRGB(255, 60, 60),
				Color3.fromRGB(0, 220, 120),
				Color3.fromRGB(255, 160, 0),
				Color3.fromRGB(255, 0, 255),
				Color3.fromRGB(0, 255, 255),
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(128, 0, 255),
				Color3.fromRGB(255, 192, 203),
			}
			local colorIndex = 1

			pickerBtn.MouseButton1Click:Connect(function()
				colorIndex = colorIndex % #colors + 1
				state = colors[colorIndex]
				ColorDisplay.BackgroundColor3 = state
				if callback then callback(state) end
			end)

			return { 
				Set = function(v) 
					state = v
					ColorDisplay.BackgroundColor3 = v
					if callback then callback(v) end
				end,
				Get = function() return state end
			}
		end

		return Tab
	end

	-- Table-style API: Window:AddTab({ Title = "Main", Icon = "box" })
	function Window:AddTab(props)
		props = props or {}
		return Window:CreateTab(props.Title or props.Name or "Tab", props.Icon)
	end

	return Window
end

return SlickUI
