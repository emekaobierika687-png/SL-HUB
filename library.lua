--[[
	SlickUI — dark, glassy, blue-accent UI library for Roblox
	Fully compatible with Nova HUB script
	
	USAGE:
		local SlickUI = loadstring(game:HttpGet("..."))()
		local Window = SlickUI:CreateWindow('Title', {
			Logo = 'image_url',
			Fullscreen = true,
		})
		local Tab = Window:CreateTab('Tab Name')
		Tab:CreateSection('Section Name')
		Tab:CreateButton('Button Text', function() end)
		Tab:CreateToggle('Toggle Text', function(state) end)
		Tab:CreateSlider('Slider Text', min, max, function(value) end)
		Tab:CreateBox('Box Text', function(value) end)
		Tab:CreateDropdown('Dropdown Text', {'Option1','Option2'}, function(value) end)
		Tab:CreateLabel('Label Text')
		Tab:CreateColorPicker('Color Picker', function(color) end)
		SlickUI:Notify({ Title = "Title", Content = "Content", Duration = 3 })
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ===================== THEME =====================

local Theme = {
	Blue      = Color3.fromRGB(0, 104, 249),
	BlueHover = Color3.fromRGB(39, 128, 255),
	Bg        = Color3.fromRGB(6, 8, 11),
	Panel     = Color3.fromRGB(12, 16, 22),
	Panel2    = Color3.fromRGB(17, 22, 30),
	Ink       = Color3.fromRGB(246, 248, 251),
	Muted     = Color3.fromRGB(138, 148, 165),
	Dim       = Color3.fromRGB(91, 101, 117),
	Line      = Color3.fromRGB(255, 255, 255),
}

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
	return new("UICorner", { CornerRadius = UDim.new(0, radius or 10) })
end

local function stroke(color, thickness, transparency)
	return new("UIStroke", {
		Color = color or Theme.Line,
		Thickness = thickness or 1,
		Transparency = transparency == nil and 0.88 or transparency,
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
		time or 0.18,
		style or Enum.EasingStyle.Quad,
		dir or Enum.EasingDirection.Out
	)
	local tweenObj = TweenService:Create(inst, tweenInfo, props)
	tweenObj:Play()
	return tweenObj
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
SlickUI.__index = SlickUI

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
	Size = UDim2.new(0, 300, 1, -40),
	Parent = ScreenGui,
}, {
	new("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

function SlickUI:Notify(opts)
	opts = opts or {}
	local card = new("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.05,
		Parent = NotifHolder,
	}, {
		corner(12),
		stroke(Theme.Line, 1, 0.88),
		pad(14, 12, 14, 12),
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
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
	
	tween(card, { BackgroundTransparency = 0.05 }, 0.25)

	task.delay(opts.Duration or 3.5, function()
		tween(card, { BackgroundTransparency = 1 }, 0.25)
		task.wait(0.25)
		card:Destroy()
	end)
end

-- ===================== WINDOW =====================

function SlickUI:CreateWindow(title, options)
	options = options or {}
	local isFullscreen = options.Fullscreen or false
	local logoUrl = options.Logo or ""

	local Window = setmetatable({}, SlickUI)
	Window.Tabs = {}
	Window.TabObjects = {}
	Window.IsFullscreen = isFullscreen
	Window.LogoUrl = logoUrl

	-- Window sizes
	local windowSize = isFullscreen and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 580, 0, 360)
	local windowPosition = isFullscreen and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, -290, 0.5, -180)
	local sidebarWidth = isFullscreen and 180 or 150
	local cornerRadius = isFullscreen and 0 or 18

	local Main = new("Frame", {
		Name = "Main",
		BackgroundColor3 = Theme.Bg,
		BackgroundTransparency = 0.06,
		Position = windowPosition,
		Size = windowSize,
		Parent = ScreenGui,
	}, {
		corner(cornerRadius),
		stroke(Theme.Line, 1, 0.85),
		new("UIGradient", {
			Color = ColorSequence.new(Theme.Bg, Theme.Panel),
			Rotation = 90,
		}),
	})

	-- Top glow
	new("Frame", {
		Name = "TopGlow",
		BackgroundColor3 = Theme.Blue,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 0, 0),
		Parent = Main,
	}, {
		new("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Theme.Blue),
				ColorSequenceKeypoint.new(0.5, Theme.BlueHover),
				ColorSequenceKeypoint.new(1, Theme.Blue),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 0.4),
			}),
		}),
	})

	-- Top bar
	local topBarHeight = isFullscreen and 60 or 52
	local TopBar = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, topBarHeight),
		Parent = Main,
	}, { pad(18, 0, 18, 0) })

	-- Logo/Image
	local LogoContainer = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 32, 0, 32),
		Parent = TopBar,
	})

	local LogoImage = new("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Image = logoUrl,
		ScaleType = Enum.ScaleType.Fit,
		Parent = LogoContainer,
	}, { corner(8) })

	-- Fallback icon if no logo
	if logoUrl == "" then
		LogoImage.Image = "rbxassetid://0"
		LogoImage.BackgroundColor3 = Theme.Blue
		LogoImage.BackgroundTransparency = 0
	end

	-- Title
	local titleOffset = logoUrl ~= "" and 42 or 0
	local TitleLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Text = title or "SlickUI",
		Font = Enum.Font.GothamBold,
		TextSize = isFullscreen and 18 or 16,
		TextColor3 = Theme.Ink,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, titleOffset, 0.5, 0),
		Size = UDim2.new(0, 200, 1, 0),
		Parent = TopBar,
	})

	-- Minimize/Collapse Button
	local CollapseBtn = new("TextButton", {
		Text = "−",
		Font = Enum.Font.GothamBold,
		TextSize = isFullscreen and 22 or 20,
		TextColor3 = Theme.Muted,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		Parent = TopBar,
	})
	CollapseBtn.MouseEnter:Connect(function() tween(CollapseBtn, { TextColor3 = Theme.Ink }, 0.12) end)
	CollapseBtn.MouseLeave:Connect(function() tween(CollapseBtn, { TextColor3 = Theme.Muted }, 0.12) end)

	-- Fullscreen toggle button
	local FullscreenBtn = new("TextButton", {
		Text = "⛶",
		Font = Enum.Font.GothamBold,
		TextSize = isFullscreen and 18 or 16,
		TextColor3 = Theme.Muted,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -34, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		Parent = TopBar,
	})
	FullscreenBtn.MouseEnter:Connect(function() tween(FullscreenBtn, { TextColor3 = Theme.Ink }, 0.12) end)
	FullscreenBtn.MouseLeave:Connect(function() tween(FullscreenBtn, { TextColor3 = Theme.Muted }, 0.12) end)

	-- State tracking
	local isCollapsed = false
	local isFullscreenState = isFullscreen

	-- Collapse function
	local function toggleCollapse()
		isCollapsed = not isCollapsed
		if isCollapsed then
			local targetSize = UDim2.new(0, 200, 0, 48)
			local targetPos = UDim2.new(0.5, -100, 0.5, -24)
			tween(Main, { Size = targetSize, Position = targetPos }, 0.3)
			CollapseBtn.Text = "+"
			for _, child in ipairs(Main:GetChildren()) do
				if child ~= TopBar and child.Name ~= "TopGlow" then
					tween(child, { BackgroundTransparency = 1 }, 0.2)
					task.wait(0.05)
					child.Visible = false
				end
			end
		else
			local targetSize = isFullscreenState and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 580, 0, 360)
			local targetPos = isFullscreenState and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, -290, 0.5, -180)
			tween(Main, { Size = targetSize, Position = targetPos }, 0.3)
			CollapseBtn.Text = "−"
			for _, child in ipairs(Main:GetChildren()) do
				if child ~= TopBar and child.Name ~= "TopGlow" then
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
			for _, child in ipairs(Main:GetChildren()) do
				if child:IsA("Frame") and child.Size == UDim2.new(0, sidebarWidth, 1, -(topBarHeight + 1)) then
					child.Size = UDim2.new(0, 180, 1, -(topBarHeight + 1))
				end
			end
		else
			tween(Main, { Size = UDim2.new(0, 580, 0, 360), Position = UDim2.new(0.5, -290, 0.5, -180) }, 0.3)
			FullscreenBtn.Text = "⛶"
			for _, child in ipairs(Main:GetChildren()) do
				if child:IsA("Frame") and child.Size == UDim2.new(0, 180, 1, -(topBarHeight + 1)) then
					child.Size = UDim2.new(0, sidebarWidth, 1, -(topBarHeight + 1))
				end
			end
		end
	end

	FullscreenBtn.MouseButton1Click:Connect(toggleFullscreen)

	makeDraggable(TopBar, Main)

	new("Frame", {
		BackgroundColor3 = Theme.Line,
		BackgroundTransparency = 0.92,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, topBarHeight),
		Parent = Main,
	})

	-- Sidebar (tabs)
	local Sidebar = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, topBarHeight + 1),
		Size = UDim2.new(0, sidebarWidth, 1, -(topBarHeight + 1)),
		Parent = Main,
	}, {
		pad(12, 12, 12, 12),
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	new("Frame", {
		BackgroundColor3 = Theme.Line,
		BackgroundTransparency = 0.92,
		Size = UDim2.new(0, 1, 1, -(topBarHeight + 1)),
		Position = UDim2.new(0, sidebarWidth, 0, topBarHeight + 1),
		Parent = Main,
	})

	-- Content area
	local ContentHolder = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, sidebarWidth + 1, 0, topBarHeight + 1),
		Size = UDim2.new(1, -(sidebarWidth + 1), 1, -(topBarHeight + 1)),
		Parent = Main,
	})

	Window.Main = Main
	Window.Sidebar = Sidebar
	Window.ContentHolder = ContentHolder
	Window.TopBar = TopBar

	-- Method to update logo
	function Window:SetLogo(url)
		LogoImage.Image = url
		if url == "" then
			LogoImage.Image = "rbxassetid://0"
			LogoImage.BackgroundColor3 = Theme.Blue
			LogoImage.BackgroundTransparency = 0
		end
	end

	function Window:CreateTab(name)
		local Tab = {}
		Tab.Name = name

		local TabBtn = new("TextButton", {
			Text = name,
			Font = Enum.Font.Gotham,
			TextSize = isFullscreenState and 14 or 13,
			TextColor3 = Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Theme.Panel2,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, isFullscreenState and 36 or 32),
			Parent = Sidebar,
		}, { corner(8), pad(10, 0, 10, 0) })

		local Page = new("ScrollingFrame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Blue,
			ScrollBarImageTransparency = 0.4,
			Visible = false,
			Parent = ContentHolder,
		}, {
			pad(18, 16, 18, 16),
			new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
		})

		Tab.Page = Page
		Tab.Button = TabBtn

		local function select()
			for _, t in pairs(Window.TabObjects) do
				t.Page.Visible = false
				tween(t.Button, { BackgroundTransparency = 1, TextColor3 = Theme.Muted }, 0.12)
			end
			Page.Visible = true
			tween(TabBtn, { BackgroundTransparency = 0, TextColor3 = Theme.Ink }, 0.12)
		end

		TabBtn.MouseButton1Click:Connect(select)
		table.insert(Window.TabObjects, Tab)

		if #Window.TabObjects == 1 then select() end

		-- ============ COMPONENTS ============

		function Tab:CreateSection(text)
			new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				Size = UDim2.new(1, 0, 0, 30),
				Parent = Page,
			}, {
				corner(6),
				pad(12, 0, 12, 0),
				new("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextColor3 = Theme.Muted,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 1, 0),
				}),
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
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundColor3 = Theme.Blue,
				Size = UDim2.new(1, 0, 0, 36),
				Parent = Page,
			}, { corner(10) })
			Btn.MouseEnter:Connect(function() tween(Btn, { BackgroundColor3 = Theme.BlueHover }, 0.12) end)
			Btn.MouseLeave:Connect(function() tween(Btn, { BackgroundColor3 = Theme.Blue }, 0.12) end)
			Btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
			return Btn
		end

		function Tab:CreateToggle(text, callback)
			local state = false

			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel,
				Size = UDim2.new(1, 0, 0, 40),
				Parent = Page,
			}, { corner(10), stroke(Theme.Line, 1, 0.9), pad(12, 0, 12, 0) })

			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = text or "Toggle",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -50, 1, 0),
				Parent = Row,
			})

			local Track = new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 38, 0, 20),
				Parent = Row,
			}, { corner(10), stroke(Theme.Line, 1, 0.85) })

			local Knob = new("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 2, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				Parent = Track,
			}, { corner(8) })

			local click = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				Parent = Row,
			})

			click.MouseButton1Click:Connect(function()
				state = not state
				tween(Track, { BackgroundColor3 = state and Theme.Blue or Theme.Panel2 }, 0.15)
				tween(Knob, { Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }, 0.15)
				if callback then callback(state) end
			end)

			return { 
				Set = function(v) 
					state = v
					click.MouseButton1Click:Fire()
				end,
				Get = function() return state end
			}
		end

		function Tab:CreateSlider(text, min, max, callback)
			min = min or 0
			max = max or 100
			local value = min

			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel,
				Size = UDim2.new(1, 0, 0, 50),
				Parent = Page,
			}, { corner(10), stroke(Theme.Line, 1, 0.9), pad(12, 10, 12, 10) })

			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = text or "Slider",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -50, 0, 16),
				Parent = Row,
			})

			local ValLabel = new("TextLabel", {
				BackgroundTransparency = 1,
				Text = tostring(value),
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Theme.Blue,
				TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 50, 0, 16),
				Parent = Row,
			})

			local Bar = new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				Position = UDim2.new(0, 0, 0, 28),
				Size = UDim2.new(1, 0, 0, 6),
				Parent = Row,
			}, { corner(3) })

			local Fill = new("Frame", {
				BackgroundColor3 = Theme.Blue,
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
			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel,
				Size = UDim2.new(1, 0, 0, 40),
				Parent = Page,
			}, { corner(10), stroke(Theme.Line, 1, 0.9), pad(12, 0, 12, 0) })

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

			local Box = new("TextBox", {
				BackgroundColor3 = Theme.Panel2,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = Theme.Ink,
				Text = "",
				PlaceholderText = "Enter value...",
				PlaceholderColor3 = Theme.Dim,
				TextXAlignment = Enum.TextXAlignment.Left,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0.55, 0, 0.7, 0),
				Parent = Row,
			}, { corner(6), pad(10, 0, 10, 0) })

			Box.FocusLost:Connect(function()
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

			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel,
				ClipsDescendants = true,
				Size = UDim2.new(1, 0, 0, 40),
				Parent = Page,
			}, { corner(10), stroke(Theme.Line, 1, 0.9) })

			local Head = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 0, 40),
				Parent = Row,
			}, { pad(12, 0, 12, 0) })

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

			local List = new("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 40),
				Size = UDim2.new(1, 0, 0, #options * 30),
				Parent = Row,
			}, {
				pad(12, 4, 12, 8),
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
					Size = UDim2.new(1, 0, 0, 26),
					Parent = List,
				})
				OptBtn.MouseButton1Click:Connect(function()
					selected = opt
					SelLabel.Text = tostring(opt)
					open = false
					tween(Row, { Size = UDim2.new(1, 0, 0, 40) }, 0.15)
					if callback then callback(opt) end
				end)
				OptBtn.MouseEnter:Connect(function() tween(OptBtn, { TextColor3 = Theme.Ink }, 0.1) end)
				OptBtn.MouseLeave:Connect(function() tween(OptBtn, { TextColor3 = Theme.Muted }, 0.1) end)
			end

			Head.MouseButton1Click:Connect(function()
				open = not open
				tween(Row, { Size = UDim2.new(1, 0, 0, open and (40 + #options * 30) or 40) }, 0.15)
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
			local state = Color3.fromRGB(0, 104, 249)

			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel,
				Size = UDim2.new(1, 0, 0, 40),
				Parent = Page,
			}, { corner(10), stroke(Theme.Line, 1, 0.9), pad(12, 0, 12, 0) })

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
			}, { corner(8), stroke(Theme.Line, 1, 0.85) })

			local pickerBtn = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				Parent = Row,
			})

			-- Color palette for cycling
			local colors = {
				Color3.fromRGB(0, 104, 249),   -- Blue
				Color3.fromRGB(255, 0, 0),      -- Red
				Color3.fromRGB(0, 255, 0),      -- Green
				Color3.fromRGB(255, 255, 0),    -- Yellow
				Color3.fromRGB(255, 0, 255),    -- Magenta
				Color3.fromRGB(0, 255, 255),    -- Cyan
				Color3.fromRGB(255, 255, 255),  -- White
				Color3.fromRGB(255, 128, 0),    -- Orange
				Color3.fromRGB(128, 0, 255),    -- Purple
				Color3.fromRGB(255, 192, 203),  -- Pink
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

	return Window
end

return SlickUI
