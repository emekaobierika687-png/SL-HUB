--[[
	SlickUI v2 — dark, glassy, blue/black-shaded UI library for Roblox

	NEW IN v2:
	  - Auto-scales to the player's screen (desktop/tablet/mobile) via UIScale
	  - Diagonal blue -> black gradient background instead of flat black
	  - Faint background grid (toggleable) like the reference site
	  - Soft top glow ("orb") behind the header
	  - Switchable accent themes: Blue / Purple / Teal / Red / Green / Orange
	  - Smoother tweens on everything, incl. a working drag-slider
	  - New CreateSection() header + CreateThemePicker() swatch row

	USAGE:
		local SlickUI = loadstring(game:HttpGet("RAW_URL"))()

		local Window = SlickUI:CreateWindow({
			Title = "CavTape",
			SubTitle = "v2.0",
			Accent = "Blue",   -- Blue / Purple / Teal / Red / Green / Orange
			Grid = true,       -- background grid on/off
		})

		local Tab = Window:CreateTab("Home")
		Tab:CreateSection("General")
		Tab:CreateToggle({ Text = "Enabled", Default = true, Callback = function(v) end })
		Tab:CreateSlider({ Text = "Speed", Min = 0, Max = 100, Default = 50, Callback = function(v) end })
		Tab:CreateThemePicker() -- lets the user swap accent colors live

		SlickUI:Notify({ Title = "Saved", Content = "Config saved.", Duration = 3 })
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ===================== THEME =====================

local Accents = {
	Blue   = Color3.fromRGB(0, 104, 249),
	Purple = Color3.fromRGB(130, 90, 255),
	Teal   = Color3.fromRGB(0, 209, 190),
	Red    = Color3.fromRGB(255, 66, 92),
	Green  = Color3.fromRGB(50, 220, 130),
	Orange = Color3.fromRGB(255, 145, 50),
}

local Theme = {
	Accent    = Accents.Blue,
	AccentDim = Color3.fromRGB(39, 128, 255),
	Bg        = Color3.fromRGB(6, 8, 11),
	BgBlue    = Color3.fromRGB(8, 16, 30),   -- mixed-in blue-black shade
	Panel     = Color3.fromRGB(13, 17, 24),
	Panel2    = Color3.fromRGB(19, 25, 34),
	Ink       = Color3.fromRGB(246, 248, 251),
	Muted     = Color3.fromRGB(140, 150, 167),
	Dim       = Color3.fromRGB(93, 103, 119),
	Line      = Color3.fromRGB(255, 255, 255),
}

-- objects registered here get recolored live when the accent changes
local AccentBindings = {} -- { {inst=Frame, prop="BackgroundColor3"}, ... }

local function bindAccent(inst, prop)
	prop = prop or "BackgroundColor3"
	AccentBindings[#AccentBindings + 1] = { inst = inst, prop = prop }
	inst[prop] = Theme.Accent
end

-- ===================== HELPERS =====================

local function new(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	return inst
end

local function corner(r) return new("UICorner", { CornerRadius = UDim.new(0, r or 10) }) end

local function stroke(color, thickness, transparency)
	return new("UIStroke", {
		Color = color or Theme.Line,
		Thickness = thickness or 1,
		Transparency = transparency == nil and 0.88 or transparency,
	})
end

local function pad(l, t, r, b)
	return new("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0), PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or l or 0), PaddingBottom = UDim.new(0, b or t or 0),
	})
end

local function tween(inst, props, time, style, dir)
	TweenService:Create(inst, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function makeDraggable(handle, target)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- soft round glow built from stacked, fading circles (no image assets needed)
local function glowOrb(parent, size, color, centerTransparency)
	local holder = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, size, 0, size * 0.6),
		Parent = parent,
	})
	local steps = 4
	for i = steps, 1, -1 do
		local scale = i / steps
		new("Frame", {
			BackgroundColor3 = color,
			BackgroundTransparency = 1 - ((1 - (centerTransparency or 0.55)) * (1 - scale) * 0.6 + (1 - scale) * 0.15),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(scale, 0, scale, 0),
			ZIndex = i,
			Parent = holder,
		}, { corner(9999) })
	end
	return holder
end

-- ===================== ROOT =====================

local SlickUI = {}
SlickUI.__index = SlickUI

local ScreenGui = new("ScreenGui", {
	Name = "SlickUI", ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = PlayerGui,
})

local NotifHolder = new("Frame", {
	Name = "Notifications", BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -20),
	Size = UDim2.new(0, 300, 1, -40), Parent = ScreenGui,
}, {
	new("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

function SlickUI:Notify(opts)
	opts = opts or {}
	local card = new("Frame", {
		BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = NotifHolder,
	}, {
		corner(12), stroke(Theme.Line, 1, 0.88), pad(14, 12, 14, 12),
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
		new("TextLabel", {
			BackgroundTransparency = 1, Text = opts.Title or "Notification", TextColor3 = Theme.Ink,
			Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.Y,
		}),
		new("TextLabel", {
			BackgroundTransparency = 1, Text = opts.Content or "", TextColor3 = Theme.Muted,
			Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		}),
	})
	local accent = new("Frame", { Size = UDim2.new(0, 3, 1, 0), Parent = card }, { corner(2) })
	bindAccent(accent)

	tween(card, { BackgroundTransparency = 0.05 }, 0.25)
	task.delay(opts.Duration or 3.5, function()
		tween(card, { BackgroundTransparency = 1 }, 0.25)
		task.wait(0.25)
		card:Destroy()
	end)
end

function SlickUI:SetAccent(nameOrColor)
	local color = typeof(nameOrColor) == "Color3" and nameOrColor or Accents[nameOrColor]
	if not color then return end
	Theme.Accent = color
	for _, b in ipairs(AccentBindings) do
		tween(b.inst, { [b.prop] = color }, 0.2)
	end
end

-- ===================== WINDOW =====================

function SlickUI:CreateWindow(opts)
	opts = opts or {}
	if opts.Accent and Accents[opts.Accent] then Theme.Accent = Accents[opts.Accent] end

	local Window = setmetatable({}, SlickUI)
	Window.Tabs = {}

	local Main = new("Frame", {
		Name = "Main", BackgroundColor3 = Theme.Bg, ClipsDescendants = true,
		Position = UDim2.new(0.5, -290, 0.5, -190), Size = UDim2.new(0, 580, 0, 380),
		Parent = ScreenGui,
	}, {
		corner(18), stroke(Theme.Line, 1, 0.85),
		new("UIGradient", {
			Color = ColorSequence.new(Theme.BgBlue, Theme.Bg),
			Rotation = 65,
		}),
	})

	-- UIScale that keeps the panel a sensible size on any device
	local Scale = new("UIScale", { Scale = 1, Parent = Main })
	local function updateScale()
		local vp = Camera.ViewportSize
		local s = math.clamp(math.min(vp.X / 1280, vp.Y / 800), 0.55, 1.05)
		tween(Scale, { Scale = s }, 0.25)
		-- re-center after scaling so it never drifts off-screen on tiny devices
		Main.Position = UDim2.new(0.5, -290, 0.5, -190)
	end
	updateScale()
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

	-- background glow behind the header, like the hero orb in the reference
	local orb = glowOrb(Main, 620, Theme.Accent, 0.62)
	orb.Position = UDim2.new(0.5, 0, 0, -40)
	bindAccent(orb:GetChildren()[1])
	for _, c in ipairs(orb:GetChildren()) do bindAccent(c) end

	-- faint grid backdrop
	if opts.Grid ~= false then
		local Grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 0, Parent = Main })
		for x = 0, 580, 40 do
			new("Frame", { BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.955, Position = UDim2.new(0, x, 0, 0), Size = UDim2.new(0, 1, 1, 0), ZIndex = 0, Parent = Grid })
		end
		for y = 0, 380, 40 do
			new("Frame", { BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.955, Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, 0, 0, 1), ZIndex = 0, Parent = Grid })
		end
	end

	-- top accent hairline (animated left-right like the reference underline glow)
	local hairline = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 2), Parent = Main }, {
		new("UIGradient", {
			Color = ColorSequence.new(Theme.Accent, Theme.Accent),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.4),
			}),
		}),
	})

	local TopBar = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 54), Parent = Main }, { pad(18, 0, 18, 0) })

	new("TextLabel", {
		BackgroundTransparency = 1, Text = opts.Title or "SlickUI", Font = Enum.Font.GothamBold, TextSize = 16,
		TextColor3 = Theme.Ink, TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 200, 1, 0), Parent = TopBar,
	})

	if opts.SubTitle then
		new("TextLabel", {
			BackgroundTransparency = 1, Text = opts.SubTitle, Font = Enum.Font.Gotham, TextSize = 11,
			TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 76, 0.5, 0), Size = UDim2.new(0, 120, 1, 0), Parent = TopBar,
		})
	end

	local CloseBtn = new("TextButton", {
		Text = "×", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Theme.Muted, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 28, 0, 28), Parent = TopBar,
	})
	CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, { TextColor3 = Theme.Ink }, 0.12) end)
	CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, { TextColor3 = Theme.Muted }, 0.12) end)
	CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

	makeDraggable(TopBar, Main)

	new("Frame", { BackgroundColor3 = Theme.Line, BackgroundTransparency = 0.92, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 54), Parent = Main })

	local Sidebar = new("Frame", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 55), Size = UDim2.new(0, 150, 1, -55), Parent = Main,
	}, { pad(12, 12, 12, 12), new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	new("Frame", { BackgroundColor3 = Theme.Line, BackgroundTransparency = 0.92, Size = UDim2.new(0, 1, 1, -55), Position = UDim2.new(0, 150, 0, 55), Parent = Main })

	local ContentHolder = new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 151, 0, 55), Size = UDim2.new(1, -151, 1, -55), Parent = Main })

	Window.Main, Window.Sidebar, Window.ContentHolder = Main, Sidebar, ContentHolder

	function Window:CreateTab(name)
		local Tab = {}
		Tab.Name = name

		local TabBtn = new("TextButton", {
			Text = name, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = Theme.Panel2, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32), Parent = Sidebar,
		}, { corner(8), pad(10, 0, 10, 0) })

		local Page = new("ScrollingFrame", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3, ScrollBarImageTransparency = 0.4, Visible = false, Parent = ContentHolder,
		}, { pad(18, 16, 18, 16), new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
		bindAccent(Page, "ScrollBarImageColor3")

		Tab.Page = Page

		local function select()
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				tween(t.Button, { BackgroundTransparency = 1, TextColor3 = Theme.Muted }, 0.12)
			end
			Page.Visible = true
			tween(TabBtn, { BackgroundTransparency = 0, TextColor3 = Theme.Ink }, 0.12)
		end

		TabBtn.MouseButton1Click:Connect(select)
		Tab.Button = TabBtn
		Window.Tabs[#Window.Tabs + 1] = Tab
		if #Window.Tabs == 1 then select() end

		function Tab:CreateSection(text)
			new("TextLabel", {
				BackgroundTransparency = 1, Text = string.upper(text), Font = Enum.Font.GothamBold, TextSize = 11,
				TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 20), Parent = Page,
			})
		end

		function Tab:CreateLabel(text)
			new("TextLabel", {
				BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Muted,
				TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Page,
			})
		end

		function Tab:CreateButton(o)
			o = o or {}
			local Btn = new("TextButton", {
				Text = o.Text or "Button", Font = Enum.Font.GothamMedium, TextSize = 13,
				TextColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(1, 0, 0, 36), Parent = Page,
			}, { corner(10) })
			bindAccent(Btn)
			Btn.MouseEnter:Connect(function() tween(Btn, { BackgroundColor3 = Theme.AccentDim }, 0.12) end)
			Btn.MouseLeave:Connect(function() tween(Btn, { BackgroundColor3 = Theme.Accent }, 0.12) end)
			Btn.MouseButton1Click:Connect(function() if o.Callback then o.Callback() end end)
			return Btn
		end

		function Tab:CreateToggle(o)
			o = o or {}
			local state = o.Default or false
			local Row = new("Frame", { BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 40), Parent = Page }, { corner(10), stroke(Theme.Line, 1, 0.9), pad(12, 0, 12, 0) })
			new("TextLabel", { BackgroundTransparency = 1, Text = o.Text or "Toggle", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Ink, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -50, 1, 0), Parent = Row })
			local Track = new("Frame", { BackgroundColor3 = state and Theme.Accent or Theme.Panel2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 38, 0, 20), Parent = Row }, { corner(10), stroke(Theme.Line, 1, 0.85) })
			local Knob = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), Size = UDim2.new(0, 16, 0, 16), Parent = Track }, { corner(8) })
			if state then bindAccent(Track) end
			local click = new("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 1, 0), Parent = Row })
			click.MouseButton1Click:Connect(function()
				state = not state
				tween(Track, { BackgroundColor3 = state and Theme.Accent or Theme.Panel2 }, 0.15)
				tween(Knob, { Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }, 0.15)
				if o.Callback then o.Callback(state) end
			end)
			return { Set = function(v) if v ~= state then click.MouseButton1Click:Fire() end end }
		end

		function Tab:CreateSlider(o)
			o = o or {}
			local min, max = o.Min or 0, o.Max or 100
			local value = math.clamp(o.Default or min, min, max)
			local Row = new("Frame", { BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 50), Parent = Page }, { corner(10), stroke(Theme.Line, 1, 0.9), pad(12, 10, 12, 10) })
			new("TextLabel", { BackgroundTransparency = 1, Text = o.Text or "Slider", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Ink, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -50, 0, 16), Parent = Row })
			local ValLabel = new("TextLabel", { BackgroundTransparency = 1, Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 50, 0, 16), Parent = Row })
			bindAccent(ValLabel, "TextColor3")
			local Bar = new("Frame", { BackgroundColor3 = Theme.Panel2, Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 6), Parent = Row }, { corner(3) })
			local Fill = new("Frame", { Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0), Parent = Bar }, { corner(3) })
			bindAccent(Fill)
			local Knob = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new((value - min) / math.max(max - min, 1), 0, 0.5, 0), Size = UDim2.new(0, 12, 0, 12), ZIndex = 2, Parent = Bar }, { corner(6), stroke(Theme.Accent, 2, 0) })

			local dragging = false
			local function updateFromX(x)
				local pct = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				value = math.floor(min + (max - min) * pct)
				Fill.Size = UDim2.new(pct, 0, 1, 0)
				Knob.Position = UDim2.new(pct, 0, 0.5, 0)
				ValLabel.Text = tostring(value)
				if o.Callback then o.Callback(value) end
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

			return { Set = function(v) updateFromX(Bar.AbsolutePosition.X + (math.clamp(v, min, max) - min) / math.max(max - min, 1) * Bar.AbsoluteSize.X) end }
		end

		function Tab:CreateDropdown(o)
			o = o or {}
			local options = o.Options or {}
			local open = false
			local selected = o.Default or options[1]
			local Row = new("Frame", { BackgroundColor3 = Theme.Panel, ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 40), Parent = Page }, { corner(10), stroke(Theme.Line, 1, 0.9) })
			local Head = new("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 40), Parent = Row }, { pad(12, 0, 12, 0) })
			new("TextLabel", { BackgroundTransparency = 1, Text = o.Text or "Dropdown", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Ink, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.5, 0, 1, 0), Parent = Head })
			local SelLabel = new("TextLabel", { BackgroundTransparency = 1, Text = tostring(selected), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), Parent = Head })
			local List = new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 0, #options * 30), Parent = Row }, { pad(12, 4, 12, 8), new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
			for _, opt in ipairs(options) do
				local OptBtn = new("TextButton", { Text = tostring(opt), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Parent = List })
				OptBtn.MouseButton1Click:Connect(function()
					selected = opt
					SelLabel.Text = tostring(opt)
					open = false
					tween(Row, { Size = UDim2.new(1, 0, 0, 40) }, 0.15)
					if o.Callback then o.Callback(opt) end
				end)
				OptBtn.MouseEnter:Connect(function() tween(OptBtn, { TextColor3 = Theme.Ink }, 0.1) end)
				OptBtn.MouseLeave:Connect(function() tween(OptBtn, { TextColor3 = Theme.Muted }, 0.1) end)
			end
			Head.MouseButton1Click:Connect(function()
				open = not open
				tween(Row, { Size = UDim2.new(1, 0, 0, open and (40 + #options * 30) or 40) }, 0.15)
			end)
			return { Set = function(v) selected = v; SelLabel.Text = tostring(v) end }
		end

		function Tab:CreateThemePicker()
			Tab:CreateSection("Accent Color")
			local Row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Parent = Page }, {
				new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
			for name, color in pairs(Accents) do
				local Swatch = new("TextButton", { Text = "", BackgroundColor3 = color, Size = UDim2.new(0, 28, 0, 28), Parent = Row }, { corner(8), stroke(Theme.Line, 1, 0.7) })
				Swatch.MouseButton1Click:Connect(function() SlickUI:SetAccent(name) end)
			end
		end

		return Tab
	end

	return Window
end

return SlickUI
