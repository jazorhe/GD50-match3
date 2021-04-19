PlayState = Class{__includes = BaseState}

function PlayState:init()
    -- start our transition alpha at full, so we fade in
    self.currentMenuItem = 0
    self.transitionAlpha = 1

    -- position in the grid which we're highlighting
    self.boardHighlightX = 0
    self.boardHighlightY = 0

    -- timer used to switch the highlight rect's color
    self.rectHighlighted = false

    -- flag to show whether we're able to process input (not swapping or clearing)
    self.canInput = false
    self.canMatch = false
    self.dragging = false

    -- tile we're currently highlighting (preparing to swap)
    self.highlightedTile = nil

    self.score = 0
    self.timer = 60

    -- set our Timer class to turn cursor highlight on and off
    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
    end)

    -- subtract 1 from timer every second
    Timer.every(1, function()
        self.timer = self.timer - 1

        -- play warning sound on timer if we get low
        if self.timer <= 5 then
            gSounds['clock']:play()
        end
    end)
end

function PlayState:enter(params)
    -- grab level # from the params we're passed
    self.level = params.level

    -- spawn a board and place it toward the right
    self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16, {1, 4, 6, 7, 13, 16}, {1, 5, 6})

    -- grab score from params if it was passed
    self.score = params.score or 0

    -- score we have to reach to get to the next level
    self.scoreGoal = self.level * 1.25 * 1000
end

function PlayState:update(dt)

    if love.keyboard.wasPressed('escape') then
        gStateMachine:change('start')
    end

    globalMute()

    if self.timer <= 0 then
        -- clear timers from prior PlayStates
        Timer.clear()

        gSounds['game-over']:play()

        gStateMachine:change('game-over', {
            score = self.score
        })
    end

    -- go to next level if we surpass score goal
    if self.score >= self.scoreGoal then
        Timer.clear()

        gSounds['next-level']:play()

        gStateMachine:change('begin-game', {
            level = self.level + 1,
            score = self.score
        })
    end

    if self.canInput then
        -- move cursor around based on bounds of grid, playing sounds
        if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('w') then
            self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('down') or love.keyboard.wasPressed('s') then
            self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('left') or love.keyboard.wasPressed('a') then
            self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('right') or love.keyboard.wasPressed('d') then
            self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
            gSounds['select']:play()
        end

        if mouseX > VIRTUAL_WIDTH - 272 and mouseX < VIRTUAL_WIDTH - 272 + 32 * 8 and mouseY > 16 and mouseY < 16 + 32 * 8 then

            if mouseMoved then
                self.boardHighlightX = math.floor((mouseX - (VIRTUAL_WIDTH - 272)) / 32)
                self.boardHighlightY = math.floor((mouseY - 16) / 32)
            end

            if love.mouse.wasPressed(1) then
                self:confirmTile()
            end

            if self.dragging and not love.mouse.isDown(1) then
                self:confirmTile()
                self.dragging = false
            end

            if self.highlightedTile and love.mouse.isDown(1) then
                self.dragging = true
            end

        end

        if mouseX > 20 and mouseX < 182 and mouseY > 136 and mouseY < 136 + 20 then

            if mouseMoved and self.currentMenuItem == 0 then
                self.currentMenuItem = 1
            end

            if love.mouse.wasPressed(1) then
                gStateMachine:change('start')
            end

        else
            self.currentMenuItem = 0
        end

        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            self:confirmTile()
        end
    else
        self.canMatch = false
        if self:predictMatches() then
            self.canMatch = true
            self.canInput = true
        end
    end

    self.board:update(dt)
    Timer.update(dt)
end


function PlayState:predictMatches()

    self.checkBoard = self.board
    self.checkBoard.tiles = self.board.tiles

    for y = 1, 8 do
        for x = 1, 7 do

            local tileA = self.checkBoard.tiles[y][x]
            local tileB = self.checkBoard.tiles[y][x + 1]

            local tempX = tileA.gridX
            local tempY = tileA.gridY

            tileA.gridX = tileB.gridX
            tileA.gridY = tileB.gridY
            tileB.gridX = tempX
            tileB.gridY = tempY

            self.checkBoard.tiles[tileA.gridY][tileA.gridX] = tileA
            self.checkBoard.tiles[tileB.gridY][tileB.gridX] = tileB
            local foundMatch = self.checkBoard:calculateMatches()
            tempX = tileA.gridX
            tempY = tileA.gridY
            tileA.gridX = tileB.gridX
            tileA.gridY = tileB.gridY
            tileB.gridX = tempX
            tileB.gridY = tempY
            self.checkBoard.tiles[tileA.gridY][tileA.gridX] = tileA
            self.checkBoard.tiles[tileB.gridY][tileB.gridX] = tileB

            if foundMatch then
                return true
            end

        end
    end

    for x = 1, 8 do
        for y = 1, 7 do

            local tileA = self.checkBoard.tiles[y][x]
            local tileB = self.checkBoard.tiles[y + 1][x]

            local tempX = tileA.gridX
            local tempY = tileA.gridY

            tileA.gridX = tileB.gridX
            tileA.gridY = tileB.gridY
            tileB.gridX = tempX
            tileB.gridY = tempY

            self.checkBoard.tiles[tileA.gridY][tileA.gridX] = tileA
            self.checkBoard.tiles[tileB.gridY][tileB.gridX] = tileB
            local foundMatch = self.checkBoard:calculateMatches()
            tempX = tileA.gridX
            tempY = tileA.gridY
            tileA.gridX = tileB.gridX
            tileA.gridY = tileB.gridY
            tileB.gridX = tempX
            tileB.gridY = tempY
            self.checkBoard.tiles[tileA.gridY][tileA.gridX] = tileA
            self.checkBoard.tiles[tileB.gridY][tileB.gridX] = tileB

            if foundMatch then
                return true
            end
        end
    end

    return false

end

function PlayState:confirmTile()
    -- if same tile as currently highlighted, deselect
    local x = self.boardHighlightX + 1
    local y = self.boardHighlightY + 1

    -- if nothing is highlighted, highlight current tile
    if not self.highlightedTile then
        self.highlightedTile = self.board.tiles[y][x]

    -- if we select the position already highlighted, remove highlight
    elseif self.highlightedTile == self.board.tiles[y][x] then
        self.highlightedTile = nil

    -- if the difference between X and Y combined of this highlighted tile
    -- vs the previous is not equal to 1, also remove highlight
    elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
        gSounds['error']:play()
        self.highlightedTile = nil
    else
        self:swapTiles(x, y)
    end
end


function PlayState:swapTiles(x, y)
    local tempX = self.highlightedTile.gridX
    local tempY = self.highlightedTile.gridY

    local newTile = self.board.tiles[y][x]

    self.highlightedTile.gridX = newTile.gridX
    self.highlightedTile.gridY = newTile.gridY
    newTile.gridX = tempX
    newTile.gridY = tempY

    -- swap tiles in the tiles table
    self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] = self.highlightedTile

    self.board.tiles[newTile.gridY][newTile.gridX] = newTile

    -- tween coordinates between the two so they swap
    Timer.tween(0.2, {
        [self.highlightedTile] = {x = newTile.x, y = newTile.y},
        [newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
    })
    -- once the swap is finished, we can tween falling blocks as needed
    :finish(function()
        self:calculateMatches(tempX, tempY)
    end)
end

function PlayState:calculateMatches(x, y)

    local matches = self.board:calculateMatches()

    if matches then
        self.highlightedTile = nil
        gSounds['match']:stop()
        gSounds['match']:play()

        -- add score for each match
        for k, match in pairs(matches) do
            local totalBonus = 0
            local bonus = 0

            for i = 1, #match do

                if match[i].variety > 1 and match[i].variety < 5 then
                    bonus = 1.1
                elseif match[i].variety == 5 then
                    bonus = 1.2
                elseif match[i].variety == 6 then
                    bonus = 1.3
                end

                if match[i].isShiny then
                    bonus = 5
                end

            totalBonus = totalBonus + bonus * BASE_SCORE

        end

            self.score = self.score + #match * BASE_SCORE + totalBonus
            self.timer = self.timer + #match * 1
        end

        -- remove any tiles that matched from the board, making empty spaces
        self.board:removeMatches()

        -- gets a table with tween values for tiles that should now fall
        local tilesToFall = self.board:getFallingTiles()

        -- first, tween the falling tiles over 0.25s
        Timer.tween(0.25, tilesToFall):finish(function()
            local newTiles = self.board:getNewTiles()

            -- then, tween new tiles that spawn from the ceiling over 0.25s to fill in
            -- the new upper gaps that exist
            Timer.tween(0.25, newTiles):finish(function()
                -- recursively call function in case new matches have been created
                -- as a result of falling blocks once new blocks have finished falling
                self:calculateMatches()
            end)
        end)
    -- if no matches, we can continue playing
    else
        if not self.highlightedTile then
            self.canInput = true
        else
            self:swapTiles(x, y)
            self.highlightedTile = nil
            self.canInput = false
            self.canMatch = false
        end
    end
end


function PlayState:render()
    -- render board of tiles
    self.board:render()

    -- render highlighted tile if it exists
    if self.highlightedTile then
        -- multiply so drawing white rect makes it brighter
        love.graphics.setBlendMode('add')

        love.graphics.setColor(1, 1, 1, 96 / 255)
        love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
            (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)

        -- back to alpha
        love.graphics.setBlendMode('alpha')
    end

    -- render highlight rect color based on timer
    if self.rectHighlighted then
        love.graphics.setColor(217 / 255, 87 / 255, 99 / 255, 1)
    else
        love.graphics.setColor(172 / 255, 50 / 255, 50 / 255, 1)
    end

    -- draw actual cursor rect
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272),
        self.boardHighlightY * 32 + 16, 32, 32, 4)

    -- GUI text
    love.graphics.setColor(56 / 255, 56 / 255, 56 / 255, 234 / 255)
    love.graphics.rectangle('fill', 16, 16, 186, 144, 4)

    love.graphics.setColor(99 / 255, 155 / 255, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')

    drawTextShadow('Menu', 20, 182, 136)
    if self.currentMenuItem == 1 then
        love.graphics.setColor(99 / 255, 155 / 255, 1, 1)
    else
        love.graphics.setColor(48 / 255, 96 / 255, 130 / 255, 1)
    end
    love.graphics.printf('Menu', 20, 136, 182, 'center')
end

function PlayState:debugRender()
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(99 / 255, 155 / 255, 1, 1)
    love.graphics.print('bX: ' .. tostring(self.boardHighlightX), 8, VIRTUAL_HEIGHT - 64)
    love.graphics.print('bY: ' .. tostring(self.boardHighlightY), 8, VIRTUAL_HEIGHT - 48)
end
