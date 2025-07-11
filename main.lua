-- Lindo Hub v2.0 - Auto Fruit Hopper (Loop Infinito + Delay Humano)
-- Compatível com Delta Executor e emuladores móveis

-- Auto-escolhe time (Piratas)
pcall(function()
    local rs = game:GetService("ReplicatedStorage")
    local chooseTeam = rs:WaitForChild("Remotes"):FindFirstChild("ChooseTeam")
    if chooseTeam then
        chooseTeam:FireServer("Pirates") -- troca pra "Marines" se quiser
    end
end)

-- Aguarda personagem
repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

-- Serviços
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeId = game.PlaceId
local currentJobId = game.JobId

-- GUI simples só para saber que está rodando
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LindoHub"

local info = Instance.new("TextLabel", gui)
info.Text = "🍉 Lindo Hub v2.0 rodando..."
info.Size = UDim2.new(0, 220, 0, 25)
info.Position = UDim2.new(0, 10, 0, 10)
info.BackgroundColor3 = Color3.fromRGB(20,20,20)
info.TextColor3 = Color3.fromRGB(255,255,255)
info.Font = Enum.Font.SourceSansBold
info.TextSize = 16
info.BorderSizePixel = 0

-- Verifica se tem fruta spawnada
function CheckFruit()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v.Name:lower():find("fruit") then
            return v:FindFirstChild("Handle") or v
        end
    end
    return nil
end

-- Vai até a fruta
function GoToFruit(fruit)
    local char = player.Character or player.CharacterAdded:Wait()
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.CFrame = CFrame.new(fruit.Position + Vector3.new(0, 3, 0))
        info.Text = "✅ Fruta encontrada: " .. fruit.Parent.Name
        wait(10)
    end
end

-- Busca servidores públicos e válidos
function GetServers()
    local servers = {}
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= currentJobId then
                table.insert(servers, server.id)
            end
        end
    end
    return servers
end

-- Troca de servidor
function ServerHop()
    local servers = GetServers()
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        info.Text = "🔁 Pulando servidor..."
        wait(1)
        TeleportService:TeleportToPlaceInstance(placeId, randomServer, player)
    else
        info.Text = "⚠️ Nenhum servidor válido encontrado."
    end
end

-- Loop infinito: detecta fruta e troca se não tiver
while true do
    local fruit = CheckFruit()
    if fruit then
        GoToFruit(fruit)
        -- Depois de pegar, você pode encerrar ou continuar loop se quiser mais
        info.Text = "🍇 Esperando nova fruta..."
        wait(60) -- espera 1 min depois de pegar uma fruta
    else
        info.Text = "❌ Nenhuma fruta. Trocando de servidor..."
        wait(15) -- delay entre trocas (tempo realista)
        ServerHop()
    end
end
