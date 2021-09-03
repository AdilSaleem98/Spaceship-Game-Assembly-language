##################################################################### 
#
# 
# Student: Name, Student Number, 
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 (update this as needed) 
# - Unit height in pixels: 8 (update this as needed) 
# - Display width in pixels: 256 (update this as needed) 
# - Display height in pixels: 256 (update this as needed) 
# - Base Address for Display: 0x10008000 ($gp) 
# 
# Which milestones have been reached in this submission? 
# (See the assignment handout for descriptions of the milestones) 
# - Milestone 1/2/3 (choose the one that applies) 
#
# Which approved features have been implemented for milestone 3? 
# (See the assignment handout for the list of additional features) 
# 1. (fill in the feature, if any) 
# 2. (fill in the feature, if any) 
# 3. (fill in the feature, if any) 
# ... (add more if necessary) 
# 
# Link to video demonstration for final submission: 
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it! 
# 
# Are you OK with us sharing the video with people outside course staff? 
# - yes / no / yes, and please share this project github link as well! 
# 
# Any additional information that the TA needs to know: 
# - (write here, if any) 
#
#####################################################################

.data
frameBuffer: 	.space 	0x40000		#256 wide x 256 high pixels

xPos:		.word	11		# x position
yPos:		.word	4		# y position
shipX:		.word	11		# ship x position
shipY:		.word	4		# ship y position
ObX:		.word	29		# ship y position
Ob1Xn:		.word	29		# ship y position

Ob1Y:		.word	1		# ship y position

width:		.word	32		# width of framebuffer in units
four:		.word	4		# 4 for formula
shipUp:		.word	0x0000ff00	# green pixel for when snaking moving up
shipDown:	.word	0x0100ff00	# green pixel for when snaking moving down
shipLeft:	.word	0x0200ff00	# green pixel for when snaking moving left
shipRight:	.word	0x0300ff00	# green pixel for when snaking moving right

# Bitmap display starter code 
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 256 
# - Display height in pixels: 256 
# - Base Address for Display: 0x10008000 ($gp) 
# 
.eqv BASE_ADDRESS 		0x10008000 

.text 
main:
	
### DRAW BORDER SECTION
	
	# top wall section
	la	$t0, BASE_ADDRESS	# load frame buffer addres
	addi	$t1, $zero, 16		# t1 = 64 length of row
	li 	$t2, 0x00ffffff		# load black color
Top:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 8		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, Top	# repeat unitl pixel count == 0
	
	# Bottom wall section
	la	$t0, BASE_ADDRESS	# load frame buffer addres
	addi	$t0, $t0, 3972		# set pixel to be near the bottom left
	addi	$t1, $zero, 16		# t1 = 512 length of row

Bottom:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 8		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, Bottom	# repeat unitl pixel count == 0
	
	# left wall section
	la	$t0, BASE_ADDRESS	# load frame buffer address
	addi	$t1, $zero, 16		# t1 = 512 length of col

Left:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, Left	# repeat unitl pixel count == 0
	
	# Right wall section
	la	$t0, BASE_ADDRESS	# load frame buffer address
	addi	$t0, $t0, 252		# make starting pixel top right
	addi	$t1, $zero, 16		# t1 = 512 length of col

Right:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, Right	# repeat unitl pixel count == 0
	
	
	li $t1, 0x00ffff00 
	li $t3, 0x000000ff 
	li $t4, 0x00ff0000 
	li $t5, 0x0000ff00  
	li $t6, 0x00ff0000  
	li $t7, 0x0000ff00  
	li $t8, 0x0000ffff 

DrawShip:

	lw	$t0, yPos		# t0 = xPos of apple
	lw	$t2, width
	lw	$t3, xPos
	mult	$t2, $t0
	mflo	$t2
	add	$t2, $t2, $t3
	lw	$t3, four
	mult	$t2, $t3
	mflo	$t2
	la	$t3, BASE_ADDRESS
	add 	$t2, $t2, $t3
	sw 	$t1, 0($t2)
	addi	$t3, $t2, -128
	sw 	$t1, 0($t3)
	sw 	$t4, 4($t2)
	sw 	$t1, 128($t2)
	
	
gameUpdateLoop:
	jal	updateOb1
	jal	updateOb1
	lw	$t3, 0xffff0004		# get keypress from keyboard input
	
	### Sleep for 66 ms so frame rate is about 15
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 66	# 66 ms
	syscall
	
	beq	$t3, 100, moveRight	# if key press = 'd' branch to moveright
	beq	$t3, 97, moveLeft	# else if key press = 'a' branch to moveLeft
	beq	$t3, 119, moveUp	# if key press = 'w' branch to moveUp
	beq	$t3, 115, moveDown	# else if key press = 's' branch to moveDown
	beq	$t3, 112, restart		# start game
	j 	gameUpdateLoop

	
