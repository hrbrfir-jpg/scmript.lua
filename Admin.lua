-- IranChat v1.1
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local BAN_FILE = "IranChat_Bans.txt"
local FILTER_FILE = "IranChat_Filters.txt"

local function loadList(file)
    local ok, data = pcall(readfile, file)
    if ok and data then
        local t = {}
        for line in data:gmatch("[^\r\n]+") do
            if line ~= "" then t[#t+1] = line end
        end
        return t
    end
    return {}
end

local function saveList(file, list)
    pcall(writefile, file, table.concat(list, "\n"))
end

local bans = loadList(BAN_FILE)
local filters = loadList(FILTER_FILE)

local function isBanned(name)
    for _, b in ipairs(bans) do
        if b:lower() == name:lower() then return true end
    end
    return false
end

local function isFiltered(text)
    for _, f in ipairs(filters) do
        if f ~= "" and text:lower():find(f:lower(), 1, true) then return true end
    end
    return false
end

_G.IranChat = _G.IranChat or {messages = {}, private = {}}

local function pushGlobal(sender, text)
    table.insert(_G.IranChat.messages, {from = sender, text = text, time = os.time()})
    if #_G.IranChat.messages > 200 then table.remove(_G.IranChat.messages, 1) end
end

local function pushPrivate(from, to, text)
    local key = from .. "|" .. to
    _G.IranChat.private[key] = _G.IranChat.private[key] or {}
    table.insert(_G.IranChat.private[key], {from = from, text = text, time = os.time()})
end

local gui = Instance.new("ScreenGui")
gui.Name = "IranChatGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0, 50, 0, 50)
icon.Position = UDim2.new(0, 20, 0.5, -25)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
icon.BorderSizePixel = 0
icon.Text = "📜"
icon.TextSize = 28
icon.TextColor3 = Color3.new(1,1,1)
icon.Font = Enum.Font.SourceSansBold
icon.AutoButtonColor = false
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 12)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 420, 0, 320)
panel.Position = UDim2.new(0.5, -210, 0.5, -160)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "IranChat"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.Parent = panel
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, -20, 0, 30)
tabsFrame.Position = UDim2.new(0, 10, 0, 40)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = panel

local function makeTab(name, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 95, 1, 0)
    b.Position = UDim2.new(0, x, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.Parent = tabsFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local tabGlobal = makeTab("🌍 جهانی", 0)
local tabPrivate = makeTab("💬 شخصی", 100)
local tabAdmin = makeTab("⚙️ ادمین", 200)
local tabAbout = makeTab("ℹ️ درباره", 300)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -110)
content.Position = UDim2.new(0, 10, 0, 75)
content.BackgroundTransparency = 1
content.Parent = panel

-- تب جهانی
local globalFrame = Instance.new("Frame")
globalFrame.Size = UDim2.new(1, 0, 1, 0)
globalFrame.BackgroundTransparency = 1
globalFrame.Parent = content

local globalScroll = Instance.new("ScrollingFrame")
globalScroll.Size = UDim2.new(1, 0, 1, -40)
globalScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
globalScroll.BorderSizePixel = 0
globalScroll.ScrollBarThickness = 4
globalScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
globalScroll.Parent = globalFrame
Instance.new("UICorner", globalScroll).CornerRadius = UDim.new(0, 6)

local globalLayout = Instance.new("UIListLayout")
globalLayout.SortOrder = Enum.SortOrder.LayoutOrder
globalLayout.Padding = UDim.new(0, 3)
globalLayout.Parent = globalScroll

local globalInput = Instance.new("TextBox")
globalInput.Size = UDim2.new(1, -70, 0, 32)
globalInput.Position = UDim2.new(0, 0, 1, -36)
globalInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
globalInput.TextColor3 = Color3.new(1,1,1)
globalInput.PlaceholderText = "پیام جهانی..."
globalInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
globalInput.Text = ""
globalInput.ClearTextOnFocus = false
globalInput.TextSize = 14
globalInput.BorderSizePixel = 0
globalInput.Parent = globalFrame
Instance.new("UICorner", globalInput).CornerRadius = UDim.new(0, 6)

local globalSend = Instance.new("TextButton")
globalSend.Size = UDim2.new(0, 60, 0, 32)
globalSend.Position = UDim2.new(1, -60, 1, -36)
globalSend.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
globalSend.Text = "ارسال"
globalSend.TextColor3 = Color3.new(1,1,1)
globalSend.TextSize = 14
globalSend.BorderSizePixel = 0
globalSend.Parent = globalFrame
Instance.new("UICorner", globalSend).CornerRadius = UDim.new(0, 6)

-- تب شخصی
local privateFrame = Instance.new("Frame")
privateFrame.Size = UDim2.new(1, 0, 1, 0)
privateFrame.BackgroundTransparency = 1
privateFrame.Visible = false
privateFrame.Parent = content

