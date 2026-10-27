--// VENIX HUB — full black premium (single file)
--// made by [WOLF JAILBREAK]
--// ===== Compat shims =====
local genv = (typeof(getgenv) == "function" and getgenv()) or _G
local cloneref = (typeof(cloneref) == "function" and cloneref) or function(o) return o end
local gethui = (typeof(gethui) == "function" and gethui) or nil
local wrapC = (typeof(newcclosure) == "function" and newcclosure) or function(f) return f end

if genv.VenixHub and genv.VenixHub.Unload then pcall(genv.VenixHub.Unload) end

--// ===== Services =====
local function Svc(n) return cloneref(game:GetService(n)) end
local Players = Svc("Players")
local UIS = Svc("UserInputService")
local TweenService = Svc("TweenService")
local RunService = Svc("RunService")
local CoreGui = Svc("CoreGui")
local Workspace = Svc("Workspace")
local Lighting = Svc("Lighting")
local VirtualUser = Svc("VirtualUser")
local VIM = (function()
	local ok, s = pcall(Svc, "VirtualInputManager")
	return ok and s or nil
end)()
local LP = Players.LocalPlayer

local RealWS = workspace
local RealMouse = game:GetService("Players").LocalPlayer:GetMouse()

--// ===== Thème full black premium, accent rouge sang =====
local Theme = {
	Bg = Color3.fromRGB(8, 8, 10),
	Side = Color3.fromRGB(12, 12, 14),
	Elem = Color3.fromRGB(18, 18, 21),
	ElemHover = Color3.fromRGB(26, 26, 30),
	Accent = Color3.fromRGB(220, 30, 45),
	AccentDim = Color3.fromRGB(120, 18, 26),
	Text = Color3.fromRGB(240, 240, 245),
	Dim = Color3.fromRGB(110, 110, 120),
	Stroke = Color3.fromRGB(30, 30, 34),
}
local Flags, Callbacks, Conns, Keybinds = {}, {}, {}, {}
genv.VenixConfig = Flags
local Hub = { Flags = Flags, Alive = true, Unloading = false }
local Runtime = { Render = {}, Scan = {}, Thread = nil }
local dragging, dragStart, startPos, activeSlider = false, nil, nil, nil
local order = 0

--// ===== Helpers =====
local function track(c) table.insert(Conns, c) return c end
local function nextOrder() order += 1 return order end
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function matches(i, k)
	return k ~= nil and (i.KeyCode == k or i.UserInputType == k)
end

local function new(class, props, kids)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do if k ~= "Parent" then o[k] = v end end
	for _, k in ipairs(kids or {}) do k.Parent = o end
	if props and props.Parent then o.Parent = props.Parent end
	return o
end
local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = o }) end
local function stroke(o, c, th, tr)
	return new("UIStroke", { Color = c or Theme.Stroke, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o })
end
local function tween(o, t, props) return TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props) end
local function label(parent, text, size, font, color)
	return new("TextLabel", {
		Text = text, Font = font or Enum.Font.Gotham, TextSize = 13, TextColor3 = color or Theme.Text, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0), Size = size or UDim2.new(1, -50, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = parent,
	})
end

local function guiParent()
	if gethui then
		local ok, h = pcall(gethui)
		if ok and h then return h end
	end
	local ok = pcall(function() local f = Instance.new("Folder"); f.Parent = CoreGui; f:Destroy() end)
	if ok then return CoreGui end
	return LP:WaitForChild("PlayerGui")
end

--// ===== Runtime partagé =====
local function runList(list, ...)
	for id, fn in pairs(list) do
		local ok, err = pcall(fn, ...)
		if not ok then warn(("[VenixHub] %s: %s"):format(tostring(id), tostring(err))) end
	end
end
function Hub:OnRender(id, fn) Runtime.Render[id] = fn end
function Hub:OnScan(id, fn) Runtime.Scan[id] = fn end

--// ===== Fenêtre =====
local Gui = new("ScreenGui", { Name = "VenixUI", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
Gui.Parent = guiParent()

local function makeFOV(id)
	local frame = new("Frame", {
		Name = id, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(240, 240), BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.94, BorderSizePixel = 0, Visible = false, ZIndex = 0, Parent = Gui,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = frame })
	local st = new("UIStroke", { Color = Theme.Accent, Thickness = 1.5, Transparency = 0.2, Parent = frame })
	local F = { Frame = frame, Stroke = st, Radius = 120 }
	function F:SetRadius(r) self.Radius = r frame.Size = UDim2.fromOffset(r * 2, r * 2) end
	function F:SetColor(c) frame.BackgroundColor3 = c st.Color = c end
	function F:SetThickness(n) st.Thickness = n end
	function F:SetOpacity(p) st.Transparency = 1 - p frame.BackgroundTransparency = 1 - p * 0.06 end
	function F:SetVisible(v)
		frame.Visible = v and true or false
		Hub:OnRender(id, v and function()
			local m = UIS:GetMouseLocation()
			frame.Position = UDim2.fromOffset(m.X, m.Y)
		end or nil)
	end
	return F
end
Hub.FOV = makeFOV("AimFOV")
Hub.SilentFOV = makeFOV("SilentFOV")

local Main = new("Frame", { Size = UDim2.fromOffset(560, 380), Position = UDim2.new(0.5, -280, 0.5, -190), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Parent = Gui })
corner(Main, 10)
stroke(Main, Theme.Stroke, 1, 0)
local Glow = new("ImageLabel", {
	Image = "rbxassetid://5028857084", ImageColor3 = Theme.Accent, ImageTransparency = 0.82,
	ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276),
	Size = UDim2.new(1, 48, 1, 48), Position = UDim2.fromOffset(-24, -24), BackgroundTransparency = 1, ZIndex = 0, Parent = Main,
})

local Top = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Side, BorderSizePixel = 0, Parent = Main })
corner(Top, 10)
new("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = Theme.Side, BorderSizePixel = 0, Parent = Top })
new("Frame", { Size = UDim2.fromOffset(3, 18), Position = UDim2.fromOffset(14, 11), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = Top })
new("TextLabel", {
	Text = "VENIX", Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Theme.Text, BackgroundTransparency = 1,
	Position = UDim2.fromOffset(26, 0), Size = UDim2.new(0, 70, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = Top,
})
new("TextLabel", {
	Text = "HUB", Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Theme.Accent, BackgroundTransparency = 1,
	Position = UDim2.fromOffset(84, 0), Size = UDim2.new(0, 50, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = Top,
})
new("TextLabel", {
	Text = "RightShift = toggle", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, BackgroundTransparency = 1,
	Position = UDim2.new(1, -230, 0, 0), Size = UDim2.fromOffset(120, 40), TextXAlignment = Enum.TextXAlignment.Right, Parent = Top,
})
local UnloadBtn = new("TextButton", {
	Text = "✕", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Dim, BackgroundColor3 = Theme.Elem,
	BorderSizePixel = 0, Size = UDim2.fromOffset(28, 24), Position = UDim2.new(1, -40, 0.5, -12), AutoButtonColor = false, Parent = Top,
})
corner(UnloadBtn, 6)
track(UnloadBtn.MouseEnter:Connect(function() tween(UnloadBtn, 0.15, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text }):Play() end))
track(UnloadBtn.MouseLeave:Connect(function() tween(UnloadBtn, 0.15, { BackgroundColor3 = Theme.Elem, TextColor3 = Theme.Dim }):Play() end))

local Side = new("Frame", { Size = UDim2.new(0, 130, 1, -52), Position = UDim2.fromOffset(8, 46), BackgroundColor3 = Theme.Side, BorderSizePixel = 0, Parent = Main })
corner(Side, 8)
new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Side })
new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = Side })
local Pages = new("Frame", { Size = UDim2.new(1, -150, 1, -52), Position = UDim2.fromOffset(146, 46), BackgroundTransparency = 1, Parent = Main })

