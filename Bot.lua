-- SCRIPT BOT MOBILE - Versão Final
-- Aimbot + ESP + Ir até Inimigo + Puxar Inimigo + Esconder FOV

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Aguardar carregamento completo
repeat task.wait() until LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
local LP = LocalPlayer

print("✅ SCRIPT INICIANDO...")

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
local FOVVisible = true -- Nova variável para controle de visibilidade do FOV

-- Criar ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptBot"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LP.PlayerGui

print("✅ GUI CRIADA")

-- Função para verificar inimigos
local function IsEnemy(player)
    if not player or player == LP then return false end
    if not player.Character then return false end
    
    if TeamCheck then
        local lpTeam = LP.Team
        local playerTeam = player.Team
        if lpTeam and playerTeam then
            return lpTeam ~= playerTeam
        end
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    return true
end

-- Função para criar/atualizar FOV Circle
local function UpdateFOVVisibility()
    if FOVCircle then
        -- Se o aimbot estiver ativo E FOVVisible for true, mostra
        -- Se o aimbot estiver ativo E FOVVisible for false, esconde mas continua funcionando
        FOVCircle.Visible = AimbotEnabled and FOVVisible
        
        -- Se quiser esconder mas manter uma referência visual mínima (opcional)
        if AimbotEnabled and not FOVVisible then
            FOVCircle.BackgroundTransparency = 1
            if FOVCircle:FindFirstChild("UIStroke") then
                FOVCircle.UIStroke.Transparency = 1
            end
        else
            FOVCircle.BackgroundTransparency = 1
            if FOVCircle:FindFirstChild("UIStroke") then
                FOVCircle.UIStroke.Transparency = 0
            end
        end
    end
end

-- Função para pegar inimigo mais próximo
local function GetClosestEnemy()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local closest = nil
    local shortestDistance = math.huge
    local myPos = LP.Character.HumanoidRootPart.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (myPos - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closest = player
            end
        end
    end
    
    return closest
end

-- Função para ir até o inimigo
local function TeleportToTarget()
    local target = GetClosestEnemy()
    if not target then
        Notify("❌ Nenhum inimigo encontrado!")
        return
    end
    
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
        Notify("❌ Você não tem personagem!")
        return
    end
    
    local targetPos = target.Character.HumanoidRootPart.Position
    local myRoot = LP.Character.HumanoidRootPart
    
    local direction = (myRoot.Position - targetPos).Unit
    local newPos = targetPos + direction * 3
    
    myRoot.CFrame = CFrame.new(newPos)
    Notify("✅ Teleportado para: " .. target.Name)
end

-- Função para puxar o inimigo
local function PullTarget()
    local target = GetClosestEnemy()
    if not target then
        Notify("❌ Nenhum inimigo encontrado!")
        return
    end
    
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
        Notify("❌ Você não tem personagem!")
        return
    end
    
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        Notify("❌ Inimigo sem personagem!")
        return
    end
    
    local myPos = LP.Character.HumanoidRootPart.Position
    local targetRoot = target.Character.HumanoidRootPart
    
    local direction = (myPos - targetRoot.Position).Unit
    local newPos = myPos - direction * 2
    
    targetRoot.CFrame = CFrame.new(newPos)
    
    local targetHumanoid = target.Character:FindFirstChild("Humanoid")
    if targetHumanoid then
        targetHumanoid.Sit = true
        task.wait(0.1)
        targetHumanoid.Sit = false
    end
    
    Notify("✅ Inimigo puxado: " .. target.Name)
end

-- Função para pegar a hit part
local function GetHitPart(character)
    if not character then return nil end
    
    if HitPart == "Head" then
        return character:FindFirstChild("Head")
    elseif HitPart == "HumanoidRootPart" then
        return character:FindFirstChild("HumanoidRootPart")
    elseif HitPart == "Torso" then
        return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end
    
    return character:FindFirstChild("Head")
end

-- Notificação
local function Notify(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.75, 0, 0, 40)
    frame.Position = UDim2.new(0.5, 0, 0.1, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 999
    frame.Parent = ScreenGui
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(80, 130, 255)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.ZIndex = 1000
    
    frame.Position = UDim2.new(0.5, 0, -0.1, 0)
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.1, 0)
    }):Play()
    
    task.delay(2, function()
        if frame.Parent then
            TweenService:Create(frame, TweenInfo.new(0.2), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, -0.1, 0)
            }):Play()
            task.wait(0.2)
            frame:Destroy()
        end
    end)
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
OpenBtn.Parent = ScreenGui

Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 27)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(80, 130, 255)