local targetInput = Instance.new("TextBox")
targetInput.Size = UDim2.new(1, 0, 0, 30)
targetInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
targetInput.TextColor3 = Color3.new(1,1,1)
targetInput.PlaceholderText = "اسم بازیکن مقصد..."
targetInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
targetInput.Text = ""
targetInput.TextSize = 14
targetInput.BorderSizePixel = 0
targetInput.Parent = privateFrame
Instance.new("UICorner", targetInput).CornerRadius = UDim.new(0, 6)

local privateScroll = Instance.new("ScrollingFrame")
privateScroll.Size = UDim2.new(1, 0, 1, -72)
privateScroll.Position = UDim2.new(0, 0, 0, 36)
privateScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
privateScroll.BorderSizePixel = 0
privateScroll.ScrollBarThickness = 4
privateScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
privateScroll.Parent = privateFrame
Instance.new("UICorner", privateScroll).CornerRadius = UDim.new(0, 6)

local privateLayout = Instance.new("UIListLayout")
privateLayout.SortOrder = Enum.SortOrder.LayoutOrder
privateLayout.Padding = UDim.new(0, 3)
privateLayout.Parent = privateScroll

local privateInput = Instance.new("TextBox")
privateInput.Size = UDim2.new(1, -70, 0, 32)
privateInput.Position = UDim2.new(0, 0, 1, -36)
privateInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
privateInput.TextColor3 = Color3.new(1,1,1)
privateInput.PlaceholderText = "پیام شخصی..."
privateInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
privateInput.Text = ""
privateInput.ClearTextOnFocus = false
privateInput.TextSize = 14
privateInput.BorderSizePixel = 0
privateInput.Parent = privateFrame
Instance.new("UICorner", privateInput).CornerRadius = UDim.new(0, 6)

local privateSend = Instance.new("TextButton")
privateSend.Size = UDim2.new(0, 60, 0, 32)
privateSend.Position = UDim2.new(1, -60, 1, -36)
privateSend.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
privateSend.Text = "ارسال"
privateSend.TextColor3 = Color3.new(1,1,1)
privateSend.TextSize = 14
privateSend.BorderSizePixel = 0
privateSend.Parent = privateFrame
Instance.new("UICorner", privateSend).CornerRadius = UDim.new(0, 6)

-- تب ادمین
local adminFrame = Instance.new("Frame")
adminFrame.Size = UDim2.new(1, 0, 1, 0)
adminFrame.BackgroundTransparency = 1
adminFrame.Visible = false
adminFrame.Parent = content

local adminUnlocked = false
local ADMIN_PASS = "Adminp"

local passBox = Instance.new("TextBox")
passBox.Size = UDim2.new(1, -80, 0, 32)
passBox.Position = UDim2.new(0, 0, 0, 0)
passBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
passBox.TextColor3 = Color3.new(1,1,1)
passBox.PlaceholderText = "رمز ادمین..."
passBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
passBox.Text = ""
passBox.TextSize = 14
passBox.BorderSizePixel = 0
passBox.Parent = adminFrame
Instance.new("UICorner", passBox).CornerRadius = UDim.new(0, 6)

local passBtn = Instance.new("TextButton")
passBtn.Size = UDim2.new(0, 70, 0, 32)
passBtn.Position = UDim2.new(1, -70, 0, 0)
passBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
passBtn.Text = "ورود"
passBtn.TextColor3 = Color3.new(1,1,1)
passBtn.TextSize = 14
passBtn.BorderSizePixel = 0
passBtn.Parent = adminFrame
Instance.new("UICorner", passBtn).CornerRadius = UDim.new(0, 6)

local adminBody = Instance.new("Frame")
adminBody.Size = UDim2.new(1, 0, 1, -40)
adminBody.Position = UDim2.new(0, 0, 0, 40)
adminBody.BackgroundTransparency = 1
adminBody.Visible = false
adminBody.Parent = adminFrame

local adminStatus = Instance.new("TextLabel")
adminStatus.Size = UDim2.new(1, 0, 0, 24)
adminStatus.BackgroundTransparency = 1
adminStatus.Text = "وارد شدی."
adminStatus.TextColor3 = Color3.fromRGB(100, 220, 100)
adminStatus.TextSize = 13
adminStatus.TextXAlignment = Enum.TextXAlignment.Left
adminStatus.Parent = adminBody

local filterInput = Instance.new("TextBox")
filterInput.Size = UDim2.new(1, -150, 0, 28)
filterInput.Position = UDim2.new(0, 0, 0, 30)
filterInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
filterInput.TextColor3 = Color3.new(1,1,1)
filterInput.PlaceholderText = "کلمه فیلتر..."
filterInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
filterInput.Text = ""
filterInput.TextSize = 13
filterInput.BorderSizePixel = 0
filterInput.Parent = adminBody
Instance.new("UICorner", filterInput).CornerRadius = UDim.new(0, 6)

