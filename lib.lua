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
	Bg        = Color3.fromRGB(10, 10, 15),
	Panel     = Color3.fromRGB(18, 18, 28),
	Panel2    = Color3.fromRGB(25, 25, 38),
	Panel3    = Color3.fromRGB(35, 35, 50),
	Ink       = Color3.fromRGB(255, 255, 255),
	Muted     = Color3.fromRGB(160, 160, 180),
	Dim       = Color3.fromRGB(100, 100, 120),
	Line      = Color3.fromRGB(60, 60, 80),
	Green     = Color3.fromRGB(0, 220, 120),
	Red       = Color3.fromRGB(255, 60, 60),
	Orange    = Color3.fromRGB(255, 160, 0),
	Accent    = Color3.fromRGB(0, 150, 255),
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

	-- Logo
	local LogoContainer = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 36, 0, 36),
		Parent = TopBar,
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

	-- Title
	local titleOffset = logoUrl ~= "" and 46 or 0
	local TitleLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Text = title or "SlickUI",
		Font = Enum.Font.GothamBold,
		TextSize = isFullscreen and 20 or 18,
		TextColor3 = Theme.Ink,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, titleOffset, 0.5, 0),
		Size = UDim2.new(0, 200, 1, 0),
		Parent = TopBar,
	})

	-- Version
	local VersionLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Text = "Version : " .. version,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, titleOffset + 120, 0.5, 0),
		Size = UDim2.new(0, 120, 1, 0),
		Parent = TopBar,
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

	function Window:CreateTab(name)
		local Tab = {}
		Tab.Name = name

		local TabBtn = new("TextButton", {
			Text = name,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Theme.Panel3,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 34),
			Parent = Sidebar,
		}, { 
			corner(6), 
			pad(12, 0, 12, 0),
			new("UIStroke", {
				Color = Theme.Line,
				Thickness = 1,
				Transparency = 1,
			})
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
					TextColor3 = Theme.Muted,
					BackgroundColor3 = Theme.Panel3
				}, 0.12)
				local strokeObj = t.Button:FindFirstChild("UIStroke")
				if strokeObj then
					tween(strokeObj, { Transparency = 1 }, 0.12)
				end
			end
			Page.Visible = true
			tween(TabBtn, { 
				BackgroundTransparency = 0.5,
				TextColor3 = Theme.Ink,
				BackgroundColor3 = Theme.Panel
			}, 0.12)
			local strokeObj = TabBtn:FindFirstChild("UIStroke")
			if strokeObj then
				tween(strokeObj, { Transparency = 0.5 }, 0.12)
			end
		end

		TabBtn.MouseButton1Click:Connect(select)
		table.insert(Window.TabObjects, Tab)

		if #Window.TabObjects == 1 then select() end

		-- ============ COMPONENTS ============

		function Tab:CreateSection(text)
			new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				BackgroundTransparency = 0.3,
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
				new("UIStroke", {
					Color = Theme.Line,
					Thickness = 1,
					Transparency = 0.7,
				})
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

			local click = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				Parent = Row,
			})

			click.MouseButton1Click:Connect(function()
				state = not state
				if state then
					tween(Track, { BackgroundColor3 = Theme.Green }, 0.15)
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
				BackgroundColor3 = Theme.Panel2,
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 0, 52),
				Parent = Page,
			}, { 
				corner(8), 
				stroke(Theme.Line, 1, 0.7),
				pad(14, 8, 14, 8) 
			})

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
				Text = text or "Input",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.4, 0, 1, 0),
				Parent = Row,
			})

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
				stroke(Theme.Line, 1, 0.5)
			})

			Box.FocusLost:Connect(function()
				if callback then callback(Box.Text) end
			})

			return { 
				Set = function(v) Box.Text = tostring(v) end,
				Get = function() return Box.Text end
			}
		end

		function Tab:CreateDropdown(text, options, callback)
			local open = false
			local selected = options[1] or ""

			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel2,
				BackgroundTransparency = 0.3,
				ClipsDescendants = true,
				Size = UDim2.new(1, 0, 0, 42),
				Parent = Page,
			}, { 
				corner(8), 
				stroke(Theme.Line, 1, 0.7) 
			})

			local Head = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 0, 42),
				Parent = Row,
			}, { pad(14, 0, 14, 0) })

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

			local List = new("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 42),
				Size = UDim2.new(1, 0, 0, #options * 28),
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

	return Window
end

return SlickUI
