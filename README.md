# GD50-match3

## Overview:

-   Anonymous Functions:

    A fundamental concept in many dynamic languages, as well as Lua. Anonymous functions are functions that are first class, meaning that they operate as data types.

-   Tweening:

    Interpolating a value between two values over time. Useful for asynchronous behavior and asynchronous variable manipulation.

-   Timers

-   Solving Matches


-   Procedural Grids


-   Sprite Art and Palettes

<img src="img/goal.png" width="700">


# Developing & Learning Notes:

## timer0: "The Simple Way"

-   Pseudocode:
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

## timer1: "The Ugly Way"

-   Do the above 5 times

## timer2: "The Clean Way"

-   Timer.every(internal, callback)
-   Timer.after(interval, callback)


## tween0: "The Simple Way"
## tween1
## tween2
## chain0
## chain1
## match-3
## swap0
## swap1
## swap2

# Assignment 3

\-- Enter Description Here...

Final Submission:

\-- Enter Description Here...

## Helpful Links:
