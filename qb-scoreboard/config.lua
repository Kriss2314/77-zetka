Config = Config or {}

-- Open scoreboard key
Config.OpenKey = 'Z' -- https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/

-- Max Server Players
Config.MaxPlayers = GetConvarInt('sv_maxclients', 140) -- It returns 48 if it cant find the Convar Int

-- Minimum Police for Actions
Config.IllegalActions = {
    ["kasetka"] = {
        minimum = 1,
        busy = false,
    },
    ["trucker"] = {
        minimum = 2,
        busy = false,
    },
    ["groupe6"] = {
        minimum = 4,
        busy = false,
    },
    ["sklep"] = {
        minimum = 4,
        busy = false,
    },
    ["jubiler"] = {
        minimum = 6,
        busy = false,
    },
    ["bank"] = {
        minimum = 7,
        busy = false,
    },
    ["pacyfic"] = {
        minimum = 12,
        busy = false,
    },
}


-- Current Cops Online
Config.CurrentCops = 0

-- Current Ambulance / Doctors Online
Config.CurrentAmbulance = 0

-- Show ID's for all players or Opted in Staff
Config.ShowIDforALL = true