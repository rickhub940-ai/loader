-- =========================================================================
-- [Full] UI LIBRARY - Tab Scroll + onPress + แยก Scroll + Auto-resize
-- =========================================================================
local ui = (function()
    local DEFAULT_THEME_COLOR = Color3.fromRGB(255, 59, 59)
    local BG_COLOR = Color3.fromRGB(10, 10, 10)
    local BG_DARK = Color3.fromRGB(0, 0, 0)

    local library = {
        version = "windui-6"; toggled = true; binding = false; binds = {};
        themeColor = DEFAULT_THEME_COLOR; themeElements = {};
    }

    local function buildThemeGradient(base)
        local light = base:Lerp(Color3.new(1, 1, 1), 0.35)
        local dark = base:Lerp(Color3.new(0, 0, 0), 0.55)
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, light);
            ColorSequenceKeypoint.new(0.5, base);
            ColorSequenceKeypoint.new(1, dark);
        })
    end

    local function applyTheme(obj, prop)
        if prop == "ImageColor3" then
            pcall(function() obj[prop] = library.themeColor end); return
        end
        local ok = pcall(function() obj[prop] = Color3.new(1, 1, 1) end)
        if not ok then return end
        local gradient = obj:FindFirstChild("themeGradient")
        if not gradient then
            gradient = Instance.new("UIGradient")
            gradient.Name = "themeGradient"; gradient.Rotation = 45; gradient.Parent = obj
        end
        gradient.Color = buildThemeGradient(library.themeColor)
    end

    local function registerTheme(obj, prop)
        table.insert(library.themeElements, {obj = obj, prop = prop})
        applyTheme(obj, prop)
    end

    local function createPrimaryCheck(size, position, zIndex)
        local check = Instance.new("Frame")
        check.Name = "toggle"; check.Size = size; check.Position = position
        registerTheme(check, "BackgroundColor3")
        check.BorderSizePixel = 0; check.ClipsDescendants = true; check.ZIndex = zIndex or 1
        local corner = Instance.new("UICorner", check); corner.CornerRadius = UDim.new(0, 4)
        local mark = Instance.new("ImageLabel", check)
        mark.Name = "check"; mark.Size = UDim2.fromScale(0.9, 0.9); mark.Position = UDim2.fromScale(0.05, 0.05)
        mark.BackgroundTransparency = 1; mark.Image = "rbxassetid://90637392710152"
        mark.ImageColor3 = Color3.fromRGB(255, 255, 255); mark.ScaleType = Enum.ScaleType.Fit
        mark.ZIndex = check.ZIndex + 1
        return check
    end

    local function createSwitch(initialOn, zIndex)
        local z = zIndex or 1
        local track = Instance.new("Frame")
        track.Name = "toggle"; track.Size = UDim2.new(1, 0, 1, 0)
        track.BackgroundColor3 = Color3.fromRGB(38, 38, 38); track.BorderSizePixel = 0
        track.ClipsDescendants = true; track.ZIndex = z
        local tc = Instance.new("UICorner", track); tc.CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame", track)
        fill.Name = "fill"
        fill.Size = (initialOn and UDim2.new(1, 0, 1, 0)) or UDim2.new(0, 0, 0, 0)
        fill.BorderSizePixel = 0; fill.ZIndex = z + 1
        registerTheme(fill, "BackgroundColor3")
        local fc = Instance.new("UICorner", fill); fc.CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame", track)
        knob.Name = "knob"; knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Size = UDim2.new(0.42, 0, 0.72, 0)
        knob.Position = (initialOn and UDim2.new(0.72, 0, 0.5, 0)) or UDim2.new(0.28, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.BorderSizePixel = 0; knob.ZIndex = z + 2
        local kc = Instance.new("UICorner", knob); kc.CornerRadius = UDim.new(1, 0)
        return track
    end

    local function setToggleVisual(toggleObj, on)
        local fill = toggleObj:FindFirstChild("fill")
        local knob = toggleObj:FindFirstChild("knob")
        if fill and knob then
            fill:TweenSize((on and UDim2.new(1, 0, 1, 0)) or UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.18, true)
            knob:TweenPosition((on and UDim2.new(0.72, 0, 0.5, 0)) or UDim2.new(0.28, 0, 0.5, 0), "Out", "Quad", 0.18, true)
        else
            toggleObj:TweenSizeAndPosition(
                (on and UDim2.new(1, 0, 1, 0)) or UDim2.new(0, 0, 0, 0),
                (on and UDim2.new(0, 0, 0, 0)) or UDim2.new(0.5, 0, 0.5, 0),
                (on and 'Out') or 'In', (on and 'Elastic') or 'Quad',
                (on and 0.75) or 0.15, true)
        end
    end

    --==================== ระบบไอค่อน ====================
    local icons = (function()
        local cloneref = (cloneref or clonereference or function(i) return i end)
        local HttpService = cloneref(game:GetService("HttpService"))
        local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
        local BASE_URL = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main"
        local function IsExploit() return request and true or false end
        local function Get(url)
            if IsExploit() then return game:HttpGet(url) end
            local ok, r = pcall(function() return HttpService:GetAsync(url) end)
            if ok then return r end
            return ReplicatedStorage:WaitForChild("Request", 9999):InvokeServer({ Url = url })
        end
        local function Loadstring(src)
            if not IsExploit() and ReplicatedStorage:FindFirstChild("Loadstring") then
                return function() return ReplicatedStorage:WaitForChild("Loadstring", 9999):InvokeServer(src) end
            end
            return loadstring(src)
        end
        local IconModule = { IconsType = "lucide", New = nil, IconThemeTag = nil, Icons = {} }
        local function parseIconString(s)
            if type(s) == "string" then
                local idx = s:find(":", 1, true)
                if idx then return s:sub(1, idx-1), s:sub(idx+1) end
            end
            return nil, s
        end
        local function loadPack(name)
            local c = IconModule.Icons[name]
            if c ~= nil then return c or nil end
            local ok, data = pcall(function()
                return Loadstring(Get(("%s/%s/dist/Icons.lua"):format(BASE_URL, name)))()
            end)
            if ok and type(data) == "table" then IconModule.Icons[name] = data; return data end
            IconModule.Icons[name] = false; return nil
        end
        function IconModule.SetIconsType(t) IconModule.IconsType = t end
        function IconModule.Init(New, T) IconModule.New = New; IconModule.IconThemeTag = T; return IconModule end
        function IconModule.Icon(Icon, Type, DefaultFormat)
            DefaultFormat = DefaultFormat ~= false
            local t, n = parseIconString(Icon)
            local tt = t or Type or IconModule.IconsType
            local iconSet = IconModule.Icons[tt]
            if iconSet == nil then iconSet = loadPack(tt) end
            if not iconSet then return nil end
            if iconSet.Icons and iconSet.Icons[n] then
                return { iconSet.Spritesheets[tostring(iconSet.Icons[n].Image)], iconSet.Icons[n] }
            elseif type(iconSet[n]) == "string" and string.find(iconSet[n], "rbxassetid://") then
                return DefaultFormat and { iconSet[n], { ImageRectSize = Vector2.new(0,0), ImageRectPosition = Vector2.new(0,0) } } or iconSet[n]
            end
            return nil
        end
        function IconModule.GetIcon(I, T) return IconModule.Icon(I, T, false) end
        function IconModule.Icon2(I, T) return IconModule.Icon(I, T, true) end
        return IconModule
    end)()
    library.icons = icons

    local function applyIcon(imageLabel, icon, iconType)
        if not icon or not imageLabel then return end
        local ok, data = pcall(function() return icons.Icon2(icon, iconType) end)
        if ok and data then
            imageLabel.Image = data[1]
            local info = data[2]
            if info and info.ImageRectSize and info.ImageRectSize.X > 0 then
                imageLabel.ImageRectSize = info.ImageRectSize
                imageLabel.ImageRectOffset = info.ImageRectPosition or Vector2.new(0, 0)
            end
        end
    end

    if getgenv and getgenv().ui then
        pcall(function()
            if getgenv().ui.Parent then getgenv().ui.Parent:Destroy()
            else getgenv().ui:Destroy() end
        end)
        getgenv().ui = nil
    end

    do
        local contentProvider = game:GetService("ContentProvider")
        local userInputService = game:GetService("UserInputService")
        local runService = game:GetService("RunService")
        local camera = workspace.CurrentCamera

        contentProvider:PreloadAsync({
            "rbxassetid://90637392710152"; "rbxassetid://5882688826";
            "rbxassetid://4896743658"; "rbxassetid://4894670678";
            "rbxassetid://4892761119"; "rbxassetid://4892463081";
        })

        local tabList = {}; local dropList = {}
        local main = {}; main.__index = main
        local tabs = {}; tabs.__index = tabs
        local labels = {}; labels.__index = labels

        local function isPrimaryInput(input)
            return input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
        end

        -- ✅ onPress: ใช้ MouseButton1Click + TouchTap (กันกดโดนตอน scroll)
        local function onPress(object, callback)
            local lastFire = 0
            local function fire()
                local now = tick()
                if now - lastFire < 0.25 then return end
                lastFire = now
                callback()
            end
            local hitbox = Instance.new("TextButton")
            hitbox.Name = "Hitbox"
            hitbox.Size = UDim2.new(1, 0, 1, 0)
            hitbox.BackgroundTransparency = 1
            hitbox.Position = UDim2.new(0.5, 0, 0.5, 0)
            hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            hitbox.Text = ""
            hitbox.AutoButtonColor = false
            hitbox.BorderSizePixel = 0
            hitbox.ZIndex = 10
            hitbox.Parent = object
            hitbox.MouseButton1Click:Connect(fire)
            hitbox.TouchTap:Connect(function() fire() end)
        end

        local function toGuiPosition(screenPos)
            if typeof(screenPos) == "Vector3" then screenPos = Vector2.new(screenPos.X, screenPos.Y) end
            return screenPos
        end

        local function isInGui(frame, screenPos)
            if not frame then return end
            local mouse = toGuiPosition(screenPos or userInputService:GetMouseLocation())
            local x1, x2 = frame.AbsolutePosition.X, frame.AbsolutePosition.X + frame.AbsoluteSize.X
            local y1, y2 = frame.AbsolutePosition.Y, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y
            return (mouse.X >= x1 and mouse.X <= x2) and (mouse.Y >= y1 and mouse.Y <= y2)
        end

        local function setScrollingEnabled(frame, enabled)
            local p = frame.Parent
            while p and not p:IsA("ScrollingFrame") do p = p.Parent end
            if p then p.ScrollingEnabled = enabled end
        end

        -- ==================== Auto-resize Helper ====================
        local function getAutoSize()
            local vp = camera.ViewportSize
            local isMobile = userInputService.TouchEnabled and not userInputService.KeyboardEnabled
            local isSmall = vp.X < 700
            local w, h
            if isMobile or isSmall then
                w = math.clamp(vp.X * 0.95, 320, 620)
                h = math.clamp(vp.Y * 0.82, 260, 520)
            else
                w = math.clamp(vp.X * 0.55, 520, 720)
                h = math.clamp(vp.Y * 0.72, 380, 540)
            end
            return w, h
        end

        local function getSidebarWidth()
            local vp = camera.ViewportSize
            if vp.X < 500 then return 110 end
            if vp.X < 700 then return 130 end
            return 160
        end

        -- ==================== Section Builder ====================
        local function buildSection(container, order, name, icon)
            local sec = library:createElement("Frame", {
                Name = "section"; Size = UDim2.new(1, 0, 0, 24);
                LayoutOrder = order; BackgroundTransparency = 1; ZIndex = 3; Parent = container;
            })
            if icon then
                local il = library:createElement("ImageLabel", {
                    Name = "icon"; Size = UDim2.new(0, 14, 0, 14); Position = UDim2.new(0, 4, 0, 5);
                    BackgroundTransparency = 1; ImageColor3 = "@theme"; ZIndex = 3; Parent = sec;
                })
                applyIcon(il, icon)
                library:createElement("TextLabel", {
                    Name = "text"; Size = UDim2.new(1, -26, 1, 0); Position = UDim2.new(0, 24, 0, 0);
                    BackgroundTransparency = 1; Text = name; TextColor3 = Color3.fromRGB(200, 200, 200);
                    TextXAlignment = Enum.TextXAlignment.Left; Font = Enum.Font.GothamSemibold;
                    TextSize = 11; ZIndex = 3; Parent = sec;
                })
            else
                library:createElement("TextLabel", {
                    Name = "text"; Size = UDim2.new(1, 0, 1, 0); Position = UDim2.new(0, 4, 0, 0);
                    BackgroundTransparency = 1; Text = name; TextColor3 = Color3.fromRGB(200, 200, 200);
                    TextXAlignment = Enum.TextXAlignment.Left; Font = Enum.Font.GothamSemibold;
                    TextSize = 11; ZIndex = 3; Parent = sec;
                })
            end
            return sec
        end

        function main:section(name, icon)
            return buildSection(self.container, self:getOrder(), name, icon)
        end

        function tabs:section(name, icon, side)
            side = side or "Left"
            local col = (side == "Right") and self.rightContainer or self.leftContainer
            return buildSection(col, self:getOrder(side), name, icon)
        end

        function main:resize() end

        function main:getOrder()
            local count = 0
            for i,v in pairs(self.container:GetChildren()) do
                if not v:IsA("UIListLayout") then count = count + 1 end
            end
            return count
        end

        function tabs:getOrder(side)
            side = side or "Left"
            local col = (side == "Right") and self.rightContainer or self.leftContainer
            local count = 0
            for i,v in pairs(col:GetChildren()) do
                if not v:IsA("UIListLayout") then count = count + 1 end
            end
            return count
        end

        -- ==================== Drag ====================
        local function CreateDrag(gui)
            if gui:GetAttribute("HasDrag") then return end
            gui:SetAttribute("HasDrag", true)
            local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
            local dragHitbox = Instance.new("TextButton")
            dragHitbox.Name = "dragHitbox"
            dragHitbox.Size = UDim2.new(1, 0, 0, 40)
            dragHitbox.BackgroundTransparency = 1
            dragHitbox.Text = ""
            dragHitbox.AutoButtonColor = false
            dragHitbox.BorderSizePixel = 0
            dragHitbox.ZIndex = 1
            dragHitbox.Parent = gui.frame.topBorder
            dragHitbox.InputBegan:Connect(function(input)
                if dragging or not isPrimaryInput(input) then return end
                dragging = true; dragInput = input; dragStart = input.Position; startPos = gui.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                        dragging = false; dragInput = nil
                    end
                end)
            end)
            userInputService.InputChanged:Connect(function(input)
                if not dragging then return end
                local isDragMove = (input == dragInput) or (input.UserInputType == Enum.UserInputType.MouseMovement)
                    or (dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch)
                if not isDragMove then return end
                local delta = input.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end)
        end

        -- ==================== Resize ====================
        local RESIZE_MIN_X, RESIZE_MIN_Y = 340, 260
        local function CreateResize(gui)
            if gui:GetAttribute("HasResize") then return end
            gui:SetAttribute("HasResize", true)
            local resizing, resizeInput, resizeStart, startSize = false, nil, nil, nil
            local handle = library:createElement("ImageLabel", {
                Name = "resizeHandle"; Size = UDim2.new(0, 24, 0, 24);
                Position = UDim2.new(1, -24, 1, -24);
                BackgroundTransparency = 1; Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(60, 60, 60); ImageTransparency = 0.5;
                ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                ZIndex = 6; Parent = gui;
            })
            for i = 0, 2 do
                library:createElement("Frame", {
                    Name = "grip"; Size = UDim2.new(0, 2, 0, 8);
                    Position = UDim2.new(0, 6 + i * 5, 0, 12 - i * 5);
                    Rotation = 45; BorderSizePixel = 0;
                    BackgroundColor3 = Color3.fromRGB(150, 150, 150); ZIndex = 7; Parent = handle;
                })
            end
            handle.InputBegan:Connect(function(input)
                if resizing or not isPrimaryInput(input) then return end
                resizing = true; resizeInput = input; resizeStart = input.Position; startSize = gui.AbsoluteSize
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                        resizing = false; resizeInput = nil
                    end
                end)
            end)
            userInputService.InputChanged:Connect(function(input)
                if not resizing then return end
                local isResizeMove = (input == resizeInput) or (input.UserInputType == Enum.UserInputType.MouseMovement)
                    or (resizeInput and resizeInput.UserInputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch)
                if not isResizeMove then return end
                local delta = input.Position - resizeStart
                gui.Size = UDim2.new(0, math.max(RESIZE_MIN_X, startSize.X + delta.X), 0, math.max(RESIZE_MIN_Y, startSize.Y + delta.Y))
            end)
        end

        -- ==================== Window ====================
        function main:window(name, icon, subtitle)
            local autoW, autoH = getAutoSize()
            local sidebarW = getSidebarWidth()
            local vp = camera.ViewportSize
            local posX = math.max(10, (vp.X - autoW) / 2)
            local posY = math.max(10, (vp.Y - autoH) / 2)

            local newWindow = library:createElement("ImageLabel", {
                Name = name;
                Size = UDim2.fromOffset(autoW, autoH);
                Position = UDim2.fromOffset(posX, posY);
                Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK; ImageTransparency = 0.3;
                ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                BackgroundTransparency = 1; ClipsDescendants = true;
                library:createElement("ImageLabel", {
                    Name = "frame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                    Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK;
                    ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 454, 297);
                    BackgroundTransparency = 1;
                    library:createElement("ImageLabel", {
                        Name = "topBorder"; Size = UDim2.new(1, 0, 0, 40); Position = UDim2.new(0, 0, 0, 0);
                        Image = "rbxassetid://4892463081"; ImageColor3 = BG_COLOR;
                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 125);
                        BackgroundTransparency = 1;
                    })
                });
                Parent = library.container;
            })

            local tabTitleLabel = library:createElement("TextLabel", {
                Name = "tabTitle"; Size = UDim2.new(0, 130, 1, 0); Position = UDim2.new(0, 10, 0, 0);
                BackgroundTransparency = 1; Text = "General"; TextColor3 = Color3.fromRGB(200, 200, 200);
                TextXAlignment = Enum.TextXAlignment.Left; Font = Enum.Font.GothamSemibold;
                TextSize = 13; ZIndex = 4; Parent = newWindow.frame.topBorder;
            })

            if icon then
                local iconLabel = library:createElement("ImageLabel", {
                    Name = "icon"; Size = UDim2.new(0, 20, 0, 20); Position = UDim2.new(0, 145, 0, 10);
                    BackgroundTransparency = 1; ImageColor3 = "@theme"; ZIndex = 3;
                    Parent = newWindow.frame.topBorder;
                })
                applyIcon(iconLabel, icon)
            end

            library:createElement("TextLabel", {
                Name = "title"; Size = UDim2.new(1, -300, 0, 18); Position = UDim2.new(0, 150, 0, 3);
                Text = name; TextWrapped = true; TextXAlignment = Enum.TextXAlignment.Center;
                TextColor3 = Color3.fromRGB(250, 250, 250); Font = Enum.Font.GothamBold;
                TextSize = 15; BackgroundTransparency = 1; ZIndex = 3; Parent = newWindow.frame.topBorder;
            })

            library:createElement("TextLabel", {
                Name = "subtitle"; Size = UDim2.new(1, -300, 0, 14); Position = UDim2.new(0, 150, 0, 22);
                Text = subtitle or ""; TextXAlignment = Enum.TextXAlignment.Center;
                TextColor3 = Color3.fromRGB(150, 150, 150); Font = Enum.Font.GothamSemibold;
                TextSize = 10; BackgroundTransparency = 1; ZIndex = 3; Parent = newWindow.frame.topBorder;
            })

            library:createElement("Frame", {
                Name = "line"; Size = UDim2.new(1, 0, 0, 2); Position = UDim2.new(0, 0, 1, -2);
                BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(28, 28, 28); ZIndex = 3;
                Parent = newWindow.frame.topBorder;
            })

            -- ✅ Sidebar ใช้ ScrollingFrame เลื่อนได้
            library:createElement("ImageLabel", {
                Name = "containerBorder"; Size = UDim2.new(0, sidebarW, 1, -60); Position = UDim2.new(0, 10, 0, 50);
                Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK;
                ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                BackgroundTransparency = 1; ZIndex = 3;
                library:createElement("ScrollingFrame", {
                    Name = "Container"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                    BackgroundColor3 = BG_COLOR; BorderSizePixel = 0; ZIndex = 3;
                    ScrollingDirection = Enum.ScrollingDirection.Y;
                    ScrollBarThickness = 2; ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                    ScrollBarImageTransparency = 0.6;
                    CanvasSize = UDim2.new(0, 0, 0, 0);
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    ClipsDescendants = true;
                    library:createElement("UIListLayout", { SortOrder = 2; Name = "list"; })
                });
                Parent = newWindow;
            })

            CreateDrag(newWindow)
            CreateResize(newWindow)

            local win = setmetatable({
                toggled = true; object = newWindow;
                container = newWindow.containerBorder.Container;
                tabTitleLabel = tabTitleLabel;
                sidebarWidth = sidebarW;
            }, main)

            -- ✅ Auto-resize when viewport changes
            camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                if not newWindow or not newWindow.Parent then return end
                local w, h = getAutoSize()
                newWindow.Size = UDim2.fromOffset(w, h)
            end)

            return win
        end

        -- ==================== newTab ====================
        function main:newTab(name, icon)
            local sidebarW = self.sidebarWidth or 160
            local newTab = library:createElement("Frame", {
                Name = name; Size = UDim2.new(1, 0, 0, 32); BackgroundTransparency = 1;
                LayoutOrder = self:getOrder(); ZIndex = 3;
                library:createElement("ImageLabel", {
                    Name = "outline"; Size = UDim2.new(1, -8, 0, 28); Position = UDim2.new(0, 4, 0, 2);
                    BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = "@theme";
                    ImageTransparency = 1; ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297); ZIndex = 2;
                });
                library:createElement("ImageLabel", {
                    Name = "bg"; Size = UDim2.new(1, -10, 0, 26); Position = UDim2.new(0, 5, 0, 3);
                    BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = "@theme";
                    ImageTransparency = 1; ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297); ZIndex = 3;
                });
                library:createElement("TextButton", {
                    Name = "button"; Size = UDim2.new(1, 0, 1, 0); Text = "";
                    AutoButtonColor = false; BackgroundTransparency = 1; ZIndex = 5;
                    library:createElement("ImageLabel", {
                        Name = "icon"; Size = UDim2.new(0, 16, 0, 16); Position = UDim2.new(0, 16, 0.5, -8);
                        BackgroundTransparency = 1; ImageColor3 = "@theme"; ImageTransparency = 0.4; ZIndex = 5;
                    });
                    library:createElement("TextLabel", {
                        Name = "title"; Size = UDim2.new(1, -42, 1, 0); Position = UDim2.new(0, 42, 0, 0);
                        BackgroundTransparency = 1; Text = name; TextColor3 = Color3.fromRGB(170, 170, 170);
                        TextXAlignment = Enum.TextXAlignment.Left; Font = Enum.Font.GothamSemibold;
                        TextSize = 12; ZIndex = 5;
                    });
                });
                Parent = self.container;
            })
            if icon then applyIcon(newTab.button.icon, icon) end

            -- Container (ไม่มี scroll)
            local container = library:createElement("Frame", {
                Name = "container"; Size = UDim2.new(1, -(sidebarW + 30), 1, -62);
                Position = UDim2.new(0, sidebarW + 20, 0, 50);
                BackgroundTransparency = 1; ZIndex = 2; Visible = false;
                ClipsDescendants = true; Parent = self.object;
            })

            -- ✅ ซ้าย scroll แยก
            local leftContainer = library:createElement("ScrollingFrame", {
                Name = "leftCol"; Size = UDim2.new(0.5, -4, 1, 0); Position = UDim2.new(0, 0, 0, 0);
                BackgroundTransparency = 1; BorderSizePixel = 0; ZIndex = 2;
                ClipsDescendants = true; ScrollingDirection = Enum.ScrollingDirection.Y;
                ScrollBarThickness = 2; ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                ScrollBarImageTransparency = 0.6;
                CanvasSize = UDim2.new(0, 0, 0, 0);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                library:createElement("UIListLayout", { Name = "list"; SortOrder = 2; Padding = UDim.new(0, 4); });
                Parent = container;
            })

            -- ✅ ขวา scroll แยก
            local rightContainer = library:createElement("ScrollingFrame", {
                Name = "rightCol"; Size = UDim2.new(0.5, -4, 1, 0); Position = UDim2.new(0.5, 4, 0, 0);
                BackgroundTransparency = 1; BorderSizePixel = 0; ZIndex = 2;
                ClipsDescendants = true; ScrollingDirection = Enum.ScrollingDirection.Y;
                ScrollBarThickness = 2; ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                ScrollBarImageTransparency = 0.6;
                CanvasSize = UDim2.new(0, 0, 0, 0);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                library:createElement("UIListLayout", { Name = "list"; SortOrder = 2; Padding = UDim.new(0, 4); });
                Parent = container;
            })

            local tab = setmetatable({
                toggled = false; parentObject = self.object; parentContainer = self.container;
                object = newTab; container = container;
                leftContainer = leftContainer; rightContainer = rightContainer;
                flags = {}; spFuncs = {}; tabName = name; parentWindow = self;
            }, tabs)
            table.insert(tabList, tab)

            function tab.spFuncs:SimClck()
                tab.toggled = not tab.toggled
                for i,v in pairs(dropList) do
                    if v.toggled then
                        v.toggled = false; v.object.ZIndex = 1
                        if not v.usesToggles then v.label.TextTransparency = 0; v.label.Text = v.l[v.f] end
                        v.container.Parent.Parent.Parent:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.15, true)
                        v.arrow.Rotation = 0; wait(0.15)
                    end
                end
                for i,v in pairs(tabList) do
                    if v ~= tab and v.toggled then
                        spawn(function()
                            v.toggled = false
                            v.object.outline.ImageTransparency = 1
                            v.object.bg.ImageTransparency = 1
                            v.object.button.title.TextColor3 = Color3.fromRGB(170, 170, 170)
                            v.object.button.icon.ImageTransparency = 0.4
                            v.container.Visible = false
                        end)
                    end
                end
                if tab.toggled then
                    tab.object.outline.ImageTransparency = 0
                    tab.object.bg.ImageTransparency = 0.75
                    tab.object.button.title.TextColor3 = Color3.fromRGB(255, 255, 255)
                    tab.object.button.icon.ImageTransparency = 0
                    tab.container.Visible = true
                    if tab.parentWindow and tab.parentWindow.tabTitleLabel then
                        tab.parentWindow.tabTitleLabel.Text = tab.tabName
                    end
                else
                    tab.object.outline.ImageTransparency = 1
                    tab.object.bg.ImageTransparency = 1
                    tab.object.button.title.TextColor3 = Color3.fromRGB(170, 170, 170)
                    tab.object.button.icon.ImageTransparency = 0.4
                    tab.container.Visible = false
                    local anyOpen = false
                    for _, t in ipairs(tabList) do if t.toggled then anyOpen = true; break end end
                    if not anyOpen and tab.parentWindow and tab.parentWindow.tabTitleLabel then
                        tab.parentWindow.tabTitleLabel.Text = "General"
                    end
                end
            end

            onPress(newTab.button, function() spawn(function() tab.spFuncs:SimClck() end) end)
            self:resize()
            return tab
        end

        -- ==================== Label ====================
        function tabs:label(name, text, options)
            options = options or {}
            local side = options.side or "Left"
            local parent = (side == "Right") and self.rightContainer or self.leftContainer
            local newLabel = library:createElement("Frame", {
                Name = name; Size = UDim2.new(1, 0, 0, 35); BackgroundTransparency = 1;
                LayoutOrder = self:getOrder(side);
                library:createElement("ImageLabel", {
                    Name = "border"; Size = UDim2.new(1, 0, 0, 26); Position = UDim2.new(0, 0, 0, 5);
                    BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = "@theme";
                    ImageTransparency = 0.35; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                    library:createElement("ImageButton", {
                        Name = "frame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                        BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK;
                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); ClipsDescendants = true;
                        library:createElement("TextLabel", {
                            Name = "text"; Size = UDim2.new(1, -10, 1, -10); Position = UDim2.new(0, 5, 0, 5);
                            Text = text; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12;
                            TextWrapped = true; Font = Enum.Font.GothamSemibold; BackgroundTransparency = 1;
                        });
                    })
                });
                Parent = parent;
            })
            local label = setmetatable({ object = newLabel; tabObject = self.object; parentObject = self.parentObject; container = parent; textBox = newLabel.border.frame.text; }, labels)
            while not label.textBox.TextFits do
                runService.RenderStepped:Wait()
                newLabel.Size = newLabel.Size + UDim2.new(0, 0, 0, 10)
                newLabel.border.Size = newLabel.border.Size + UDim2.new(0, 0, 0, 10)
            end
            return label
        end

        function labels:changeText(text)
            self.textBox.Text = text
            if self.textBox.TextFits then
                while self.textBox.TextFits do
                    runService.RenderStepped:Wait()
                    self.object.Size = self.object.Size + UDim2.new(0, 0, 0, -10)
                    self.object.border.Size = self.object.border.Size + UDim2.new(0, 0, 0, -10)
                end
                self.object.Size = self.object.Size + UDim2.new(0, 0, 0, 10)
                self.object.border.Size = self.object.border.Size + UDim2.new(0, 0, 0, 10)
            else
                while not self.textBox.TextFits do
                    runService.RenderStepped:Wait()
                    self.object.Size = self.object.Size + UDim2.new(0, 0, 0, 10)
                    self.object.border.Size = self.object.border.Size + UDim2.new(0, 0, 0, 10)
                end
            end
        end

        -- ==================== Textbox ====================
        function tabs:textbox(name, options, callback)
            local default = options.default or "..."
            local location = options.location or self.flags
            local flag = options.flag or ""
            local side = options.side or "Left"
            local parent = (side == "Right") and self.rightContainer or self.leftContainer
            local callback = callback or function() end

            local newTextBox = library:createElement("Frame", {
                Name = name; Size = UDim2.new(1, 0, 0, 45); BackgroundTransparency = 1; LayoutOrder = self:getOrder(side);
                library:createElement("ImageLabel", {
                    Name = "border"; Size = UDim2.new(1, 0, 0, 35); Position = UDim2.new(0, 0, 0, 5);
                    Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(28, 28, 28);
                    ImageTransparency = 0.5; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                    BackgroundTransparency = 1; ClipsDescendants = true;
                    library:createElement("ImageLabel", {
                        Name = "frame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                        Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK;
                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); BackgroundTransparency = 1;
                        library:createElement("TextLabel", {
                            Name = "title"; Size = UDim2.new(1, -8, 0.5, 0); Position = UDim2.new(0, 8, 0, 0);
                            Text = name; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12;
                            TextWrapped = true; Font = Enum.Font.GothamSemibold; BackgroundTransparency = 1;
                        });
                        library:createElement("ImageLabel", {
                            Name = "textBorder"; Size = UDim2.new(1, -16, 0, 15); Position = UDim2.new(0, 8, 0, 16);
                            Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(28, 28, 28);
                            ImageTransparency = 0.5; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                            BackgroundTransparency = 1;
                            library:createElement("ImageLabel", {
                                Name = "textFrame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                                Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(20, 20, 20);
                                ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                                BackgroundTransparency = 1; ClipsDescendants = true;
                                library:createElement("TextBox", {
                                    Name = "textInput"; Size = UDim2.new(1, 0, 1, 0);
                                    Text = default; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12;
                                    TextWrapped = true; Font = Enum.Font.GothamSemibold; BackgroundTransparency = 1;
                                })
                            })
                        });
                    })
                });
                Parent = parent;
            })

            local textFrame = newTextBox.border.frame.textBorder.textFrame
            local textBox = textFrame.textInput
            local textHitbox = Instance.new("TextButton")
            textHitbox.Name = "Hitbox"; textHitbox.Size = UDim2.new(1, 0, 1, 0); textHitbox.BackgroundTransparency = 1
            textHitbox.Text = ""; textHitbox.ZIndex = 10; textHitbox.Parent = textFrame
            textHitbox.MouseButton1Click:Connect(function() textBox:CaptureFocus() end)
            textFrame.InputBegan:Connect(function(input)
                if not isPrimaryInput(input) then return end
                textBox:CaptureFocus()
            end)
            textBox.FocusLost:Connect(function()
                location[flag] = textBox.Text
                callback(location[flag])
            end)
        end

        -- ==================== Button ====================
        function tabs:button(name, callback, icon, options)
            options = options or {}
            local side = options.side or "Left"
            local parent = (side == "Right") and self.rightContainer or self.leftContainer
            local callback = callback or function() end
            local newButton = library:createElement("Frame", {
                Name = name; Size = UDim2.new(1, 0, 0, 35); BackgroundTransparency = 1; LayoutOrder = self:getOrder(side);
                library:createElement("ImageLabel", {
                    Name = "border"; Size = UDim2.new(1, 0, 0, 26); Position = UDim2.new(0, 0, 0, 5);
                    BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = "@theme";
                    ImageTransparency = 0.35; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                    library:createElement("ImageButton", {
                        Name = "frame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                        BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK;
                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); ClipsDescendants = true;
                        library:createElement("TextLabel", {
                            Name = "title"; Size = UDim2.new(1, 0, 1, 0);
                            Text = name; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12;
                            TextWrapped = true; Font = Enum.Font.GothamSemibold; BackgroundTransparency = 1;
                        });
                    })
                });
                Parent = parent;
            })
            if icon then
                local iconLabel = library:createElement("ImageLabel", {
                    Name = "icon"; Size = UDim2.new(0, 16, 0, 16); Position = UDim2.new(0, 8, 0, 4);
                    BackgroundTransparency = 1; ImageColor3 = "@theme"; ZIndex = 3; Parent = newButton.border.frame;
                })
                applyIcon(iconLabel, icon)
                newButton.border.frame.title.Position = UDim2.new(0, 30, 0, 0)
                newButton.border.frame.title.Size = UDim2.new(1, -38, 1, 0)
                newButton.border.frame.title.TextXAlignment = Enum.TextXAlignment.Left
            end
            onPress(newButton.border.frame, callback)
        end

        -- ==================== Toggle ====================
        function tabs:toggle(name, options, useBind, bindOptions, callback)
            local location = options.location or self.flags
            local flag = options.flag or ""
            local default = options.default or false
            local side = options.side or "Left"
            local parent = (side == "Right") and self.rightContainer or self.leftContainer
            local callback = callback or function() end
            location[flag] = default

            local newToggle = library:createElement("Frame", {
                Name = name; Size = UDim2.new(1, 0, 0, (options.card and 50) or 35); BackgroundTransparency = 1;
                LayoutOrder = self:getOrder(side);
                library:createElement("ImageLabel", {
                    Name = "border"; Size = UDim2.new(1, 0, 0, (options.card and 42) or 26); Position = UDim2.new(0, 0, 0, (options.card and 4) or 5);
                    BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(28, 28, 28);
                    ImageTransparency = 0.5; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                    library:createElement("ImageButton", {
                        Name = "frame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                        AutoButtonColor = false; BackgroundTransparency = 1; Image = "rbxassetid://4894670678";
                        ImageColor3 = BG_DARK; ScaleType = Enum.ScaleType.Slice;
                        SliceCenter = Rect.new(5, 5, 434, 297); ClipsDescendants = true;
                        library:createElement("TextLabel", {
                            Name = "title"; Size = UDim2.new(1, -50, 1, 0); Position = UDim2.new(0, 10, 0, 0);
                            Text = name; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12;
                            TextWrapped = true; Font = Enum.Font.GothamSemibold; TextXAlignment = Enum.TextXAlignment.Left;
                            BackgroundTransparency = 1;
                        });
                        library:createElement("ImageLabel", {
                            Name = "button"; Size = UDim2.new(0, (options.card and 36) or 18, 0, (options.card and 20) or 18);
                            Position = UDim2.new(1, (options.card and -44) or -26, 0, (options.card and 2) or 3);
                            BackgroundTransparency = 1; Image = (options.card and "") or "rbxassetid://4892761119";
                            ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(6, 6, 14, 14);
                            ((options.card and createSwitch(location[flag], 2)) or createPrimaryCheck(
                                (location[flag] and UDim2.new(1, 0, 1, 0)) or UDim2.new(0, 0, 0, 0),
                                (location[flag] and UDim2.new(0, 0, 0, 0)) or UDim2.new(0.5, 0, 0.5, 0), 2
                            ))
                        })
                    })
                });
                Parent = parent;
            })

            if options.icon then
                local iconLabel = library:createElement("ImageLabel", {
                    Name = "icon"; Size = UDim2.new(0, 16, 0, 16); Position = UDim2.new(0, 10, 0, 4);
                    BackgroundTransparency = 1; ImageColor3 = "@theme"; ZIndex = 3; Parent = newToggle.border.frame;
                })
                applyIcon(iconLabel, options.icon)
                newToggle.border.frame.title.Position = UDim2.new(0, 32, 0, 0)
                newToggle.border.frame.title.Size = UDim2.new(1, -60, 1, 0)
            end

            if options.card then
                local title = newToggle.border.frame.title
                title.Size = UDim2.new(1, -60, 0, 16); title.Position = UDim2.new(0, (options.icon and 32) or 10, 0, 1); title.TextSize = 13
                library:createElement("TextLabel", {
                    Name = "subtitle"; Size = UDim2.new(1, -60, 0, 13); Position = UDim2.new(0, (options.icon and 32) or 10, 0, 18);
                    Text = options.subtitle or ""; TextColor3 = Color3.fromRGB(160, 160, 160); TextSize = 11;
                    TextWrapped = true; Font = Enum.Font.GothamSemibold; TextXAlignment = Enum.TextXAlignment.Left;
                    BackgroundTransparency = 1; ZIndex = 3; Parent = newToggle.border.frame;
                })
            end

            local button = newToggle.border.frame.button
            local click = function()
                location[flag] = not location[flag]
                callback(location[flag])
                setToggleVisual(button.toggle, location[flag])
            end

            if useBind then
                local shortNames = { LeftControl = "LeftCtrl"; LeftShift = "LShift"; RightShift = "RShift"; MouseButton1 = "Mouse1"; MouseButton2 = "Mouse2"; }
                local banned = { Return = true; Space = true; Tab = true; Unknown = true; RightControl = true; }
                local allowed = { MouseButton1 = true; MouseButton2 = true; }
                local bindLocation = bindOptions.location or self.flags
                local bindFlag = bindOptions.flag or ""
                local kbOnly = bindOptions.kbonly or false
                local bindDefault = bindOptions.default or nil

                local passed = true
                if kbOnly and tostring(bindDefault):find("MouseButton") then passed = false end
                if passed then bindLocation[bindFlag] = bindDefault end
                local name = (bindDefault and (shortNames[bindDefault.Name] or bindDefault.Name)) or "None"

                local bind = library:createElement("ImageLabel", {
                    Name = "bindBorder";
                    Size = ((bindDefault and shortNames[bindDefault.Name] or name == "None") and UDim2.new(0, 50, 0, 15)) or UDim2.new(0, 30, 0, 15);
                    Position = ((bindDefault and shortNames[bindDefault.Name] or name == "None") and UDim2.new(1, -55, 0, 4)) or UDim2.new(1, -35, 0, 4);
                    Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(28, 28, 28); ImageTransparency = 0.5;
                    ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); BackgroundTransparency = 1; ZIndex = 10;
                    library:createElement("ImageLabel", {
                        Name = "bindFrame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                        Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(20, 20, 20);
                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                        BackgroundTransparency = 1; ClipsDescendants = true;
                        library:createElement("TextButton", {
                            Name = "bindLabel"; Size = UDim2.new(1, 0, 1, 0);
                            Text = name; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12;
                            TextWrapped = true; Font = Enum.Font.GothamSemibold; BackgroundTransparency = 1;
                        })
                    });
                    Parent = newToggle.border.frame;
                })

                onPress(bind.bindFrame.bindLabel, function()
                    library.binding = true; bind.bindFrame.bindLabel.Text = "..."
                    local input, b = userInputService.InputBegan:Wait()
                    if (input.UserInputType ~= Enum.UserInputType.Keyboard and allowed[input.UserInputType.Name] and not kbOnly)
                        or (input.KeyCode and not banned[input.KeyCode.Name]) then
                        local n = (input.UserInputType ~= Enum.UserInputType.Keyboard and input.UserInputType.Name)
                            or ((input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Escape) and "None")
                            or input.KeyCode.Name
                        if n == "None" then bindLocation[bindFlag] = nil else bindLocation[bindFlag] = input end
                        if shortNames[n] then
                            bind:TweenSizeAndPosition(UDim2.new(0, 50, 0, 15), UDim2.new(1, -55, 0, 4), "Out", "Quad", 0.15, true)
                            bind.bindFrame.bindLabel.Text = shortNames[n]
                        else
                            bind:TweenSizeAndPosition((string.len(n) > 3 and UDim2.new(0, 50, 0, 15)) or UDim2.new(0, 30, 0, 15),
                                (string.len(n) > 3 and UDim2.new(1, -55, 0, 4)) or UDim2.new(1, -35, 0, 4),
                                "Out", "Quad", 0.15, true)
                            bind.bindFrame.bindLabel.Text = n
                        end
                    end
                    wait(0.1); library.binding = false
                end)
                library.binds[bindFlag] = { location = bindLocation; call = click; }
            end

            onPress(newToggle.border.frame, click)
        end

        -- ==================== Slider ====================
        function tabs:slider(name, options, sliderCallback, useToggle, toggleOptions)
            local sLocation = options.location or self.flags
            local sFlag = options.flag or ""
            local min = options.min or 0
            local max = options.max or 1
            local sDefault = (options.default ~= nil and math.floor(math.clamp(options.default, min, max))) or min
            local side = options.side or "Left"
            local parent = (side == "Right") and self.rightContainer or self.leftContainer
            local sCallback = sliderCallback or function() end
            sLocation[sFlag] = sDefault

            local newSlider = library:createElement("Frame", {
                Name = name; Size = UDim2.new(1, 0, 0, 55); BackgroundTransparency = 1; LayoutOrder = self:getOrder(side);
                library:createElement("ImageLabel", {
                    Name = "border"; Size = UDim2.new(1, 0, 0, 45); Position = UDim2.new(0, 0, 0, 5);
                    Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(28, 28, 28); ImageTransparency = 0.5;
                    ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); BackgroundTransparency = 1; ClipsDescendants = true;
                    library:createElement("ImageLabel", {
                        Name = "frame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                        Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK;
                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); BackgroundTransparency = 1;
                        library:createElement("TextLabel", {
                            Name = "title"; Size = UDim2.new(1, -50, 0.5, 0); Position = UDim2.new(0, 8, 0, 0);
                            Text = name; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12; TextWrapped = true;
                            Font = Enum.Font.GothamSemibold; TextXAlignment = Enum.TextXAlignment.Left; BackgroundTransparency = 1;
                        });
                        library:createElement("ImageLabel", {
                            Name = "valueButtonBorder"; Size = UDim2.new(0, 35, 0, 15); Position = UDim2.new(1, -42, 0, 4);
                            Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(28, 28, 28); ImageTransparency = 0.5;
                            ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); BackgroundTransparency = 1;
                            library:createElement("ImageLabel", {
                                Name = "valueButtonFrame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                                Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(20, 20, 20);
                                ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); BackgroundTransparency = 1; ClipsDescendants = true;
                                library:createElement("TextBox", {
                                    Name = "valueLabel"; Size = UDim2.new(1, 0, 1, 0);
                                    Text = tostring(sDefault); TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12;
                                    TextWrapped = true; Font = Enum.Font.GothamSemibold; BackgroundTransparency = 1;
                                })
                            })
                        });
                        library:createElement("TextLabel", {
                            Name = "minus"; Size = UDim2.new(0, 13, 0, 13); Position = UDim2.new(0, 8, 0, 24);
                            Text = "-"; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 13; Font = Enum.Font.GothamSemibold;
                            BackgroundColor3 = Color3.fromRGB(20, 20, 20); BorderSizePixel = 0; ZIndex = 2;
                            (function() local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) return c end)();
                        });
                        library:createElement("TextLabel", {
                            Name = "plus"; Size = UDim2.new(0, 13, 0, 13); Position = UDim2.new(1, -21, 0, 24);
                            Text = "+"; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 13; Font = Enum.Font.GothamSemibold;
                            BackgroundColor3 = Color3.fromRGB(20, 20, 20); BorderSizePixel = 0; ZIndex = 2;
                            (function() local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) return c end)();
                        });
                        library:createElement("Frame", {
                            Name = "container"; BorderSizePixel = 0; Size = UDim2.new(1, -60, 0, 8);
                            Position = UDim2.new(0, 25, 0, 27); BackgroundTransparency = 1;
                            library:createElement("Frame", {
                                Name = "sliderBar"; Size = UDim2.new(1, 0, 0, 2); Position = UDim2.new(0, 0, 0, 3); BorderSizePixel = 0;
                                library:createElement("Frame", {
                                    Name = "moveBar"; Size = UDim2.new(((sDefault - min) / (max - min)), 0, 1, 0);
                                    Position = UDim2.new(0, 0, 0, 0); BorderSizePixel = 0; BackgroundColor3 = "@theme"; BackgroundTransparency = 0;
                                });
                                library:createElement("ImageLabel", {
                                    Name = "circleBorder"; Size = UDim2.new(0, 10, 0, 10);
                                    Position = UDim2.new(((sDefault - min) / (max - min)), 0, 0, -4); BackgroundTransparency = 1;
                                    Image = "rbxassetid://4896743658"; ImageColor3 = "@theme"; ImageTransparency = 0.3;
                                    library:createElement("ImageLabel", {
                                        Name = "circleFrame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                                        BackgroundTransparency = 1; Image = "rbxassetid://4896743658"; ImageColor3 = Color3.fromRGB(255, 255, 255);
                                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 5, 5);
                                    })
                                })
                            })
                        })
                    })
                });
                Parent = parent;
            })

            local renderStepped, activeInput, connected, first = nil, nil, false, true
            local container = newSlider.border.frame.container
            local textBox = newSlider.border.frame.valueButtonBorder.valueButtonFrame.valueLabel

            local function update()
                if renderStepped then renderStepped:Disconnect() end
                renderStepped = runService.RenderStepped:Connect(function()
                    local screenPos = userInputService:GetMouseLocation()
                    if activeInput and activeInput.UserInputType == Enum.UserInputType.Touch then screenPos = activeInput.Position end
                    local mouse = toGuiPosition(screenPos)
                    local percent = (mouse.X - container.AbsolutePosition.X) / (container.AbsoluteSize.X)
                    percent = math.clamp(percent, 0, 1)
                    percent = tonumber(string.format("%.2f", percent))
                    if first then
                        container.sliderBar.circleBorder.Position = UDim2.new(((sDefault - min) / (max - min)), -4, 0, -4)
                        container.sliderBar.moveBar.Size = UDim2.new(((sDefault - min) / (max - min)), -4, 0, 2)
                        first = false
                    end
                    container.sliderBar.circleBorder.Position = UDim2.new(math.clamp(percent, 0, 1), -4, 0, -4)
                    container.sliderBar.moveBar.Size = UDim2.new(math.clamp(percent, 0, 1), -4, 0, 2)
                    local value = math.floor(min + (max - min) * percent)
                    textBox.Text = value; sLocation[sFlag] = tonumber(value); sCallback(sLocation[sFlag])
                end)
            end
            local function stop() if renderStepped then renderStepped:Disconnect() end; renderStepped = nil end
            local function pressEnded(input)
                if not connected or input ~= activeInput then return end
                connected = false; activeInput = nil; stop()
            end
            local function pressBegan(input)
                if not isPrimaryInput(input) then return end
                if connected and activeInput == input then return end
                activeInput = input; connected = true; update()
                input.Changed:Connect(function()
                    local state = input.UserInputState
                    if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then pressEnded(input) end
                end)
                local conn
                conn = userInputService.InputEnded:Connect(function(ended)
                    if ended == input then conn:Disconnect(); pressEnded(input) end
                end)
            end
            container.InputBegan:Connect(pressBegan); container.InputEnded:Connect(pressEnded)
            container.sliderBar.InputBegan:Connect(pressBegan); container.sliderBar.InputEnded:Connect(pressEnded)

            local step = options.step or 1
            local function setValue(v)
                v = math.floor(math.clamp(tonumber(v) or min, min, max)); sLocation[sFlag] = v; textBox.Text = tostring(v)
                local p = (max > min) and ((v - min) / (max - min)) or 0
                container.sliderBar.circleBorder.Position = UDim2.new(math.clamp(p, 0, 1), -4, 0, -4)
                container.sliderBar.moveBar.Size = UDim2.new(math.clamp(p, 0, 1), -4, 0, 2); sCallback(v)
            end
            onPress(newSlider.border.frame.minus, function() setValue((sLocation[sFlag] or min) - step) end)
            onPress(newSlider.border.frame.plus, function() setValue((sLocation[sFlag] or min) + step) end)

            textBox:GetPropertyChangedSignal("Text"):Connect(function()
                textBox.Text = textBox.Text:gsub("[^%-%d]", "")
            end)
            textBox.FocusLost:Connect(function()
                local n = tonumber(textBox.Text)
                if not n then textBox.Text = tostring(sLocation[sFlag] or min); return end
                setValue(n)
            end)
        end

        -- ==================== Dropdown ====================
        function tabs:dropdown(name, useToggles, options, callback)
            local location = options.location or self.flags
            local flag = not useToggles and options.flag or ""
            local side = options.side or "Left"
            local parent = (side == "Right") and self.rightContainer or self.leftContainer
            local callback = callback or function() end
            local list = {}
            for i,v in ipairs(options.list or {}) do
                if type(v) == "table" then
                    local item = {}
                    for k,val in pairs(v) do item[k] = val end
                    item.Name = tostring(v.Name or v.name or v[1] or ("Option " .. i))
                    item.flag = v.flag or item.Name
                    table.insert(list,item)
                else
                    local n = tostring(v)
                    table.insert(list, { Name = n; flag = n; })
                end
            end
            local default
            if useToggles then
                local defaults = type(options.default) == "table" and options.default or {}
                for _,item in ipairs(list) do
                    if location[item.flag] == nil then
                        local c = defaults[item.flag]
                        if c == nil then c = table.find(defaults,item.Name) ~= nil end
                        location[item.flag] = c == true
                    end
                end
                default = name
            else
                default = options.default or (list[1] and list[1].Name) or "None"
            end
            if not useToggles then location[flag] = default end

            local newDropdown = library:createElement("Frame", {
                Name = name; Size = UDim2.new(1, 0, 0, 35); BackgroundTransparency = 1; LayoutOrder = self:getOrder(side);
                library:createElement("ImageLabel", {
                    Name = "border"; Size = UDim2.new(1, 0, 0, 26); Position = UDim2.new(0, 0, 0, 5);
                    BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(28, 28, 28);
                    ImageTransparency = 0.5; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); ZIndex = 2;
                    library:createElement("ImageButton", {
                        Name = "frame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                        BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK;
                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); ZIndex = 2;
                        library:createElement("TextLabel", {
                            Name = "label"; Size = UDim2.new(1, -30, 0, 25); Position = UDim2.new(0, 10, 0, 0);
                            Text = default; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12; TextWrapped = true;
                            Font = Enum.Font.GothamSemibold; TextXAlignment = Enum.TextXAlignment.Left;
                            TextTruncate = Enum.TextTruncate.AtEnd; BackgroundTransparency = 1; ZIndex = 2;
                        })
                    })
                });
                Parent = parent;
            })

            local arrow = library:createElement("ImageLabel", {
                Name = "arrow"; Size = UDim2.new(0, 11, 0, 6); Position = UDim2.new(1, -25, 0, 10);
                BackgroundTransparency = 1; Image = "rbxassetid://5882688826"; ImageColor3 = "@theme";
                ZIndex = 2; Parent = newDropdown.border;
            })

            local container = library:createElement("Frame", {
                Name = "containerFrame"; Size = UDim2.new(1, 0, 0, 0); Position = UDim2.new(0, 0, 0, 31);
                BackgroundTransparency = 1; ZIndex = 20; ClipsDescendants = true;
                library:createElement("ImageLabel", {
                    Name = "containerBorder"; Size = UDim2.new(1, 0, 1, 0);
                    BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(25, 25, 25);
                    ImageTransparency = 0.15; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                    ClipsDescendants = true; ZIndex = 1;
                    library:createElement("ImageLabel", {
                        Name = "container"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                        BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(10, 10, 10);
                        ImageTransparency = 0.02; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                        ClipsDescendants = true; ZIndex = 1;
                        library:createElement("ScrollingFrame", {
                            Name = "scroll"; Size = UDim2.new(1, -10, 1, -10); Position = UDim2.new(0, 5, 0, 5);
                            CanvasSize = UDim2.new(0, 0, 0, #list * 32 + 2); ScrollingEnabled = #list > 5;
                            ScrollBarThickness = (#list > 5 and 2) or 0; ScrollBarImageTransparency = (#list > 5 and 0.2) or 1;
                            ScrollingDirection = Enum.ScrollingDirection.Y; ElasticBehavior = Enum.ElasticBehavior.Never;
                            BackgroundTransparency = 1;
                            library:createElement("UIListLayout", {
                                Name = "list"; SortOrder = 2; Padding = UDim.new(0, 2); HorizontalAlignment = Enum.HorizontalAlignment.Center;
                            })
                        })
                    })
                });
                Parent = newDropdown;
            })

            if options.icon then
                local iconLabel = library:createElement("ImageLabel", {
                    Name = "icon"; Size = UDim2.new(0, 16, 0, 16); Position = UDim2.new(0, 10, 0, 4);
                    BackgroundTransparency = 1; ImageColor3 = "@theme"; ZIndex = 2; Parent = newDropdown.border.frame;
                })
                applyIcon(iconLabel, options.icon)
                newDropdown.border.frame.label.Position = UDim2.new(0, 32, 0, 0)
                newDropdown.border.frame.label.Size = UDim2.new(1, -42, 0, 25)
            end

            local border = newDropdown:WaitForChild("border")
            local button = border:WaitForChild("frame")
            local label = button:WaitForChild("label")

            local dropDown = {
                toggled = false; object = newDropdown; border = border; label = label; arrow = arrow;
                container = container.containerBorder.container.scroll; l = location; f = flag; usesToggles = useToggles;
            }
            table.insert(dropList, dropDown)

            for i,v in pairs(list) do
                local listItem = library:createElement("ImageButton", {
                    Name = v.Name; Size = UDim2.new(1, -8, 0, 30); BackgroundTransparency = 1;
                    Image = "rbxassetid://4894670678"; ImageColor3 = Color3.fromRGB(45, 45, 45); ImageTransparency = 1;
                    ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                    AutoButtonColor = false; LayoutOrder = i; ZIndex = 2;
                    library:createElement("TextLabel", {
                        Name = "title"; Size = UDim2.new(1, -44, 1, 0); Position = UDim2.new(0, 12, 0, 0);
                        BackgroundTransparency = 1; Text = v.Name; TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 12; Font = Enum.Font.GothamSemibold; TextXAlignment = Enum.TextXAlignment.Left;
                        TextTruncate = Enum.TextTruncate.AtEnd; TextTransparency = 0.4; ZIndex = 2;
                    });
                    library:createElement("TextLabel", {
                        Name = "mark"; Size = UDim2.new(0, 16, 1, 0); Position = UDim2.new(1, -24, 0, 0);
                        BackgroundTransparency = 1; Text = "✓"; TextColor3 = "@theme";
                        TextSize = 12; Font = Enum.Font.GothamBold; TextTransparency = 1; ZIndex = 2;
                    });
                    Parent = dropDown.container;
                })

                local function applyVisual(selected)
                    listItem.ImageTransparency = (selected and 0.7) or 1
                    listItem.title.TextTransparency = (selected and 0) or 0.4
                    listItem.mark.TextTransparency = (selected and 0) or 1
                end
                applyVisual((useToggles and location[v.flag]) or ((not useToggles) and v.Name == default))

                local function switch()
                    if useToggles then
                        location[v.flag] = not location[v.flag]
                        callback(location[v.flag], v.Name, v.flag)
                        applyVisual(location[v.flag])
                    else
                        for _, other in pairs(dropDown.container:GetChildren()) do
                            if other:IsA("GuiButton") and other ~= listItem then
                                other.ImageTransparency = 1; other.title.TextTransparency = 0.4; other.mark.TextTransparency = 1
                            end
                        end
                        applyVisual(true); dropDown.toggled = false
                        button.label.TextTransparency = 0; button.label.Text = v.Name
                        dropDown.arrow.Rotation = 0; newDropdown.ZIndex = 1
                        container:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.15, true)
                        location[flag] = v.Name; callback(location[flag])
                    end
                end
                onPress(listItem, switch)
            end

            onPress(button, function()
                dropDown.toggled = not dropDown.toggled
                if not useToggles then
                    dropDown.label.TextTransparency = (dropDown.toggled and 0.5) or 0
                    dropDown.label.Text = (dropDown.toggled and name) or location[flag]
                end
                local y = math.min(#list, 5) * 32 + 10
                for i,v in pairs(dropList) do
                    if v ~= dropDown and v.toggled then
                        v.toggled = false; v.object.ZIndex = 1; v.arrow.Rotation = 0
                        v.container.Parent.Parent.Parent:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.15, true)
                        wait(0.15)
                        if not v.usesToggles then v.label.TextTransparency = 0; v.label.Text = v.l[v.f] end
                    end
                end
                dropDown.arrow.Rotation = (dropDown.toggled and 180) or 0
                newDropdown.ZIndex = (dropDown.toggled and 30) or 1
                container:TweenSize(UDim2.new(1, 0, 0, (dropDown.toggled and y) or 0), (dropDown.toggled and "Out") or "In", "Quad", 0.15, true)
            end)

            userInputService.InputBegan:Connect(function(input)
                if not isPrimaryInput(input) then return end
                if not dropDown.toggled or (isInGui(dropDown.border, input.Position) or isInGui(container.containerBorder, input.Position)) then return end
                dropDown.toggled = false
                if not useToggles then dropDown.label.TextTransparency = 0; dropDown.label.Text = location[flag] end
                newDropdown.ZIndex = 1
                container:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.15, true)
                dropDown.arrow.Rotation = 0
            end)
        end

        -- ==================== Color Selector ====================
        function tabs:colorSelector(name, options, callback)
            local location = options.location or self.flags
            local flag = options.flag or ""
            local side = options.side or "Left"
            local parent = (side == "Right") and self.rightContainer or self.leftContainer
            local default = options.default or Color3.fromRGB(255, 255, 255)
            local callback = callback or function() end
            location[flag] = default
            local R, G, B = math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)

            local newColorSelector = library:createElement("Frame", {
                Name = name; Size = UDim2.new(1, 0, 0, 130); BackgroundTransparency = 1; LayoutOrder = self:getOrder(side);
                library:createElement("ImageLabel", {
                    Name = "border"; Size = UDim2.new(1, 0, 0, 120); Position = UDim2.new(0, 0, 0, 5);
                    BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = "@theme";
                    ImageTransparency = 0.35; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                    library:createElement("ImageLabel", {
                        Name = "frame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                        BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK;
                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); ClipsDescendants = true;
                        library:createElement("TextLabel", {
                            Name = "title"; Size = UDim2.new(1, 0, 0, 24);
                            Text = name; TextColor3 = Color3.fromRGB(250, 250, 250); TextSize = 12;
                            Font = Enum.Font.GothamSemibold; BackgroundTransparency = 1;
                        });
                    })
                });
                Parent = parent;
            })

            local frame = newColorSelector.border.frame
            local colors = {R = R, G = G, B = B}
            local preview

            for idx, ch in ipairs({"R", "G", "B"}) do
                local color = ch == "R" and Color3.fromRGB(255,0,0) or ch == "G" and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,255)
                local bar = library:createElement("Frame", {
                    Name = ch.."Bar"; Size = UDim2.new(1, -20, 0, 6); Position = UDim2.new(0, 10, 0, 32 + (idx-1)*22);
                    BackgroundColor3 = Color3.fromRGB(40,40,40); BorderSizePixel = 0; ZIndex = 2; Parent = frame;
                })
                library:createElement("Frame", {
                    Name = "fill"; Size = UDim2.new(colors[ch]/255, 0, 1, 0); BackgroundColor3 = color;
                    BorderSizePixel = 0; ZIndex = 3; Parent = bar;
                })
                library:createElement("TextLabel", {
                    Name = "label"; Size = UDim2.new(0, 20, 0, 6); Position = UDim2.new(0, -20, 0, 0);
                    Text = ch; TextColor3 = Color3.fromRGB(200,200,200); TextSize = 10;
                    Font = Enum.Font.GothamSemibold; BackgroundTransparency = 1; Parent = bar;
                })

                local dragging, dInput = false, nil
                local function updateFromX(x)
                    local p = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    colors[ch] = math.floor(p * 255)
                    bar.fill.Size = UDim2.new(p, 0, 1, 0)
                    location[flag] = Color3.fromRGB(colors.R, colors.G, colors.B)
                    if preview then preview.BackgroundColor3 = location[flag] end
                    callback(location[flag])
                end
                bar.InputBegan:Connect(function(input)
                    if not isPrimaryInput(input) then return end
                    dragging = true; dInput = input; updateFromX(input.Position.X)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                            dragging = false
                        end
                    end)
                end)
                userInputService.InputChanged:Connect(function(input)
                    if not dragging then return end
                    if input == dInput or input.UserInputType == Enum.UserInputType.MouseMovement
                        or (dInput and dInput.UserInputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch) then
                        updateFromX(input.Position.X)
                    end
                end)
            end

            preview = library:createElement("Frame", {
                Name = "preview"; Size = UDim2.new(0, 40, 0, 20); Position = UDim2.new(1, -50, 0, 3);
                BackgroundColor3 = default; BorderSizePixel = 0; ZIndex = 3; Parent = frame;
                (function() local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) return c end)();
            })
        end

        function library:setTheme(color)
            if type(color) == "string" then color = Color3.fromHex(color) end
            self.themeColor = color
            for _, entry in ipairs(self.themeElements) do applyTheme(entry.obj, entry.prop) end
            for _, tab in ipairs(tabList) do
                if tab.toggled and tab.object.button and tab.object.button.icon then
                    tab.object.button.icon.ImageColor3 = color
                end
            end
        end

        function library:createElement(class, data)
            local obj = Instance.new(class)
            for i,v in pairs(data) do
                if i ~= "Parent" then
                    if typeof(v) == "Instance" then v.Parent = obj
                    elseif v == "@theme" then registerTheme(obj, i)
                    else pcall(function() obj[i] = v end) end
                end
            end
            obj.Parent = data.Parent
            return obj
        end

        function library:createWindow(name, icon, subtitle)
            if not library.container then
                library.container = self:createElement("ScreenGui", {
                    IgnoreGuiInset = true;
                    self:createElement("Frame", {
                        Name = "Container"; Size = UDim2.new(1, -30, 1, 0);
                        Position = UDim2.new(0, 20, 0, 20);
                        BackgroundTransparency = 1; Active = false;
                    });
                }):FindFirstChild("Container")
            end
            if syn and syn.protect_gui then syn.protect_gui(library.container.Parent) end
            library.container.Parent.Parent = game:GetService("CoreGui")
            if getgenv then getgenv().ui = library.container end
            return main:window(name, icon, subtitle)
        end

        function library:notify(title, text, timeout)
            local timeout = timeout or 5
            local notification = library:createElement("ImageLabel", {
                Name = "border"; Size = UDim2.new(0, 200, 0, 75); Position = UDim2.new(1.1, 0, 0.87, 0);
                BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = "@theme";
                ImageTransparency = 0.35; ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297);
                library:createElement("ImageLabel", {
                    Name = "frame"; Size = UDim2.new(1, -2, 1, -2); Position = UDim2.new(0, 1, 0, 1);
                    BackgroundTransparency = 1; Image = "rbxassetid://4894670678"; ImageColor3 = BG_DARK;
                    ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 297); ClipsDescendants = true;
                    library:createElement("ImageLabel", {
                        Name = "topBorder"; Size = UDim2.new(1, 0, 0, 30);
                        Image = "rbxassetid://4892463081"; ImageColor3 = BG_COLOR;
                        ScaleType = Enum.ScaleType.Slice; SliceCenter = Rect.new(5, 5, 434, 125); BackgroundTransparency = 1;
                        library:createElement("TextLabel", {
                            Name = "title"; Size = UDim2.new(0, 200, 0, 30); Position = UDim2.new(0, 15, 0, 0);
                            Text = title; TextWrapped = true; TextXAlignment = Enum.TextXAlignment.Left;
                            TextColor3 = Color3.fromRGB(250, 250, 250); Font = Enum.Font.GothamSemibold;
                            TextSize = 14; BackgroundTransparency = 1;
                        });
                        library:createElement("Frame", {
                            Name = "line"; Size = UDim2.new(1, 0, 0, 2); Position = UDim2.new(0, 0, 1, -2);
                            BorderSizePixel = 0; BackgroundColor3 = Color3.fromRGB(28, 28, 28);
                        })
                    });
                    library:createElement("TextLabel", {
                        Name = "text"; Size = UDim2.new(0, 180, 0, 40); Position = UDim2.new(0, 10, 0, 30);
                        Text = text; TextColor3 = Color3.fromRGB(250, 250, 250); TextWrapped = true;
                        Font = Enum.Font.GothamSemibold; TextSize = 12; BackgroundTransparency = 1;
                    })
                });
                Parent = library.container;
            })
            spawn(function()
                wait(0.2)
                notification:TweenPosition(UDim2.new(0.88, 0, 0.87, 0), "In", "Quad", 0.25, true)
                wait(timeout)
                notification:TweenPosition(UDim2.new(1.1, 0, 0.87, 0), "In", "Quad", 0.25, true)
                wait(0.25); notification:Destroy()
            end)
        end

        local function isReallyPressed(bind, input)
            if typeof(bind) == "Instance" then
                if bind.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == bind.KeyCode then return true
                elseif tostring(bind.UserInputType):find("MouseButton") and input.UserInputType == bind.UserInputType then return true end
            end
            if tostring(bind):find("MouseButton1") then return bind == input.UserInputType
            else return bind == input.KeyCode end
        end

        userInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.RightControl then
                library.toggled = not library.toggled
                library.container.Visible = not library.container.Visible
            end
            if library.binding then return end
            for i,v in pairs(library.binds) do
                if v.location[i] ~= nil then
                    local rb = v.location[i]
                    if rb and isReallyPressed(rb, input) then v.call() end
                end
            end
        end)
    end
    return library
