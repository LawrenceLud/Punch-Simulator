--[[
    Hub Loader for Roblox Exploit
    
    This script is responsible for:
    1. Getting a unique device HWID
    2. Validating the key with the server
    3. Loading Temple Hub after verification
    4. Allowing key acquisition via WorkInk
]]

-- Configuration
local CONFIG = {
    API_URL = "https://48dfc51f-b7e3-4af8-b659-4a0f0a47230e-00-1wojx538iylzl.spock.replit.dev", -- Replace with the actual URL where the code is hosted
    HUB_NAME = "Templo Hub",
    VERSION = "3.0.0",
    TEMPLO_HUB_URL = "https://raw.githubusercontent.com/LawrenceLud/ProjectBaki3/refs/heads/main/TemploHub.lua"
}

-- Utilities
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlaceId = game.PlaceId

-- Function to get the unique hardware ID
local function GetHWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    
    -- Combine with additional identifiers for greater security
    if identifyexecutor then
        hwid = hwid .. "_" .. identifyexecutor()
    end
    
    -- Add a basic hash to make tampering more difficult
    local function SimpleHash(str)
        local hash = 0
        for i = 1, #str do
            hash = bit32.bxor(bit32.lshift(hash, 5) - hash, string.byte(str, i))
        end
        return tostring(hash)
    end
    
    return SimpleHash(hwid)
end

