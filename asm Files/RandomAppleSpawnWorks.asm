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
.macro enqueueSnake(%pixel) # Used for eating apples and moving
	bge $s3, $s2, gameOver	# Exit if snake is full
	
	addi $s1, $s1, 4 	# Get next head address
	addi $s6, $s6, 1	# Increment queue head loop counter
	
	ble $s6, $s2, add	# Branch if the queue has not reach its end 
	
	# Loop the head queue array
	la $s1, queue		# Set head address to queue base
	li $s6, 1		# Reset queue header pointer
	
add:	
	sw %pixel, ($s1)	# Store the pixel of head into queue
.end_macro

.macro movingSnakeQueue(%pixel) #used to move
	enqueueSnake(%pixel)
	dequeueSnake
.end_macro

.macro dequeueSnake # Only used when snake is moving
	bge $s3, $s2, gameOver	# Exit if snake is full
	
	lw $t1, ($s4)		# Load old tail offset
	add $t1, $t1, $s7	# Get old tail on grid
	sw $t0, ($t1)		# Turn it to grey
	
	li $t1, 0		# Load an empty value
	sw $t1, ($s4)		# Clear the old tail in queue
	
	# Go next tail cell
	addi $s4, $s4, 4	# Get next tail address
	addi $s0, $s0, 1	# Increment queue tail loop counter
	
	ble $s0, $s2, cont
	
	# Loop queue tail
	la $s4, queue		# Set tail address to queue base
	li $s0, 1		# Reset queue tail pointer
	
cont:	
	# Do nothing since it already dequeue the old tail point
.end_macro

.data
frameBuffer: 	.space 	0x40000		#((64 * 64) / 4) / 4
max_size: 	.word 	196		# Size of playable spots - 196
queue:		.space 	784		# Memory allocation for all spots (196 x 4 bytes)
snakeUp:	.word	0x0000ff00	# green pixel for when snaking moving up
snakeDown:	.word	0x0100ff00	# green pixel for when snaking moving down
snakeLeft:	.word	0x0200ff00	# green pixel for when snaking moving left
snakeRight:	.word	0x0300ff00	# green pixel for when snaking moving right
tail:		.word 	800		# tail starting pixel
head:		.word	736		# head starting pixel
gameOverPrompt: .asciiz "Game Over!"
replayMessage:	.asciiz "Would you like to try again?"

#testing data
appleConfirm:	.asciiz "Apple is generating"
newLine: 	.asciiz "\n"


.text
main:
ClearRegisters:

	li $v0, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
########################################################################################################################################
#Initialize the board
la $t0, frameBuffer		#Loads the board address
li $t1, 4096 			#Saves the pixels we need for the display ((64 * 64) / 4) / 4 bytes per pixel
li $t2, 0x00d3d3d3		#Loads the color light grey

initializeBoard:
sw $t2, 0($t0)			#Stores the empty space characer on the board
addi $t0, $t0, 4		#Goes on to the next cell
addi $t1, $t1, -1		#Decreases the cell count (we need to reach zero)
bnez $t1, initializeBoard	#If $t1 = 0 then the board is initialized

#Draw the border
la $t0, frameBuffer		#Reset the board address
addi $t1, $zero, 16 		#64 = $t1 which is the length of the row
li $t2, 0x000000		#Load the color red for the border

topBorder:
sw $t2, 0($t0)			#Set pixel to red
addi $t0, $t0, 4		#Move on to the next pixel
addi $t1, $t1, -1		#Decrease the pixel count (For some damn reason, I coul not get subi to work!)
bnez $t1, topBorder		#Loops until the top border is done

#Bottome side of the border
la $t0, frameBuffer		#Load board address
addi $t0, $t0, 960 		#Moves pixel to the bottom left (This part was stupid and I did it by basically knowing this: 64 / 4 = 16. Our size is 16x16. Taking into consideration the top row, we needto worry about 15 others. To get to the bottom row all we do is 64 * 15 = 960
addi $t1, $zero, 16 		#Length of row

bottomBorder:
sw $t2, 0($t0)			#Set pixel to red
addi $t0, $t0, 4		#Move on to the next pixel
addi $t1, $t1, -1		#Decrease the pixel count
bnez $t1, bottomBorder		#Loops until the bottom border is done