end)()

-- =========================================================================
-- [ส่วนที่ 2] ตัวอย่างการใช้งาน
-- =========================================================================
local Window = ui:createWindow("ReaperX (Made by x2Swiftz)", "lucide:zap", "Dungeon: Northern Lands")

local AutoFarmTab  = Window:newTab("Auto Farm",    "lucide:swords")
local AutoRaidTab  = Window:newTab("Auto Raids",   "lucide:skull")
local AutoPartyTab = Window:newTab("Auto Party",   "lucide:users")
local AutoSellTab  = Window:newTab("Auto Sell",    "lucide:shopping-cart")
local AutoCrateTab = Window:newTab("Auto Crates",  "lucide:gift")
local WebhookTab   = Window:newTab("Webhook",      "lucide:bell")
local UtilityTab   = Window:newTab("Utilities",    "lucide:globe")
local ServerTab    = Window:newTab("Servers",      "lucide:server")

-- ===== Auto Farm =====
AutoFarmTab:section("Combat", "lucide:swords", "Left")
AutoFarmTab:toggle("Combat", { flag = "combat", default = true, side = "Left", icon = "lucide:swords", card = true, subtitle = "Dungeon Farming" }, false, {}, function(s) end)
AutoFarmTab:toggle("Auto Farm",   { flag = "autoFarm",   default = false, side = "Left" }, false, {}, function(s) end)
AutoFarmTab:toggle("Auto Attack", { flag = "autoAttack", default = false, side = "Left" }, false, {}, function(s) end)