--// ===== Composants =====
local function Section(page, tabName, title)
	local sec = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Side, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = page })
	corner(sec, 8)
	stroke(sec, Theme.Stroke, 1, 0.3)
	new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = sec })
	local head = new("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 0, Parent = sec,
	})
	new("Frame", { Size = UDim2.fromOffset(3, 14), Position = UDim2.fromOffset(10, 9), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = head })
	new("TextLabel", {
		Text = title:upper(), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Text, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 0), Size = UDim2.new(1, -40, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = head,
	})
	local arrow = new("TextLabel", { Text = "−", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Theme.Dim, BackgroundTransparency = 1, Size = UDim2.fromOffset(20, 32), Position = UDim2.new(1, -28, 0, 0), Parent = head })
	local body = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Parent = sec })
	new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = body })
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = body })

	local open = true
	track(head.MouseButton1Click:Connect(function()
		open = not open
		body.Visible = open
		arrow.Text = open and "−" or "+"
	end))

	local S = { Body = body }
	function S:Toggle(name, default, cb)
		local key = tabName .. "_" .. name
		Flags[key] = default and true or false
		Callbacks[key] = cb
		local row = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Elem, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = body })
		corner(row, 6)
		label(row, name, UDim2.new(1, -56, 1, 0), Enum.Font.GothamMedium, Theme.Text)
		local box = new("Frame", { Size = UDim2.fromOffset(38, 18), Position = UDim2.new(1, -48, 0.5, -9), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Parent = row })
		corner(box, 9)
		stroke(box, Theme.Stroke, 1, 0)
		local knob = new("Frame", { Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(2, 2), BackgroundColor3 = Theme.Dim, BorderSizePixel = 0, Parent = box })
		corner(knob, 7)
		track(row.MouseEnter:Connect(function() tween(row, 0.12, { BackgroundColor3 = Theme.ElemHover }):Play() end))
		track(row.MouseLeave:Connect(function() tween(row, 0.12, { BackgroundColor3 = Theme.Elem }):Play() end))
		local function set(v)
			if not Hub.Alive then return end
			Flags[key] = v
			tween(box, 0.18, { BackgroundColor3 = v and Theme.Accent or Theme.Bg }):Play()
			tween(knob, 0.18, {
				Position = v and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
				BackgroundColor3 = v and Color3.new(1, 1, 1) or Theme.Dim,
			}):Play()
			if cb then task.spawn(cb, v) end
		end
		track(row.MouseButton1Click:Connect(function() set(not Flags[key]) end))
		set(Flags[key])
	end

	function S:Slider(name, min, max, default, cb)
		local key = tabName .. "_" .. name
		default = math.clamp(default, min, max)
		Flags[key] = default
		Callbacks[key] = cb
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Theme.Elem, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = body })
		corner(row, 6)
		label(row, name, UDim2.new(1, -64, 0, 24), Enum.Font.GothamMedium)
		local val = new("TextLabel", {
			Text = tostring(default), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Accent, BackgroundTransparency = 1,
			Size = UDim2.fromOffset(52, 24), Position = UDim2.new(1, -62, 0, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
		})
		local bar = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, -20, 0, 5), Position = UDim2.new(0, 10, 0, 30), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Parent = row })
		corner(bar, 3)
		local fill = new("Frame", { Size = UDim2.fromScale((default - min) / (max - min), 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = bar })
		corner(fill, 3)
		local function update(x)
			local w = bar.AbsoluteSize.X
			if w <= 0 then return end
			local r = math.clamp((x - bar.AbsolutePosition.X) / w, 0, 1)
			local v = math.floor(min + (max - min) * r + 0.5)
			fill.Size = UDim2.fromScale(r, 1)
			val.Text = tostring(v)
			if v ~= Flags[key] then
				Flags[key] = v
				if cb then task.spawn(cb, v) end
			end
		end
		track(bar.InputBegan:Connect(function(i)
			if isPress(i) then activeSlider = update; update(i.Position.X) end
		end))
		if cb then task.spawn(cb, default) end
	end

	function S:Dropdown(name, options, default, cb)
		local key = tabName .. "_" .. name
		Flags[key] = default or options[1] or ""
		Callbacks[key] = cb
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Elem, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = body })
		corner(row, 6)
		local head = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Parent = row })
		label(head, name, UDim2.new(0.5, -8, 1, 0), Enum.Font.GothamMedium)
		local cur = new("TextLabel", {
			Text = "", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Accent, BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, -28, 1, 0), TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = head,
		})
		local chev = new("TextLabel", { Text = "▾", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, BackgroundTransparency = 1, Size = UDim2.fromOffset(18, 30), Position = UDim2.new(1, -24, 0, 0), Parent = head })
		local list = new("Frame", { Position = UDim2.fromOffset(0, 32), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false, Parent = row })
		new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = list })
		local btns = {}
		local function refresh()
			cur.Text = Flags[key] == "" and "-" or tostring(Flags[key])
			for opt, b in pairs(btns) do
				b.TextColor3 = (opt == Flags[key]) and Theme.Accent or Theme.Dim
				b.BackgroundColor3 = (opt == Flags[key]) and Theme.ElemHover or Theme.Bg
			end
		end
		local function build(opts)
			for _, b in pairs(btns) do b:Destroy() end
			table.clear(btns)
			for i, opt in ipairs(opts) do
				local b = new("TextButton", {
					Text = tostring(opt), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Dim, BackgroundColor3 = Theme.Bg,
					BorderSizePixel = 0, AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = i, Parent = list,
				})
				corner(b, 5)
				btns[opt] = b
				b.MouseButton1Click:Connect(function()
					if not Hub.Alive then return end
					Flags[key] = opt
					list.Visible = false
					chev.Text = "▾"
					refresh()
					if cb then task.spawn(cb, opt) end
				end)
			end
		end
		build(options)
		track(head.MouseButton1Click:Connect(function()
			list.Visible = not list.Visible
			chev.Text = list.Visible and "▴" or "▾"
			refresh()
		end))
		refresh()
		if cb then task.spawn(cb, Flags[key]) end
		local D = {}
		function D:SetOptions(opts)
			build(opts)
			if not table.find(opts, Flags[key]) then Flags[key] = opts[1] or "" end
			refresh()
		end
		function D:Get() return Flags[key] end
		return D
	end

	function S:Textbox(name, default, cb)
		local key = tabName .. "_" .. name
		Flags[key] = default or ""
		Callbacks[key] = cb
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = Theme.Elem, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = body })
		corner(row, 6)
		label(row, name, UDim2.new(1, -20, 0, 24), Enum.Font.GothamMedium)
		local box = new("TextBox", {
			Text = Flags[key], PlaceholderText = "...", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = Theme.Text, PlaceholderColor3 = Theme.Dim, BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
			Size = UDim2.new(1, -20, 0, 22), Position = UDim2.fromOffset(10, 26), TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		corner(box, 5)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = box })
		track(box.FocusLost:Connect(function()
			if not Hub.Alive then return end
			Flags[key] = box.Text
			if cb then task.spawn(cb, box.Text) end
		end))
		if cb then task.spawn(cb, Flags[key]) end
	end

	function S:Button(name, cb)
		local b = new("TextButton", {
			Text = name, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Text, BackgroundColor3 = Theme.AccentDim,
			BorderSizePixel = 0, AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = nextOrder(), Parent = body,
		})
		corner(b, 6)
		track(b.MouseEnter:Connect(function() tween(b, 0.12, { BackgroundColor3 = Theme.Accent }):Play() end))
		track(b.MouseLeave:Connect(function() tween(b, 0.12, { BackgroundColor3 = Theme.AccentDim }):Play() end))
		track(b.MouseButton1Click:Connect(function()
			if Hub.Alive and cb then task.spawn(cb) end
		end))
		return b
	end
	return S
end

--// ===== Onglets =====
local Tabs = {}
local function selectTab(t)
	for _, o in ipairs(Tabs) do
		local on = (o == t)
		o.Page.Visible = on
		tween(o.Btn, 0.15, { BackgroundColor3 = on and Theme.Elem or Theme.Side }):Play()
		tween(o.Label, 0.15, { TextColor3 = on and Theme.Text or Theme.Dim }):Play()
		o.Bar.Visible = on
	end
end
local function Tab(name)
	local t = {}
	t.Btn = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Side, BorderSizePixel = 0, LayoutOrder = #Tabs + 1, Parent = Side })
	corner(t.Btn, 6)
	t.Bar = new("Frame", { Size = UDim2.fromOffset(3, 16), Position = UDim2.fromOffset(4, 9), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Visible = false, Parent = t.Btn })
	corner(t.Bar, 2)
	t.Label = new("TextLabel", {
		Text = name, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Dim, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -18, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = t.Btn,
	})
	t.Page = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = Pages })
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = t.Page })
	new("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6), Parent = t.Page })
	function t:Section(title) return Section(self.Page, name, title) end
	track(t.Btn.MouseEnter:Connect(function() if not t.Page.Visible then tween(t.Btn, 0.12, { BackgroundColor3 = Theme.Elem }):Play() end end))
	track(t.Btn.MouseLeave:Connect(function() if not t.Page.Visible then tween(t.Btn, 0.12, { BackgroundColor3 = Theme.Side }):Play() end end))
	track(t.Btn.MouseButton1Click:Connect(function() selectTab(t) end))
	table.insert(Tabs, t)
	if #Tabs == 1 then selectTab(t) end
	return t
end
Hub.Tab = Tab

--// ===== Keybinds =====
function Hub:Keybind(name, defaultKey, cb)
	local kb = { Key = defaultKey, Callback = cb, Held = false }
	Keybinds[name] = kb
	local handle = {}
	function handle:Set(k) kb.Key = k; kb.Held = false end
	function handle:Get() return kb.Key end
	function handle:IsHeld() return kb.Held end
	return handle
end

--// ===== Input global =====
track(Top.InputBegan:Connect(function(i)
	if isPress(i) then dragging = true; dragStart = i.Position; startPos = Main.Position end
end))
track(UIS.InputChanged:Connect(function(i)
	if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
	if activeSlider then
		activeSlider(i.Position.X)
	elseif dragging and dragStart and startPos then
		local d = i.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end))
track(UIS.InputEnded:Connect(function(i)
	if isPress(i) then dragging = false; activeSlider = nil end
	for _, kb in pairs(Keybinds) do
		if kb.Held and matches(i, kb.Key) then
			kb.Held = false
			if kb.Callback then task.spawn(kb.Callback, false) end
		end
	end
end))
track(UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end
	if i.KeyCode == Enum.KeyCode.F6 then
		Flags["Farm_Auto Click E"] = not Flags["Farm_Auto Click E"]
		if Hub.AutoClickSet then Hub.AutoClickSet(Flags["Farm_Auto Click E"]) end
	end
	for _, kb in pairs(Keybinds) do
		if matches(i, kb.Key) then
			kb.Held = true
			if kb.Callback then task.spawn(kb.Callback, true) end
		end
	end
end))

--// ===== Boucles runtime =====
track(RunService.RenderStepped:Connect(function(dt) runList(Runtime.Render, dt) end))
Runtime.Thread = task.spawn(function()
	while Hub.Alive do
		runList(Runtime.Scan)
		task.wait(0.5)
	end
end)

--// ===== TARGET =====
local Target = {
	Modes = { "ClosestToCursor", "ClosestDistance", "LowestHealth", "HighestChance" },
	Hitboxes = { "Head", "HumanoidRootPart", "UpperTorso", "NearestPoint" },
	Cache = {},
}
Hub.Target = Target

local function addModels(folder, source, out)
	if not folder then return end
	for _, m in ipairs(folder:GetChildren()) do
		if m:IsA("Model") then
			local hum = m:FindFirstChildOfClass("Humanoid")
			if hum then
				local parts = {}
				for _, p in ipairs(m:GetChildren()) do
					if p:IsA("BasePart") then table.insert(parts, p) end
				end
				table.insert(out, { Model = m, Humanoid = hum, Parts = parts, Source = source })
			end
		end
	end