print("✅ BOTÃO CRIADO")

-- ===== MENU PRINCIPAL =====
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0.92, 0, 0.7, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.ZIndex = 80
Main.Parent = ScreenGui

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

-- Sistema de Abas
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 45)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 81
TabBar.Parent = Main

local TabButtons = {}
local TabContents = {}

local function CreateTab(name, icon, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -3, 1, 0)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(150, 150, 180)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.ZIndex = 82
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, -80)
    content.Position = UDim2.new(0, 0, 0, 80)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(80, 130, 255)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Visible = false
    content.ZIndex = 80
    content.Parent = Main
    
    local list = Instance.new("UIListLayout", content)
    list.Padding = UDim.new(0, 6)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    TabButtons[name] = btn
    TabContents[name] = {Frame = content, List = list}
    
    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
            b.TextColor3 = Color3.fromRGB(150, 150, 180)
            TabContents[n].Frame.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        content.Visible = true
    end)
end

CreateTab("Combate", "🎯", UDim2.new(0, 0, 0, 0))
CreateTab("Visual", "👁", UDim2.new(0.335, 0, 0, 0))
CreateTab("Ajustes", "⚙", UDim2.new(0.67, 0, 0, 0))

TabButtons["Combate"].BackgroundColor3 = Color3.fromRGB(80, 130, 255)
TabButtons["Combate"].TextColor3 = Color3.fromRGB(255, 255, 255)
TabContents["Combate"].Frame.Visible = true

print("✅ ABAS CRIADAS")

-- Componentes UI
local function GetScroll(tabName)
    return TabContents[tabName].Frame
end

local function AddSection(tabName, title)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(0.92, 0, 0, 26)
    sec.BackgroundTransparency = 1
    sec.ZIndex = 81
    sec.Parent = GetScroll(tabName)
    
    local label = Instance.new("TextLabel", sec)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(140, 140, 170)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 82
    
    local line = Instance.new("Frame", sec)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
    line.BorderSizePixel = 0
    line.ZIndex = 81
end

local function AddToggle(tabName, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.92, 0, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    frame.BorderSizePixel = 0
    frame.ZIndex = 81
    frame.Parent = GetScroll(tabName)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 82
    
    local btn = Instance.new("TextButton", frame)
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

local function AddButton(tabName, text, color, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.92, 0, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    frame.BorderSizePixel = 0
    frame.ZIndex = 81
    frame.Parent = GetScroll(tabName)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.5, 0, 0.5, 0)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.ZIndex = 82
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.85, 0, 0, 28)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.9, 0, 0, 30)}):Play()
        callback()
    end)
end

local function AddSlider(tabName, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.92, 0, 0, 58)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    frame.BorderSizePixel = 0
    frame.ZIndex = 81
    frame.Parent = GetScroll(tabName)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 0, 18)
    label.Position = UDim2.new(0.05, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 82
    
    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0.25, 0, 0, 18)
    valLabel.Position = UDim2.new(0.7, 0, 0, 5)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.ZIndex = 82
    
    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(0.9, 0, 0, 4)
    bg.Position = UDim2.new(0.05, 0, 0, 35)
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
        local val = math.floor(min + (max - min) * pos)
        valLabel.Text = tostring(val)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -9, 0.5, -9)
        callback(val)
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
    
    UserInputService.InputEnded:Connect(function(input)
        dragging = false
    end)
end

local function AddDropdown(tabName, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.92, 0, 0, 65)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    frame.BorderSizePixel = 0
    frame.ZIndex = 81
    frame.Parent = GetScroll(tabName)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 82
    
    for i, opt in pairs(options) do
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.3, 0, 0, 28)
        btn.Position = UDim2.new(0.03 + ((i-1) * 0.32), 0, 0, 30)
        btn.BackgroundColor3 = opt == default and Color3.fromRGB(80, 130, 255) or Color3.fromRGB(50, 50, 70)
        btn.Text = opt
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.ZIndex = 82
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            for _, child in pairs(frame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
            callback(opt)
        end)
    end
end

