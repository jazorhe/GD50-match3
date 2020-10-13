# GD50-match3

## Overview:

### Summary:

-   **Anonymous Functions:**  A fundamental concept in many dynamic languages, as well as Lua. Anonymous functions are functions that are first class, meaning that they operate as data types.
-   **Tweening:**  Interpolating a value between two values over time. Useful for asynchronous behavior and asynchronous variable manipulation.
-   **Timers**
-   **Solving Matches**
-   **Procedural Grids**
-   **Sprite Art and Palettes**


### Goal:
<img src="img/goal.png" width="700">


<br>
<br>

## Developing & Learning Notes:

### timer0: "The Simple Way"

-   **Pseudocode:**
    -   In love.load()
        -   Create timer variable
        -   Create counter variable
    -   In love.update(dt)
        -   Increment timer variable by dt
        -   If timer > 1
            -   Increment counter by 1
            -   Take remainers of timer
        -   End if
    -   In love.draw()
        -   Render and print counter variable


#### Results:
<img src="img/timer0.png" width="700">

<br>

### timer1: "The Ugly Way"

-   Do the above 5 times with different interval values

<br>

### timer2: "The Clean Way"

Need to include the "Timer" library or module

-   Timer.every(internal, callback)
-   Timer.after(interval, callback)


-   **Pseudocode:**
    -   In love.load()
        -   Create table of intervals
        -   Create table of counters
        -   for each interval value in table
            -   Timer.every() increment counter at same index
            -   loop
    -   In love.update(dt)
        -   Do nothing
    -   In love.draw()
        -   for each counter value in table
            -   draw
            -   loop


#### Results:
<img src="img/timer2.png" width="700">

<br>

### tween0: "The Simple Way"


-   Lua Trick: Assign 2 values to two variables using a comma

        flappyX, flappyY = 0, VIRTUAL_HEIGHT / 2 - 8


-   Make use of a timer and the ratio of (timer / MOVE_INTERVAL) to achieve  discrete but very accurate result of dividing steps within an interval period of time

        flappyX = math.min(endX, endX * (timer / MOVE_DURATION))


### tween1: "A Better Way"


-   Knife Library  

    <img src="img/knifeModules.png" width="700">


-   Again, put them all in table


-   **Pseudocode:**
    -   In love.load()
        -   Create timer
        -   Initiate empty flappy bird table
        -   for x amount of times
            -   Insert into table a bird with a random rate (see below for random rate)
            -   Loop
    -   In love.update(dt)
        -   If timer less than TIMER_MAX
            -   Update timer with dt
            -   for each bird
                -   Update position with the above (timer / rate) ratio


-   For random floats in Lua and Love2d:

        rate = math.random() + math.random(TIMER_MAX - 1)


-   Stress test the game with love.timer.getFPS() and ramp up the number of flappy birds


#### Results:  
<img src="img/tween1.png" width="700">


### tween2: "The Timer.tween Way"

-   Opacity:

        love.graphics.setColor(255, 255, 255, bird.opacity)


-   Now start bird.opacity at 0
-   Then change opacity and also position for each bird with bird.rate (you can pass as many parameters in and also as many entities in as you like, POWERFUL. Refer to knife documentations)

        for k, bird in pairs(birds) do
            Timer.tween(bird.rate, {
                [bird] = { x = endX, opacity = 255 }
            })
        end


-   For example a translation screen:
    -   Draw rectangle that is the screen size and tween its opacity from 0 to 255
    -   Enter next game state
    -   Draw same rectangle but tween its opacity from 255 to 0
    -   Can be any colour you like


-   In match-3 source code, as an example to achieve multicolour flashing alphabets

        self.colors = {
            [1] = {217, 87, 99, 255},
            [2] = {95, 205, 228, 255},
            [3] = {251, 242, 54, 255},
            [4] = {118, 66, 138, 255},
            [5] = {153, 229, 80, 255},
            [6] = {223, 113, 38, 255}
        }

        self.letterTable = {
            {'M', -108},
            {'A', -64},
            {'T', -28},
            {'C', 2},
            {'H', 40},
            {'3', 112}
        }

        self.colorTimer = Timer.every(0.075, function()
            -- shift every color to the next, looping the last to front
            -- assign it to 0 so the loop below moves it to 1, default start
            self.colors[0] = self.colors[6]

            for i = 6, 1, -1 do
                self.colors[i] = self.colors[i - 1]
            end
        end)


-   Also an example for **manipulating [self]** and using a **finish function**

        Timer.tween(1, {
            [self] = {transitionAlpha = 255}
        }):finish(function()
            gStateMachine:change('begin-game', {
                level = 1
            })


-   

### chain0
### chain1
### match-3
### swap0
### swap1
### swap2


# Assignment 3

\-- Enter Description Here...

Final Submission:

\-- Enter Description Here...

## Helpful Links:
-   [Lua Knife](https://github.com/airstruck/knife)
-   [GitHub: Mastering Markdown](https://guides.github.com/features/mastering-markdown/)
