#2015113233 KimHyunWoo
#2015113233 KimHyunWoo

## Data for the program:
	.data
EnterMsg:	.asciiz "Enter the number: "
array:		.space 1024		#2^32 => 10spaces
point:		.asciiz "."
IntegerMsg:	.asciiz "Integer number detected"
FloatMsg:	.asciiz "Floating point number detected"
overflow_msg:	.asciiz "OverFlow\n"	
newline:	.asciiz "\n"
HalfMsg:	.asciiz "Half of the input number: "
blank:		.asciiz " "
InputMsg:	.asciiz "Input string: "
BinaryMsg:	.asciiz "Binary number: "
HexaMsg	:	.asciiz "Hexa number: "		#data for FP
FZero:		.float	0.0
FOne:		.float 	1.0
FMOne:		.float	-1.0
FTen:		.float	10.0
FMTen:		.float	0.1
FTwo:		.float 	2.0


##
	.text
main: 
	li	$v0, 4
	la	$a0, EnterMsg
	syscall			#print message
	
	la	$a0, array	#$a1 == &array
	li   	$a1, 1024
	li	$v0, 8		#string press
	syscall
	la	$a0, InputMsg
	li	$v0, 4
	syscall
	li	$v0, 4
	la	$a0, array
	syscall
	
	la 	$s0, array
	
	#addi	$s0, $a0, 0		#load the address of array to $s0
	move	$t3, $a0
	
	addi	$t2, $zero, 10		#$t2 is  null (\n)	for asciiz
	addi	$t9, $zero, 46		#$t0 is "."
	#li	$t1, $a0, 0		#array adress is in $t1 
	
	b	 loop
	
loop:	
	lb	$t5, 0($t3)
	beq	$t5, $t9, Float		#if array doesn't have ".", go to Int 
	addi	$t3, $t3, 1		#array's address ++1
	beq	$t5, $t2, Int		#if $t5 (array) is "\n", go to Int
	b	loop
	
Float:	
	li	$v0, 4
	la	$a0, FloatMsg
	syscall			#print message
	
	addi	$s3, $s3, 4	#FP is -> s3 = 4
	lwc1	$f2, FZero	#t2 initialize to 0
	li	$t2, 0
	b 	get_signF	#Stirng to FP
Int:	
	li	$v0, 4
	la	$a0, IntegerMsg
	syscall			#print message
	
	li	$t2, 0		# t2 initialize to 0
	b	get_sign	#String to Int
	
get_signF:
	lwc1	$f7, FZero
	lwc1	$f6, FZero
	lwc1	$f3, FOne
	lb	$t1, ($s0)	#check the first Character for (- or +)
	bne	$t1, '-', positiveF
	lwc1	$f3, FMOne
	addu	$s0, $s0, 1
positiveF:
	lwc1	$f4, FTen
	lwc1	$f5, FMTen
	lwc1	$f8, FMTen
sum_loopF:
	lb	$t1, ($s0)
	addu	$s0, $s0, 1
	beq	$t1, $t9, sum_loop2F	#$t9 == "."

	#mtc1	$t2, $f2 		#int to fp
	#cvt.s.w	$f2, $f2 		#convert from integer to single precision FP
	#mul.s	$f2, $f2, $f4
		
	#cvt.w.s	$f2, $f2	
	#mfc1	$t2, $f2		#fp to int
	
	sub	$t1, $t1, '0'
	move	$t2, $t1
	
	mtc1	$t2, $f2 		#int to fp
	cvt.s.w	$f2, $f2 		#convert from integer to single precision FP
	mul.s	$f6, $f6, $f4
	add.s 	$f6, $f6, $f2
		
	b	sum_loopF
