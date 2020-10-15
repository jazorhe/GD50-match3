--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, isShiny)
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.isShiny = isShiny


    if self.isShiny then
        self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 5)
        self.psystem:setSizes(0.6, 0.8)
        self.psystem:setParticleLifetime(0.2, 0.4)
        self.psystem:setLinearAcceleration(-15, -20, 15, 10)
        self.psystem:setEmissionArea('normal', 6, 6)
    end

end

function Tile:update(dt)

    if self.isShiny then

        self.psystem:setColors(
            251 / 255, 231 / 255, 45 / 255, 0.8,
            251 / 255, 231 / 255, 45 / 255, 0.2
        )
        self.psystem:emit(5)
        self.psystem:update(dt)

    end

end


function Tile:renderParticles(x, y)
    love.graphics.draw(self.psystem, self.x + x + 18, self.y + y + 18)
end

--[[
    Function to swap this tile with another tile, tweening the two's positions.
]]
function Tile:swap(tile)

end

function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34 / 255, 32 / 255, 52 / 255, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
end
