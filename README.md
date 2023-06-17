# DOSassembly-knightTour
(DOS)assembly project that allows you to play and automaticly solve a variant of the knight tour problem

firstly the program solves the knight tour problem yet doesnt return to the original spot where the knight started as well as always starting in the upper left but this can be easly changed in the code.
the program uses a simple backtracking array with a estimated running time of the solve is  less then a second to find the 5x5 solution yet about 15 seconds to solve the 6x6 so its a bit problematic

https://replit.com/@omer2oo7/UnimportantMistyroseSystemcall - a solution in java (not the same as the solution in the code) that works faster but a bit harder to implement

code is in "base.asm" and uses most of the files but not all.
i used DOSbox to run the program and wrote it inside of VScode (it cannot run with the images in VS code)

to use the program you need to enter a number up to 15  and i will create a board by that inputed number(no need to press enter)
you can click on a square and if it follows the chess knight moving it will color that square blue
the point of the game is to make the whole board blue

on the right you can restart the program to input a number again and on the left you can tell the computer to solve it when i finishes solving it restarts