#Left side of the border
la $t0, frameBuffer		#Load border address
addi $t1, $zero, 64		#Length of column

leftBorder:
sw $t2, 0($t0)			#Set pixel to red
addi $t0, $t0, 64		#Move on to the next pixel
addi $t1, $t1, -1		#Decrease the pixel count
bnez $t1, leftBorder		#Loops until the left border is done

#Right side of the border
la $t0, frameBuffer		#Load border address
addi $t0, $t0, 60		#Here is the pixel we start with at the top right 256 - 4 = 252 (We subtract 4 because that is a byte)
addi $t1, $zero, 63		#Length of column

rightBorder:
sw $t2, 0($t0)			#Set pixel red
addi $t0, $t0, 64		#Move on to the next pixel
addi $t1, $t1, -1		#Decrease the pixel count
bnez $t1, rightBorder		#Loops until the right border is done


###########################################################################################################################################
	### draw initial snake section
	la $s7, frameBuffer	# load frame buffer address
	lw $s5, snakeUp		# s5 = direction of snake
	
	lw $s2, tail		# s2 = tail location of snake
	add $t1, $s2, $s7	# t1 = tail start on bit map display
	sw $s5, 0($t1)		# draw pixel where snake is
	
	lw $s2, head		# s2 = tail location of snake
	add $t1, $s2, $s7	# set t1 to pixel above
	sw $s5, 0($t1)		# draw pixel where snake currently is
###########################################################################################################################################

# Initialize snake
loadSnake:
	jal init_queue
	
############################
#Generate first apple
lw $t0, head #head is 736

#68 is top left
#952 is bottom right
			# Get new head pixel offset
	

add $t0, $s7, $t0 #$t0 is now 26801600
add $t0, $t0, -128
li $t1, 0x00ff0000
sw $t1, ($t0)

#addi $t0, $t0, -64
#sw $t1, ($t0)



#########
	
j gameUpdateLoop

init_queue:
	la $t0, queue		# load queue base address
	addi $s1, $t0, 4	# $s1 - head pointer address
	add $s4, $t0, $zero	# $s4 - tail pointer address (at queue base)
	lw $s2, max_size	# $s2 - load max_size of playable grid slots
	la $s3, 2		# $s3 - Initialize pixel count of snake
	li $s6, 2		# $s6 - Queue header counter for looping queue
	li $s0, 1		# $s0 - Queue tail counter for looping queue
	lw $t1, head		# Store head pos in queue
	sw $t1, ($s1)
	lw $t1, tail		# Store tail pos in queue
	sw $t1, ($s4)
	
	jr $ra			# return
############################################################################################################################################

# Movement
gameUpdateLoop:

	lw	$t3, 0xffff0004		# get keypress from keyboard input
	addi	$v0, $zero, 32		# syscall sleep
	addi	$a0, $zero, 500		# frame rate
	syscall
	
	lw $t2, ($s1)			# Load value at the head

	beq $t8, 119, moveUp		# start game moving up	

checkDirection:
	beq $t3, 119, checkIsDownPressed #if  moving up, check to see if down is pressed
	beq $t3, 115, checkIsUpPressed	#if moving down, check to see if up is pressed
	beq $t3, 97, checkIsRightPressed #if moving left, check to see if right is pressed
	beq $t3, 100, checkIsLeftPressed #if moving right, check to see if left is pressed
	
checkIsDownPressed:
	beq $a3, 115, moveDown #if already moving down, will stay moving down if up is pressed.
	j moveUp

checkIsUpPressed:
	beq $a3, 119, moveUp #if already moving up, will stay moving up if down is pressed
	j moveDown

checkIsRightPressed:
	beq $a3, 100, moveRight #if already moving right, will stay moving right if left is pressed
	j moveLeft
	
checkIsLeftPressed:
	beq $a3, 97, moveLeft #if if already moving left, will stay moving left if rigth is pressed
	j moveRight

moveRight:
	lw $s5, snakeRight	# Load directions
	addi $t2, $t2, 4	# New pixel right of the head
	li $a3, 100
	j updateSnakeQueue
	
moveLeft:
	lw $s5, snakeLeft	# Load directions
	addi $t2, $t2, -4	# New pixel left of the head
	li $a3, 97
	j updateSnakeQueue
