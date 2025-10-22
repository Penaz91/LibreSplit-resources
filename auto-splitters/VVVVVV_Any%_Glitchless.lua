-- For VVVVVV 2.4.3 Linux
-- Only for ANY% glitchless runs
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
end

function start()
    if not current.fadetomode and old.fadetomode then
        if current.menustate == 0 then
            if current.gotomode == 0 and current.ingame_titlemode == 0 then
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
                -- Split on Warp zone
                return true
            end
        elseif gamestate_between(current, 3020, 3025) then
            if not gamestate_between(old, 3020, 3025) then
                -- Split on Vitellary (Space 2)
                return true
            end
        elseif gamestate_between(current, 3040, 3045) then
            if not gamestate_between(old, 3040, 3045) then
                -- Split on Victoria
                return true
            end
        elseif gamestate_between(current, 3060, 3065) then
            if not gamestate_between(old, 3060, 3065) then
                -- Split on Vermilion
                return true
            end
        elseif gamestate_between(current, 3080, 3082) then
            if not gamestate_between(old, 3080, 3082) then
                -- Split on Gravitron
                return true
            end
        elseif gamestate_between(current, 3085, 3087) then
            if not gamestate_between(old, 3085, 3087) then
                -- Split on Intermission 1
                return true
            end
        end

        -- Other splits
        if gamestate_between(current, 4091, 4099) then
            if not gamestate_between(old, 4091, 4099) then
                -- Split on Violet teleporter
                return true
            end
        elseif gamestate_between(current, 3503, 3509) then
            if not gamestate_between(old, 3503, 3509) then
                -- Split on All members rescued
                return true
            end
        end
    end
    return false
end