local addFilterBtn = Instance.new("TextButton")
addFilterBtn.Size = UDim2.new(0, 70, 0, 28)
addFilterBtn.Position = UDim2.new(1, -140, 0, 30)
addFilterBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
addFilterBtn.Text = "افزودن"
addFilterBtn.TextColor3 = Color3.new(1,1,1)
addFilterBtn.TextSize = 13
addFilterBtn.BorderSizePixel = 0
addFilterBtn.Parent = adminBody
Instance.new("UICorner", addFilterBtn).CornerRadius = UDim.new(0, 6)

local removeFilterBtn = Instance.new("TextButton")
removeFilterBtn.Size = UDim2.new(0, 70, 0, 28)
removeFilterBtn.Position = UDim2.new(1, -70, 0, 30)
removeFilterBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 30)
removeFilterBtn.Text = "حذف"
removeFilterBtn.TextColor3 = Color3.new(1,1,1)
removeFilterBtn.TextSize = 13
removeFilterBtn.BorderSizePixel = 0
removeFilterBtn.Parent = adminBody
Instance.new("UICorner", removeFilterBtn).CornerRadius = UDim.new(0, 6)

local banInput = Instance.new("TextBox")
banInput.Size = UDim2.new(1, -150, 0, 28)
banInput.Position = UDim2.new(0, 0, 0, 66)
banInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
banInput.TextColor3 = Color3.new(1,1,1)
banInput.PlaceholderText = "اسم بازیکن برای بن..."
banInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
banInput.Text = ""
banInput.TextSize = 13
banInput.BorderSizePixel = 0
banInput.Parent = adminBody
Instance.new("UICorner", banInput).CornerRadius = UDim.new(0, 6)

local banBtn = Instance.new("TextButton")
banBtn.Size = UDim2.new(0, 70, 0, 28)
banBtn.Position = UDim2.new(1, -140, 0, 66)
banBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 30)
banBtn.Text = "بن"
banBtn.TextColor3 = Color3.new(1,1,1)
banBtn.TextSize = 13
banBtn.BorderSizePixel = 0
banBtn.Parent = adminBody
Instance.new("UICorner", banBtn).CornerRadius = UDim.new(0, 6)

local unbanBtn = Instance.new("TextButton")
unbanBtn.Size = UDim2.new(0, 70, 0, 28)
unbanBtn.Position = UDim2.new(1, -70, 0, 66)
unbanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
unbanBtn.Text = "آنبن"
unbanBtn.TextColor3 = Color3.new(1,1,1)
unbanBtn.TextSize = 13
unbanBtn.BorderSizePixel = 0
unbanBtn.Parent = adminBody
Instance.new("UICorner", unbanBtn).CornerRadius = UDim.new(0, 6)

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, 0, 0, 28)
listLabel.Position = UDim2.new(0, 0, 0, 102)
listLabel.BackgroundTransparency = 1
listLabel.Text = ""
listLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
listLabel.TextSize = 12
listLabel.TextWrapped = true
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = adminBody

local function refreshAdminList()
    listLabel.Text = "فیلترها: " .. (#filters > 0 and table.concat(filters, ", ") or "هیچ") .. "\nبن‌ها: " .. (#bans > 0 and table.concat(bans, ", ") or "هیچ")
end

-- تب درباره
local aboutFrame = Instance.new("Frame")
aboutFrame.Size = UDim2.new(1, 0, 1, 0)
aboutFrame.BackgroundTransparency = 1
aboutFrame.Visible = false
aboutFrame.Parent = content

local aboutScroll = Instance.new("ScrollingFrame")
aboutScroll.Size = UDim2.new(1, 0, 1, 0)
aboutScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
aboutScroll.BorderSizePixel = 0
aboutScroll.ScrollBarThickness = 4
aboutScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
aboutScroll.Parent = aboutFrame
Instance.new("UICorner", aboutScroll).CornerRadius = UDim.new(0, 6)

local aboutLayout = Instance.new("UIListLayout")
aboutLayout.SortOrder = Enum.SortOrder.LayoutOrder
aboutLayout.Padding = UDim.new(0, 6)
aboutLayout.Parent = aboutScroll

local function aboutLine(text, size, color, bold)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 0, 0)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.new(1,1,1)
    l.TextSize = size or 13
    l.Font = bold and Enum.Font.SourceSansBold or Enum.Font.SourceSans
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = aboutScroll
    return l
end

