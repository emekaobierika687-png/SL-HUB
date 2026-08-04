--[[
	SlickUI — dark, glassy, blue-accent UI library for Roblox
	Inspired by the CavTape landing page aesthetic:
	  bg #06080b, panel #0c1016, accent blue #0068f9, ink #f6f8fb

	USAGE:
		local SlickUI = loadstring(game:HttpGet("..."))() -- or require(module)

		local Window = SlickUI:CreateWindow({
			Title = "CavTape",
			SubTitle = "v1.0",
		})

		local Tab = Window:CreateTab("Home")

		Tab:CreateButton({ Text = "Explore", Callback = function() end })
		Tab:CreateToggle({ Text = "Enabled", Default = true, Callback = function(v) end })
		Tab:CreateSlider({ Text = "Speed", Min = 0, Max = 100, Default = 50, Callback = function(v) end })
		Tab:CreateDropdown({ Text = "Mode", Options = {"A","B","C"}, Callback = function(v) end })
		Tab:CreateLabel("Some info text")

		SlickUI:Notify({ Title = "Saved", Content = "Config saved.", Duration = 3 })
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

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
	TweenService:Create(
		inst,
		TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	):Play()
end

local function makeDraggable(handle, target)
	local dragging, dragStart, startPos
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

-- subtle background grid glow behind everything (purely cosmetic, optional)
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
	local accent = new("Frame", {
		BackgroundColor3 = Theme.Blue,
		Size = UDim2.new(0, 3, 1, 0),
		Parent = card,
	}, { corner(2) })

	card.BackgroundTransparency = 1
	for _, d in ipairs(card:GetDescendants()) do
		if d:IsA("TextLabel") then d.TextTransparency = 1 end
	end
	tween(card, { BackgroundTransparency = 0.05 }, 0.25)

	task.delay(opts.Duration or 3.5, function()
		tween(card, { BackgroundTransparency = 1 }, 0.25)
		task.wait(0.25)
		card:Destroy()
	end)
end

-- ===================== WINDOW =====================

function SlickUI:CreateWindow(opts)
	opts = opts or {}

	local Window = setmetatable({}, SlickUI)
	Window.Tabs = {}

	local Main = new("Frame", {
		Name = "Main",
		BackgroundColor3 = Theme.Bg,
		BackgroundTransparency = 0.06,
		Position = UDim2.new(0.5, -290, 0.5, -180),
		Size = UDim2.new(0, 580, 0, 360),
		Parent = ScreenGui,
	}, {
		corner(18),
		stroke(Theme.Line, 1, 0.85),
		new("UIGradient", {
			Color = ColorSequence.new(Theme.Bg, Theme.Panel),
			Rotation = 90,
		}),
	})

	-- faux top glow like the hero orb in the reference site
	new("Frame", {
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
	local TopBar = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52),
		Parent = Main,
	}, { pad(18, 0, 18, 0) })

	new("TextLabel", {
		BackgroundTransparency = 1,
		Text = opts.Title or "SlickUI",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Theme.Ink,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 200, 1, 0),
		Parent = TopBar,
	})

	if opts.SubTitle then
		new("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.SubTitle,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = Theme.Dim,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 76, 0.5, 0),
			Size = UDim2.new(0, 120, 1, 0),
			Parent = TopBar,
		})
	end

	local CloseBtn = new("TextButton", {
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Theme.Muted,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		Parent = TopBar,
	})
	CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, { TextColor3 = Theme.Ink }, 0.12) end)
	CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, { TextColor3 = Theme.Muted }, 0.12) end)
	CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

	makeDraggable(TopBar, Main)

	new("Frame", {
		BackgroundColor3 = Theme.Line,
		BackgroundTransparency = 0.92,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 52),
		Parent = Main,
	})

	-- Sidebar (tabs)
	local Sidebar = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 53),
		Size = UDim2.new(0, 150, 1, -53),
		Parent = Main,
	}, {
		pad(12, 12, 12, 12),
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	new("Frame", {
		BackgroundColor3 = Theme.Line,
		BackgroundTransparency = 0.92,
		Size = UDim2.new(0, 1, 1, -53),
		Position = UDim2.new(0, 150, 0, 53),
		Parent = Main,
	})

	-- Content area
	local ContentHolder = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 151, 0, 53),
		Size = UDim2.new(1, -151, 1, -53),
		Parent = Main,
	})

	Window.Main = Main
	Window.Sidebar = Sidebar
	Window.ContentHolder = ContentHolder

	function Window:CreateTab(name)
		local Tab = {}
		Tab.Name = name

		local TabBtn = new("TextButton", {
			Text = name,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Theme.Panel2,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32),
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

		-- ============ COMPONENTS ============

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

		function Tab:CreateButton(o)
			o = o or {}
			local Btn = new("TextButton", {
				Text = o.Text or "Button",
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
				if o.Callback then o.Callback() end
			end)
			return Btn
		end

		function Tab:CreateToggle(o)
			o = o or {}
			local state = o.Default or false

			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel,
				Size = UDim2.new(1, 0, 0, 40),
				Parent = Page,
			}, { corner(10), stroke(Theme.Line, 1, 0.9), pad(12, 0, 12, 0) })

			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = o.Text or "Toggle",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.Ink,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -50, 1, 0),
				Parent = Row,
			})

			local Track = new("Frame", {
				BackgroundColor3 = state and Theme.Blue or Theme.Panel2,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 38, 0, 20),
				Parent = Row,
			}, { corner(10), stroke(Theme.Line, 1, 0.85) })

			local Knob = new("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
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
				if o.Callback then o.Callback(state) end
			end)

			return { Set = function(v) state = v; click.MouseButton1Click:Fire() end }
		end

		function Tab:CreateSlider(o)
			o = o or {}
			local min, max = o.Min or 0, o.Max or 100
			local value = o.Default or min

			local Row = new("Frame", {
				BackgroundColor3 = Theme.Panel,
				Size = UDim2.new(1, 0, 0, 50),
				Parent = Page,
			}, { corner(10), stroke(Theme.Line, 1, 0.9), pad(12, 10, 12, 10) })

			new("TextLabel", {
				BackgroundTransparency = 1,
				Text = o.Text or "Slider",
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
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
				Parent = Bar,
			}, { corner(3) })

			local dragging = false
			local function updateFromX(x)
				local pct = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				value = math.floor(min + (max - min) * pct)
				Fill.Size = UDim2.new(pct, 0, 1, 0)
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

			return { Set = function(v) updateFromX(Bar.AbsolutePosition.X + (v - min) / (max - min) * Bar.AbsoluteSize.X) end }
		end

		function Tab:CreateDropdown(o)
			o = o or {}
			local options = o.Options or {}
			local open = false
			local selected = o.Default or options[1]

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
				Text = o.Text or "Dropdown",
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

		return Tab
	end

	return Window
end

return SlickUI
