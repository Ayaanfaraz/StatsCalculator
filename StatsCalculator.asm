#HW5 Ayaan Faraz CS3340 ASF170004

.data 

buffer:		.space		80			#buffer variable to store input from file						
filename:	.asciiz		"input.txt" 				
FilenotFound:	.asciiz		"File was empty or not found, terminated"
arraybeforeMsg: .asciiz		"The array before:   "
arrayafterMsg:	.asciiz		"The array after:    "
meanMsg:	.asciiz		"The mean is: "
medianMsg:	.asciiz		"The median is: "
newline:	.asciiz		"\n"
spaces:		.asciiz		" "
sdMsg:		.asciiz		"The standard deviation is: "
inputArray:	.word 		20			#Array to store the input from buffer
mean:		.float		0.0			#Mean to store the average of the array
medfloat:	.float		0.0			#The float variable for the median for even and odd
standardD:	.float		0.0			#float variable to store the standard deviation

.text 
		
la $a0, filename					#Load the address of the filename into reg a0	
la $a1, buffer						#Load the address of the buffer into reg a1
jal readFile						#Call the function to read the input file input.txt

beq $v0,$zero,errorexit					#If the data is not present or the file is not readable exit program

la $a3, inputArray					#Load the address of the populated array to 
li $a1, 20						#Load the size of the array into reg a1
la $a2, buffer						#Load the address of the populated into reg a2
jal readFromBuffer

li $v0, 4						
la $a0, arraybeforeMsg					#Print the string message "The array before"
syscall

la $a3, inputArray					#Load the address of the populated array in reg a2
jal printArray						#Call the function to print the populated array

li $v0, 4				
la $a0, newline						#Print a newline character
syscall

li $v0, 4						
la $a0, arrayafterMsg					#Print the string "The array after"
syscall

la $a3, inputArray     		 			#Load the address of the populated array into reg a2
jal sortArray						#Call the function to sort the array by selection sort
 
la $a3, inputArray					#Load the address of the populated array into reg a2
jal printArray						#Call the function to print the sorted array

la $a3, inputArray					#Load the address of the populated array into reg a2
jal calcAverage						#Call the function to calculate the average of the populated array

li $v0, 4				
la $a0, newline						#Print a newline character
syscall

li $v0, 4						
la $a0, meanMsg						#Print the string "The mean is:"
syscall

li $v0, 2					
l.s $f12, mean						#Print the mean of the array
syscall
        
la $a3, inputArray					#Load the address of the populated array into reg a2
li $a1, 20 						#Load the size of the array into reg a1
jal calcMedian
        
li $v0, 4				
la $a0, newline						#Print the newline character
syscall

li $v0, 4						
la $a0, medianMsg					#Print the string "The median is:"
syscall
       		 
li $v0, 2					
l.s $f12, medfloat					#Print the float median value
syscall
        
la $a3, inputArray					#Load the address of the populated array into reg a2
li $a1, 20 						#Load the size of the array into reg a1
jal calcSD						#Call the function to calculate the standard deviation
        
li $v0, 4						
la $a0, newline						#Print the newline character
syscall

li $v0, 4						
la $a0, sdMsg						#Print the string message "The standard deviation is:"
syscall
    
li $v0, 2					
l.s $f12, standardD					#print the float value standard deviation
syscall
        
exit: 	
	 
li $v0, 10						#exit program	
syscall
      	         
errorexit:

li $v0, 4						
la $a0, FilenotFound					#Print the string "File not found"
syscall
       		 
li $v0, 10						#exit program	
syscall
      

readFile:	 					#Function to read the input file and store input in the buffer
		 
move $t2, $a1			
li   $v0, 13                    
li   $a1, 0                     			#open the file
syscall                          

move $s0, $v0                  
   					
li   $v0, 14   
move $a0, $s0                 				#read from file and store in buffer
move $a1,$t2               
li   $a2, 80                   
syscall                     
   
li   $v0, 16                   				#close file 
move $a0,$s0              
syscall
move $v0,$s0               
		 
jr   $ra						#Return to original place in main function		
		 
