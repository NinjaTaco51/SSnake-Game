#CS 2640
#Akshit Gupta, David Lam, Alan Mac, Alejandro Manzo, Benjamin Tran
#Final Project: Snake Game
#Goals:
#1.) Make the board for the game
#2.) Make the snake that the playerwill control
#3.) Make the food that the player will have to eat in order to grow the snake
#4.) Figure out how to handle user input for movement (maybe arrow keys or traditional 'w', 'a', 's', 'd')
#5.) Figure out how to update the ovement of the snake
#6.) Check for collisions if the player were to hit the border, end the game or cease movement until another attempt
#7.) Check for the food and if the snake reaches the food increase the size of the snake
#8.) That's it???

.data
board: .space 0x40000#((256 * 256) / 4) / 4

.text
main:
#Initialize the board
la $t0, board#Loads the board address
li $t1, 4096#Saves the pixels we need for the display ((256 * 256) / 4) / 4 bytes per pixel
li $t2, 0x808080#Loads the color grey

initializeBoard:
sw $t2, 0($t0)#Stores the empty space characer on the board
addi $t0, $t0, 4#Goes on to the next cell
addi $t1, $t1, -1#Decreases the cell count (we need to reach zero)
bnez $t1, initializeBoard#If $t1 = 0 then the board is initialized

#Draw the border
la $t0, board#Reset the board address
addi $t1, $zero, 64#64 = $t1 which is the length of the row
li $t2, 0xFF0000#Load the color red for the border

topBorder:
sw $t2, 0($t0)#Set pixel to red
addi $t0, $t0, 4#Move on to the next pixel
addi $t1, $t1, -1#Decrease the pixel count (For some damn reason, I coul not get subi to work!)
bnez $t1, topBorder#Loops until the top border is done

#Bottome side of the border
la $t0, board#Load board address
addi $t0, $t0, 16128#Moves pixel to the bottom left (This part was stupid and I did it by basically knowing this: 256 / 4 = 64. Our size is 64x64. Taking into consideration the top row, we needto worry about 63 others. To get to the bottom row all we do is 256 * 63 = 16128
addi $t1, $zero, 64#Length of row

bottomBorder:
sw $t2, 0($t0)#Set pixel to red
addi $t0, $t0, 4#Move on to the next pixel
addi $t1, $t1, -1#Decrease the pixel count
bnez $t1, bottomBorder#Loops until the bottom border is done

#Left side of the border
la $t0, board#Load border address
addi $t1, $zero, 256#Length of column

leftBorder:
sw $t2, 0($t0)#Set pixel to red
addi $t0, $t0, 256#Move on to the next pixel
addi $t1, $t1, -1#Decrease the pixel count
bnez $t1, leftBorder#Loops until the left border is done

#Right side of the border
la $t0, board#Load border address
addi $t0, $t0, 252#Here is the pixel we start with at the top right 256 - 4 = 252 (We subtract 4 because that is a byte)
addi $t1, $zero, 255#Length of column

rightBorder:
sw $t2, 0($t0)#Set pixel red
addi $t0, $t0, 256#Move on to the next pixel
addi $t1, $t1, -1#Decrease the pixel count
bnez $t1, rightBorder#Loops until the right border is done

#We need to keep going, but I ended the looping here just to make sure that the map display loads
li $v0, 10
syscall