AutoFarmTab:section("Abilities", "lucide:star", "Left")
AutoFarmTab:toggle("Abilities", { flag = "abilities", default = true, side = "Left", icon = "lucide:star", card = true, subtitle = "Skill automation" }, false, {}, function(s) end)
AutoFarmTab:toggle("Auto Skills", { flag = "autoSkills", default = true, side = "Left", icon = "lucide:zap" }, false, {}, function(s) end)
AutoFarmTab:slider("Attack Range", { flag = "atkRange",  min = 1,  max = 100, default = 20, step = 1, side = "Left" }, function(v) end)
AutoFarmTab:slider("Walk Speed",   { flag = "walkSpeed", min = 16, max = 200, default = 20, step = 1, side = "Left" }, function(v) end)

AutoFarmTab:section("Auto Restart", "lucide:rotate-cw", "Left")
AutoFarmTab:toggle("Auto Restart", { flag = "autoRestart", default = true, side = "Left", icon = "lucide:rotate-cw", card = true, subtitle = "Restart game after seconds." }, false, {}, function(s) end)
AutoFarmTab:slider("Restart After", { flag = "restartAfter", min = 10, max = 600, default = 60, step = 10, side = "Left" }, function(v) end)

AutoFarmTab:section("Launch", "lucide:play", "Right")
AutoFarmTab:toggle("Launch", { flag = "launch", default = true, side = "Right", icon = "lucide:play", card = true, subtitle = "Create a Dungeon" }, false, {}, function(s) end)
AutoFarmTab:toggle("Auto Start", { flag = "autoStart", default = false, side = "Right" }, false, {}, function(s) end)
AutoFarmTab:toggle("Auto Select Best Dungeon", { flag = "autoSelect", default = false, side = "Right" }, false, {}, function(s) end)
AutoFarmTab:dropdown("Dungeon", false, { flag = "dungeon", side = "Right", list = {"Desert Temple", "Northern Lands", "Frozen Kingdom", "Volcano"} }, function(sel) end)
AutoFarmTab:dropdown("Difficulty", false, { flag = "difficulty", side = "Right", list = {"Easy", "Medium", "Hard", "Nightmare"} }, function(sel) end)
AutoFarmTab:toggle("Hardcore", { flag = "hardcore", default = false, side = "Right" }, false, {}, function(s) end)

