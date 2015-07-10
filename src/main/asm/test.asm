	.data errorText "error ",0
	.data allPassedText "all passed!",0
	
	.word DATA1
	.word DATA2

	.data errFlagText "errFlag set: ",0

	.const TERMINAL_PORT 0x1f

	.reg errNum R7
	.reg errFlag R8

;   test LDI CPI   0x0000
	LDI errNum,0x0000
	XOR r0,r0
	LDI r0,5
	cpi r0,5
	brz _SKIP_ADDR_
	jmp error
	cpi r0,4
	brnz _SKIP_ADDR_
	jmp error
	cpi r0,4
	brnz _SKIP_ADDR_
	jmp error
	LDI R0,1
	DEC R0
	brz _SKIP_ADDR_
	jmp error

;         test ADD 0x0001
	LDI errNum,0x0001 		
	LDI r0,7
	LDI r1,5
	ADD r0,r1
	cpi r0,5+7
	brz _SKIP_ADDR_
	jmp error

	LDI r0,30
	LDI r1,30
	ADD r0,r1
	cpi r0,60
	brz _SKIP_ADDR_
	jmp error

;         test SUB 0x0002
	LDI errNum,0x0002 		
	LDI r0,7
	LDI r1,5
	SUB r0,r1
	cpi r0,7-5
	brz _SKIP_ADDR_
	jmp error

	LDI r0,35
	LDI r1,33
	SUB r0,r1
	cpi r0,2
	brz _SKIP_ADDR_
	jmp error

;         test ADC 0x0003
	LDI errNum,0x0003 		
	LDI r0,7
	LDI r1,5
	LDI r2,1
	LSR r2
	ADC r0,r1
	cpi r0,7+5+1
	brz _SKIP_ADDR_
	jmp error

;         test SBC 0x0004
	LDI errNum,0x0004 		
	LDI r0,7
	LDI r1,5
	LDI r2,1
	LSR r2
	SBC r0,r1
	cpi r0,7-5-1
	brz _SKIP_ADDR_
	jmp error

;         test ASR 0x0005
	LDI errNum,0x0005 		
	LDI r0,-1
	ASR r0
	cpi r0,-1
	brz _SKIP_ADDR_
	jmp error
	LDI r0,0x7fff
	ASR r0
	cpi r0,0x3fff
	brz _SKIP_ADDR_
	jmp error
	LDI r0,0x1
	ASR r0
	brc _SKIP_ADDR_
	jmp error
	ASR r0
	brnc _SKIP_ADDR_
	jmp error


;        test SWAP 0x0006
	LDI errNum,0x0006 		
	LDI r0,0x1234
	swap r0
	cpi r0,0x3412
	brz _SKIP_ADDR_
	jmp error
	LDI r0,0x1234
	swapn r0
	cpi r0,0x2143
	brz _SKIP_ADDR_
	jmp error


;       test RCALL 0x0007
	LDI errNum,0x0007
	cpi errFlag,0
	brz _SKIP_ADDR_
	jmp error
	ldi errFlag,1	
	rcall r0,c1
c1:	LDI r1,_ADDR_
	ldi errFlag,0	
	cmp r1,r0
	brz _SKIP_ADDR_
	jmp error

;       test RRET 0x0008
	LDI errNum,0x0008
	cpi errFlag,0
	brz _SKIP_ADDR_
	jmp error
	LDI r0,c2
	ldi errFlag,2
	RRET r0
	jmp error
c2:	ldi errFlag,0


;       test MUL   0x0009
	LDI errNum,0x0009 		
	LDI R0,7
	MULI r0,3
	cpi R0,3*7
	brz _SKIP_ADDR_
	jmp error
	LDI R0,7
	MULI r0,40
	cpi R0,40*7
	brz _SKIP_ADDR_
	jmp error
	LDI R0,7
	LDI R1,3
	MUL r0,r1
	cpi R0,3*7
	brz _SKIP_ADDR_
	jmp error

;       test LD    0x000A
	LDI errNum,0x000A
	LDI R0,5
	STS R0,DATA1
	INC R0 
	STS R0,DATA2
	LDS R1,DATA1
	cpi R1,5
	brz _SKIP_ADDR_
	jmp error
	LDS R1,DATA2
	cpi R1,6
	brz _SKIP_ADDR_
	jmp error
	LDI R3,DATA1
	LD R4,R3
	cpi R4,5
	brz _SKIP_ADDR_
	jmp error
	inc r3
	LD R4,R3
	cpi R4,6
	brz _SKIP_ADDR_
	jmp error

;       test ST    0x000B
	LDI errNum,0x000B
	LDI R3,DATA1
	LDI R0,5
	ST R3,R0
	INC R0
	INC R3
	ST R3,R0
	LDS R2,DATA1
	cpi R2,5
	brz _SKIP_ADDR_
	jmp error
	LDS R2,DATA2
	cpi R2,6
	brz _SKIP_ADDR_
	jmp error
	
;       test LDO   0x000C
	LDI errNum,0x000C
	LDI R0,15
	STS R0,DATA1
	LDI R0,DATA1-4
	LDO R1,R0,4
	cpi R1,15
	brz _SKIP_ADDR_
	jmp error

;       test STO   0x000D
	LDI errNum,0x000D
	LDI R0,16
	LDI R1,DATA2-4
	STO R1,R0,4
	LDS R1,DATA2
	cpi R1,16
	brz _SKIP_ADDR_
	jmp error

; if this statement is reached all tests are passed

	cpi errFlag,0    ; check errflag
	brz ok
	ldi r0,errFlagText
	_call textOutR0
	mov r0,errFlag
	_call hexOutR0
	brk
	jmp _ADDR_	; if ok do nothing

ok:	ldi r0,allPassedText
	_call textOutR0

	jmp _ADDR_	; if ok do nothing

; is called if an error ocured
error:	ldi r0,errorText
	_call textOutR0

	MOV r0,errNum
	_call hexOutR0

	brk		; on error set a break!
	jmp _ADDR_

; write text to console R0 points to 
	.reg TEXT r0 ; text addr
	.reg CHAR r1 ; a single character
textOutR0:
 	LD CHAR, TEXT
	out CHAR,TERMINAL_PORT
	inc TEXT
	cpi CHAR,0
	brnz textOutR0
	ret

; write R0 to console as 4 digit hex number
	.reg DATA r0  ; data
	.reg DIGIT r1 ; a single digit
	.reg CREG r2  ; return adress register

hexOutR0: 
	swap DATA
	swapn DATA
	RCALL CREG,hexDigitOutR0
	swapn DATA
	RCALL CREG,hexDigitOutR0
	swap DATA
	swapn DATA
	RCALL CREG,hexDigitOutR0
	swapn DATA
	RCALL CREG,hexDigitOutR0
	ret

; write R0 to console as 1 digit hex number
hexDigitOutR0: 
	mov DIGIT,DATA
	andi DIGIT,0xf
	cpi DIGIT,10
	brnc h3      ; larger then 10
	addi DIGIT,'0'
	jmp h4
h3:	addi DIGIT,'A'-10
h4:	out DIGIT,TERMINAL_PORT
	rret CREG