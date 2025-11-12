-- For VVVVVV 2.4.3
process("VVVVVV")

local current = {
    gotomode = nil,
    fadetomode = false,
    gamestate = nil,
    menustate = nil,
    hours = 0,
    minutes = 0,
    seconds = 0,
    frames = 0,
    ingame_titlemode = false,
    trinkets = {},
}

local old = {
    gotomode = nil,
    fadetomode = false,
    gamestate = nil,
    menustate = nil,
    hours = 0,
    minutes = 0,
    seconds = 0,
    frames = 0,
    ingame_titlemode = false,
    trinkets = {},
}

function startup()
    refreshRate = 60
    useGameTime = true
end

function gameTime()
    return current.hours * 3600000 + current.minutes * 60000 + current.seconds * 1000 + 100 * ((current.frames - 1) / 3)
end

function shallow_copy_tbl(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function print_tbl(t)
    for k,v in pairs(t) do
        print(k, " -> ", v)
    end
end

function state()
    old = shallow_copy_tbl(current)
    current.fadetomode = readAddress("bool", 0x2FD97C)
    current.gotomode = readAddress("int", 0x2CBA38)
    current.gamestate = readAddress("int", 0x2F86E4)
    current.menustate = readAddress("long", 0x2f86f0)
    current.hours = readAddress("int", 0x2f8740)
    current.minutes = readAddress("int", 0x2f873C)
    current.seconds = readAddress("int", 0x2f8738)
    current.frames = readAddress("int", 0x2f8734)
    -- Currently not in use
    current.ingame_titlemode = readAddress("int", 0x2FD8F8)
    current.trinkets = readAddress("byte20", 0x2e41dc)
end

function start()
    if not current.fadetomode and old.fadetomode then
        if current.menustate == 0 then
            if current.gotomode == 0 then
            --if current.gotomode == 0 and current.ingame_titlemode == 0 then
                print("Start condition triggered")
                return true
            end
            -- Check we're in game, to avoid false run starts
            -- Having the run start a bit later but at 3 seconds is acceptable for me
        end
    end
    return false
end

function gamestate_between(gs_tab, lower, upper)
    return gs_tab.gamestate >= lower and gs_tab.gamestate <= upper
end

function gamestate_in(gs, states_tab)
    result = true
    for i=1, #states_tab do
        result = result or states_tab[i]
    end
    return result
end

function split()
    if current.gamestate ~= old.gamestate then
        if gamestate_between(current, 3050, 3056) then
            if not gamestate_between(old, 3050, 3056) then
                -- Split on Violet (Space 1)
                -- Activated elsewhere
            end
        end
        if gamestate_between(current, 3006, 3011) then
            if not gamestate_between(old, 3006, 3011) then
                print("Split on Warp Zone")
                -- Split on Warp zone
                return true
            end
        elseif gamestate_between(current, 3020, 3025) then
            if not gamestate_between(old, 3020, 3025) then
                print("Split on Space 2")
                -- Split on Vitellary (Space 2)
                return true
            end
        elseif gamestate_between(current, 3040, 3045) then
            if not gamestate_between(old, 3040, 3045) then
                print("Split Victoria")
                -- Split on Victoria
                return true
            end
        elseif gamestate_between(current, 3060, 3065) then
            if not gamestate_between(old, 3060, 3065) then
                print("Split Vermilion")
                -- Split on Vermilion
                return true
            end
        elseif gamestate_between(current, 3080, 3082) then
            if not gamestate_between(old, 3080, 3082) then
                print("Split on Gravitron")
                -- Split on Gravitron
                return true
            end
        elseif gamestate_between(current, 3085, 3087) then
            if not gamestate_between(old, 3085, 3087) then
                print("Split on Intermission 1")
                -- Split on Intermission 1
                return true
            end
        end

        -- Other splits
        if gamestate_between(current, 4091, 4099) then
            if not gamestate_between(old, 4091, 4099) then
                -- Split on Violet teleporter
                print("Split on Violet Teleporter")
                return true
            end
        elseif gamestate_between(current, 3503, 3509) then
            if not gamestate_between(old, 3503, 3509) then
                -- Split on All members rescued
                print("Split on All Members rescued")
                return true
            end
        end

        -- Trinket splits
        if (current.trinkets[1] == 1 and old.trinkets[1] == 0) then
            -- Trinket - It's a secret to Nobody
            return true
        elseif (current.trinkets[2] == 1 and old.trinkets[2] == 0) then
            -- Trinket - Trench Warfare
            return true
        elseif (current.trinkets[10] == 1 and old.trinkets[10] == 0) then
            -- Trinket - Young Man, It's Worth the Challenge
            return true
        elseif (current.trinkets[15] == 1 and old.trinkets[15] == 0) then
            -- Trinket - Lab Maze
            return true
        elseif (current.trinkets[11] == 1 and old.trinkets[11] == 0) then
            -- Trinket - The Tantalizing Trinket
            return true
        elseif (current.trinkets[12] == 1 and old.trinkets[12] == 0) then
            -- Trinket - Purest Unobtanium
            return true
        elseif (current.trinkets[19] == 1 and old.trinkets[19] == 0) then
            -- Trinket - Victoria
            return true
        elseif (current.trinkets[8] == 1 and old.trinkets[8] == 0) then
            -- Trinket - Tower 1
            return true
        elseif (current.trinkets[9] == 1 and old.trinkets[9] == 0) then
            -- Trinket - Lab Maze
            return true
        elseif (current.trinkets[18] == 1 and old.trinkets[18] == 0) then
            -- Trinket - Elephant
            return true
        elseif (current.trinkets[3] == 1 and old.trinkets[3] == 0) then
            -- Trinket - One way Room
            return true
        elseif (current.trinkets[4] == 1 and old.trinkets[4] == 0) then
            -- Trinket - You just keep coming back
            return true
        elseif (current.trinkets[5] == 1 and old.trinkets[5] == 0) then
            -- Trinket - Clarion call
            return true
        elseif (current.trinkets[6] == 1 and old.trinkets[6] == 0) then
            -- Trinket - Doing things the hard way
            return true
        elseif (current.trinkets[7] == 1 and old.trinkets[7] == 0) then
            -- Trinket - Prize for the reckless
            return true
        elseif (current.trinkets[16] == 1 and old.trinkets[16] == 0) then
            -- Trinket - Cave 1
            return true
        elseif (current.trinkets[17] == 1 and old.trinkets[17] == 0) then
            -- Trinket - Cave 2
            return true
        elseif (current.trinkets[14] == 1 and old.trinkets[14] == 0) then
            -- Trinket - Cave 3
            return true
        elseif (current.trinkets[13] == 1 and old.trinkets[13] == 0) then
            -- Trinket - Edge Games
            return true
        elseif (current.trinkets[20] == 1 and old.trinkets[20] == 0) then
            -- Trinket - V
            return true
        end

    end
    return false
end