AutoFarmTab:section("Loop", "lucide:refresh-cw", "Right")
AutoFarmTab:toggle("Loop", { flag = "loop", default = true, side = "Right", icon = "lucide:refresh-cw", card = true, subtitle = "Repeat dungeon runs" }, false, {}, function(s) end)
AutoFarmTab:toggle("Auto Replay",        { flag = "autoReplay", default = false, side = "Right" }, false, {}, function(s) end)
AutoFarmTab:toggle("Auto Back to Lobby", { flag = "autoLobby",  default = false, side = "Right" }, false, {}, function(s) end)
AutoFarmTab:slider("Back to Lobby After", { flag = "backLobbyAfter", min = 1, max = 50, default = 5, step = 1, side = "Right" }, function(v) end)

-- ===== Auto Raids =====
AutoRaidTab:section("Raid Settings", "lucide:skull", "Left")
AutoRaidTab:toggle("Auto Raid", { flag = "autoRaid", default = false, side = "Left", icon = "lucide:skull", card = true, subtitle = "Auto join raid" }, false, {}, function(s) end)
AutoRaidTab:toggle("Auto Attack Boss", { flag = "autoBoss", default = false, side = "Left" }, false, {}, function(s) end)
AutoRaidTab:dropdown("เลือก Raid", false, { flag = "raidType", side = "Right", list = {"Raid 1", "Raid 2", "Raid 3", "Raid 4"} }, function(sel) end)
AutoRaidTab:slider("Attack Range", { flag = "raidRange", min = 1, max = 100, default = 30, step = 1, side = "Right" }, function(v) end)

