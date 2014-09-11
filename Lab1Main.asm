;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section

Testing:	.byte		0x11, 0x11, 0x11, 0x11, 0x11, 0x44, 0x22, 0x22, 0x22, 0x11, 0xCC, 0x55
ADD_OP:		.equ		0x11
SUB_OP:		.equ		0x22
MUL_OP:		.equ		0x33
CLR_OP:		.equ		0x44
END_OP:		.equ		0x55
MAX:		.equ		255
MIN:		.equ		0
			.data
RESULTS:	.space		40
			.text
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
start:										; Initialize the calculator by placing test values into ROM
			mov		#Testing, r5
			mov		#RESULTS, r6
			mov.b	@r5+,	  r7

look:										; Take a look at the test values to determine operations
			mov.b	@r5+,	  r8
			mov.b	@r5+,	  r9

choose:										; Choose which operation to conduct based on test values
			cmp.b	#ADD_OP,  r8
			jz		 addop
			cmp.b	#SUB_OP,  r8
			jz		 subop
			cmp.b	#CLR_OP,  r8
			jz		 clrop
			jmp 	 END

addop:										; Adding operation
			add.b r9, r7
			jc	  MAX_VALUE
			jmp	  RAM

subop:										; Subtracting operation
			sub  r9, r7
			jn	  MIN_VALUE
			jmp   RAM

clrop:										; Clear operation
			mov.b r9, r7
			mov.b #MIN, 0(r6)
			inc   r6
			jmp	  look

MIN_VALUE:
			clr	  r7
			jmp	  RAM

MAX_VALUE:
			mov.b #MAX, r7

RAM:
			mov.b  r7, 0(r6)
			inc    r6
			jmp    look

END:
			jmp END


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