moveUp:
	li $t8, 0
	lw $s5, snakeUp		# Load directions
	addi $t2, $t2, -64	# New pixel on top of the head
	li $a3, 119
	j updateSnakeQueue
		
moveDown:
	lw $s5, snakeDown	# Load directions
	addi $t2, $t2, 64	# New pixel on the bottom of the head
	li $a3, 115
	
updateSnakeQueue:
	li $t0, 0x00d3d3d3 	# Load color light grey
	enqueueSnake($t2)	# Move snake head
	add $a0, $s5, $zero	# Store directions

	###########################
	#s1 new pixel offset 'content' for head
	#Check if new head tile is a certain color
	# See grey, keep moving
	# See red, add snake
	# See any other color, end game
	lw $t6, ($s1)
	
	
	add $t6, $t6, $s7		# Get address of new head on grid

	
	lw $t7, ($t6)		# Load of color of the new head location
	
	li $v0, 1
	move $a0, $t7
	syscall 
	li $v0, 4
	la $a0, newLine
	syscall
	
	li $t6, 0x00ff0000		# Load color red (16711680)	

	
	beq $t7, $t6, appleHead		# If new head was an apple, branch to add on to snake
	
	dequeueSnake			# Will properly move the snake's tail if new head was not apple
	beq $t7, $t0, continueUpdate	# If new tile was grey, continue
	
	li $t0, 0x0000ff00
	beq $t7, $t0, smallSnake	# Due to checking, if next tile is green check if it is a small snake	
	
	b gameOver			# End game if it touches any other color
	#############################
continueUpdate:
	li $t1, 0x0000ff00	# Load color green
	move $t2, $s4		# Load the beginning of the queue (starting at tail)
	move $t5, $s3		# Load amount of iterations (snake size)
	
	la $t8, queue
	addi $t8, $t8, 780	# Get end of queue
	
printSnake:
	beqz $t5, gameUpdateLoop
	bgt $t2, $t8, resetQueuePointer

continuePrinting:
	lw $t4, ($t2)		# Get cell content in queue
	add $t4, $t4, $s7	# Get cell position
	sw $s5, ($t4)		# Store color+direction on grid
	add $t2, $t2, 4		# Iterate to next element in queue
	addi $t5, $t5, -1	# Loop countdown
	
	j printSnake

resetQueuePointer:
	la $t2, queue
	j continuePrinting

appleHead:	
	addi $s3, $s3, 1
	#BEN CODE
 	generateNewApple:
 	
    		li $v0, 42            # System call for random number generation
    		#I want a number between 68 and 952, but only a multiple of 4
    		#so do random from 68/4 = 17 and 952/4 = 238
    		li $a1, 222
    		syscall
    		
    		move $t0, $a0  
    		add $t0, $t0, 17       # Store random number in $t0
    		mul $t0, $t0, 4       # Convert random index to byte offset (4 bytes per grid cell)
		add $t0, $s7, $t0
	
	
    		# Check if the new position is valid (not in the snake)
   		# Get the actual address in the grid
    		lw $t2, ($t0)         # Load the color of the chosen spot
    		li $t3, 0x00d3d3d3    # Light grey (empty spot color)
    		beq $t2, $t3, placeApple  # If spot is empty, place the apple

    		# If the spot is not empty, generate another random position
    		j generateNewApple
		
				# Increment to the snake size
	j continueUpdate	# Continue to print out the snake with new length
	
#BEN CODE
placeApple:
    	li $t4, 0x00ff0000    # Load apple color (red)
    	sw $t4, ($t0)         # Place apple at the valid position
    	j continueUpdate                # Return to continueUpdate

smallSnake:
	beq $s3, 4, continueUpdate	# If it is a small snake that forms a square, continue game
	# Will exit game if not	

gameOver:
	#end program
	li $t0, 0x0000ff00
	lw $t1, ($s1)
	add $t1, $t1, $s7
	sw $t0, ($t1)
	
	#opens game over prompt
	li $v0, 55
	la $a0, gameOverPrompt
	syscall 
	
	#Asks user to play again
	li $v0, 50 
	la $a0, replayMessage 
	syscall
	
	beqz $a0, resetDirection #jump back to start of program if user says yes to play again
	j exitGame
	
resetDirection:
	#resets direction for start of game if playing again
	li $t8, 119 
	j main
    
exitGame:
	li $v0, 10
	syscall

    	
