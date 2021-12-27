@ Christa Manges
@ chm0014@uah.edu
@ CS 309-01 Fall 2021
@ November 6, 2021

@ Purpose: Simulate the one-day operation of a simple teller machine.
@ The teller will dispense, upon request, $20, and $10 bills up to $200
@ total per customer.

@ File: tellermachine
@ Author: Christa Manges
@ History:
@	6-Nov-2021 Created original file.
@
@ Use these commands to assemble, link, run, and debug the program
@
@	as -o tellermachine.o tellermachine.s
@	gcc -o tellermachine tellermachine.o
@   ./tellermachine ;echo $?
@   gdb --args ./tellermachine



@********* List of What Registers Contain***************
@ r4 - amount of $20 bills in teller
@ r5 - amount of $10 bills in teller
@ r6 - total value of money in teller
@ r7 - amount of $20 bills withdrawn from teller
@ r8 - amount of $10 bills withdrawn from teller
@ r9 - number of valid transactions that have occured
@ r10 and r11 - registers for scratchwork.


.global main
main:

@**********
initialize:
@**********
@ Initialize the amount of bills in the teller.
@ r4 is the number of $20 bills and r5 is the number of $10 bills
@ Initial investory of bills is 50 of each type.  Also initialize 
@ in r6 the total amount of money in the machine.

	MOV r4, #50   @ There are 50 $20 bills to start.
	MOV r5, #50   @ There are 50 $10 bills to start.
	MOV r0, #20   @ The value of a $20 bill, used to determine the value of all $20 bills in next line.
	MUL r10, r4, r0   @ Use r10 for scratch work to determine the value of the $20 bills.
	MOV r0, #10  @ The value of a $10 bill, used to determine the value of all $10 bills in next line.
	MUL r11, r5, r0   @ Use r11 for scratch work to determine the value of the $10 bills.
	ADD r6, r10, r11  @ Add the values of the $20 bills and the values of the $10 bills to
	                @ determine the amount of money in the register; store result in r6
	MOV r7, #0      @ r7 is used to store the number of $20 bills distributed.
	MOV r8, #0      @ r8 is used to store the number of $10 bills distributed.
	MOV r9, #0      @ r9 is used to store the number of transactions completed
	                @ (not including invalid transactions).
					
	                     
@**********
welcome:
@**********	
@ Display a welcome message.  The prompt the user the enter a withdraw
@ request and give the user instructions on how to make a valid withdraw.

	LDR r0, =welcomeMessage  @ Prepare a welcome message to be printed.
	BL printf;  @ Print the welcome message.
	
@************
instructions:
@************
@ Prompt the user to enter a withdraw request and give the user instructions
@ on how to make a valid withdraw.

	LDR r0, =instructionMessage  @ Prepare a message to prompt the user to enter a valid withdraw request.
	BL printf;             @ Print the message that prompts the user to enter a valid withdraw request.
	
@************
readrequest:
@************
@ Read in the withdraw request.  If the special code of -9 is entered, display data about the teller.
@ Else, see if the withdraw request is greater than 200. 0, or negative, and ask again for the withdraw request if so.
@ Also check if the amount of funds in the teller is insufficient to fulfill the withdraw request, and
@ request a smaller withdraw if so.

	LDR r0, =numInputPattern  @ Prepare for the withdraw request to be read in.
	LDR r1, =withdrawInput    @ Load address where the withdraw request input will be stored.
	BL scanf                  @ Read in the withdraw request of the user.
	LDR r1, =withdrawInput    @ Load the adress of the withdraw request value into r6
	LDR r1, [r1]              @ Load actual value of the withdraw request into r1.
	CMP r1, #-9               @ See if -9 has been entered.
	BEQ secretcode            @ The secret code of -9 has been entered, so display data about the teller.
	CMP r1, #201              @ Test to see if the withdraw request is greater than $200 dollars
	BPL invalid               @ The input was greater than $200, so ask again for the withdraw request.
	CMP r1, #0                @ Set the flags for r1.
	BEQ invalid               @ The withdraw request is $0, so ask again for the withdraw request.
	BMI invalid               @ The withdraw request is negative, so ask again for the withdraw request.
	CMP r6, r1                @ Compare the amount of money in the teller to amount of the withdraw request.
	BMI insufficient          @ The amount in the teller is insufficient to fulfill the withdraw request.  
	