end
local function addPlayers(out)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then
				local parts = {}
				for _, p in ipairs(char:GetChildren()) do
					if p:IsA("BasePart") then table.insert(parts, p) end
				end
				table.insert(out, { Model = char, Humanoid = hum, Parts = parts, Source = "Player", Player = plr })
			end
		end
	end
end
local function scanTargets()
	local out = {}
	addModels(Workspace:FindFirstChild("HoodLocal"), "Zombie", out)
	local decor = Workspace:FindFirstChild("Decor")
	addModels(decor and decor:FindFirstChild("Avatars"), "NPC", out)
	addPlayers(out)
	Target.Cache = out
end
scanTargets()
Hub:OnScan("TargetCache", scanTargets)

local function nearestPoint(parts, ray)
	local best, bestD
	for _, part in ipairs(parts) do
		if part.Parent then
			local t = math.max((part.Position - ray.Origin):Dot(ray.Direction), 0)
			local lp = part.CFrame:PointToObjectSpace(ray.Origin + ray.Direction * t)
			local h = part.Size / 2
			local w = part.CFrame:PointToWorldSpace(Vector3.new(
				math.clamp(lp.X, -h.X, h.X), math.clamp(lp.Y, -h.Y, h.Y), math.clamp(lp.Z, -h.Z, h.Z)))
			local rel = w - ray.Origin
			local d = (rel - ray.Direction * rel:Dot(ray.Direction)).Magnitude
			if not bestD or d < bestD then best, bestD = w, d end
		end
	end
	return best
end
local function hitboxPos(e, mode, ray)
	if mode == "NearestPoint" then
		local p = nearestPoint(e.Parts, ray)
		if p then return p end
	end
	local m, part = e.Model, nil
	if mode == "HumanoidRootPart" then
		part = e.Humanoid.RootPart or m:FindFirstChild("HumanoidRootPart")
	elseif mode == "UpperTorso" then
		part = m:FindFirstChild("UpperTorso") or m:FindFirstChild("Torso")
	else
		part = m:FindFirstChild("Head")
	end
	if not (part and part:IsA("BasePart")) then part = m.PrimaryPart end
	return part and part.Position or nil
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true
local function baseFilter()
	local f = {}
	local char = LP.Character
	if char then
		table.insert(f, char)
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then table.insert(f, tool) end
	end
	local fx = Workspace:FindFirstChild("FX")
	if fx then table.insert(f, fx) end
	return f
end
local function ignorable(inst)
	if inst.Name == "BulletHole" or inst:FindFirstAncestor("BulletHole") then return true end
	if inst:IsA("BasePart") and inst.LocalTransparencyModifier > 0.9 then return true end
	return false
end
function Target.Wallcheck(origin, pos, model, filter)
	local f = table.clone(filter or baseFilter())
	local dir = pos - origin
	for _ = 1, 10 do
		rayParams.FilterDescendantsInstances = f
		local res = Workspace:Raycast(origin, dir, rayParams)
		if not res then return true end
		local hit = res.Instance
		if hit:IsDescendantOf(model) then return true end
		if not ignorable(hit) then return false end
		table.insert(f, hit)
	end
	return false
end

function Target.GetTargets(opts)
	opts = opts or {}
	local cam = Workspace.CurrentCamera
	if not cam then return {} end
	local hitbox = opts.Hitbox or Flags["Aimbot_Hitbox"] or "Head"
	local maxDist = opts.MaxDistance or Flags["Aimbot_Max Distance"] or 1000
	local doWall = opts.Wallcheck
	if doWall == nil then doWall = Flags["Aimbot_Wallcheck"] == true end
	local teamCheck = opts.TeamCheck
	if teamCheck == nil then teamCheck = Flags["Aimbot_Team Check"] == true end
	local camPos = cam.CFrame.Position
	local mouse = UIS:GetMouseLocation()
	local ray = cam:ViewportPointToRay(mouse.X, mouse.Y)
	local myChar = LP.Character
	local filter = doWall and baseFilter() or nil
	local out = {}
	for _, e in ipairs(Target.Cache) do
		local m, hum = e.Model, e.Humanoid
		local valid = m.Parent and hum.Parent == m and hum.Health > 0 and m ~= myChar
		if valid and teamCheck then
			local owner = Players:GetPlayerFromCharacter(m)
			if owner and owner.Team and owner.Team == LP.Team then valid = false end
		end
		if valid then
			local pos = hitboxPos(e, hitbox, ray)
			if pos then
				local dist = (pos - camPos).Magnitude
				local sp = cam:WorldToViewportPoint(pos)
				if dist <= maxDist and sp.Z > 0 and (not doWall or Target.Wallcheck(camPos, pos, m, filter)) then
					local screen = Vector2.new(sp.X, sp.Y)
					table.insert(out, {
						Model = m, Humanoid = hum, Source = e.Source, Distance = dist, Position = pos,
						Screen = screen, CursorDistance = (screen - mouse).Magnitude,
						Health = hum.Health, Chance = m:GetAttribute("Chance"),
					})
				end
			end
		end
	end
	return out
end

local Scorers = {
	ClosestToCursor = function(t) return t.CursorDistance end,
	ClosestDistance = function(t) return t.Distance end,
	LowestHealth = function(t) return t.Health end,
	HighestChance = function(t) return -(tonumber(t.Chance) or -math.huge) end,
}
function Target.GetBest(mode, opts)
	opts = opts or {}
	mode = mode or Flags["Aimbot_Target Mode"] or "ClosestToCursor"
	local score = Scorers[mode] or Scorers.ClosestToCursor
	local doWall = opts.Wallcheck
	if doWall == nil then doWall = Flags["Aimbot_Wallcheck"] == true end
	local cands = {}
	for _, t in ipairs(Target.GetTargets({ Hitbox = opts.Hitbox, MaxDistance = opts.MaxDistance, TeamCheck = opts.TeamCheck, Wallcheck = false })) do
		if not opts.FOV or t.CursorDistance <= opts.FOV then
			t.Score = score(t)
			table.insert(cands, t)
		end
	end
	table.sort(cands, function(a, b)
		if a.Score == b.Score then return a.Distance < b.Distance end
		return a.Score < b.Score
	end)
	if not doWall then return cands[1] end
	local cam = Workspace.CurrentCamera
	if not cam then return nil end
	local camPos, filter = cam.CFrame.Position, baseFilter()
	for _, t in ipairs(cands) do
		if Target.Wallcheck(camPos, t.Position, t.Model, filter) then return t end
	end
	return nil
end

--// ===== Partagé =====
local KeyNames = { "MouseButton2", "MouseButton1", "E", "Q", "X", "LeftAlt", "LeftShift" }
local KeyMap = {
	MouseButton2 = Enum.UserInputType.MouseButton2, MouseButton1 = Enum.UserInputType.MouseButton1,
	E = Enum.KeyCode.E, Q = Enum.KeyCode.Q, X = Enum.KeyCode.X,
	LeftAlt = Enum.KeyCode.LeftAlt, LeftShift = Enum.KeyCode.LeftShift,
}
local ColorNames = { "Rouge", "Blanc", "Cyan", "Vert", "Bleu", "Jaune" }
local ColorMap = {
	Rouge = Theme.Accent, Blanc = Color3.new(1, 1, 1), Cyan = Color3.fromRGB(40, 220, 230),
	Vert = Color3.fromRGB(70, 220, 110), Bleu = Color3.fromRGB(70, 150, 255), Jaune = Color3.fromRGB(250, 210, 60),
}

local function predicted(t, prefix)
	if not Flags[prefix .. "_Prediction"] then return t.Position end
	local root = t.Humanoid.RootPart or t.Model.PrimaryPart
	if not root then return t.Position end
	local speed = math.max(Flags[prefix .. "_Projectile Speed"] or 1000, 1)
	local mult = (Flags[prefix .. "_Prediction %"] or 100) / 100
	return t.Position + root.AssemblyLinearVelocity * (t.Distance / speed) * mult
end

local function resolveFolder(path)
	local cur = Workspace
	for _, n in ipairs(path) do
		if not cur then return nil end
		cur = cur:FindFirstChild(n)
	end
	return cur
end
local function resolveAdornee(inst)
	if inst:IsA("BasePart") then return inst end
	if inst:IsA("Model") then
		local hum = inst:FindFirstChildOfClass("Humanoid")
		if hum and hum.RootPart then return hum.RootPart end
		local p = inst.PrimaryPart or inst:FindFirstChild("HumanoidRootPart")
		if p and p:IsA("BasePart") then return p end
	end
	return inst:FindFirstChildWhichIsA("BasePart", true)
end
local function partFor(model, hum, hitbox)
	local part
	if hitbox == "HumanoidRootPart" then
		part = hum.RootPart or model:FindFirstChild("HumanoidRootPart")
	elseif hitbox == "UpperTorso" then
		part = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
	else
		part = model:FindFirstChild("Head")
	end
	if not (part and part:IsA("BasePart")) then part = hum.RootPart or model.PrimaryPart end
	return part
end

--// ===== AIMBOT =====
local Aim = { Held = false, Toggled = false, Locked = nil, LastShot = 0 }
Hub.Aim = Aim
local function aimActive()
	if Flags["Aimbot_Aim Mode"] == "Toggle" then return Aim.Toggled end
	return Aim.Held
end
local AimKey = Hub:Keybind("Aimbot", Enum.UserInputType.MouseButton2, function(pressed)
	Aim.Held = pressed
	if pressed and Flags["Aimbot_Aim Mode"] == "Toggle" then Aim.Toggled = not Aim.Toggled end
end)
local function tryShoot(cam, aimPos)
	if not Flags["Aimbot_Auto Shoot"] then return end
	local now = os.clock()
	if now - Aim.LastShot < (Flags["Aimbot_Cooldown (ms)"] or 150) / 1000 then return end
	local delta = aimPos - cam.CFrame.Position
	if delta.Magnitude < 1e-3 then return end
	if cam.CFrame.LookVector:Dot(delta.Unit) < 0.9995 then return end
	local char = LP.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	if not tool then return end
	Aim.LastShot = now
	pcall(function() tool:Activate() end)