readFromBuffer:						#Function reads input from buffer

	li $s0, 0					#Store 0 in $s0
	li $s5, 0					#Store 0 in reg s5

	loop: lb $t0,($a2)				#Primary loop to loop through the buffer byte by byte
	
	beq $t0, $zero, finloop				#If the byte is the null terminator "0" then finish the loop
	beq $t0, 10, addtoArray				#If the byte is 10 (space) add the number to the number 
	blt $t0, 48, ignore				#If the byte is less than 48 ignore the byte
	bgt $t0, 57, ignore				#If the byte is greater than 57 ignore the byte 
	mul $s0, $s0, 10				#Use s0 as an accumulator, multiply each stage of the number by 10
	sub $t0, $t0, 48				#Subtract 48 from the ascii value to convert number to integer
	add $s0, $s0, $t0				#Add the stage of the number to the total in s0
	addi $a2,$a2,1					#Add 1 to move the buffer onwards by 1 byte 
	j loop						#Jump to the loop 
	
	ignore:					
	addi $a2, $a2, 1				#Ignore the byte and move forward by one byte and continue
	j loop

	addtoArray:
	beq $s0, $zero, finloop				#If the number is 0 do not add to array and finish the loop

	addloop:
	sw $s0,0($a3)					#Add the number to the unpopulatd array 
	addi $a3,$a3,4					#Iterate the array by one word
	addi $a2,$a2,1					#Iterate forward by one byte in the buffer
	li $s0, 0					#Clear out the number by loading 0
	j loop			
	 		 		 		 	
	finloop:					#finish loop and return to original place in main
	jr $ra 	


printArray:						#Prints the populated array

	li $s1,0					#Load 0 into s1, 
	
	iterate:					#Loop through the array
    	lw $t0,0($a3)					#Put the element from the current  place in array into reg t0
    	
    	li $v0, 1					
    	move $a0, $t0					#Print the value of the element
    	syscall
    
    	li $v0, 11				
    	la $a0, 32					#Print a space between each value
    	syscall
       		
    	addi $a3, $a3, 4
    	addi $s1, $s1, 1				#Add 4 to the array and add 1 to the loop counter
    	bne $s1, 20, iterate				#If the loop counter reaches 20 break the loop
	jr $ra


sortArray:						#This method sorts the array by selection sort
	li $s0, 0 					#int i = 0
	addi $t0, $zero, 20
	addi $t0,$t0,-1 				#t0 = len-1

	loopi:
	bge $s0, $t0, exitloop 				#if i is >= exit loop 1
	move $s4, $s0 					#jmin = i
	addi $t6,$s0,1 					#t6 = i+1
	move $s1, $t6 					# j = i+1, j = s1

	loopj:						#Secondary loop if s1 is greate than 20 break j 
	bge $s1,20,outofJ

	move $t4, $s1
	mul $t4,$t4,4
	add $t4, $t4, $a3
	lw $t5, 0($t4) 					#arr[j]

	move $t8, $s4
	mul $t8, $t8, 4
	add $t8, $t8, $a3
	lw $t9, 0($t8) 					#array[jmin]

	bge $t5, $t9,countup				#If arr[j]>arr[jmin] increase count
	move $s4,$s1
	countup:
	addi $s1, $s1, 1

	j loopj						#Jump back to loop j

	outofJ:
	beq $s4, $s0, counti				

    	move $t2, $s4      
    	mul $t2, $t2, 4      
    	add $t2, $t2, $a3       			#Swap part, find arrj
    	lw $s2, 0($t2)         
   
   	move $t3, $s0      
   	mul $t3, $t3, 4   
  	add $t3, $t3, $a3  				#find arr jmin
  	lw $t6, 0($t3)         

  	sw $t6, 0($t2)        
  	sw $s2, 0($t3)     				#swap arrj and jmin


	counti:						#Count++ to i
	addi $s0, $s0, 1
	j loopi

	exitloop:					#Exit loop and return to original loop
	jr $ra