@*****************
divisiblebyten:
@*****************	
@ Check if the input is divisible by 10.  If not, prompt the user to enter a valid request.
	
	MOV r11, r1               @ Use r11 for scratchwork because do not want to change original withdraw request value.
	SUBS r11, #0              @ Set the flags for r11.

divisiblewhile:
	BEQ twentybills    @ Repeated subtraction by 10 of the withdraw request has resulted in a value of 0.
	                   @ The withdraw request is divisible by 10, so continue on to determine w
					   
	BMI invalid        @ Repeated subtraction by 10 of the withdraw request has resulted in a negative value
	                   @ without previously resulting in a value of 0.  Therefore the withdraw request is not
					   @ divisible by 10, so print a message saying the input is invalid and allow the user to
					   @ reenter input.
					   
	SUBS r11, #10      @ Perform the next subtracton of the withdraw request to see if it is divisible by 10.
	B divisiblewhile   @ Check again to see if divisiblity can be determined and act on that determination.  Else 
	                   @ subtract 10 again.
					   
					   
@***************
 twentybills:
@***************
@ Withdraw as many $20 bills as possible for the withdraw request.

	LDR r11, =withdrawInput   @ r11 is being used as a stratchwork register.  Load the address of the withdraw request.
	LDR r11, [r11]            @ Load the actual value of the withdraw request into r11.
	MOV r1, #0               @ r1 will hold the number of $20 bills given away for this transaction.
	
twentywhile:
	CMP r4, #0                @ Set the flags for the amount $20 bills in the teller.
	BEQ printtwenty              @ The teller is out of $20 bills.  Continue on to $20 bills
	CMP r11, #20              @ Compare the remaining value of the withdraw request with 20.
	BMI printtwenty              @ The actual value of the withdraw request minus 20 is negative, so no more $20 bills can be
	                          @ used in the withdraw amount.  Continue on to $10 bills.
	SUB r11, #20              @ Reduce the withdraw request by the amount of the $20 bill
	SUB r4, #1                @ Reduce the amount of $20 bills in the machine by 1.
    ADD r7, #1                @ Increase the amount of $20 bills given away by 1.
	ADD r1, #1               @ Keep track of the number of $20 bills given away for this transaction.
	B twentywhile             @ See if another $20 bill can fit into the remaining amount of the withdraw request.
	
@**********
printtwenty:
@***********
@ Print out the amount of $20 bills distributed for this transaction.
	
	LDR r0, =twentiesDist   @ Prepare to print out a message saying the numbers of twenties distributed.
	@ The number of $20 bills distributed is already stored in r1.
	BL printf               @ Print out the number of $20 bills distributed. 
	
	
@**********
tenbills:
@**********
@ Withdraw the remaining amount of the withdraw request as $10 bills.

	MOV r1, #0     @ Use r1 to store the number of $10 bills withdrawn for the current transaction.


tenwhile:
	CMP r11, #0 @ See if there is any remaining value of the withdraw request.
	BEQ printten            @ All of the money for the transaction has been withdrawn, so see if another
	                        @ transaction can be performed.
	SUB r11, #10            @ Reduce the withdraw request by the amount of the $20 bill
	SUB r5, #1              @ Reduce the amount of $10 bills in the machine by 1.
	ADD r8, #1              @ Increase the amount of $10 bills given away by 1.
	ADD r1, #1              @ Increase the number of $10 bills withdrawn for this transaction by 1.
	B tenwhile              @ See if another $10 bill can fit into the remaining amount of the withdraw request.
	
@**********
printten:
@**********
@ Print out the number of $10 bills distributed for this transaction.

	LDR r0, =tensDist   @ Prepare to print out a message saying the numbers of tens distributed.
	@ The number of $10 bills distributed is already stored in r1.
	BL printf               @ Print out the number of $10 bills distributed. 
	
	