end
local function aimStep(dt)
	if not aimActive() then Aim.Locked = nil return end
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local t = Target.GetBest(Flags["Aimbot_Target Mode"], {
		FOV = Hub.FOV.Radius, Hitbox = Flags["Aimbot_Hitbox"], MaxDistance = Flags["Aimbot_Max Distance"],
		Wallcheck = Flags["Aimbot_Wallcheck"] == true, TeamCheck = Flags["Aimbot_Team Check"] == true,
	})
	Aim.Locked = t
	if not t then return end
	local aimPos = predicted(t, "Aimbot")
	local s = math.max(Flags["Aimbot_Smoothness"] or 1, 1)
	local alpha = 1 - (1 - 1 / s) ^ (dt * 60)
	cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, aimPos), math.clamp(alpha, 0, 1))
	tryShoot(cam, aimPos)
end

--// ===== SILENT AIM =====
local Redirect = { Hooked = false, Installed = false, Root = nil, CamPos = nil }
Hub.Redirect = Redirect
local installHooks
local Silent = { Held = false, Toggled = false, Roll = true, Current = nil, AimPos = nil, Part = nil, Restore = nil }
Hub.Silent = Silent
local function silentActive()
	if not Hub.Alive or not Flags["Silent_Enabled"] then return false end
	local mode = Flags["Silent_Mode"]
	if mode == "Hold" then return Silent.Held end
	if mode == "Toggle" then return Silent.Toggled end
	return true
end
local function silentPick()
	local t = Target.GetBest("ClosestToCursor", {
		FOV = Hub.SilentFOV.Radius, Hitbox = Flags["Silent_Hitbox"], MaxDistance = Flags["Silent_Max Distance"],
		Wallcheck = Flags["Silent_Wallcheck"] == true, TeamCheck = false,
	})
	if not t then return nil, nil, nil end
	return t, predicted(t, "Silent"), partFor(t.Model, t.Humanoid, Flags["Silent_Hitbox"])
end
local function silentRestore()
	local cam = Workspace.CurrentCamera
	if Silent.Restore and cam then cam.CFrame = Silent.Restore end
	Silent.Restore = nil
end
local function silentStep()
	if Silent.Restore then silentRestore() end
	if silentActive() then
		Silent.Current, Silent.AimPos, Silent.Part = silentPick()
	else
		Silent.Current, Silent.AimPos, Silent.Part = nil, nil, nil
	end
end
local function silentSnap()
	if Redirect.Hooked or not silentActive() or not Silent.Roll then return end
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local t, aimPos, part = silentPick()
	Silent.Current, Silent.AimPos, Silent.Part = t, aimPos, part
	if not aimPos then return end
	local orig = Silent.Restore or cam.CFrame
	Silent.Restore = orig
	cam.CFrame = CFrame.lookAt(orig.Position, aimPos)
end
local SilentKey = Hub:Keybind("Silent", Enum.KeyCode.Q, function(pressed)
	Silent.Held = pressed
	if pressed and Flags["Silent_Mode"] == "Toggle" then Silent.Toggled = not Silent.Toggled end
end)
track(UIS.InputBegan:Connect(function(i)
	if not Hub.Alive or not Flags["Silent_Enabled"] or i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	Silent.Roll = math.random(1, 100) <= (Flags["Silent_Hit Chance"] or 100)
	silentSnap()
end))

--// ===== ESP =====
local ESP = { Entries = {}, Pool = {}, PoolSize = 28, Acc = math.huge }
Hub.ESP = ESP
local ESPFolder = new("Folder", { Name = "VenixESP", Parent = Gui.Parent })
local TracerLayer = new("Frame", { Name = "Tracers", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 0, Parent = Gui })
local ESPCats = {
	{ Name = "Joueurs", Collect = function()
		local list = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character then table.insert(list, plr.Character) end
		end
		return list
	end, Color = "Blanc", Offset = 3 },
	{ Name = "Zombies", Paths = { { "HoodLocal" } }, Color = "Rouge", Offset = 3 },
	{ Name = "NPC", Paths = { { "Decor", "Avatars" } }, Color = "Jaune", Offset = 3 },
	{ Name = "Loot", Paths = { { "GroundLoot" }, { "LootLocal" } }, Color = "Vert", Offset = 1.5 },
	{ Name = "Coffres", Paths = { { "Coffres" } }, Color = "Cyan", Offset = 2 },
	{ Name = "Airdrops", Paths = { { "AirdropSpots" } }, Color = "Bleu", Offset = 3 },
	{ Name = "Voitures", Paths = { { "Cars" } }, Color = "Bleu", Offset = 4 },
}
ESP.Categories = ESPCats
local function getHealth(e)
	local hum = e.Humanoid
	if hum and hum.Parent then return hum.Health, math.max(hum.MaxHealth, 1) end
	local hp, mx = e.Inst:GetAttribute("Health"), e.Inst:GetAttribute("MaxHealth")
	if type(hp) == "number" and type(mx) == "number" and mx > 0 then return hp, mx end
	return nil, nil
end
local function hlTarget(e)
	local i = e.Inst
	if i:IsA("Model") or i:IsA("BasePart") then return i end
	return e.Adornee
end
local function espPool()
	while #ESP.Pool < ESP.PoolSize do
		table.insert(ESP.Pool, new("Highlight", {
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillTransparency = 0.65, OutlineTransparency = 0,
			Enabled = false, Parent = ESPFolder,
		}))
	end
end
local function espCreate(inst, cat)
	local ad = resolveAdornee(inst)
	if not ad then return nil end
	local bb = new("BillboardGui", {
		Name = "ESP_" .. cat.Name, AlwaysOnTop = true, LightInfluence = 0, Size = UDim2.fromOffset(220, 40),
		StudsOffsetWorldSpace = Vector3.new(0, cat.Offset, 0), Adornee = ad, Enabled = false, Parent = ESPFolder,
	})
	new("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1), Parent = bb,
	})
	local nameL = new("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.3, Text = inst.Name, LayoutOrder = 1, Parent = bb,
	})
	local infoL = new("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = Theme.Text, TextStrokeTransparency = 0.3, Text = "", LayoutOrder = 2, Parent = bb,
	})
	local barBack = new("Frame", { Size = UDim2.fromOffset(60, 4), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.3, BorderSizePixel = 0, LayoutOrder = 3, Parent = bb })
	local barFill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(70, 220, 110), BorderSizePixel = 0, Parent = barBack })
	local tracer = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Size = UDim2.fromOffset(0, 1.5), Visible = false, Parent = TracerLayer })
	return {
		Inst = inst, Cat = cat, Adornee = ad, Humanoid = inst:FindFirstChildOfClass("Humanoid"),
		Billboard = bb, NameL = nameL, InfoL = infoL, BarBack = barBack, BarFill = barFill, Tracer = tracer,
		Color = Color3.new(1, 1, 1), Dist = math.huge, Shown = false,
	}
end
local function espRelease(inst)
	local e = ESP.Entries[inst]
	if not e then return end
	ESP.Entries[inst] = nil
	pcall(function() e.Billboard:Destroy() end)
	pcall(function() e.Tracer:Destroy() end)
end
local function espClear()
	for inst in pairs(ESP.Entries) do espRelease(inst) end
	for _, h in ipairs(ESP.Pool) do h.Enabled = false h.Adornee = nil end
end
local function espScan()
	if Hub.Unloading or not Flags["ESP_Enabled"] then return end
	local seen = {}
	local function process(inst, cat)
		local e = ESP.Entries[inst]
		if e and e.Cat ~= cat then espRelease(inst) e = nil end
		if not e then
			e = espCreate(inst, cat)
			if e then ESP.Entries[inst] = e end
		elseif not (e.Adornee and e.Adornee.Parent and (e.Adornee == inst or e.Adornee:IsDescendantOf(inst))) then
			local ad = resolveAdornee(inst)
			e.Adornee = ad
			e.Billboard.Adornee = ad
			e.Humanoid = inst:FindFirstChildOfClass("Humanoid")
		end
		if e then seen[inst] = true end
	end
	for _, cat in ipairs(ESPCats) do
		if Flags["ESP_" .. cat.Name] then
			if cat.Collect then
				for _, inst in ipairs(cat.Collect()) do process(inst, cat) end
			elseif cat.Paths then
				for _, path in ipairs(cat.Paths) do
					local folder = resolveFolder(path)
					if folder then for _, inst in ipairs(folder:GetChildren()) do process(inst, cat) end end
				end
			end
		end
	end
	for inst in pairs(ESP.Entries) do
		if not seen[inst] then espRelease(inst) end
	end