sum_loop2F:
	lb	$t1, ($s0)
	addu	$s0, $s0, 1
	
	beq	$t1, 10,  end_sum_loopF	#if $t1 == \n, branch out of loop
	blt	$t1, '0', end_sum_loopF	#make sure 0<= t1
	bgt	$t1, '9', end_sum_loopF 	#make sure 9>= t1
	
	sub	$t1, $t1, '0'
	move	$t2, $t1
	
	mtc1	$t2, $f2 		#int to fp
	cvt.s.w	$f2, $f2 		#convert from integer to single precision FP
	mul.s	$f2, $f2, $f5
	add.s 	$f7, $f7, $f2
	mul.s	$f5, $f5, $f8
	
	b	sum_loop2F
	
end_sum_loopF:
	la	$a0, newline
	li	$v0, 4
	syscall
	
	add.s	$f6, $f6, $f7
	mul.s	$f6, $f6, $f3	#sign? -1 : 1
	

	#addi	$a0, $t2, 0
	#li	$v0, 1
	#syscall
	b	FPmakehalf
	
get_sign:
	li	$t3, 1
	lb	$t1, ($s0)
	bne	$t1, '-', positive
	li	$t3, -1
	addu	$s0, $s0, 1
	li	$t4, 10
	b	sum_loopM
sum_loopM:
	lb	$t1, ($s0)
	addu	$s0, $s0, 1
	
	##use 10 instead of '\n' due to SPIM bug
	beq	$t1, 10, end_sum_loopM	#if $t1 == \n, branch out of loop
	
	blt	$t1, '0', end_sum_loopM#make sure 0<= t1
	bgt	$t1, '9', end_sum_loopM #make sure 9>= t1
	
	mul	$t2, $t2, $t4
	
	mflo	$t2
	
	sub	$t1, $t1, '0'
	mul	$t1, $t1, $t3	#sign? -1 : 1
	add	$t2, $t2, $t1
	
	b	sum_loopM
end_sum_loopM:
	
	la	$a0, newline
	li	$v0, 4
	syscall

	move	$s2, $t2
	
	b	Intmakehalf
	
positive:
	li	$t4, 10
sum_loop:
	lb	$t1, ($s0)
	addu	$s0, $s0, 1
	
	##use 10 instead of '\n' due to SPIM bug
	beq	$t1, 10, end_sum_loop	#if $t1 == \n, branch out of loop
	
	blt	$t1, '0', end_sum_loop	#make sure 0<= t1
	bgt	$t1, '9', end_sum_loop #make sure 9>= t1
	
	mult	$t2, $t4
	
	mflo	$t2
	blt	$t2, $0, overflow
	
	sub	$t1, $t1, '0'
	add	$t2, $t2, $t1
	blt	$t2, $0, overflow
	
	b	sum_loop
end_sum_loop:
	mul	$t2, $t2, $t3	#sign? -1 : 1
	
	la	$a0, newline
	li	$v0, 4
	syscall
	#addi	$a0, $t2, 0
	#li	$v0, 1
	#syscall
	move	$s2, $t2
	
	b	Intmakehalf
	
overflow:
	la	$a0, newline
	li	$v0, 4
	syscall
	la	$a0, overflow_msg
	li	$v0, 4
	syscall
	b	exit
	
Intmakehalf:
	li	$t4, 2
	div	$t3, $s2, $t4	#divide by 2 
	#mflo	
	
	la	$a0, HalfMsg
	li	$v0, 4
	syscall			#print message
	
	move	$a0, $t3
	li	$v0, 1
	syscall
	la	$a0, newline
	li	$v0, 4
	syscall
	
	la	$a0, BinaryMsg
	li	$v0, 4
	syscall
	b	Tobin
	
FPmakehalf:
	lwc1	$f4, FTwo
	div.s	$f7, $f6, $f4	#divide by 2 
	
	la	$a0, HalfMsg
	li	$v0, 4
	syscall			#print message
	
	li 	$v0, 2
	mov.s	$f12, $f7
	syscall

	la	$a0, newline
	li	$v0, 4
	syscall

	mfc1 	$s2, $f6
	cvt.w.s	$f6, $f6
	
	la	$a0, BinaryMsg
	li	$v0, 4
	syscall
	b	Tobin
	