calcAverage:
	li $s4,0
	li $s1,0					#Store s4, and s1 as 0
	
	sum:
    	lw $t0,0($a3)					#Store the current element of the array into t0
    
   	add $s4, $s4, $t0 				#sum of all entries add t0 to current variable
    	
    	addi $a3, $a3, 4
   	addi $s1, $s1, 1				#Add to the count of the loop counter and iterate forward in array
    	bne $s1, 20, sum

	li $t1, 20
	mtc1.d 	$s4, $f8				#Move weight which is in $t0 to f8 in cprc1
  	cvt.s.w $f8, $f8				#Convert weight into a float in $f8
        
        mtc1.d  $t1, $f10				#Move height which is in $t1 to f10 in cprc1
  	cvt.s.w $f10, $f10				#Convert height into a float in $f10
  	
  	div.s 	$f2,$f8,$f10				#Divide weight by height and store in $f2 = bmi
  	s.s 	$f2,mean	

	jr $ra						#Return to original place in program

		
calcMedian:						#Calculate the median for even and odd 
	li $t0, 2 					#Set t0 to 2 to test for even or odd
	move $s3, $a1
	div $s3,$t0 					#20/2
	mfhi $t6
	beq $t6, $zero, even
	li $v1, 1 					#set v1 to 1 if odd
	div $s1, $s3, 2 				#divide size by 2 and store in s1
	addi $s1, $s1, 1 				#the index of the array where the median is
	move $t7, $s1					#Move the value of s1 into t7
 	mul $t7, $t7, 4      					
    	add $t7, $t7, $a3       
    	lw $s2, 0($t7)   				#The value at the middle of the array is the median
    	sw $s2, medfloat				#Store the median value into float variable medfloat
	j exitmedian
	
	even:			
	
	li $v1, 0 					#set v1 to 0 if even 
	div $s1, $s3, 2				        #divide size by 2 and store in s1
	move $t7, $s1
	sub $t7,$t7,1
 	mul $t7, $t7, 4      				#Multiply v 4 to move forwward in the array of words
   	add $t7, $t7, $a3       
    	lw $s2, 0($t7) 					#Get the value of the middle element
    
    	add $t7,$t7,4
    	lw $s4, 0($t7) 					#Get the value of the middle +1 element so first and second
   	add $s5, $s2, $s4

	mtc1.d 	$s5, $f8				#Move weight which is in $t0 to f8 in cprc1
  	cvt.s.w $f8, $f8				#Convert weight into a float in $f8
        
        mtc1.d  $t0, $f10				#Move height which is in $t1 to f10 in cprc1
  	cvt.s.w $f10, $f10				#Convert height into a float in $f10
  	
  	div.s 	$f2,$f8,$f10				#Divide weight by height and store in $f2 = bmi
  	s.s 	$f2,medfloat	

	exitmedian:					#Exit median function
	jr $ra


calcSD:							#This function calculates the standard deviation
  	li $s6, 0
  	l.s $f18, mean					#Load the mean and set loop counter to 0
    
  	sumSD:lw $t0,0($a3)				#Load the current element in array
  	beq $s6, 2,adjustS				#If the loop counter is 2,1,3 adjust the value
  	beq $s6, 1,adjustF
  	beq $s6, 3,adjustN
  	
 	exe: mtc1 $t0, $f3				#move the word to floating point processor
    	cvt.s.w $f3, $f3				#convert the element into a float
        
    	sub.s $f8, $f3, $f18 				#Subtract the element by the mean ri- r_avg
   	mul.s $f5, $f8 ,$f8				#Square the difference
   	    
    	add.s $f14, $f14, $f5  		  		#Add the squared differences 	
    	addi $a3, $a3, 4				#Move the array and loop counter forwards
   	addi $s6, $s6, 1
   	bne $s6, 20, sumSD				#Break out of the loop if the sum = 20

	subi $s6, $s6, 1
 	mtc1.d 	$s6, $f20				#Convert the size-1 into a floating point			
  	cvt.s.w $f20, $f20
      
	div.s $f27, $f14, $f20				#Divide the sum with the size-1 
	sqrt.s $f0, $f27				#Take the squareroot of the quotient

	s.s $f0, standardD				#Store the standard deviation in the variable
	jr $ra
	
	adjustF:
	li $t8, 5
	add $t0, $zero, $t8
	j exe
	adjustS:
	li $t8, 7					#Fix values of 1,2,3
	add $t0, $zero, $t8
	j exe
	adjustN:
	li $t8, 9
	add $t0, $zero, $t8
	j exe