end
local function espRescan() pcall(espScan) end
local function espRefresh()
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local camPos = cam.CFrame.Position
	local maxD = Flags["ESP_Max Distance"] or 1000
	local fs = Flags["ESP_Font Size"] or 13
	local showName, showHp, showDist = Flags["ESP_Names"] == true, Flags["ESP_Health"] == true, Flags["ESP_Distance"] == true
	local visible = {}
	for inst, e in pairs(ESP.Entries) do
		local ad = e.Adornee
		local alive = inst.Parent ~= nil and ad ~= nil and ad.Parent ~= nil
		if alive and e.Humanoid and e.Humanoid.Parent and e.Humanoid.Health <= 0 then alive = false end
		local dist = alive and (ad.Position - camPos).Magnitude or math.huge
		local show = alive and dist <= maxD
		e.Dist, e.Shown = dist, show
		if show then
			local color = ColorMap[Flags["ESP_Couleur " .. e.Cat.Name]] or Color3.new(1, 1, 1)
			e.Color = color
			e.NameL.Visible = showName
			e.NameL.Text = inst.Name
			e.NameL.TextColor3 = color
			e.NameL.TextSize = fs
			e.NameL.Size = UDim2.new(1, 0, 0, fs + 3)
			local parts = {}
			if showDist then table.insert(parts, ("%d m"):format(math.floor(dist))) end
			if e.Cat.Name == "Zombies" then
				local ch = inst:GetAttribute("Chance")
				if ch ~= nil then table.insert(parts, "Chance: " .. tostring(ch)) end
			end
			e.InfoL.Text = table.concat(parts, " | ")
			e.InfoL.Visible = #parts > 0
			e.InfoL.TextSize = math.max(fs - 1, 6)
			e.InfoL.Size = UDim2.new(1, 0, 0, fs + 2)
			local hp, mx = getHealth(e)
			local bar = showHp and hp ~= nil
			e.BarBack.Visible = bar
			if bar then
				local r = math.clamp(hp / mx, 0, 1)
				e.BarFill.Size = UDim2.fromScale(r, 1)
				e.BarFill.BackgroundColor3 = Color3.fromRGB(235, 60, 60):Lerp(Color3.fromRGB(70, 220, 110), r)
			end
			e.Billboard.Size = UDim2.fromOffset(220, fs * 2 + 14)
			e.Billboard.Enabled = e.NameL.Visible or e.InfoL.Visible or bar
			table.insert(visible, e)
		else
			e.Billboard.Enabled = false
		end
	end
	local used = 0
	if Flags["ESP_Chams"] then
		table.sort(visible, function(a, b) return a.Dist < b.Dist end)
		for _, e in ipairs(visible) do
			if used >= #ESP.Pool then break end
			used += 1
			local h = ESP.Pool[used]
			h.Adornee = hlTarget(e)
			h.FillColor = e.Color
			h.OutlineColor = e.Color
			h.Enabled = true
		end
	end
	for i = used + 1, #ESP.Pool do
		local h = ESP.Pool[i]
		h.Enabled = false
		h.Adornee = nil
	end
end
local function espTracers()
	local cam = Workspace.CurrentCamera
	local origin
	if cam and Flags["ESP_Tracers"] then
		if Flags["ESP_Tracer Origin"] == "Curseur" then
			origin = UIS:GetMouseLocation()
		else
			local vp = cam.ViewportSize
			origin = Vector2.new(vp.X / 2, vp.Y)
		end
	end
	for _, e in pairs(ESP.Entries) do
		local line, vis = e.Tracer, false
		if origin and e.Shown and e.Adornee and e.Adornee.Parent then
			local sp = cam:WorldToViewportPoint(e.Adornee.Position)
			if sp.Z > 0 then
				local b = Vector2.new(sp.X, sp.Y)
				local d = b - origin
				line.Position = UDim2.fromOffset((origin.X + b.X) / 2, (origin.Y + b.Y) / 2)
				line.Size = UDim2.fromOffset(d.Magnitude, 1.5)
				line.Rotation = math.deg(math.atan2(d.Y, d.X))
				line.BackgroundColor3 = e.Color
				vis = true
			end
		end
		if line.Visible ~= vis then line.Visible = vis end
	end
end
local function espStep(dt)
	ESP.Acc += dt
	if ESP.Acc >= (Flags["ESP_Refresh (ms)"] or 200) / 1000 then
		ESP.Acc = 0
		espRefresh()
	end
	espTracers()
end
local function espSetEnabled(v)
	if v then
		espPool()
		ESP.Acc = math.huge
		Hub:OnScan("ESP", espScan)
		Hub:OnRender("ESP", espStep)
		espRescan()
	else
		Hub:OnScan("ESP", nil)
		Hub:OnRender("ESP", nil)
		espClear()
	end
end

--// ===== WEAPON (infinite ammo + rapid fire + no break) =====
-- made by [WOLF JAILBREAK]
local Weapon = { LastFire = 0 }
Hub.Weapon = Weapon
local function weaponStep(dt)
	local char = LP.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	if not tool then return end
	if Flags["Weapon_Infinite Ammo"] then
		local mag = tool:GetAttribute("MagSize")
		if type(mag) == "number" and tool:GetAttribute("Ammo") ~= mag then
			pcall(function() tool:SetAttribute("Ammo", mag) end)
		end
		pcall(function() tool:SetAttribute("Reserve", 9999) end)
	end
	if Flags["Weapon_No Break"] then
		local maxd = tool:GetAttribute("MaxDurability")
		if type(maxd) == "number" then pcall(function() tool:SetAttribute("Durability", maxd) end) end
	end
	if Flags["Weapon_Rapid Fire"] then
		local now = os.clock()
		local delay = 1 / math.max(Flags["Weapon_Fire Rate"] or 20, 1)
		if now - Weapon.LastFire >= delay then
			local ok, down = pcall(function() return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end)
			if ok and down and not UIS:GetFocusedTextBox() then
				Weapon.LastFire = now
				pcall(function() tool:Activate() end)
			end
		end
	end
end
Hub:OnRender("Weapon", weaponStep)

--// ===== AUTO CLICK E =====
-- made by [WOLF JAILBREAK]
local AutoClick = { Thread = nil }
Hub.AutoClick = AutoClick
local function autoClickLoop()
	if AutoClick.Thread then return end
	AutoClick.Thread = task.spawn(function()
		while Hub.Alive and Flags["Farm_Auto Click E"] do
			if VIM and not UIS:GetFocusedTextBox() then
				pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
				task.wait(0.05)
				pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
			end
			task.wait(math.max((Flags["Farm_Click Delay (ms)"] or 1000) / 1000, 0.05))
		end
		AutoClick.Thread = nil
	end)
end
local function autoClickSet(v)
	if v and not Hub.Unloading then autoClickLoop() end
end
Hub.AutoClickSet = autoClickSet

--// ===== TP BYPASS =====
-- made by [WOLF JAILBREAK] - TP par petits pas (anti-détection), SetNetworkOwner retiré (serveur-only, planterait sur client)
local TpBypass = {}
Hub.TpBypass = TpBypass
local function getRootPart()
	local char = LP.Character
	return char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
end
local function getHum()
	local char = LP.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end
local function zeroVelocity(root)
	if not root then return end
	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)
end
function TpBypass.Go(targetCF)
	local root = getRootPart()
	local hum = getHum()
	if not root or not hum then return end
	local STEP = Flags["TP_Pas (studs)"] or 10
	local INTERVAL = (Flags["TP_Délai pas (ms)"] or 65) / 1000
	local prevJump = hum.JumpPower
	local prevWalk = hum.WalkSpeed
	hum.WalkSpeed = 0
	hum.JumpPower = 0
	pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
	local origin = root.CFrame
	local dist = (targetCF.Position - origin.Position).Magnitude
	local steps = math.max(1, math.ceil(dist / math.max(STEP, 1)))
	for i = 1, steps do
		if not (root.Parent and hum.Parent) then break end
		local cf = origin:Lerp(targetCF, i / steps)
		root.CFrame = cf
		zeroVelocity(root)
		task.wait(INTERVAL)
	end
	if root.Parent then root.CFrame = targetCF zeroVelocity(root) end
	if hum.Parent then
		hum.WalkSpeed = prevWalk
		hum.JumpPower = prevJump
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
	end
end
function TpBypass.ToPlayer(plr)
	if typeof(plr) == "string" then plr = Players:FindFirstChild(plr) end
	if not plr or not plr.Character then return end
	local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
	if not root then return end
	TpBypass.Go(root.CFrame * CFrame.new(3, 0, 0))
end
function TpBypass.ToPos(x, y, z) TpBypass.Go(CFrame.new(x, y, z)) end

--// ===== FARM (statique + viser auto) =====
local Farm = {
	Zombies = {}, Fallback = nil, ScanN = 0, Skip = {}, Acc = 0,
	LastAttack = 0, LastReload = 0, Job = nil, Target = nil,
	ShootPos = nil, ShootPart = nil, ShootUntil = 0, TrackHP = nil, TrackT = 0,
}
Hub.Farm = Farm
local function myRig()
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = hum and hum.RootPart
	if not (hum and hrp and hum.Health > 0) then return nil, nil, nil end
	return char, hum, hrp
end
local function stopShoot() Farm.ShootPos, Farm.ShootPart, Farm.ShootUntil = nil, nil, 0 end
local function toolScore(t)
	local d = t:GetAttribute("Damage")
	return type(d) == "number" and d or 0
end
local function equipBest(hum)
	local char = LP.Character
	local bp = LP:FindFirstChildOfClass("Backpack")
	local cur = char and char:FindFirstChildOfClass("Tool")
	local best, bestS = cur, cur and toolScore(cur) or -math.huge
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") then
				local s = toolScore(t)
				if s > bestS then best, bestS = t, s end
			end
		end
	end
	if best and best ~= cur then pcall(function() hum:EquipTool(best) end) end
end
local function overHub(p)
	if not (Gui.Parent and Gui.Enabled and Main.Visible) then return false end
	local a, s = Main.AbsolutePosition, Main.AbsoluteSize
	return p.X >= a.X - 6 and p.X <= a.X + s.X + 6 and p.Y >= a.Y - 6 and p.Y <= a.Y + s.Y + 6
end
local function freePoint()
	local cam = Workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local cands = { Vector2.new(vp.X / 2, vp.Y / 2), Vector2.new(vp.X / 2, vp.Y * 0.85), Vector2.new(vp.X * 0.85, vp.Y / 2), Vector2.new(vp.X * 0.15, vp.Y / 2) }
	for _, p in ipairs(cands) do if not overHub(p) then return p end end
	return cands[2]
end
local function simClick()
	if VIM then
		local p = freePoint()
		pcall(function() VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0) end)
		task.delay(0.04, function() pcall(function() VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0) end) end)
	elseif typeof(mouse1click) == "function" and not overHub(UIS:GetMouseLocation()) then
		pcall(mouse1click)
	end
end
local function simKey(k)
	if not VIM then return end
	pcall(function() VIM:SendKeyEvent(true, k, false, game) end)
	task.delay(0.05, function() pcall(function() VIM:SendKeyEvent(false, k, false, game) end) end)
end
local AmmoNames = { "Ammo", "CurrentAmmo", "AmmoInMag", "MagAmmo", "Mag", "Clip", "Bullets" }
local function ammoOf(tool)
	for _, n in ipairs(AmmoNames) do
		local a = tool:GetAttribute(n)
		if type(a) == "number" then return a end
		local v = tool:FindFirstChild(n, true)
		if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then return v.Value end
	end
	return nil
