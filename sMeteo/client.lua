local CurrentWeather = 'EXTRASUNNY'
local lastWeather = CurrentWeather
local baseTime = 0
local timeOffset = 0
local timer = 0
local freezeTime = false
local blackout = false

local WeatherCommand = {
    {command = "extrasunny", weather = "EXTRASUNNY"},
    {command = "rain", weather = "RAIN"},
    {command = "neutral", weather = "NEUTRAL"},
    {command = "smog", weather = "SMOG"},
    {command = "foggy", weather = "FOGGY"},
    {command = "overcast", weather = "OVERCAST"},
    {command = "clouds", weather = "CLOUDS"},
    {command = "clearing", weather = "CLEARING"},
    {command = "snow", weather = "SNOW"},
    {command = "blizzard", weather = "BLIZZARD"},
    {command = "snowlight", weather = "SNOWLIGHT"},
    {command = "xmas", weather = "XMAS"},
    {command = "halloween", weather = "HALLOWEEN"},
    {command = "thunder", weather = "THUNDER"},
}

for _,v in pairs(WeatherCommand) do
    RegisterCommand(v.command, function()
        CurrentWeather = v.command
    end)
end

function ShiftToHour(hour)
    timeOffset = timeOffset - ( ( ((baseTime+timeOffset)/60) % 24 ) - hour ) * 60
    return timeOffset
end

timeOffset = ShiftToHour(08)

local function OnSelected(self, mMenu,Select, _, button, slt)
    local MenuSelect = mMenu.currentMenu
    local btn = button.name
    local m = MenuSelect
    if m == "heure" then
        timeOffset = ShiftToHour(Select.time)
    elseif m == "temps"then
        CurrentWeather = Select.weather
    end
end

local weatherTime = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, HeaderColor = {255, 255, 255}, Title = "Menu Meteo"},
    Data = { currentMenu = "Menu Meteo"},
    Events = { onSelected = OnSelected },
    Menu = {
        ["Menu Meteo"] = {
            b = {
                {name = "Heure",ask = ">",askX = true},
                {name = "Temps",ask = ">",askX = true},
            }
        },
        ["temps"] = {
            b = {
                { name = "extrasunny", weather = "EXTRASUNNY" },
                { name = "rain", weather = "RAIN" },
                { name = "neutral", weather = "NEUTRAL" },
                { name = "smog", weather = "SMOG" },
                { name = "foggy", weather = "FOGGY" },
                { name = "overcast", weather = "OVERCAST" },
                { name = "clouds", weather = "CLOUDS" },
                { name = "clearing", weather = "CLEARING" },
                { name = "snow", weather = "SNOW" },
                { name = "blizzard", weather = "BLIZZARD" },
                { name = "snowlight", weather = "SNOWLIGHT" },
                { name = "xmas", weather = "XMAS" },
                { name = "halloween", weather = "HALLOWEEN" },
                { name = "thunder", weather = "THUNDER" },
            }
        },
        ["heure"] = {
            b = {
                { name = "00H", time = 00 },
                { name = "04H", time = 04 },
                { name = "06H", time = 06 },
                { name = "08H", time = 08 },
                { name = "10H", time = 10 },
                { name = "12H", time = 12 },
                { name = "14H", time = 14 },
                { name = "16H", time = 16 },
                { name = "18H", time = 18,},
                { name = "21H", time = 21 },
                { name = "22H", time = 22 },
            }
        },
    }
}


function RegisterControlKey(strKeyName, strDescription, strKey, cbPress, cbRelease)
    RegisterKeyMapping("+" .. strKeyName, strDescription, "keyboard", strKey)

    RegisterCommand("+" .. strKeyName, function()
        if not cbPress or UpdateOnscreenKeyboard() == 0 then
            return
        end
        cbPress()
    end, false)

    RegisterCommand("-" .. strKeyName, function()
        if not cbRelease or UpdateOnscreenKeyboard() == 0 then
            return
        end
        cbRelease()
    end, false)
end
RegisterControlKey("weather","Ouvrir le menu météo","F1",function()
    CreateMenu(weatherTime)
end)


Citizen.CreateThread(function()
    while true do
        if lastWeather ~= CurrentWeather then
            lastWeather = CurrentWeather
            SetWeatherTypeOverTime(CurrentWeather, 15.0)
            Citizen.Wait(15000)
        end
        Citizen.Wait(100)
        SetBlackout(blackout)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(lastWeather)
        SetWeatherTypeNow(lastWeather)
        SetWeatherTypeNowPersist(lastWeather)
        if lastWeather == 'XMAS' then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
    end
end)

Citizen.CreateThread(function()
    local hour = 0
    local minute = 0
    while true do
        Citizen.Wait(0)
        local newBaseTime = baseTime
        if GetGameTimer() - 500  > timer then
            newBaseTime = newBaseTime + 0.25
            timer = GetGameTimer()
        end
        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime
        end
        baseTime = newBaseTime
        hour = math.floor(((baseTime+timeOffset)/60)%24)
        minute = math.floor((baseTime+timeOffset)%60)
        NetworkOverrideClockTime(hour, minute, 0)
    end
end)