@*****************
anothertransaction:
@*****************
@ Update the total amount of money in the teller and increase the number of transactions by 1.
@ If the number of transactions is 10 and/or the teller is out of money, output information about
@ the transactions for the day.  Else, start another transaction.

	ADD r9, #1  @ Increase the number of transactions by 1.

	LDR r1, =withdrawInput  @ Load the address of the original withdraw request into r1
	LDR r1, [r1]            @ Load the actual value of the original withdraw request into r1
	
	SUBS r6, r1             @ Subtract the amount of the withdraw request from the amount of money  
	                        @ in the teller.  This is the new amount of money in the teller and is 
							@ stored back in r1.
	BEQ finish              @ If the amount of money in the teller is the same as the amount of the 
	                        @ withdraw request, the teller is out of money.  Continue on to output
							@ information about the transactions for the day.
	
	CMP r9, #10             @ See if 10 transactions have been reached.
	BEQ finish              @ If 10 transactions has been reached, continue on to output information
	                        @ about the transactions for the day.
	
	B welcome  @ The teller still has money and less than 10 transactions have been performed, so
	           @ start another transaction.
			   

@**********
finish:
@**********
@ Print out a message saying the end of the day has been reached.  Then print out the 
@ total number of valid transactions, the number of $20 bills distributed, the number 
@ of $10 bills distributed, the total amount of money distributed, and the remaining
@ funds on hand.  The program then exits.
			
	LDR r0, =endday  @ Prepare message for printing that says the day has ended.
	BL printf        @ Print message that says the day has ended.
	
	LDR r0, =transactions  @ Prepare message for printing that says the total number
	                       @ of valid transactions.
	MOV r1, r9             @ Load the number of transactions into r1 to prepare for printing
	BL printf              @ Print message that says the total number of valid transactions.
	
	LDR r0, =twentiesDist  @ Prepare message for printing that says the total number of
	                       @ $20 bills distributed.
	MOV r1, r7             @ Load the number of $20 bills distributed into r1 to prepare for printing.
	BL printf              @ Print message that says the total number of $20 bills distributed.
	
	LDR r0, =tensDist      @ Prepare message for printing that says the total number of   
	                       @ $10 bills distributed.
	MOV r1, r8             @ Load the number of $10 bills distributed into r1 to prepare for printing.
	BL printf              @ Print message that says the total number of $10 bills distributed.
	
	MOV r0, #20           @ Value of $20 bill, used to determine value of all $20 bills in next line.
	MUL r10, r7, r0       @ Determine the value of the $20 bills distributed and store it in r10.
	MOV r0, #10            @ Value of $10 bill, used to determine value of all $10 bills in next line.
	MUL r11, r8, r0       @ Determine the value of the $10 bills distributed and store it in r11.
	ADD r1, r10, r11       @ Determine the total value of all bills distributed; store it in r1 to
	                       @ prepare for printing.
	LDR r0, =totalDist     @ Prepare message for printing that says the total amount of money distributed.
	BL printf              @ Print message that says the total amount of money distributed.
	
	LDR r0, =remaining     @ Prepare message for printing that says the remaining funds on hand.
	MOV r1, r6             @ Load the remaining amount of money in the teller into r1 to prepare for printing.
	BL printf              @ Print message that says the remaining funds on hand.
	
	mov r7, #0x01  @ SVC call to exit.
	svc 0          @ Make the system call.
	

	
@**********
invalid:
@**********
@ The withdraw request was invalid because of being greater than $200 or not
@ being a multiple of 10. 
@ Display a message saying the input was invalid and then return to prompting the
@ user for input.

	LDR r0, =invalidMessage      @ Set up message for printing saying the input was invalid.
	BL printf         @ Print out the message saying the input was invalid. 
	B instructions    @ Prompt the user again for input.
	
@************
insufficient:
@************
@ The withdraw request is larger than the amount of money in the teller.
@ Print a message to the user saying there is not enough money in the teller
@ and have them request a lower withdraw amount.

	LDR r0, =insufficientMessage @ Prepare a message for printing saying there are insufficient funds and 
	                  @ asking the user to enter a smaller withdraw request.
	MOV r1, r6        @ Prepare the amount of money in the teller to be printed.
	BL printf         @ Print out the message saying there are insufficient funds and 
	                  @ asking the user to enter a smaller withdraw request.
	B instructions    @ Prompt the user again for input.
	
