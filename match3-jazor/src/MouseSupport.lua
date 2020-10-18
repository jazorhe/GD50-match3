function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        button = 'primary'
    elseif button == 2 then
        button = 'secondary'
    elseif button == 3 then
        button = 'middle'
    else
        button = 'unknown'
    end

    x, y = push:toGame(x, y)

    love.mouse.buttonsPressed[button] = {
        ['x'] = x,
        ['y'] = y,
        ['pressed'] = true,
        ['istouch'] = istouch
    }
end

function love.mouse.wasPressed(button)
    if button == 1 then
        button = 'primary'
    elseif button == 2 then
        button = 'secondary'
    elseif button == 3 then
        button = 'middle'
    else
        button = 'unknown'
    end

    if love.mouse.buttonsPressed[button] and love.mouse.buttonsPressed[button]['pressed'] == true then
        return true
    else
        return false
    end
end


local function inCircle(cx, cy, radius, x, y)

    if not x or not y then
        return false
    end

    local dx = cx - x
    local dy = cy - y
    return dx * dx + dy * dy <= radius * radius

end

function love.mouse.areaWasPressed(cx, cy, radius, button)
    if love.mouse.wasPressed(button) then
        if button == 1 then
            button = 'primary'
        elseif button == 2 then
            button = 'secondary'
        elseif button == 3 then
            button = 'middle'
        else
            button = 'unknown'
        end

        x = love.mouse.buttonsPressed[button]['x']
        y = love.mouse.buttonsPressed[button]['y']

        if inCircle(cx, cy, radius, x, y) then
            return true
        end
    end
    return false
end
