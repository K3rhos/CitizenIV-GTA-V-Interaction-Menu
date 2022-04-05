local boolean = false
local integer = 1
local float = 1.0



Citizen.CreateThread(function()

    while true do

        -- Open / close the menu.
        if IsGameKeyboardKeyJustPressed(50) or IsButtonJustPressed(0, 13) then -- M / Back

            Menu.isOpen = not Menu.isOpen

            if Menu.isOpen then

                PlaySoundFrontend(-1, "FRONTEND_MENU_TOGGLE_ON")

            else

                SetPlayerControl(GetPlayerId(), true)

                PlaySoundFrontend(-1, "FRONTEND_MENU_TOGGLE_OFF")
            end
        end

        if Menu.isOpen then

            Menu.Update()

            if Menu.GetSub() == Menu.subs["MainMenu"] then

                Menu.BooleanOption("Test Boolean", boolean, function(_cb) boolean = _cb end)

                Menu.IntegerOption("Test Integer", integer, 0, 10, function(_cb) integer = _cb end)

                Menu.FloatOption("Test Float", float, 0.1, 5.0, 0.1, function(_cb) float = _cb end)

                Menu.Option("Test Option", function()

                    Citizen.Trace("Hello world!\n")
                end)

                Menu.SubmenuOption("Credits", Menu.subs["Credits"], function() end)

            elseif Menu.GetSub() == Menu.subs["Credits"] then

                Menu.Option("K3rhos", function() end)
                Menu.Option("CitizenIV Docs", function() end)
                Menu.Option("GTAMods Wiki", function() end)
            end
        end

        Citizen.Wait(1)
    end
end)