restart:
	jal	RemoveShip
	lw	$t0, yPos
	sw	$t0, shipY
	lw	$t0, xPos
	sw	$t0, shipX
	jal	RemoveOb1
#	sw	$zero, Ob1Y
	lw	$t0, ObX
	sw	$t0, Ob1Xn
	jal	updateShip
	
checkkey:
	lw	$t3, 0xffff0004		# get keypress from keyboard input
	### Sleep for 66 ms so frame rate is about 15
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 66	# 66 ms
	syscall
	
	bne	$t3, 112, main	# if key press = 'd' branch to moveright	
	j checkkey
	
moveUp:
	jal	RemoveShip
	lw	$t0, shipY
	li	$t1, 2
	beq	$t1, $t0, skipU
	addi	$t0, $t0, -1
	sw	$t0, shipY
skipU:
	jal	updateShip
	
	j	exitMoving 	

moveDown:
	jal	RemoveShip
	lw	$t0, shipY
	li	$t1, 29
	beq	$t1, $t0, skipD
	addi	$t0, $t0, 1
	sw	$t0, shipY
skipD:
	jal	updateShip
	
	j	exitMoving
	
moveLeft:
	jal	RemoveShip
	lw	$t0, shipX
	li	$t1, 1
	beq	$t1, $t0, skipL
	addi	$t0, $t0, -1
	sw	$t0, shipX
skipL:
	jal	updateShip
	
	j	exitMoving
	
moveRight:
	jal	RemoveShip
	lw	$t0, shipX
	li	$t1, 29
	beq	$t1, $t0, skipR
	addi	$t0, $t0, 1
	sw	$t0, shipX
skipR:
	jal	updateShip
	
	j	exitMoving

exitMoving:
	j 	gameUpdateLoop		# loop back to beginning

updateShip:

	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	li	$t1, 0x00ffff00
	li	$t4, 0x00ff0000
	lw	$t0, shipY		# t0 = xPos of apple
	lw	$t2, width
	lw	$t3, shipX
	mult	$t2, $t0
	mflo	$t2
	add	$t2, $t2, $t3
	lw	$t3, four
	mult	$t2, $t3
	mflo	$t2
	la	$t3, BASE_ADDRESS
	add 	$t2, $t2, $t3
	sw 	$t1, 0($t2)
	addi	$t3, $t2, -128
	sw 	$t1, 0($t3)
	sw 	$t4, 4($t2)
	sw 	$t1, 128($t2)

exitUpdateShip:
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code

RemoveShip:

	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	li	$t1, 0x00000000
	lw	$t0, shipY		# t0 = xPos of apple
	lw	$t2, width
	lw	$t3, shipX
	mult	$t2, $t0
	mflo	$t2
	add	$t2, $t2, $t3
	lw	$t3, four
	mult	$t2, $t3
	mflo	$t2
	la	$t3, BASE_ADDRESS
	add 	$t2, $t2, $t3
	sw 	$t1, 0($t2)
	addi	$t3, $t2, -128
	sw 	$t1, 0($t3)
	sw 	$t1, 4($t2)
	sw 	$t1, 128($t2)

exitRemoveShip:
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code

updateOb1:

	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	li	$t1, 0x00000000
	lw	$t0, Ob1Y		# t0 = xPos of apple
	lw	$t2, width
	lw	$t3, Ob1Xn
	li	$t4, 2
	beq	$t4, $t3, skipOb1update
	mult	$t2, $t0
	mflo	$t2
	add	$t2, $t2, $t3
	lw	$t3, four
	mult	$t2, $t3
	mflo	$t2
	la	$t3, BASE_ADDRESS
	add 	$t2, $t2, $t3
	sw 	$t8, 0($t2)
	addi	$t3, $t2, -8
	sw 	$t8, 0($t3)
	sw 	$t1, 4($t2)
	lw	$t3, Ob1Xn
	addi	$t3, $t3, -1
	sw	$t3, Ob1Xn
	j	exitUpdateOb1
skipOb1update:
	jal	RemoveOb1
	li $v0, 42
	li $a0, 1
	li $a1, 30
	syscall
	sw	$a0, Ob1Y
	lw	$t0, ObX
	sw	$t0, Ob1Xn
	
exitUpdateOb1:
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code

RemoveOb1:

	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	li	$t1, 0x00000000
	lw	$t0, Ob1Y		# t0 = xPos of apple
	lw	$t2, width
	lw	$t3, Ob1Xn
	mult	$t2, $t0
	mflo	$t2
	add	$t2, $t2, $t3
	lw	$t3, four
	mult	$t2, $t3
	mflo	$t2
	la	$t3, BASE_ADDRESS
	add 	$t2, $t2, $t3
	sw 	$t1, 0($t2)
	addi	$t3, $t2, -4
	sw 	$t1, 0($t3)
	sw 	$t1, 4($t2)

exitRemoveOb1:
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code

Exit:
	li $v0, 10	# exit the program
	syscall
