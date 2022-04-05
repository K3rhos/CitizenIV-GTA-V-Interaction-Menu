GUI = {
    
    optionText = { r = 255, g = 255, b = 255, a = 255 }
}



Menu = {

    isOpen = false,

	-- Add submenus here.
    subs =
    {
        ["MainMenu"] = 0,
		["Credits"] = 1
    }
}



local safeZone = 0.02

local menuPosition = { x = 0.1125, y = 0.0450 }
local menuWidth = 0.2250

local correctionX = 0.0050
local correctionY = -0.01

local textSize = 0.18

local headerHeight = 0.1000
local subtitleHeight = 0.0350
local optionHeight = 0.0350

local maxVisibleOptions = 7

local selectPressed = false
local leftPressed = false
local rightPressed = false
local upPressed = false
local downPressed = false

local currentOption = 1
local optionsCount = 0

local currentMenuName = "INTERACTION MENU"
local currentMenu = 0
local menuLevel = 0

local menuNamesArray = {}
local optionsArray = {}
local menusArray = {}

local lastTick = 0



local function Switch(_menu, _menuName)

	menuNamesArray[menuLevel] = currentMenuName
	menusArray[menuLevel] = currentMenu
	optionsArray[menuLevel] = currentOption

	menuLevel = menuLevel + 1

	currentMenuName = string.upper(_menuName)
	currentMenu = _menu
	currentOption = 1
end



local function Back()

	menuLevel = menuLevel - 1

	currentMenuName = menuNamesArray[menuLevel]
	currentMenu = menusArray[menuLevel]
	currentOption = optionsArray[menuLevel]
end



function GUI.Rect(_x, _y, _w, _h, _r, _g, _b, _a)

    DrawRect(_x + safeZone, _y + safeZone, _w, _h, _r, _g, _b, _a)
end



function GUI.Sprite(_textureDict, _textureName, _x, _y, _w, _h, _rotation, _r, _g, _b, _a)

	if not HasStreamedTxdLoaded(_textureDict) then

		RequestStreamedTxd(_textureDict, false)

	else
        local texture = GetTextureFromStreamedTxd(_textureDict, _textureName)

		DrawSprite(texture, _x + safeZone, _y + safeZone, _w, _h, _rotation, _r, _g, _b, _a)
	end
end



function GUI.Text(_text, _x, _y, _scale, _fontId, _align, _color, _shadow)

    SetTextFont(_fontId)

    if _align == 1 then

        SetTextCentre(true)

    elseif _align == 2 then

        SetTextRightJustify(true)
        SetTextWrap(0.0, _x + safeZone)
    end

    SetTextScale(_scale, _scale * GetAspectRatio())
	SetTextDropshadow(false, 0, 0, 0, 0)
    if _shadow then SetTextEdge(true, 0, 0, 0, 255) end
    SetTextColour(_color.r, _color.g, _color.b, _color.a)

    if _align == 2 then

        DisplayTextWithLiteralString(_x - _scale + safeZone, _y + safeZone, "STRING", _text)
    else

        DisplayTextWithLiteralString(_x + safeZone, _y + safeZone, "STRING", _text)
    end
end



function Menu.GetSub()

    return currentMenu
end