-- ===== Auto Party =====
AutoPartyTab:section("Party Settings", "lucide:users", "Left")
AutoPartyTab:toggle("Auto Accept Party", { flag = "autoAccept", default = false, side = "Left", icon = "lucide:check-circle" }, false, {}, function(s) end)
AutoPartyTab:toggle("Auto Leave Party",  { flag = "autoLeave",  default = false, side = "Left" }, false, {}, function(s) end)
AutoPartyTab:textbox("ชื่อผู้เล่นที่ต้องการเชิญ", { flag = "invitePlayer", default = "...", side = "Right" }, function(text) end)
AutoPartyTab:slider("Party Size", { flag = "partySize", min = 1, max = 4, default = 4, step = 1, side = "Right" }, function(v) end)
AutoPartyTab:button("เชิญผู้เล่นทั้งหมด", function()
    ui:notify("Auto Party", "เชิญผู้เล่นทั้งหมดแล้ว!", 3)
end, "lucide:user-plus", { side = "Left" })

-- ===== Auto Sell =====
AutoSellTab:section("Sell Settings", "lucide:shopping-cart", "Left")
AutoSellTab:toggle("Auto Sell", { flag = "autoSell", default = false, side = "Left", icon = "lucide:shopping-cart", card = true, subtitle = "Auto sell items" }, false, {}, function(s) end)
AutoSellTab:toggle("Sell Common",    { flag = "sellCommon",    default = true,  side = "Left" }, false, {}, function(s) end)
AutoSellTab:toggle("Sell Rare",      { flag = "sellRare",      default = false, side = "Left" }, false, {}, function(s) end)
AutoSellTab:toggle("Sell Epic",      { flag = "sellEpic",      default = false, side = "Right" }, false, {}, function(s) end)
AutoSellTab:toggle("Sell Legendary", { flag = "sellLegendary", default = false, side = "Right" }, false, {}, function(s) end)
AutoSellTab:slider("Sell Delay", { flag = "sellDelay", min = 1, max = 60, default = 5, step = 1, side = "Right" }, function(v) end)

