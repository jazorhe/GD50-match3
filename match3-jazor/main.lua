require 'src/Dependencies'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

DEBUG = false

function love.load()
    -- initialize our nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- window bar title
    love.window.setTitle('Match 3')

    -- seed the RNG
    math.randomseed(os.time())

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- set music to loop and start
    gSounds['music']:setLooping(true)
    gSounds['music']:play()
    gVolume = love.audio.getVolume()
    gMute = false

    triggerMute()

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['begin-game'] = function() return BeginGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    -- keep track of scrolling our background on the X axis
    backgroundX = 0
    backgroundScrollSpeed = 80

    -- initialize input table
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed  = {}

    mouseX = 0
    mouseY = 0
    mouseMoved = false
    mouseGrabbed = false
    mouseDragDirection = nil
end


function love.resize(w, h)
    push:resize(w, h)
end


function love.update(dt)
    -- scroll background, used across all states
    backgroundX = backgroundX - backgroundScrollSpeed * dt

    -- if we've scrolled the entire image, reset it to 0
    if backgroundX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
        backgroundX = 0
    end

    lastMouseX = mouseX
    lastMouseY = mouseY

    mouseX, mouseY = push:toGame(love.mouse.getPosition())

    -- if not mouseGrabbed then
    --     if love.mouse.isDown(1) then
    --         startMouseX, startMouseY = mouseX, mouseY
    --         mouseGrabbed = true
    --         mouseDragDirection = nil
    --     end
    -- else
    --     if not love.mouse.isDown(1) then
    --         finMouseX, finMouseY = mouseX, mouseY
    --         mouseGrabbed = false
    --
    --         disX = finMouseX - startMouseX
    --         disY = finMouseY - startMouseY
    --
    --         if disX > 10 and math.abs(disY/disX) < 1 then
    --             mouseDragDirection = 'right'
    --         elseif disX < -10 and math.abs(disY/disX) < 1 then
    --             mouseDragDirection = 'left'
    --         elseif disY > 10 and math.abs(disY/disX) > 1 then
    --             mouseDragDirection = 'down'
    --         elseif disY < -10 and math.abs(disY/disX) > 1 then
    --             mouseDragDirection = 'up'
    --         else
    --             mouseDragDirection = nil
    --         end
    --     end
    -- end

    if not (mouseX - lastMouseX == 0) or not (mouseY - lastMouseY == 0) then
        mouseMoved = true
    else
        mouseMoved = false
    end


    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed  = {}
    -- mouseDragDirection = nil
end


function love.draw()
    push:start()

    -- scrolling background drawn behind every state
    love.graphics.draw(gTextures['background'], backgroundX, 0)

    gStateMachine:render()

    if DEBUG then
        love.graphics.setFont(gFonts['medium'])
        love.graphics.setColor(99 / 255, 155 / 255, 1, 1)
        love.graphics.print('mouseX: ' .. tostring(mouseX), 8, VIRTUAL_HEIGHT - 32)
        love.graphics.print('mouseY: ' .. tostring(mouseY), 8, VIRTUAL_HEIGHT - 16)

        love.graphics.print('startX: ' .. tostring(startMouseX), 150, VIRTUAL_HEIGHT - 32)
        love.graphics.print('startY: ' .. tostring(startMouseY), 150, VIRTUAL_HEIGHT - 16)

        love.graphics.print('finX: ' .. tostring(finMouseX), 280, VIRTUAL_HEIGHT - 32)
        love.graphics.print('finY: ' .. tostring(finMouseY), 280, VIRTUAL_HEIGHT - 16)

        love.graphics.print('disX: ' .. tostring(disX), 410, VIRTUAL_HEIGHT - 32)
        love.graphics.print('disY: ' .. tostring(disY), 410, VIRTUAL_HEIGHT - 16)

        love.graphics.print('mouseDrag: ' .. tostring(mouseDragDirection), 8, VIRTUAL_HEIGHT - 48)
        love.graphics.print('mouseGrabbed: ' .. tostring(mouseGrabbed), 8, VIRTUAL_HEIGHT - 64)

        gStateMachine:debugRender()
    end

    push:finish()
end

function drawTextShadow(text, xmin, xmax, y)
    love.graphics.setColor(34 / 255, 32 / 255, 52 / 255, 1)
    love.graphics.printf(text, xmin + 2, y + 1, xmax, 'center')
    love.graphics.printf(text, xmin + 1, y + 1, xmax, 'center')
    love.graphics.printf(text, xmin, y + 1, xmax, 'center')
    love.graphics.printf(text, xmin + 1, y + 2, xmax, 'center')
end
