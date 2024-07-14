# the data segment must have the following format exclusively
# no additions or changes to the data segment are permitted
.data
smallArray:		.word 3, 1, 8, 5, 2
findSmallVal: 		.word 1, 4, 8
foundSmallValAddr: 	.word 0, 0, 0

bigArray:		.word 8, 3, 13, 21, 34, 89, 2, 5, 1, 55
findBigVal:		.word 13, 100, 89, 34, 9 
foundBigValAddr:	.word 0, 0, 0, 0, 0


# The .text region must be structured with a main label 
# followed by any named procedures or other labels you create
# for branching and jumping followed by the exit label at the 
# very bottom of the program.
   		 
.text
main:
# PART 1: Implement quick sort here

la x22, findBigVal
la x23, foundBigValAddr

j small_array

small_array:
li s10, 0
li s11, 1
la x10, smallArray	
addi x11, x0, 0		#x11 is the starting address of the array
addi x12, x0, 4		#last number, starting pivot position
jal ra, quicksort
jal ra, big_array


partition:
addi sp, sp, -4
sw ra, 0(sp)

#x11 is loaw a1
#x12 is high a2
slli t0, x12, 2
add t0, t0, x10
lw t0, 0(t0)		#pivot = smallArray[top]
add t1, x11, x0		#j = low
addi t2, x11, -1	#i = lower - 1

partition_for_loop:
beq t1, x12, end_partition #branch if j = high

slli t3, t1, 2		#j * 4 gets to the address of Array[j]
add x13, t3, x10	#array + 7
lw t3, (x13)		#load the word in address of t4
blt t3, t0, partition_if	#if smallArray[j] < pivot
j end_partition_for_loop

partition_if:
addi t2, t2, 1		#increment index of the smaller element
slli t4, t2, 2		#i * 4 gets to the address of smallArray[i]
add x14, t4, x10
lw t4, (x14)

sw t4, (x13)		#&array[i] => &array[j]
sw t3, (x14)		#&array[j] => &array[i]

end_partition_for_loop:
addi t1, t1, 1		#j++
j partition_for_loop

end_partition:
addi t2, t2, 1		#i++
slli t3, t2, 2		#gets t1 to be the address of i * 4 (since word)
add x14, t3, x10	#address of the array + i+1
lw t3, 0(x14)		#t2 = the word in the address of array[i +1]


slli t1, x12, 2		#get the address of the end
add x13, t1, x10	#address with array
lw t1, (x13)		#x14 = the word in the address of hte pivbor

sw t3, (x13)		#&array[i] => &array[j]
sw t1, (x14)		#&array[j] => &array[i]

addi x10, t2, 0

lw ra, 0(sp)
addi sp, sp, 4
jalr x0, ra, 0


quicksort:
#x10 is low
#x11 is high
#x10 is low
#x11 is high
#addi sp, sp, -4
#sw s0, 0(sp)
#add s0, x10, x0		#address of array
#sw s1, 4(sp)
#add s1, x11, x0		#first word
#sw s2, 8(sp)
#add s2, x12, x0		#last word
#sw s3, 12(sp)		#pi
#sw ra, 0(sp)
blt x11, x12, quicksort_if	#low < high
#lw s0, 0(sp)
#lw s1, 4(sp)
#lw s2, 8(sp)
#lw s3, 12(sp)


#addi sp, sp, 4
jalr x0, 0(ra)

quicksort_if:
addi sp, sp, -4
add s0, x10, x0		#address of array
add s1, x11, x0		#first word
add s2, x12, x0		#last word
sw ra, 0(sp)
jal ra, partition
add s3, a0, x0		#pi

add x10, s0, x0		#arr
add x11, s1, x0		#start
addi x12, s3, -1	#pi-1
jal ra, quicksort  	#quicksort(arr, start, pi - 1)

add x10, s0, x0		#array
addi x11, s3, 1		#pi+1
add x12, s2, x0		#end
jal ra, quicksort  	#quicksort(arr, pi + 1, end)

big_array:
beq s10, s11, binary_small
addi s10, s10, 1
la x10, bigArray
addi x11, x0, 0
addi x12, x0, 9	#last number
jal ra, quicksort
jal ra, exit

# PART 2: Implement binary search (recursive method) here
binary_small:

j small_test

binary_search:
#x10 is the array
#x11 is low, l
#x12 is high, r
#x13 is x, being searched for
bgt x11, x12, binary_close

#addi t1, x0, -1
#mul t5, x11, t1		#-l
#add t2, t5, x12		#r-l
add s2, x11, x12		#l + (r-l)
srai s2, s2, 1		#mid = l + (r-l) / 2

slli s3, s2, 2		#bits of s2 (mid *4)
add s4, x10, s3		#getting to word
lw s3, 0(s4)		#loading that word into s3
beq s3, x14, equal	#arr[mid] == x

bgt s3, x14, greater_than

addi x11, s2, 1		#x11 becomes mid + 1
j binary_search

equal:
mv a0, s4	#put address of value in arr in a0
jalr x0, 0(ra)
#returns mid, which is x (or its address)

greater_than:
addi x12, s2, -1
j binary_search

binary_close:
li a0, -1
jalr x0, 0(ra)

# PART 2a: Test binary search using smallArray
small_test:
la x13, findSmallVal
la x15, foundSmallValAddr
li x16, 3		#max size of findSmallVal
li t3, 0		#i

small_loop:
beq  x16, t3, big_test	#if i = len(findsmallval)
la x10, smallArray	
addi x11, x0, 0		#x11 is 0
addi x12, x0, 4		#last number, starting pivot position
slli t0, t3, 2			#i * 4
add t1, t0, x13		#get to the array
lw x14, 0(t1) 		#load the number at ith position of findSmallVal, this is the number being searched for, x
jal ra, binary_search	#this should load if the value is in the array
add t1, t0, x15		#get to the ith location in memory on the foundsmallval addr
sw x10, 0(t1)		#store the result from binary search in the ith location in memory on foundsmallval
addi t3, t3, 1		#i++
j small_loop


# Part 2b: Test binary search using bigArray
# subroutines or other branching labels go herwe
big_test:
la x13 findBigVal
la x15, foundBigValAddr
li x16, 5
li t3, 0

big_loop:
beq x16, t3, exit #if i = len(findsmallval)
la x10, bigArray
addi x11, x0, 0		#x11 is 0
addi x12, x0, 9		#last number, starting pivot position
slli t0, t3, 2
add t1, t0, x13
lw x14, 0(t1)		#load the number at ith position of findBigVal, this is the number being searched for, x
jal ra, binary_search
add t1, t0, x15
sw x10, 0(t1)		#store the result from binary search in the ith location in memory on foundbigval
addi t3, t3, 1
j big_loop

exit:
la x10, bigArray
li a7, 10
ecall