-- ===== Auto Crates =====
AutoCrateTab:section("Crate Settings", "lucide:gift", "Left")
AutoCrateTab:toggle("Auto Open Crate", { flag = "autoCrate", default = false, side = "Left", icon = "lucide:gift", card = true, subtitle = "Auto open crates" }, false, {}, function(s) end)
AutoCrateTab:dropdown("เลือก Crate", false, { flag = "crateType", side = "Right", list = {"Common Crate", "Rare Crate", "Epic Crate", "Legendary Crate"} }, function(sel) end)
AutoCrateTab:slider("จำนวนที่เปิด", { flag = "crateAmount", min = 1, max = 100, default = 10, step = 1, side = "Left" }, function(v) end)
AutoCrateTab:button("เปิด Crate ทันที", function()
    ui:notify("Auto Crates", "เปิด Crate เรียบร้อย!", 3)
end, "lucide:package-open", { side = "Right" })

-- ===== Webhook =====
WebhookTab:section("Webhook Settings", "lucide:bell", "Left")
WebhookTab:toggle("Enable Webhook", { flag = "enableWebhook", default = false, side = "Left", icon = "lucide:bell", card = true, subtitle = "Send notifications to Discord" }, false, {}, function(s) end)
WebhookTab:toggle("Notify on Rare Drop", { flag = "notifyRare",  default = true, side = "Left" }, false, {}, function(s) end)
WebhookTab:toggle("Notify on Level Up",  { flag = "notifyLevel", default = true, side = "Left" }, false, {}, function(s) end)
WebhookTab:textbox("Webhook URL", { flag = "webhookUrl", default = "https://discord.com/api/webhooks/...", side = "Right" }, function(text) end)
WebhookTab:button("ทดสอบ Webhook", function()
    ui:notify("Webhook", "ส่งข้อความทดสอบแล้ว!", 3)
end, "lucide:send", { side = "Right" })