-- Function for server communication
local function SendRequest(endpoint, data)
    local success, response = pcall(function()
        return request({
            Url = CONFIG.API_URL .. endpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Accept"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success and response and response.StatusCode == 200 then
        local jsonSuccess, jsonData = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        
        if jsonSuccess then
            return true, jsonData
        end
    end
    
    return false, {
        success = false,
        message = "Failed to connect to server",
        data = nil
    }
end

-- Function to validate the key with the server
local function ValidateKey(key)
    local data = {
        key = key,
        hwid = GetHWID(),
        username = LocalPlayer.Name,
        place_id = PlaceId
    }
    
    return SendRequest("/api/roblox/authorize", data)
end

-- Function to load Temple Hub
local function LoadTemploHub()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(CONFIG.TEMPLO_HUB_URL))()
    end)
    
    if not success then
        warn("Failed to load Temple Hub: " .. tostring(result))
        return false
    end
    
    return true
end

-- User interface for key input
local function CreateKeyUI()
    -- Create ScreenGui with protection
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TempleHubKeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Protection against detection
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
    
    -- Try different methods to add the GUI
    local success = pcall(function()
        if game:GetService("CoreGui") then
            ScreenGui.Parent = game:GetService("CoreGui")
        end
    end)
    
    if not success or not ScreenGui.Parent then
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 220)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Round the borders
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Title.BorderSizePixel = 0
    Title.Font = Enum.Font.GothamBold
    Title.Text = CONFIG.HUB_NAME .. " v" .. CONFIG.VERSION
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Parent = MainFrame
    
    -- Round the borders of the title
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Text box for the key
    local KeyInput = Instance.new("TextBox")
    KeyInput.Name = "KeyInput"
    KeyInput.Size = UDim2.new(0.85, 0, 0, 35)
    KeyInput.Position = UDim2.new(0.5, 0, 0.4, 0)
    KeyInput.AnchorPoint = Vector2.new(0.5, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    KeyInput.BorderSizePixel = 0
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter your key..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = MainFrame
    
    -- Round the borders of the text box
    local KeyInputCorner = Instance.new("UICorner")
    KeyInputCorner.CornerRadius = UDim.new(0, 6)
    KeyInputCorner.Parent = KeyInput
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(0.85, 0, 0, 20)
    Status.Position = UDim2.new(0.5, 0, 0.58, 0)
    Status.AnchorPoint = Vector2.new(0.5, 0)
    Status.BackgroundTransparency = 1
    Status.Font = Enum.Font.Gotham
    Status.Text = "Enter your key to activate the hub"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 12
    Status.Parent = MainFrame
    
    -- Activation button
    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Name = "ActivateButton"
    ActivateButton.Size = UDim2.new(0.4, 0, 0, 35)
    ActivateButton.Position = UDim2.new(0.08, 0, 0.7, 0)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(60, 120, 216)
    ActivateButton.BorderSizePixel = 0
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.Text = "Activate"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.TextSize = 14
    ActivateButton.AutoButtonColor = true
    ActivateButton.Parent = MainFrame
    
    -- Round the borders of the activation button
    local ActivateButtonCorner = Instance.new("UICorner")
    ActivateButtonCorner.CornerRadius = UDim.new(0, 6)
    ActivateButtonCorner.Parent = ActivateButton
    
    -- Get key button
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Size = UDim2.new(0.4, 0, 0, 35)
    GetKeyButton.Position = UDim2.new(0.52, 0, 0.7, 0)
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Font = Enum.Font.GothamBold
    GetKeyButton.Text = "Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14
    GetKeyButton.AutoButtonColor = true
    GetKeyButton.Parent = MainFrame
    
    -- Round the borders of the get key button
    local GetKeyButtonCorner = Instance.new("UICorner")
    GetKeyButtonCorner.CornerRadius = UDim.new(0, 6)
    GetKeyButtonCorner.Parent = GetKeyButton
    
    -- Function to update the status
    local function UpdateStatus(text, color)
        Status.Text = text
        Status.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    end
    
    -- Function to get a key through WorkInk
    local function GetKeyFromWorkInk()
        UpdateStatus("Generating link...", Color3.fromRGB(255, 255, 100))
        GetKeyButton.Text = "Generating..."
        GetKeyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        GetKeyButton.AutoButtonColor = false
        
        -- Send request to get the WorkInk link
        local data = {
            hwid = GetHWID()
        }
        
        local success, response = SendRequest("/api/getkey/generate", data)
        
        if success and response.success then
            -- Open the link in browser
            UpdateStatus("Opening browser...", Color3.fromRGB(100, 255, 100))
            
            pcall(function()
                -- Try to copy URL to clipboard
                if setclipboard then
                    setclipboard(response.data.url)
                end
                
                -- Try different methods to open the URL in browser
                if syn and syn.request then
                    syn.request({
                        Url = response.data.url,
                        Method = "GET"
                    })
                elseif http and http.request then
                    http.request({
                        Url = response.data.url
                    })
                elseif request then
                    request({
                        Url = response.data.url,
                        Method = "GET"
                    })
                elseif KRNL_LOADED and krnl then
                    krnl.request({
                        Url = response.data.url,
                        Method = "GET"
                    })
                elseif getgenv().UWP_BROWSER then -- Fluxus UWP
                    getgenv().UWP_BROWSER(response.data.url)
                else
                    -- Generic attempt for other exploits
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Link Copied",
                            Text = "Paste in browser: " .. response.data.url:sub(1, 25) .. "...",
                            Duration = 10
                        })
                    end)
                end
            end)
            
            UpdateStatus("Link copied! Complete the tasks to get your key.", Color3.fromRGB(100, 255, 100))
            wait(3)
            UpdateStatus("Paste the key after completing the tasks.", Color3.fromRGB(200, 200, 200))
        else
            local errorMsg = "Error generating link. Try again."
            if response and response.message then
                errorMsg = response.message
            end
            
            UpdateStatus(errorMsg, Color3.fromRGB(255, 100, 100))
        end
        
        wait(1)
        GetKeyButton.Text = "Get Key"
        GetKeyButton.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
        GetKeyButton.AutoButtonColor = true
    end
    
    -- Connect event to get key button
    GetKeyButton.MouseButton1Click:Connect(function()
        GetKeyFromWorkInk()
    end)
    
    -- Activation button logic
    ActivateButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        
        if key == "" then
            UpdateStatus("Please enter a valid key.", Color3.fromRGB(255, 100, 100))
            return
        end
        
        UpdateStatus("Verifying key...", Color3.fromRGB(255, 255, 100))
        ActivateButton.Text = "Verifying..."
        ActivateButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        ActivateButton.AutoButtonColor = false
        
        -- Validate the key
        local success, response = ValidateKey(key)
        
        if success and response.success then
            UpdateStatus("Valid key! Loading Temple Hub...", Color3.fromRGB(100, 255, 100))
            
            -- Small delay before trying to load the hub
            wait(1)
            
            -- Destroy the UI before loading the hub
            ScreenGui:Destroy()
            
            -- Display success notification
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = CONFIG.HUB_NAME,
                    Text = "Loading Temple Hub...",
                    Duration = 5
                })
            end)
            
            -- Load Temple Hub
            local loadSuccess = LoadTemploHub()
            
            if not loadSuccess then
                -- Try again, sometimes the first attempt fails
                wait(1)
                LoadTemploHub()
            end
        else
            local errorMsg = "Error verifying key."
            if response and response.message then
                errorMsg = response.message
            end
            
            UpdateStatus(errorMsg, Color3.fromRGB(255, 100, 100))
            wait(2)
            ActivateButton.Text = "Activate"
            ActivateButton.BackgroundColor3 = Color3.fromRGB(60, 120, 216)
            ActivateButton.AutoButtonColor = true
        end
    end)
    
    -- Make the UI draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        if not dragging then return end
        
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Add close (X) effect
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseButton.TextSize = 16
    CloseButton.Parent = MainFrame
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    return ScreenGui
end

-- Main function to start the system
local function Start()
    print(CONFIG.HUB_NAME .. " v" .. CONFIG.VERSION .. " - Initializing...")
    
    -- Check if we're in Roblox
    if not game or not game:GetService("Players") then
        warn("This script can only be executed in Roblox")
        return
    end
    
    -- Wait for player to load if needed
    if not Players.LocalPlayer then
        LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    else
        LocalPlayer = Players.LocalPlayer
    end
    
    -- Check if the executor supports HTTP requests
    if not request and not http and not syn then
        warn("Your executor does not support HTTP requests")
        return
    end
    
    -- Show the key input interface
    CreateKeyUI()
end

-- Start the script
Start()
