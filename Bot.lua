-- SCRIPT BOT MOBILE - Versão Final Corrigida
-- Aimbot + ESP + Ir até Inimigo + Puxar Inimigo + Esconder FOV

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Aguardar carregamento
repeat task.wait() until LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
local LP = LocalPlayer

print("✅ INICIANDO...")

-- Variáveis
local AimbotEnabled = false
local ESPEnabled = false
local ESPBox = true
local ESPName = true
local ESPDistance = true
local ESPTracer = true
local WallcheckEnabled = false
local TeamCheck = false
local FOVRadius = 120
local Smoothness = 5
local HitPart = "Head"
local ESPColor = Color3.fromRGB(255, 80, 80)
local FOVColor = Color3.fromRGB(80, 130, 255)
local FOVCircle = nil
local ESPObjects = {}
local FOVHidden = false

-- Criar ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "ScriptBot"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = LP.PlayerGui

-- Função IsEnemy
local function IsEnemy(p)
    if not p or p == LP then return false end
    if not p.Character then return false end
    if TeamCheck then
        if LP.Team and p.Team and LP.Team ~= p.Team then return true
        elseif LP.Team and p.Team then return false end
    end
    local h = p.Character:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

-- Hit Part
local function GetHitPart(char)
    if not char then return nil end
    if HitPart == "Head" then return char:FindFirstChild("Head") end
    if HitPart == "HumanoidRootPart" then return char:FindFirstChild("HumanoidRootPart") end
    return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
end

-- Inimigo mais próximo
local function GetClosest()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local best, bestDist = nil, math.huge
    local myPos = LP.Character.HumanoidRootPart.Position
    for _, p in pairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (myPos - p.Character.HumanoidRootPart.Position).Magnitude
            if d < bestDist then best = p; bestDist = d end
        end
    end
    return best
end

-- Teleportar
local function TeleportToTarget()
    local t = GetClosest()
    if not t then Notify("❌ Nenhum inimigo!"); return end
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then Notify("❌ Sem personagem!"); return end
    local pos = t.Character.HumanoidRootPart.Position
    local dir = (LP.Character.HumanoidRootPart.Position - pos).Unit
    LP.Character.HumanoidRootPart.CFrame = CFrame.new(pos + dir * 3)
    Notify("✅ Foi para: " .. t.Name)
end

-- Puxar
local function PullTarget()
    local t = GetClosest()
    if not t then Notify("❌ Nenhum inimigo!"); return end
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then Notify("❌ Sem personagem!"); return end
    local pos = LP.Character.HumanoidRootPart.Position
    local dir = (pos - t.Character.HumanoidRootPart.Position).Unit
    t.Character.HumanoidRootPart.CFrame = CFrame.new(pos - dir * 2)
    local h = t.Character:FindFirstChild("Humanoid")
    if h then h.Sit = true; task.wait(0.1); h.Sit = false end
    Notify("✅ Puxou: " .. t.Name)
end

-- Notificação
function Notify(text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.7, 0, 0, 38)
    f.Position = UDim2.new(0.5, 0, 0.08, 0)
    f.AnchorPoint = Vector2.new(0.5, 0)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    f.BorderSizePixel = 0
    f.ZIndex = 999
    f.Parent = gui
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(80, 130, 255)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.ZIndex = 1000
    task.delay(2, function() if f.Parent then f:Destroy() end end)
end

-- ===== BOTÃO ABRIR =====
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0.85, -27, 0.75, -27)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
OpenBtn.Text = "⚡"
OpenBtn.TextColor3 = Color3.fromRGB(80, 130, 255)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 26
OpenBtn.BorderSizePixel = 0
OpenBtn.Visible = true
OpenBtn.Active = true
OpenBtn.ZIndex = 100
OpenBtn.Parent = gui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 27)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(80, 130, 255)

print("✅ Botão criado")

-- ===== MENU =====
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0.92, 0, 0.72, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.ZIndex = 80
Main.Parent = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(60, 100, 220)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 40)
Header.BorderSizePixel = 0
Header.ZIndex = 81
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0.04, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ SCRIPT BOT"
Title.TextColor3 = Color3.fromRGB(100, 150, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 82
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 82
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 16)

-- Scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -45)
Scroll.Position = UDim2.new(0, 0, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 130, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ZIndex = 80
Scroll.Parent = Main

local List = Instance.new("UIListLayout", Scroll)
List.Padding = UDim.new(0, 6)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Funções UI
local function Sec(title)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(0.92, 0, 0, 24)
    s.BackgroundTransparency = 1
    s.ZIndex = 81
    s.Parent = Scroll
    local l = Instance.new("TextLabel", s)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = title
    l.TextColor3 = Color3.fromRGB(140, 140, 170)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 82
    return s
end

local function Toggle(text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.92, 0, 0, 40)
    f.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    f.BorderSizePixel = 0
    f.ZIndex = 81
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0.05, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 82
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 46, 0, 22)
    btn.Position = UDim2.new(1, -54, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(80, 130, 255) or Color3.fromRGB(55, 55, 80)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.ZIndex = 82
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 11)
    
    local knob = Instance.new("Frame", btn)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 83
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 9)
    
    local enabled = default
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(80, 130, 255) or Color3.fromRGB(55, 55, 80)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        }):Play()
        callback(enabled)
    end)
end

local function Btn(text, color, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.92, 0, 0, 40)
    f.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    f.BorderSizePixel = 0
    f.ZIndex = 81
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0.9, 0, 0, 28)
    b.Position = UDim2.new(0.5, 0, 0.5, 0)
    b.AnchorPoint = Vector2.new(0.5, 0.5)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.ZIndex = 82
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Click:Connect(callback)
end

local function Sld(text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.92, 0, 0, 55)
    f.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    f.BorderSizePixel = 0
    f.ZIndex = 81
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.5, 0, 0, 18)
    lbl.Position = UDim2.new(0.05, 0, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 82
    
    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0.25, 0, 0, 18)
    val.Position = UDim2.new(0.7, 0, 0, 5)
    val.BackgroundTransparency = 1
    val.Text = tostring(default)
    val.TextColor3 = Color3.fromRGB(100, 150, 255)
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.ZIndex = 82
    
    local bg = Instance.new("Frame", f)
    bg.Size = UDim2.new(0.9, 0, 0, 4)
    bg.Position = UDim2.new(0.05, 0, 0, 33)
    bg.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
    bg.BorderSizePixel = 0
    bg.Active = true
    bg.ZIndex = 82
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 2)
    
    local fill = Instance.new("Frame", bg)
    local pct = (default - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
    fill.BorderSizePixel = 0
    fill.ZIndex = 83
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    
    local thumb = Instance.new("TextButton", bg)
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = UDim2.new(pct, -9, 0.5, -9)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Text = ""
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 84
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 9)
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * pos)
        val.Text = tostring(v)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -9, 0.5, -9)
        callback(v)
    end
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging then update(input) end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

local function Drop(text, options, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.92, 0, 0, 62)
    f.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    f.BorderSizePixel = 0
    f.ZIndex = 81
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -10, 0, 18)
    lbl.Position = UDim2.new(0, 5, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 82
    
    for i, opt in pairs(options) do
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0.3, 0, 0, 26)
        b.Position = UDim2.new(0.03 + ((i-1) * 0.32), 0, 0, 28)
        b.BackgroundColor3 = opt == default and Color3.fromRGB(80, 130, 255) or Color3.fromRGB(50, 50, 70)
        b.Text = opt
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.BorderSizePixel = 0
        b.ZIndex = 82
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function()
            for _, c in pairs(f:GetChildren()) do
                if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(50, 50, 70) end
            end
            b.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
            callback(opt)
        end)
    end
end