Tobin:
	li 	$t1, 1		#$t1 == cnt
	li	$t3, 31		#$t3 == i
	li	$t8, 4		#$t8 == 4
	li	$t9, 1
	move	$t4, $s2	#$s2 -> $t4 (number)
	b	TobinLoop
	
TobinLoop:		
	srlv 	$t5, $t4, $t3	#$t5 = $t4 >> $t3
	andi	$t5, $t5, 1	#$t5 = $t5 & 1
	div	$t1, $t8	#$t7 == cnt/4
	mfhi 	$t7
	beq	$t7, 1, Blank1	#if $t7 == 0 ->printf " "
	
	move	$a0, $t5	#else print $t5	
	li	$v0, 1
	syscall			
	beq	$t3, 0, ToHHH	#if $t3 == 0 -> break
	addi	$t3, $t3, -1	#else $t3 = $t3 - 1
	addi	$t1, $t1, 1	#$t1++
	b	TobinLoop	#b TobinLoop
	
Blank1:
	la	$a0, blank	#printf " "
	li	$v0, 4
	syscall
	
	move	$a0, $t5	#else print $t5	
	li	$v0, 1
	syscall	
	
	beq	$t3, 0, ToHHH	#if $t2 == 0 -> break
	addi	$t3, $t3, -1	#else $t2 = $t2 - 1
	addi	$t1, $t1, 1	#$t1++
	b 	TobinLoop
ToHHH:
	la	$a0, newline
	li	$v0, 4
	syscall
	la	$a0, HexaMsg
	li	$v0, 4
	syscall
	b	Tohex
Tohex:
	li 	$t1, 1		#$t1 == cnt
	li	$t3, 28		#$t3 == i
	li	$t8, 2		#$t8 == 2
	li	$t9, 1
	move	$t4, $s2	#$t2 -> $t4 (number)
	b	TohexLoop
	
TohexLoop:		
	srlv 	$t5, $t4, $t3	#$t5 = $t4 >> $t3
	andi	$t5, $t5, 15	#$t5 = $t5 & 15
	div	$t1, $t8	#$t7 == cnt/2
	mfhi 	$t7
	beq	$t7, 1, Blank2	#if $t7 == 0 ->printf " "
	
	bge	$t5, 10, Ascii	#t5 >= 10 -> Ascii
	
	move	$a0, $t5	#else print $t5	
	li	$v0, 1
	syscall	
			
	beq	$t3, 0, exit	#if $t3 == 0 -> break
	addi	$t3, $t3, -4	#else $t3 = $t3 - 4
	addi	$t1, $t1, 1	#$t1++
	b	TohexLoop	#b TobinLoop
	
Blank2:
	la	$a0, blank	#printf " "
	li	$v0, 4
	syscall
	
	bge	$t5, 10, Ascii	#t5 >= 10 -> Ascii
	
	move	$a0, $t5	#else print $t5	
	li	$v0, 1
	syscall		
		
	beq	$t3, 0, exit	#if $t3 == 0 -> break
	addi	$t3, $t3, -4	#else $t3 = $t3 - 4
	addi	$t1, $t1, 1	#$t1++
	b	TohexLoop	#b TobinLoop
Ascii:
	addi	$t5, $t5, 55
	move	$a0, $t5	#else print $t5	
	li	$v0, 11
	syscall		
		
	beq	$t3, 0, exit	#if $t3 == 0 -> break
	addi	$t3, $t3, -4	#else $t3 = $t3 - 4
	addi	$t1, $t1, 1	#$t1++
	b	TohexLoop	#b TobinLoop
exit:
	li	$v0, 10
	syscall

#2015113233 KimHyunWoo
#2015113233 KimHyunWoo
#2015113233 KimHyunWoo
#2015113233 KimHyunWoo
