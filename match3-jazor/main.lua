require 'src/Dependencies'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

DEBUG = true

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

    if not (mouseX - lastMouseX == 0) or not (mouseY - lastMouseY == 0) then
        mouseMoved = true
    else
        mouseMoved = false
    end


    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed  = {}
end


function love.draw()
    push:start()

    -- scrolling background drawn behind every state
    love.graphics.draw(gTextures['background'], backgroundX, 0)

    if DEBUG then
        love.graphics.setFont(gFonts['medium'])
        love.graphics.setColor(99 / 255, 155 / 255, 1, 1)
        love.graphics.print('mouseX: ' .. tostring(mouseX), 8, VIRTUAL_HEIGHT - 32)
        love.graphics.print('mousey: ' .. tostring(mouseY), 8, VIRTUAL_HEIGHT - 16)

        gStateMachine:debugRender()
    end

    gStateMachine:render()
    push:finish()
end

function drawTextShadow(text, xmin, xmax, y)
    love.graphics.setColor(34 / 255, 32 / 255, 52 / 255, 1)
    love.graphics.printf(text, xmin + 2, y + 1, xmax, 'center')
    love.graphics.printf(text, xmin + 1, y + 1, xmax, 'center')
    love.graphics.printf(text, xmin, y + 1, xmax, 'center')
    love.graphics.printf(text, xmin + 1, y + 2, xmax, 'center')
end