function Menu.Update()

	-- Disable all game inputs.
	SetPlayerControl(GetPlayerId(), false)

    -- Reset inputs state.
	selectPressed = false
	leftPressed = false
	rightPressed = false
	upPressed = false
	downPressed = false

	-- Handle inputs.
	if (GetGameTimer() - lastTick) > 100 then

		-- Down
		if IsGameKeyboardKeyPressed(208) or IsButtonPressed(0, 9) then

			if currentOption < optionsCount then

				currentOption = currentOption + 1

			else

				currentOption = 1
			end

			downPressed = true

			PlaySoundFrontend(-1, "FRONTEND_MENU_HIGHLIGHT_DOWN_UP")

			lastTick = GetGameTimer()

		-- Up
		elseif IsGameKeyboardKeyPressed(200) or IsButtonPressed(0, 8) then

			if currentOption > 1 then

				currentOption = currentOption - 1
			else

				currentOption = optionsCount
			end

			upPressed = true

            PlaySoundFrontend(-1, "FRONTEND_MENU_HIGHLIGHT_DOWN_UP")

			lastTick = GetGameTimer()

		-- Left
		elseif IsGameKeyboardKeyPressed(203) or IsButtonPressed(0, 10) then

			leftPressed = true

			PlaySoundFrontend(-1, "FRONTEND_MENU_MP_SERVER_OPTION_CHANGE")

			lastTick = GetGameTimer()

		-- Right
		elseif IsGameKeyboardKeyPressed(205) or IsButtonPressed(0, 11) then

			rightPressed = true

			PlaySoundFrontend(-1, "FRONTEND_MENU_MP_SERVER_OPTION_CHANGE")

			lastTick = GetGameTimer()
		end
	end

	-- Select
	if IsGameKeyboardKeyJustPressed(28) or IsButtonJustPressed(0, 16) then

		selectPressed = true

		-- Play select sound.
        PlaySoundFrontend(-1, "FRONTEND_MENU_SELECT")

	-- Back
	elseif IsGameKeyboardKeyJustPressed(14) or IsButtonJustPressed(0, 17) then

		if currentMenu > Menu.subs["MainMenu"] then

            PlaySoundFrontend(-1, "FRONTEND_MENU_BACK")

			Back()
		else

            PlaySoundFrontend(-1, "FRONTEND_MENU_BACK")

			Menu.isOpen = false
		end

        SetPlayerControl(GetPlayerId(), true)
	end

    -- Title text.
	GUI.Text(GetPlayerName(GetPlayerId()), menuPosition.x - (menuWidth / 2) + correctionX, menuPosition.y + correctionY * 1.6, 0.30, 6, 0, GUI.optionText, false)

    -- Title rectangle.
    GUI.Sprite("commonmenu", "interaction_bgd", menuPosition.x, menuPosition.y, menuWidth, headerHeight, 0.0, 255, 255, 255, 255)

    -- SubTitle text.
    GUI.Text(currentMenuName, menuPosition.x - (menuWidth / 2) + correctionX, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + correctionY, textSize, 0, 0, GUI.optionText, false)

    -- Options counter.
    GUI.Text(currentOption.."/"..optionsCount, menuPosition.x + (menuWidth / 2) - correctionX, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + correctionY, textSize, 0, 2, GUI.optionText, false)

    -- Subtitle rectangle.
    GUI.Rect(menuPosition.x, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2), menuWidth, optionHeight, 0, 0, 0, 255)

    -- Menu contents.
    if optionsCount > maxVisibleOptions then

        -- Options background.
        GUI.Sprite("commonmenu", "gradient_bgd", menuPosition.x, menuPosition.y + ((maxVisibleOptions * optionHeight) / 2) + (headerHeight / 2) + subtitleHeight, menuWidth, maxVisibleOptions * optionHeight, 0.0, 255, 255, 255, 255)

        -- Bottom bar rectangle.
        GUI.Rect(menuPosition.x, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((maxVisibleOptions + 1) * optionHeight), menuWidth, optionHeight, 0, 0, 0, 200)

        -- Bottom bar arrows.
        GUI.Sprite("commonmenu", "shop_arrows_upanddown", menuPosition.x, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((maxVisibleOptions + 1) * optionHeight), 0.028, 0.05, 0.0, 255, 255, 255, 255)
    else

        -- Options background.
        GUI.Sprite("commonmenu", "gradient_bgd", menuPosition.x, menuPosition.y + ((optionsCount * optionHeight) / 2) + (headerHeight / 2) + subtitleHeight, menuWidth, optionsCount * optionHeight, 0.0, 255, 255, 255, 255)
    end

    -- Reset options counter.
    optionsCount = 0
end



function Menu.Option(_text, _callback)

    optionsCount = optionsCount + 1

	local thisOption = (currentOption == optionsCount)
	
    local textColor = GUI.optionText

	if thisOption then

		textColor = { r = 0, g = 0, b = 0, a = 255 }
	end

	if (currentOption <= maxVisibleOptions and optionsCount <= maxVisibleOptions) then
		
        GUI.Text(_text, menuPosition.x - (menuWidth / 2) + correctionX, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + (optionsCount * optionHeight) + correctionY, textSize, 0, 0, textColor, false)

		if thisOption then
			
            GUI.Sprite("commonmenu", "gradient_nav", menuPosition.x, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + (optionsCount * optionHeight), menuWidth, optionHeight, 0.0, 255, 255, 255, 255)
		end

	elseif (optionsCount > currentOption - maxVisibleOptions and optionsCount <= currentOption) then
		
        GUI.Text(_text, menuPosition.x - (menuWidth / 2) + correctionX, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((optionsCount - (currentOption - maxVisibleOptions)) * optionHeight) + correctionY, textSize, 0, 0, textColor, false)

		if thisOption then
			
            GUI.Sprite("commonmenu", "gradient_nav", menuPosition.x, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((optionsCount - (currentOption - maxVisibleOptions)) * optionHeight), menuWidth, optionHeight, 0.0, 255, 255, 255, 255)
		end
	end

	if thisOption then

		if selectPressed then

			_callback()
		end
	end
end



function Menu.SubmenuOption(_text, _newMenu, _callback)

    Menu.Option(_text, function() end)

	if (currentOption == optionsCount) and selectPressed then

        Switch(_newMenu, _text)

		_callback()
	end
end