aboutLine("IranChat", 20, Color3.fromRGB(100, 220, 100), true)
aboutLine("نسخه 1.1", 13, Color3.fromRGB(180, 180, 180))
aboutLine("", 6)
aboutLine("چت درون‌سرور، چت شخصی، پنل ادمین و لیست بن محلی.", 13)
aboutLine("", 6)
aboutLine("ویژگی‌ها:", 14, Color3.fromRGB(100, 220, 100), true)
aboutLine("• دکمه شناور 📜 برای باز کردن پنل", 13)
aboutLine("• تب 🌍 جهانی: چت با همه کسانی که توی همون سرور اسکریپت رو اجرا کردن", 13)
aboutLine("• تب 💬 شخصی: چت خصوصی با یک بازیکن خاص", 13)
aboutLine("• تب ⚙️ ادمین: رمز ، افزودن/حذف فیلتر و بن/آنبن محلی", 13)
aboutLine("• تب ℹ️ درباره: همین صفحه", 13)
aboutLine("", 6)
aboutLine("نکته: چت فقط درون همون سرور کار می‌کنه.", 12, Color3.fromRGB(200, 200, 100))
aboutLine("", 6)
aboutLine("ساخته‌شده برای بقا. بدون ضمانت.", 12, Color3.fromRGB(150, 150, 150))

aboutScroll.CanvasSize = UDim2.new(0, 0, 0, aboutLayout.AbsoluteContentSize.Y + 16)

local function showTab(which)
    globalFrame.Visible = (which == "global")
    privateFrame.Visible = (which == "private")
    adminFrame.Visible = (which == "admin")
    aboutFrame.Visible = (which == "about")
end

tabGlobal.MouseButton1Click:Connect(function() showTab("global") end)
tabPrivate.MouseButton1Click:Connect(function() showTab("private") end)
tabAdmin.MouseButton1Click:Connect(function() showTab("admin") end)
tabAbout.MouseButton1Click:Connect(function() showTab("about") end)

local function addMessage(scroll, layout, from, text, isMine)
    if isBanned(from) then return end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = isMine and Color3.fromRGB(0, 90, 60) or Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = scroll
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 0)
    label.Position = UDim2.new(0, 5, 0, 3)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = from .. ": " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 13
    label.Font = Enum.Font.SourceSans
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    scroll.CanvasPosition = Vector2.new(0, math.huge)
end

globalSend.MouseButton1Click:Connect(function()
    local text = globalInput.Text
    if text == "" then return end
    if isFiltered(text) then globalInput.Text = "" return end
    pushGlobal(LocalPlayer.Name, text)
    globalInput.Text = ""
end)

globalInput.FocusLost:Connect(function(enter)
    if enter then globalSend:Fire() end
end)

privateSend.MouseButton1Click:Connect(function()
    local target = targetInput.Text
    local text = privateInput.Text
    if target == "" or text == "" then return end
    if isBanned(target) then privateInput.Text = "" return end
    if isFiltered(text) then privateInput.Text = "" return end
    pushPrivate(LocalPlayer.Name, target, text)
    privateInput.Text = ""
end)

passBtn.MouseButton1Click:Connect(function()
    if passBox.Text == ADMIN_PASS then
        adminUnlocked = true
        passBox.Visible = false
        passBtn.Visible = false
        adminBody.Visible = true
        refreshAdminList()
    else
        passBox.Text = ""
        passBox.PlaceholderText = "رمز اشتباه!"
    end
end)

addFilterBtn.MouseButton1Click:Connect(function()
    if not adminUnlocked then return end
    local w = filterInput.Text
    if w == "" then return end
    table.insert(filters, w)
    saveList(FILTER_FILE, filters)
    filterInput.Text = ""
    refreshAdminList()
end)

removeFilterBtn.MouseButton1Click:Connect(function()
    if not adminUnlocked then return end
    local w = filterInput.Text
    if w == "" then return end
    for i, f in ipairs(filters) do
        if f:lower() == w:lower() then table.remove(filters, i) break end
    end
    saveList(FILTER_FILE, filters)
    filterInput.Text = ""
    refreshAdminList()
end)

banBtn.MouseButton1Click:Connect(function()
    if not adminUnlocked then return end
    local n = banInput.Text
    if n == "" then return end
    if not isBanned(n) then table.insert(bans, n) end
    saveList(BAN_FILE, bans)
    banInput.Text = ""
    refreshAdminList()
end)

unbanBtn.MouseButton1Click:Connect(function()
    if not adminUnlocked then return end
    local n = banInput.Text
    if n == "" then return end
    for i, b in ipairs(bans) do
        if b:lower() == n:lower() then table.remove(bans, i) break end
    end
    saveList(BAN_FILE, bans)
    banInput.Text = ""
    refreshAdminList()
end)

icon.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then
        showTab("global")
        refreshAdminList()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

local dragging, dragStart, startPos
icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = icon.Position
    end
end)
icon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        icon.Position = UDim2.new(startPos.X.Sca