local function ColorPick(text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.92, 0, 0, 62)
    f.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    f.BorderSizePixel = 0
    f.ZIndex = 81
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -10, 0, 18)
    lbl.Position = UDim2.new(0, 5, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 82
    
    local colors = {
        Color3.fromRGB(255, 80, 80),
        Color3.fromRGB(80, 130, 255),
        Color3.fromRGB(80, 255, 100),
        Color3.fromRGB(255, 255, 80),
        Color3.fromRGB(180, 80, 255),
        Color3.fromRGB(255, 255, 255),
    }
    
    for i, color in pairs(colors) do
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0, 22, 0, 22)
        b.Position = UDim2.new(0.05 + ((i-1) * 0.15), 0, 0, 30)
        b.BackgroundColor3 = color
        b.Text = ""
        b.BorderSizePixel = 0
        b.ZIndex = 82
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 11)
        local st = Instance.new("UIStroke", b)
        st.Color = color == default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 60)
        st.Thickness = 2
        b.MouseButton1Click:Connect(function()
            callback(color)
            for _, c in pairs(f:GetChildren()) do
                if c:IsA("TextButton") and c:FindFirstChild("UIStroke") then
                    c.UIStroke.Color = c.BackgroundColor3 == color and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 60)
                end
            end
        end)
    end
end

local function Pad()
    local p = Instance.new("Frame")
    p.Size = UDim2.new(1, 0, 0, 10)
    p.BackgroundTransparency = 1
    p.Parent = Scroll
end

-- ===== CONTEÚDO =====
print("✅ Adicionando conteúdo...")

Sec("🎯 AIMBOT")
Toggle("Aimbot (Apenas Inimigos)", false, function(v)
    AimbotEnabled = v
    if v then
        Notify("🎯 Aimbot Ativado")
        if not FOVCircle then
            FOVCircle = Instance.new("Frame")
            FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
            FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
            FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
            FOVCircle.BackgroundTransparency = 1
            FOVCircle.BorderSizePixel = 0
            FOVCircle.ZIndex = 200
            FOVCircle.Parent = gui
            Instance.new("UIStroke", FOVCircle).Color = FOVColor
            Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
        end
        FOVCircle.Visible = not FOVHidden
        if FOVHidden then
            FOVCircle.UIStroke.Transparency = 1
        else
            FOVCircle.UIStroke.Transparency = 0
        end
    else
        Notify("🎯 Aimbot Desativado")
        if FOVCircle then FOVCircle.Visible = false end
    end
end)

Toggle("👁 Esconder FOV", false, function(v)
    FOVHidden = v
    if FOVCircle then
        if v then
            FOVCircle.UIStroke.Transparency = 1
            Notify("👁 FOV Escondido (Funcionando)")
        else
            FOVCircle.UIStroke.Transparency = 0
            Notify("👁 FOV Visível")
        end
    end
end)

Sec("⚡ MOVIMENTO")
Btn("🏃 IR ATÉ O INIMIGO", Color3.fromRGB(60, 140, 60), TeleportToTarget)
Btn("🧲 PUXAR INIMIGO", Color3.fromRGB(140, 60, 140), PullTarget)

Sec("👁 ESP")
Toggle("ESP (Ativar/Desativar)", false, function(v)
    ESPEnabled = v
    if v then Notify("👁 ESP Ativado")
    else
        Notify("👁 ESP Desativado")
        for _, o in pairs(ESPObjects) do if o and o.Frame then o.Frame:Destroy() end end
        ESPObjects = {}
    end
end)

Sec("📦 ELEMENTOS")
Toggle("Caixa (Box ESP)", true, function(v) ESPBox = v; for _, d in pairs(ESPObjects) do if d.Box then d.Box.Visible = v end end end)
Toggle("Nome do Jogador", true, function(v) ESPName = v; for _, d in pairs(ESPObjects) do if d.NameTag then d.NameTag.Visible = v end end end)
Toggle("Distância", true, function(v) ESPDistance = v; for _, d in pairs(ESPObjects) do if d.DistTag then d.DistTag.Visible = v end end end)
Toggle("Linha (Tracer)", true, function(v) ESPTracer = v; for _, d in pairs(ESPObjects) do if d.Tracer then d.Tracer.Visible = v end end end)