end
local function tryReload(tool)
	local ammo = ammoOf(tool)
	if ammo == nil or ammo > 0 then return false end
	local now = os.clock()
	if now - Farm.LastReload >= 2 then Farm.LastReload = now simKey(Enum.KeyCode.R) end
	return true
end
local function fireWeapon(tool)
	local m = Flags["Farm_Méthode tir"] or "Les deux"
	if m ~= "Clic" and tool then pcall(function() tool:Activate() end) end
	if m ~= "Activate" then simClick() end
end
local function farmScanZombies()
	local out = {}
	local function add(m)
		local hum = m:FindFirstChildOfClass("Humanoid")
		if hum and m ~= LP.Character and not Players:GetPlayerFromCharacter(m) then
			table.insert(out, { Model = m, Humanoid = hum })
		end
	end
	local hood = Workspace:FindFirstChild("HoodLocal")
	if hood then for _, m in ipairs(hood:GetChildren()) do if m:IsA("Model") then add(m) end end end
	if #out == 0 then
		Farm.ScanN += 1
		if Farm.ScanN % 4 == 1 or not Farm.Fallback then
			local decor = Workspace:FindFirstChild("Decor")
			local myChar = LP.Character
			for _, d in ipairs(Workspace:GetDescendants()) do
				if d:IsA("Model") and not (decor and d:IsDescendantOf(decor)) and not (myChar and d:IsDescendantOf(myChar)) then add(d) end
			end
			Farm.Fallback = out
		else
			out = Farm.Fallback
		end
	end
	Farm.Zombies = out
end
local function farmScan()
	if Hub.Unloading then return end
	local now = os.clock()
	for m, exp in pairs(Farm.Skip) do if exp < now or not m.Parent then Farm.Skip[m] = nil end end
	if Flags["Farm_Auto Farm Zombie"] then farmScanZombies() end
end
local function pickZombie(hrp)
	local mode = Flags["Farm_Priorité"]
	local now = os.clock()
	local best, bestS
	for _, z in ipairs(Farm.Zombies) do
		local m, hum = z.Model, z.Humanoid
		local root = hum.RootPart or m.PrimaryPart
		if m.Parent and hum.Parent and hum.Health > 0 and root and (Farm.Skip[m] or 0) <= now then
			local d = (root.Position - hrp.Position).Magnitude
			local s
			if mode == "HP bas" then s = hum.Health + d * 0.001
			elseif mode == "Chance haute" then s = -(tonumber(m:GetAttribute("Chance")) or -1e6) + d * 0.001
			else s = d end
			if not bestS or s < bestS then best, bestS = { Model = m, Humanoid = hum, Root = root, Dist = d }, s end
		end
	end
	return best
end
-- made by [WOLF JAILBREAK] - farm STATIQUE
local function jobZombie(hum, hrp)
	local z = pickZombie(hrp)
	if not z then Farm.Target = nil stopShoot() return false end
	local now = os.clock()
	if Farm.Target ~= z.Model then Farm.Target = z.Model Farm.TrackHP, Farm.TrackT = z.Humanoid.Health, now end
	local hp = z.Humanoid.Health
	if hp < (Farm.TrackHP or hp) - 0.01 then Farm.TrackHP, Farm.TrackT = hp, now
	elseif now - Farm.TrackT > (Flags["Farm_Skip cible (s)"] or 10) then
		Farm.Skip[z.Model] = now + 20
		Farm.Target = nil
		stopShoot()
		return true
	end
	if Flags["Farm_Auto Equip"] then equipBest(hum) end
	local gun = Flags["Farm_Type d'arme"] ~= "Mêlée"
	local part = partFor(z.Model, z.Humanoid, Flags["Farm_Hitbox"] or "Head") or z.Root
	local aimPos = part.Position
	if gun and Flags["Farm_Wallcheck"] then
		local head = LP.Character and LP.Character:FindFirstChild("Head")
		local eye = (head and head:IsA("BasePart")) and head.Position or (hrp.Position + Vector3.new(0, 1.5, 0))
		if not Target.Wallcheck(eye, aimPos, z.Model) then
			Farm.Skip[z.Model] = now + 1
			Farm.Target = nil
			stopShoot()
			return true
		end
	end
	if not Flags["Misc_Spinbot"] then
		local flat = Vector3.new(aimPos.X, hrp.Position.Y, aimPos.Z)
		if (flat - hrp.Position).Magnitude > 0.1 then hrp.CFrame = CFrame.lookAt(hrp.Position, flat) end
	end
	if gun then Farm.ShootPos, Farm.ShootPart, Farm.ShootUntil = aimPos, part, now + 0.4 end
	if now - Farm.LastAttack >= (Flags["Farm_Délai attaque (ms)"] or 150) / 1000 then
		Farm.LastAttack = now
		local char = LP.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		if gun then
			if not (Flags["Farm_Auto Reload"] and tool and tryReload(tool)) then fireWeapon(tool) end
		elseif tool then pcall(function() tool:Activate() end) end
	end
	return true
end
local function farmAimStep()
	if not (Flags["Farm_Auto Farm Zombie"] and Flags["Farm_Viser auto"]) then return end
	if Flags["Aimbot_Enabled"] and aimActive() then return end
	local pos = Farm.ShootPos
	if not pos and Farm.Target and Farm.Target.Parent then
		local p = Farm.Target:FindFirstChild(Flags["Farm_Hitbox"] or "Head") or Farm.Target:FindFirstChild("UpperTorso")
		if p and p:IsA("BasePart") then pos = p.Position end
	end
	if not pos then return end
	local cam = Workspace.CurrentCamera
	if cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, pos) end
end
local function farmStep(dt)
	if Farm.ShootPos then
		if os.clock() > Farm.ShootUntil then stopShoot()
		else
			local p = Farm.ShootPart
			if p and p.Parent then Farm.ShootPos = p.Position end
		end
	end
	farmAimStep()
	Farm.Acc += dt
	if Farm.Acc < 0.1 then return end
	Farm.Acc = 0
	local _, hum, hrp = myRig()
	if not hrp then stopShoot() Farm.Job = nil return end
	if Flags["Farm_Auto Farm Zombie"] and jobZombie(hum, hrp) then Farm.Job = "Zombie" return end
	Farm.Job = nil
	stopShoot()
end
local function farmUpdate()
	if Flags["Farm_Auto Farm Zombie"] and not Hub.Unloading then
		installHooks()
		Hub:OnScan("Farm", farmScan)
		if not Runtime.Render.Farm then Farm.Acc = 0 Hub:OnRender("Farm", farmStep) end
		pcall(farmScan)
	else
		Hub:OnScan("Farm", nil)
		Hub:OnRender("Farm", nil)
		stopShoot()
		Farm.Job, Farm.Target = nil, nil
	end
end

--// ===== REDIRECT (hooks silent + farm) =====
local MB1 = Enum.UserInputType.MouseButton1
local isMousePressed = UIS.IsMouseButtonPressed
local function redirectTarget()
	if not Hub.Alive then return nil, nil end
	if Farm.ShootPos and os.clock() <= Farm.ShootUntil then return Farm.ShootPos, Farm.ShootPart end
	if Silent.AimPos and Silent.Roll and silentActive() then
		local ok, down = pcall(isMousePressed, UIS, MB1)
		if ok and down then return Silent.AimPos, Silent.Part end
	end
	return nil, nil
end
local function nearUs(o)
	local r, c = Redirect.Root, Redirect.CamPos
	if r and (o - r).Magnitude <= 30 then return true end
	if c and (o - c).Magnitude <= 30 then return true end
	return false
end
local function bend(origin, dir, pos)
	if typeof(origin) ~= "Vector3" or typeof(dir) ~= "Vector3" then return nil end
	local mag = dir.Magnitude
	if mag < 5 or not nearUs(origin) then return nil end
	local to = pos - origin
	local tm = to.Magnitude
	if tm < 1e-3 then return nil end
	if dir.Unit:Dot(to.Unit) < 0 then return nil end
	return to.Unit * math.max(mag, tm + 5)
end
local RayMethods = { FindPartOnRay = true, FindPartOnRayWithIgnoreList = true, FindPartOnRayWithWhitelist = true }
local CamMethods = { ScreenPointToRay = true, ViewportPointToRay = true }
local oldNamecall, oldIndex
local function hooksWanted()
	return Flags["Silent_Enabled"] == true or Flags["Farm_Auto Farm Zombie"] == true
end
installHooks = function()
	if Redirect.Installed or not Hub.Alive then return end
	Redirect.Installed = true
	local canHook = typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" and typeof(checkcaller) == "function"
	if not canHook then
		warn("[VenixHub] hookmetamethod indispo → silent en mode snap caméra")
		return
	end
	local ok, err = pcall(function()
		oldNamecall = hookmetamethod(game, "__namecall", wrapC(function(self, ...)
			if not (Flags["Silent_Enabled"] or Flags["Farm_Auto Farm Zombie"]) or checkcaller() then
				return oldNamecall(self, ...)
			end
			local method = getnamecallmethod()
			if method == "Raycast" or RayMethods[method] or CamMethods[method] then
				local pos = redirectTarget()
				if pos then
					if method == "Raycast" then
						if self == RealWS then
							local origin, dir = ...
							local nd = bend(origin, dir, pos)
							if nd then return oldNamecall(self, origin, nd, select(3, ...)) end
						end
					elseif RayMethods[method] then
						if self == RealWS then
							local ray = ...
							if typeof(ray) == "Ray" then
								local nd = bend(ray.Origin, ray.Direction, pos)
								if nd then return oldNamecall(self, Ray.new(ray.Origin, nd), select(2, ...)) end
							end
						end
					elseif self == RealWS.CurrentCamera then
						local r = oldNamecall(self, ...)
						if typeof(r) == "Ray" then
							local d = pos - r.Origin
							if d.Magnitude > 1e-3 then return Ray.new(r.Origin, d.Unit) end
						end
						return r
					end
				end
			end
			return oldNamecall(self, ...)
		end))
		oldIndex = hookmetamethod(game, "__index", wrapC(function(self, key)
			if (key == "Hit" or key == "UnitRay" or key == "Target") and self == RealMouse
				and (Flags["Silent_Enabled"] or Flags["Farm_Auto Farm Zombie"]) and not checkcaller() then
				local pos, part = redirectTarget()
				if pos then
					if key == "Hit" then return CFrame.new(pos) end
					if key == "Target" then
						if part and part.Parent then return part end
					else
						local r = oldIndex(self, key)
						local d = pos - r.Origin
						if d.Magnitude > 1e-3 then return Ray.new(r.Origin, d.Unit) end
						return r
					end
				end
			end
			return oldIndex(self, key)
		end))
	end)
	Redirect.Hooked = ok and oldNamecall ~= nil and oldIndex ~= nil
	if not ok then warn("[VenixHub] hooks: " .. tostring(err)) end