@***********
secretcode:
@***********
@ The secret code of -9 has been entered as a withdraw request.  Display the inventory of
@ $20 and $10 bills, the remaining balance on hand, the current number of transactions,
@ and the total amount of distributions made so far. Then, ask for a withdraw request.

	LDR r0, =twentyInventory  @ Prepare a message for printing the inventory of $20 bills.
	MOV r1, r4                @ Load the number of $20 bills in the teller into r1 to prepare for printing.
	BL printf                 @ Print the message for the inventory of $20 bills.

	LDR r0, =tenInventory     @ Prepare a message for printing the inventory of $10 bills.
	MOV r1, r5                @ Load the number of $10 bills in the teller into r1 to prepare for printing.
	BL printf                 @ Print the message for the inventory of $10 bills.
	
	LDR r0, =remaining        @ Prepare a message for printing the remaining balance on hand.
	MOV r1, r6                @ Load the amount of money currently in the teller into r1 to prepare for printing.
	BL printf                 @ Print the message for the remaining balance on hand.
	
	LDR r0, =transactions     @ Prepare a message for printing the current number of transactions.
	MOV r1, r9                @ Load the current number of transactions into r1 to prepare for printing.
	BL printf                 @ Print the message for the current number of transactions.
	
	MOV r0, #20           @ Value of $20 bill, used to determine value of all $20 bills in next line.
	MUL r10, r7, r0       @ Determine the value of the $20 bills distributed and store it in r10.
	MOV r0, #10            @ Value of $10 bill, used to determine value of all $10 bills in next line.
	MUL r11, r8, r0       @ Determine the value of the $10 bills distributed and store it in r11.
	ADD r1, r10, r11       @ Determine the total value of all bills distributed; store it in r1 to
	                       @ prepare for printing.
	LDR r0, =totalDist     @ Prepare message for printing that says the total amount of money distributed so far.
	BL printf              @ Print message that says the total amount of money distributed so far.
	
	B welcome      @ Ask for a withdraw request.
	


.data

.balign 4
welcomeMessage:  .asciz "Welcome to the teller machine!\n" @ Welcome message for teller.

.balign 4
instructionMessage:   .asciz "Enter the amount of money in dollars to withdraw.\nThe amount can be up to $200 and must be a multiple of 10.\n"
@ Prompt for the user to enter a withdraw request.

.balign 4
numInputPattern:   .asciz "%d"  @ Create integer format to read in withdraw requests from the user.

.balign 4
withdrawInput:  .word 0  @ Space for the input of the withdraw request.

.balign 4
invalidMessage:       .asciz "The withdraw request was invalid.\n"  @ Message to tell the user their withdraw request was invalid.

.balign 4
insufficientMessage:  .asciz "There is not enough money in the machine.  The machine currently has $%d.\nPlease submit a smaller request.\n"

.balign 4
endday:    .asciz "The day has ended!\n"  @ Message to say that the day has ended.

.balign 4
transactions:  .asciz "Total number of valid transactions: %d\n" @ Message to print the total number of valid transactions.

.balign 4
twentiesDist:   .asciz "Number of $20 bills distributed: %d\n" @ Message to print the number of $20 bills distributed

.balign 4
tensDist:  .asciz "Number of $10 bills distributed: %d\n" @ Message to print the number of $10 bills distributed.

.balign 4
totalDist:  .asciz "Total amount of money distributed: $%d\n" @ Message to print the total amount of money distributed.

.balign 4
remaining:  .asciz "Remaining funds on hand: $%d\n"  @ Message to print the remaining amount of money in the teller.

.balign 4
twentyInventory: .asciz "Number of $20 bills in teller: %d\n"  @ Message to print the number of $20 bills in the teller.

.balign 4
tenInventory: .asciz "Number of $10 bills in teller: %d\n" @ Message to print the number of $10 bills in the teller.


@ Let the assembler know there are C library functions.

.global printf

.global scanf