Sec("🎨 CORES")
ColorPick("Cor do ESP", ESPColor, function(c)
    ESPColor = c
    for _, d in pairs(ESPObjects) do
        if d.Box and d.Box:FindFirstChild("UIStroke") then d.Box.UIStroke.Color = c end
        if d.NameTag then d.NameTag.TextColor3 = c end
        if d.DistTag then d.DistTag.TextColor3 = c end
        if d.Tracer then d.Tracer.BackgroundColor3 = c end
    end
end)

Sec("🎯 AJUSTES AIMBOT")
Sld("Tamanho do FOV", 50, 300, FOVRadius, function(v) FOVRadius = v; if FOVCircle then FOVCircle.Size = UDim2.new(0, v*2, 0, v*2) end end)
Sld("Suavidade", 1, 15, Smoothness, function(v) Smoothness = v end)
Drop("Hit Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(v) HitPart = v; Notify("🎯 " .. v) end)

Sec("🛡️ SEGURANÇA")
Toggle("Team Check", false, function(v) TeamCheck = v; Notify(v and "🛡️ Team Check On" or "🛡️ Team Check Off") end)
Toggle("Wall Check", false, function(v) WallcheckEnabled = v end)

Sec("🎨 COR FOV")
ColorPick("Cor do FOV", FOVColor, function(c) FOVColor = c; if FOVCircle and FOVCircle:FindFirstChild("UIStroke") then FOVCircle.UIStroke.Color = c end end)

Pad()

-- Ajustar Canvas
List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
end)

print("✅ Conteúdo adicionado")

-- ===== ABRIR/FECHAR =====
OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.92, 0, 0.72, 0)
    }):Play()
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    Main.Visible = false
end)

-- Drag
local dragging = false
local dragStart, startPos = nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function() dragging = false end)

-- ===== AIMBOT =====
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character then
            local t = GetHitPart(p.Character)
            if t then
                local pos, vis = Camera:WorldToViewportPoint(t.Position)
                if vis then
                    if WallcheckEnabled then
                        local ray = Ray.new(Camera.CFrame.Position, (t.Position - Camera.CFrame.Position).Unit * 500)
                        local hit = workspace:FindPartOnRay(ray, LP.Character)
                        if not hit or not hit:IsDescendantOf(p.Character) then vis = false end
                    end
                    if vis then
                        local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if d < FOVRadius and d < dist then closest = t; dist = d end
                    end
                end
            end
        end
    end
    if closest then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 1 / Smoothness)
    end
end)

-- ===== ESP =====
local function CreateESP(player)
    if ESPObjects[player] then return end
    local f = Instance.new("Frame")
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ZIndex = 30
    f.Parent = gui
    
    local box = Instance.new("Frame", f)
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = ESPBox
    box.ZIndex = 30
    Instance.new("UIStroke", box).Color = ESPColor
    
    local nm = Instance.new("TextLabel", f)
    nm.Size = UDim2.new(1, 0, 0, 18)
    nm.Position = UDim2.new(0, 0, 0, -22)
    nm.BackgroundTransparency = 1
    nm.Text = player.Name
    nm.TextColor3 = ESPColor
    nm.Font = Enum.Font.GothamBold
    nm.TextSize = 11
    nm.Visible = ESPName
    nm.ZIndex = 31
    
    local dst = Instance.new("TextLabel", f)
    dst.Size = UDim2.new(1, 0, 0, 18)
    dst.Position = UDim2.new(0, 0, 1, 4)
    dst.BackgroundTransparency = 1
    dst.Text = "0m"
    dst.TextColor3 = ESPColor
    dst.Font = Enum.Font.GothamSemibold
    dst.TextSize = 10
    dst.Visible = ESPDistance
    dst.ZIndex = 31
    
    local tr = Instance.new("Frame", f)
    tr.BackgroundColor3 = ESPColor
    tr.BorderSizePixel = 0
    tr.Visible = ESPTracer
    tr.ZIndex = 29
    tr.AnchorPoint = Vector2.new(0.5, 0)
    
    ESPObjects[player] = {Frame