end
Hub:OnRender("RedirectCache", function()
	if not hooksWanted() then return end
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = hum and hum.RootPart
	Redirect.Root = root and root.Position or nil
	local cam = Workspace.CurrentCamera
	Redirect.CamPos = cam and cam.CFrame.Position or nil
end)

--// ===== MISC =====
local Misc = {
	Hum = nil, Orig = {}, NoclipParts = {}, Fly = nil, AtmoOrig = {}, LightOrig = {},
	CamRef = nil, CamFOVOrig = nil, ZoomOrig = LP.CameraMaxZoomDistance, SpinHum = nil,
}
Hub.Misc = Misc
for _, k in ipairs({ "Brightness", "ClockTime", "GlobalShadows", "Ambient", "OutdoorAmbient", "FogStart", "FogEnd" }) do
	Misc.LightOrig[k] = Lighting[k]
end
local function snapshotHum(hum)
	if Misc.Hum ~= hum then
		Misc.Hum = hum
		Misc.Orig = { WalkSpeed = hum.WalkSpeed, JumpPower = hum.JumpPower, JumpHeight = hum.JumpHeight, UseJumpPower = hum.UseJumpPower }
	end
end
local function restoreSpeed()
	local hum = Misc.Hum
	if hum and hum.Parent and Misc.Orig.WalkSpeed then hum.WalkSpeed = Misc.Orig.WalkSpeed end
end
local function restoreJump()
	local hum, o = Misc.Hum, Misc.Orig
	if hum and hum.Parent and o.JumpPower then
		hum.UseJumpPower = o.UseJumpPower
		hum.JumpPower = o.JumpPower
		hum.JumpHeight = o.JumpHeight
	end
end
local function restoreNoclip()
	for p in pairs(Misc.NoclipParts) do if p.Parent then p.CanCollide = true end end
	table.clear(Misc.NoclipParts)
end
local function restoreSpin()
	local hum = Misc.SpinHum
	if hum and hum.Parent then pcall(function() hum.AutoRotate = true end) end
	Misc.SpinHum = nil
end
local function flyStop()
	local f = Misc.Fly
	if not f then return end
	Misc.Fly = nil
	for _, o in ipairs({ f.LV, f.AO, f.Att }) do pcall(function() o:Destroy() end) end
	if f.Hum and f.Hum.Parent then f.Hum.PlatformStand = false end
end
local function flyStart(hum, hrp)
	flyStop()
	local att = new("Attachment", { Name = "VenixFlyAtt", Parent = hrp })
	local lv = new("LinearVelocity", {
		Name = "VenixFlyLV", Attachment0 = att, MaxForce = 1e9, VelocityConstraintMode = Enum.VelocityConstraintMode.Vector,
		RelativeTo = Enum.ActuatorRelativeTo.World, VectorVelocity = Vector3.zero, Parent = hrp,
	})
	local ao = new("AlignOrientation", {
		Name = "VenixFlyAO", Attachment0 = att, Mode = Enum.OrientationAlignmentMode.OneAttachment,
		MaxTorque = 1e9, Responsiveness = 50, CFrame = hrp.CFrame - hrp.CFrame.Position, Parent = hrp,
	})
	hum.PlatformStand = true
	Misc.Fly = { Att = att, LV = lv, AO = ao, Hum = hum, Root = hrp }
end
local function applyLighting()
	if Flags["Misc_Fullbright"] then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
	end
	if Flags["Misc_No Fog"] then
		Lighting.FogStart = 0
		Lighting.FogEnd = 1e6
		for _, a in ipairs(Lighting:GetChildren()) do
			if a:IsA("Atmosphere") then
				if not Misc.AtmoOrig[a] then Misc.AtmoOrig[a] = { Density = a.Density, Haze = a.Haze } end
				a.Density = 0
				a.Haze = 0
			end
		end
	end
end
local function restoreFullbright()
	for _, k in ipairs({ "Brightness", "ClockTime", "GlobalShadows", "Ambient", "OutdoorAmbient" }) do
		pcall(function() Lighting[k] = Misc.LightOrig[k] end)
	end
end
local function restoreFog()
	pcall(function()
		Lighting.FogStart = Misc.LightOrig.FogStart
		Lighting.FogEnd = Misc.LightOrig.FogEnd
	end)
	for a, o in pairs(Misc.AtmoOrig) do
		if a.Parent then a.Density = o.Density a.Haze = o.Haze end
	end
	table.clear(Misc.AtmoOrig)
end
local function restoreCamFOV()
	if Misc.CamRef and Misc.CamFOVOrig then pcall(function() Misc.CamRef.FieldOfView = Misc.CamFOVOrig end) end
	Misc.CamRef, Misc.CamFOVOrig = nil, nil
end
local function miscStep(dt)
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = hum and hum.RootPart
	if hum then
		snapshotHum(hum)
		if Flags["Misc_Speed"] then
			local ws = Flags["Misc_WalkSpeed"] or 16
			if hum.WalkSpeed ~= ws then hum.WalkSpeed = ws end
		end
		if Flags["Misc_Jump"] then
			if not hum.UseJumpPower then hum.UseJumpPower = true end
			local jp = Flags["Misc_JumpPower"] or 50
			if hum.JumpPower ~= jp then hum.JumpPower = jp end
		end
	end
	if Flags["Misc_Noclip"] and char then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then
				Misc.NoclipParts[p] = true
				p.CanCollide = false
			end
		end
	end
	if Flags["Misc_Spinbot"] and hum and hrp and hum.Health > 0 then
		if hum.AutoRotate then Misc.SpinHum = hum hum.AutoRotate = false end
		local sp = Flags["Misc_Spin Speed"] or 720
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(sp) * (dt or 1 / 60), 0)
	elseif Misc.SpinHum then
		restoreSpin()
	end
	if Flags["Misc_Fly"] and hum and hrp and hum.Health > 0 then
		if not Misc.Fly or Misc.Fly.Root ~= hrp or not Misc.Fly.LV.Parent then flyStart(hum, hrp) end
		local cam = Workspace.CurrentCamera
		local dir = Vector3.zero
		if cam and not UIS:GetFocusedTextBox() then
			local cf = cam.CFrame
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
			local flat = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
			if flat.Magnitude > 1e-3 and not Flags["Misc_Spinbot"] then Misc.Fly.AO.CFrame = CFrame.lookAt(Vector3.zero, flat) end
		end
		Misc.Fly.LV.VectorVelocity = dir.Magnitude > 1e-3 and dir.Unit * (Flags["Misc_Fly Speed"] or 60) or Vector3.zero
		hum.PlatformStand = true
	elseif Misc.Fly then
		flyStop()
	end
	if Flags["Misc_Camera FOV"] then
		local cam = Workspace.CurrentCamera
		if cam then
			if Misc.CamRef ~= cam then Misc.CamRef, Misc.CamFOVOrig = cam, cam.FieldOfView end
			local fov = Flags["Misc_FOV"] or 70
			if cam.FieldOfView ~= fov then cam.FieldOfView = fov end
		end
	end
end
Hub:OnRender("Misc", miscStep)
Hub:OnScan("Misc", function()
	if Flags["Misc_Fullbright"] or Flags["Misc_No Fog"] then applyLighting() end
end)
track(UIS.JumpRequest:Connect(function()
	if not Hub.Alive or not Flags["Misc_Infinite Jump"] then return end
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))
track(LP.Idled:Connect(function()
	if not Hub.Alive or not Flags["Misc_Anti AFK"] then return end
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end))

--// ===== Unload =====
function Hub.Unload()
	if not Hub.Alive or Hub.Unloading then return end
	Hub.Unloading = true
	for key, v in pairs(Flags) do
		if type(v) == "boolean" then
			Flags[key] = false
			local cb = Callbacks[key]
			if cb then pcall(cb, false) end
		end
	end
	Hub.Alive = false
	for _, kb in pairs(Keybinds) do
		if kb.Held then kb.Held = false if kb.Callback then pcall(kb.Callback, false) end end
	end
	pcall(silentRestore)
	pcall(espClear)
	pcall(stopShoot)
	pcall(flyStop)
	pcall(restoreNoclip)
	pcall(restoreSpin)
	pcall(function() LP.CameraMaxZoomDistance = Misc.ZoomOrig end)
	if oldNamecall then pcall(hookmetamethod, game, "__namecall", oldNamecall) end
	if oldIndex then pcall(hookmetamethod, game, "__index", oldIndex) end
	table.clear(Keybinds)
	table.clear(Runtime.Render)
	table.clear(Runtime.Scan)
	table.clear(Target.Cache)
	table.clear(Farm.Skip)
	Aim.Locked, Aim.Held, Aim.Toggled = nil, false, false
	Silent.Current, Silent.AimPos, Silent.Part, Silent.Held, Silent.Toggled = nil, nil, nil, false, false
	if Runtime.Thread then pcall(task.cancel, Runtime.Thread) end
	for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
	table.clear(Conns)
	pcall(function() ESPFolder:Destroy() end)
	if Gui then Gui:Destroy() end
	if genv.VenixHub == Hub then genv.VenixHub = nil end