-- ===== Utilities =====
UtilityTab:section("การแจ้งเตือน", "lucide:bell", "Left")
UtilityTab:button("แจ้งเตือนสำเร็จ", function() ui:notify("สำเร็จ", "ระบบทำงานปกติ!", 3) end, "lucide:check-circle", { side = "Left" })
UtilityTab:button("แจ้งเตือนข้อผิดพลาด", function() ui:notify("ผิดพลาด", "เกิดข้อผิดพลาด!", 3) end, "lucide:alert-circle", { side = "Left" })

UtilityTab:section("ตั้งค่าธีม", "lucide:palette", "Right")
UtilityTab:button("ธีมแดง",   function() ui:setTheme(Color3.fromRGB(255, 59, 59))  end, "lucide:palette", { side = "Right" })
UtilityTab:button("ธีมเขียว", function() ui:setTheme(Color3.fromRGB(0, 200, 100)) end, "lucide:palette", { side = "Right" })
UtilityTab:button("ธีมฟ้า",   function() ui:setTheme(Color3.fromRGB(0, 150, 255)) end, "lucide:palette", { side = "Right" })
UtilityTab:button("ธีมม่วง",  function() ui:setTheme(Color3.fromRGB(150, 0, 255)) end, "lucide:palette", { side = "Right" })