function Menu.BooleanOption(_text, _boolean, _callback)

	Menu.Option(_text, function() end)

	local thisOption = (currentOption == optionsCount)

	if (currentOption <= maxVisibleOptions and optionsCount <= maxVisibleOptions) then

		if thisOption then

			if _boolean then

				GUI.Sprite("commonmenu", "shop_box_tickb", menuPosition.x + (menuWidth / 2) - correctionX - 0.007, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + (optionsCount * optionHeight), 0.028, 0.05, 0.0, 255, 255, 255, 255)
			
            else

				GUI.Sprite("commonmenu", "shop_box_blankb", menuPosition.x + (menuWidth / 2) - correctionX - 0.007, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + (optionsCount * optionHeight), 0.028, 0.05, 0.0, 255, 255, 255, 255)
			end

		else

			if _boolean then
				
                GUI.Sprite("commonmenu", "shop_box_tick", menuPosition.x + (menuWidth / 2) - correctionX - 0.007, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + (optionsCount * optionHeight), 0.028, 0.05, 0.0, 255, 255, 255, 255)

			else

				GUI.Sprite("commonmenu", "shop_box_blank", menuPosition.x + (menuWidth / 2) - correctionX - 0.007, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + (optionsCount * optionHeight), 0.028, 0.05, 0.0, 255, 255, 255, 255)
			end
		end

	elseif (optionsCount > currentOption - maxVisibleOptions and optionsCount <= currentOption) then

		if thisOption then

			if _boolean then

				GUI.Sprite("commonmenu", "shop_box_tickb", menuPosition.x + (menuWidth / 2) - correctionX - 0.007, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((optionsCount - (currentOption - maxVisibleOptions)) * optionHeight), 0.028, 0.05, 0.0, 255, 255, 255, 255)
			
            else
				
                GUI.Sprite("commonmenu", "shop_box_blankb", menuPosition.x + (menuWidth / 2) - correctionX - 0.007, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((optionsCount - (currentOption - maxVisibleOptions)) * optionHeight), 0.028, 0.05, 0.0, 255, 255, 255, 255)
			end
		else
			
            if _boolean then
				
                GUI.Sprite("commonmenu", "shop_box_tick", menuPosition.x + (menuWidth / 2) - correctionX - 0.007, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((optionsCount - (currentOption - maxVisibleOptions)) * optionHeight), 0.028, 0.05, 0.0, 255, 255, 255, 255)
			
            else
				
                GUI.Sprite("commonmenu", "shop_box_blank", menuPosition.x + (menuWidth / 2) - correctionX - 0.007, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((optionsCount - (currentOption - maxVisibleOptions)) * optionHeight), 0.028, 0.05, 0.0, 255, 255, 255, 255)
			end
		end
	end

	if thisOption and selectPressed then

        _callback(not _boolean)
	end
end



function Menu.IntegerOption(_text, _integer, _min, _max, _callback)

	Menu.Option(_text, function() end)

	local thisOption = (currentOption == optionsCount)

	local textColor = GUI.optionText

	if thisOption then

		textColor = { r = 0, g = 0, b = 0, a = 255 }
	end

	if (currentOption <= maxVisibleOptions and optionsCount <= maxVisibleOptions) then

		GUI.Text(_integer.."", menuPosition.x + (menuWidth / 2) - correctionX, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + (optionsCount * optionHeight) + correctionY, textSize, 0, 2, textColor, false)

	elseif (optionsCount > currentOption - maxVisibleOptions and optionsCount <= currentOption) then

		GUI.Text(_integer.."", menuPosition.x + (menuWidth / 2) - correctionX, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((optionsCount - (currentOption - maxVisibleOptions)) * optionHeight) + correctionY, textSize, 0, 2, textColor, false)
	end

	if thisOption then

		if leftPressed then

			if _integer > _min then

				_integer = _integer - 1

				if _integer < _min then

					_integer = _min
				end
			end

        	_callback(_integer)

		elseif rightPressed then

			if _integer < _max then
				
				_integer = _integer + 1

				if _integer > _max then

					_integer = _max
				end
			end

			_callback(_integer)

		elseif selectPressed then

			_callback(_integer)
		end
	end
end



function Menu.FloatOption(_text, _float, _min, _max, _step, _callback)

	Menu.Option(_text, function() end)

	local thisOption = (currentOption == optionsCount)

	local textColor = GUI.optionText

	if thisOption then

		textColor = { r = 0, g = 0, b = 0, a = 255 }
	end

	if (currentOption <= maxVisibleOptions and optionsCount <= maxVisibleOptions) then

		GUI.Text(Utils.Round(_float, 1), menuPosition.x + (menuWidth / 2) - correctionX, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + (optionsCount * optionHeight) + correctionY, textSize, 0, 2, textColor, false)

	elseif (optionsCount > currentOption - maxVisibleOptions and optionsCount <= currentOption) then

		GUI.Text(Utils.Round(_float, 1), menuPosition.x + (menuWidth / 2) - correctionX, menuPosition.y + (headerHeight / 2) + (subtitleHeight / 2) + ((optionsCount - (currentOption - maxVisibleOptions)) * optionHeight) + correctionY, textSize, 0, 2, textColor, false)
	end

	if thisOption then

		if leftPressed then

			if _float > _min then

				_float =  _float - _step

				if _float < _min then

					_float = _min
				end
			end

        	_callback(_float)

		elseif rightPressed then

			if _float < _max then
				
				_float = _float + _step

				if _float > _max then

					_float = _max
				end
			end

			_callback(_float)

		elseif selectPressed then

			_callback(_float)
		end
	end
end