end
genv.VenixHub = Hub
track(UnloadBtn.MouseButton1Click:Connect(Hub.Unload))

--// ===== Contenu =====
local AimTab = Tab("Aimbot")
local a1 = AimTab:Section("Main")
a1:Toggle("Enabled", false, function(v)
	if not v then Aim.Held, Aim.Toggled, Aim.Locked = false, false, nil end
	Hub:OnRender("Aimbot", v and aimStep or nil)
end)
a1:Dropdown("Aim Mode", { "Hold", "Toggle" }, "Hold", function() Aim.Toggled = false end)
a1:Dropdown("Aim Key", KeyNames, "MouseButton2", function(v)
	AimKey:Set(KeyMap[v] or Enum.UserInputType.MouseButton2)
	Aim.Held, Aim.Toggled = false, false
end)
a1:Slider("Smoothness", 1, 20, 5)
local a2 = AimTab:Section("FOV")
a2:Toggle("Show FOV", false, function(v) Hub.FOV:SetVisible(v) end)
a2:Slider("FOV", 10, 500, 120, function(v) Hub.FOV:SetRadius(v) end)
a2:Dropdown("FOV Color", ColorNames, "Rouge", function(v) Hub.FOV:SetColor(ColorMap[v] or Theme.Accent) end)
a2:Slider("FOV Thickness", 1, 6, 2, function(v) Hub.FOV:SetThickness(v) end)
a2:Slider("FOV Opacity", 0, 100, 80, function(v) Hub.FOV:SetOpacity(v / 100) end)
local a3 = AimTab:Section("Target")
a3:Dropdown("Target Mode", Target.Modes, "ClosestToCursor")
a3:Dropdown("Hitbox", Target.Hitboxes, "Head")
a3:Slider("Max Distance", 50, 2000, 500)
local a4 = AimTab:Section("Checks")
a4:Toggle("Wallcheck", true)
a4:Toggle("Team Check", true)
local a5 = AimTab:Section("Prediction")
a5:Toggle("Prediction", false)
a5:Slider("Projectile Speed", 50, 5000, 1000)
a5:Slider("Prediction %", 0, 300, 100)
local a6 = AimTab:Section("Auto Shoot")
a6:Toggle("Auto Shoot", false)
a6:Slider("Cooldown (ms)", 0, 2000, 150)

local SilTab = Tab("Silent")
local s1 = SilTab:Section("Main")
s1:Toggle("Enabled", false, function(v)
	if not v then
		pcall(silentRestore)
		Silent.Current, Silent.AimPos, Silent.Part, Silent.Held, Silent.Toggled = nil, nil, nil, false, false
	end
	if v then installHooks() end
	Hub:OnRender("Silent", v and silentStep or nil)
end)
s1:Dropdown("Mode", { "Always", "Hold", "Toggle" }, "Always", function() Silent.Toggled = false end)
s1:Dropdown("Key", KeyNames, "Q", function(v)
	SilentKey:Set(KeyMap[v] or Enum.KeyCode.Q)
	Silent.Held, Silent.Toggled = false, false
end)
s1:Slider("Hit Chance", 0, 100, 100)
local s2 = SilTab:Section("FOV")
s2:Toggle("Show FOV", false, function(v) Hub.SilentFOV:SetVisible(v) end)
s2:Slider("FOV", 10, 500, 150, function(v) Hub.SilentFOV:SetRadius(v) end)
s2:Dropdown("FOV Color", ColorNames, "Cyan", function(v) Hub.SilentFOV:SetColor(ColorMap[v] or Theme.Accent) end)
s2:Slider("FOV Opacity", 0, 100, 80, function(v) Hub.SilentFOV:SetOpacity(v / 100) end)
local s3 = SilTab:Section("Target")
s3:Dropdown("Hitbox", Target.Hitboxes, "Head")
s3:Slider("Max Distance", 50, 2000, 500)
s3:Toggle("Wallcheck", true)
local s4 = SilTab:Section("Prediction")
s4:Toggle("Prediction", false)
s4:Slider("Projectile Speed", 50, 5000, 1000)
s4:Slider("Prediction %", 0, 300, 100)

local EspTab = Tab("ESP")
local e1 = EspTab:Section("Main")
e1:Toggle("Enabled", false, espSetEnabled)
e1:Toggle("Chams", true)
e1:Toggle("Names", true)
e1:Toggle("Health", true)
e1:Toggle("Distance", true)
local e2 = EspTab:Section("Catégories")
for _, cat in ipairs(ESPCats) do e2:Toggle(cat.Name, cat.Name == "Joueurs" or cat.Name == "Zombies", espRescan) end
local e3 = EspTab:Section("Settings")
e3:Slider("Max Distance", 50, 5000, 1000)
e3:Slider("Refresh (ms)", 16, 1000, 200)
e3:Slider("Font Size", 8, 24, 13)
local e4 = EspTab:Section("Tracers")
e4:Toggle("Tracers", false)
e4:Dropdown("Tracer Origin", { "Bas", "Curseur" }, "Bas")
local e5 = EspTab:Section("Couleurs")
for _, cat in ipairs(ESPCats) do e5:Dropdown("Couleur " .. cat.Name, ColorNames, cat.Color) end

local WeaponTab = Tab("Weapon")
local w1 = WeaponTab:Section("Munitions")
w1:Toggle("Infinite Ammo", false)
w1:Toggle("No Break", false)
local w2 = WeaponTab:Section("Cadence")
w2:Toggle("Rapid Fire", false)
w2:Slider("Fire Rate", 5, 50, 20)

local FarmTab = Tab("Farm")
local f1 = FarmTab:Section("Zombies")
f1:Toggle("Auto Farm Zombie", false, farmUpdate)
f1:Toggle("Viser auto", true)
f1:Dropdown("Type d'arme", { "Arme à feu", "Mêlée" }, "Arme à feu")
f1:Dropdown("Méthode tir", { "Les deux", "Activate", "Clic" }, "Les deux")
f1:Dropdown("Priorité", { "Plus proche", "HP bas", "Chance haute" }, "Plus proche")
f1:Dropdown("Hitbox", { "Head", "HumanoidRootPart", "UpperTorso" }, "Head")
f1:Slider("Délai attaque (ms)", 30, 2000, 150)
f1:Slider("Skip cible (s)", 3, 30, 10)
f1:Toggle("Wallcheck", true)
f1:Toggle("Auto Reload", true)
f1:Toggle("Auto Equip", true)
local f2 = FarmTab:Section("Auto Click")
f2:Toggle("Auto Click E", false, autoClickSet)
f2:Slider("Click Delay (ms)", 50, 3000, 1000)

local TpTab = Tab("Teleport")
local tp1 = TpTab:Section("Réglages")
tp1:Slider("Pas (studs)", 2, 30, 10)
tp1:Slider("Délai pas (ms)", 10, 200, 65)
local tp2 = TpTab:Section("Joueurs")
-- liste dynamique des joueurs avec bouton TP sur chacun
do
	local listBody = tp2.Body
	local rows = {}
	local function clearRows()
		for _, r in ipairs(rows) do pcall(function() r:Destroy() end) end
		table.clear(rows)
	end
	local function rebuild()
		clearRows()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP then
				local row = new("TextButton", {
					Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Elem,
					BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = listBody,
				})
				corner(row, 6)
				new("TextLabel", {
					Text = plr.DisplayName .. "  (@" .. plr.Name .. ")", Font = Enum.Font.GothamMedium, TextSize = 12,
					TextColor3 = Theme.Text, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0),
					Size = UDim2.new(1, -60, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
				})
				local tpBtn = new("TextLabel", {
					Text = "TP", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Accent, BackgroundTransparency = 1,
					Position = UDim2.new(1, -40, 0, 0), Size = UDim2.fromOffset(32, 30), TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
				})
				track(row.MouseEnter:Connect(function() tween(row, 0.12, { BackgroundColor3 = Theme.ElemHover }):Play() end))
				track(row.MouseLeave:Connect(function() tween(row, 0.12, { BackgroundColor3 = Theme.Elem }):Play() end))
				track(row.MouseButton1Click:Connect(function()
					task.spawn(function() TpBypass.ToPlayer(plr) end)
				end))
				table.insert(rows, row)
			end
		end
	end
	tp1:Button("Rafraîchir la liste", rebuild)
	rebuild()
	track(Players.PlayerAdded:Connect(function() if Hub.Alive then task.defer(rebuild) end end))
	track(Players.PlayerRemoving:Connect(function() if Hub.Alive then task.defer(rebuild) end end))
end

local MiscTab = Tab("Misc")
local m1 = MiscTab:Section("Spinbot")
m1:Toggle("Spinbot", false, function(v) if not v then restoreSpin() end end)
m1:Slider("Spin Speed", 100, 3000, 720)
local m2 = MiscTab:Section("Player")
m2:Toggle("Speed", false, function(v) if not v then restoreSpeed() end end)
m2:Slider("WalkSpeed", 16, 200, 16)
m2:Toggle("Jump", false, function(v) if not v then restoreJump() end end)
m2:Slider("JumpPower", 50, 300, 50)
m2:Toggle("Infinite Jump", false)
m2:Toggle("Noclip", false, function(v) if not v then restoreNoclip() end end)
local m3 = MiscTab:Section("Fly")
m3:Toggle("Fly", false, function(v) if not v then flyStop() end end)
m3:Slider("Fly Speed", 10, 300, 60)
local m4 = MiscTab:Section("Visuals")
m4:Toggle("Fullbright", false, function(v) if v then applyLighting() else restoreFullbright() end end)
m4:Toggle("No Fog", false, function(v) if v then applyLighting() else restoreFog() end end)
m4:Toggle("Camera FOV", false, function(v) if not v then restoreCamFOV() end end)
m4:Slider("FOV", 30, 120, 70)
local m5 = MiscTab:Section("Other")
m5:Toggle("Anti AFK", false)