local function AddColorPicker(tabName, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.92, 0, 0, 65)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    frame.BorderSizePixel = 0
    frame.ZIndex = 81
    frame.Parent = GetScroll(tabName)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 82
    
    local colors = {
        Color3.fromRGB(255, 80, 80),
        Color3.fromRGB(80, 130, 255),
        Color3.fromRGB(80, 255, 100),
        Color3.fromRGB(255, 255, 80),
        Color3.fromRGB(180, 80, 255),
        Color3.fromRGB(255, 255, 255),
    }
    
    for i, color in pairs(colors) do
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 22, 0, 22)
        btn.Position = UDim2.new(0.05 + ((i-1) * 0.15), 0, 0, 33)
        btn.BackgroundColor3 = color
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.ZIndex = 82
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 11)
        
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = color == default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 60)
        stroke.Thickness = 2
        
        btn.MouseButton1Click:Connect(function()
            callback(color)
            for _, child in pairs(frame:GetChildren()) do
                if child:IsA("TextButton") and child:FindFirstChild("UIStroke") then
                    child.UIStroke.Color = child.BackgroundColor3 == color and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 60)
                end
            end
        end)
    end
end

local function AddPadding(tabName)
    local pad = Instance.new("Frame")
    pad.Size = UDim2.new(1, 0, 0, 10)
    pad.BackgroundTransparency = 1
    pad.ZIndex = 80
    pad.Parent = GetScroll(tabName)
end

-- ===== CONTEÚDO DAS ABAS =====
print("✅ ADICIONANDO CONTEÚDO...")

-- ============ ABA COMBATE ============
AddSection("Combate", "🎯 AIMBOT")

AddToggle("Combate", "Aimbot (Apenas Inimigos)", false, function(val)
    AimbotEnabled = val
    if val then
        Notify("🎯 Aimbot Ativado")
        if not FOVCircle then
            FOVCircle = Instance.new("Frame")
            FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
            FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
            FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
            FOVCircle.BackgroundTransparency = 1
            FOVCircle.BorderSizePixel = 0
            FOVCircle.ZIndex = 200
            FOVCircle.Parent = ScreenGui
            Instance.new("UIStroke", FOVCircle).Color = FOVColor
            Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
        end
        UpdateFOVVisibility()
    else
        Notify("🎯 Aimbot Desativado")
        UpdateFOVVisibility()
    end
end)

-- NOVA OPÇÃO: Esconder FOV
AddToggle("Combate", "👁 Esconder FOV (Funciona Oculto)", false, function(val)
    FOVVisible = not val -- Inverte porque o toggle diz "Esconder"
    if val then
        Notify("👁 FOV Escondido (Aimbot funcionando)")
    else
        Notify("👁 FOV Visível")
    end
    UpdateFOVVisibility()
end)

AddSection("Combate", "⚡ MOVIMENTO")

AddButton("Combate", "🏃 IR ATÉ O INIMIGO", Color3.fromRGB(60, 140, 60), function()
    TeleportToTarget()
end)

AddButton("Combate", "🧲 PUXAR INIMIGO", Color3.fromRGB(140, 60, 140), function()
    PullTarget()
end)

AddPadding("Combate")

-- ============ ABA VISUAL ============
AddSection("Visual", "👁 ESP")

AddToggle("Visual", "ESP (Ativar/Desativar)", false, function(val)
    ESPEnabled = val
    if val then
        Notify("👁 ESP Ativado")
    else
        Notify("👁 ESP Desativado")
        for _, obj in pairs(ESPObjects) do
            if obj and obj.Frame then obj.Frame:Destroy() end
        end
        ESPObjects = {}
    end
end)

AddSection("Visual", "📦 ELEMENTOS")

AddToggle("Visual", "Caixa (Box ESP)", true, function(val)
    ESPBox = val
    for _, data in pairs(ESPObjects) do
        if data.Box then data.Box.Visible = val end
    end
end)

AddToggle("Visual", "Nome do Jogador", true, function(val)
    ESPName = val
    for _, data in pairs(ESPObjects) do
        if data.NameTag then data.NameTag.Visible = val end
    end
end)

AddToggle("Visual", "Distância", true, function(val)
    ESPDistance = val
    for _, data in pairs(ESPObjects) do
        if data.DistTag then data.DistTag.Visible = val end
    end
end)

AddToggle("Visual", "Linha (Tracer)", true, function(val)
    ESPTracer = val
    for _, data in pairs(ESPObjects) do
        if data.Tracer then data.Tracer.Visible = val end
    end
end)

AddSection("Visual", "🎨 CORES")

AddColorPicker("Visual", "Cor do ESP", ESPColor, function(color)
    ESPColor = color
    for _, data in pairs(ESPObjects) do
        if data.Box and data.Box:FindFirstChild("UIStroke") then data.Box.UIStroke.Color = color end
        if data.NameTag then data.NameTag.TextColor3 = color end
        if data.DistTag then data.DistTag.TextColor3 = color end
        if data.Tracer then data.Tracer.BackgroundColor3 = color end
    end