UtilityTab:section("อื่นๆ", "lucide:settings", "Left")
UtilityTab:toggle("Anti AFK",    { flag = "antiAfk",    default = true,  side = "Left", icon = "lucide:user-check" }, false, {}, function(s) end)
UtilityTab:toggle("Auto Rejoin", { flag = "autoRejoin", default = false, side = "Left", icon = "lucide:log-in" }, false, {}, function(s) end)

-- ===== Servers =====
ServerTab:section("Server Hop", "lucide:server", "Left")
ServerTab:toggle("Auto Server Hop", { flag = "autoHop", default = false, side = "Left", icon = "lucide:refresh-cw", card = true, subtitle = "Hop to a new server" }, false, {}, function(s) end)
ServerTab:slider("Hop Delay", { flag = "hopDelay", min = 5, max = 300, default = 30, step = 5, side = "Right" }, function(v) end)
ServerTab:dropdown("เลือก Region", false, { flag = "region", side = "Right", list = {"Singapore", "Japan", "USA", "Europe", "Auto"} }, function(sel) end)
ServerTab:button("Rejoin Server",  function() ui:notify("Server", "กำลัง Rejoin...", 2) end, "lucide:log-in",   { side = "Left" })
ServerTab:button("Hop Server ใหม่", function() ui:notify("Server", "กำลัง Hop...",    2) end, "lucide:shuffle", { side = "Right" })

ui:notify("ยินดีต้อนรับ", "โหลด UI เรียบร้อย! กด RightControl เพื่อซ่อน", 5)