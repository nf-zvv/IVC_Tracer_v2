;------------------------------------------------------------------------------
; Graphic LCD with Toshiba T6963 controller
; 
; 
; (C) 2019-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; History
; =======
; 22.05.2019 initial
; 
;------------------------------------------------------------------------------

.include "t6963c_config.inc"
.include "t6963c_codes.inc"

.ifndef __zero_reg__
.def __zero_reg__ = r2
.endif

.ifndef __tmp_reg__
.def __tmp_reg__ = r16
.endif

#define T6963C_LEGACY 0
#define CG_ROM_MODE   0


;------------------------------------------------------------------------------
; Init GLCD
;
; USED: __tmp_reg__*, r16*, [r17*], r18*
; CALL: WaitMiliseconds, [T6963C_CheckStatus], T6963C_WriteData, T6963C_WriteCommand
; IN: -
; OUT: -
;------------------------------------------------------------------------------
T6963C_Initalize:
			ldi		__tmp_reg__,0xFF
			out		GLCD_DATA_DDR,__tmp_reg__

			ldi		__tmp_reg__,(1 << GLCD_WR)|(1 << GLCD_RD)|(1 << GLCD_CE)|(1 << GLCD_CD)|(1 << GLCD_RESET)|(1 << GLCD_FS)
			out		GLCD_CTRL_DDR,__tmp_reg__

			in		__tmp_reg__,GLCD_CTRL_PORT
			ori		__tmp_reg__,(1 << GLCD_WR)|(1 << GLCD_RD)|(1 << GLCD_CE)|(1 << GLCD_CD)|(1 << GLCD_RESET)|(1 << GLCD_FS)
			out		GLCD_CTRL_PORT,__tmp_reg__
		
			cbi		GLCD_CTRL_PORT,GLCD_RESET	; LCD RESET LOW
			ldi		r16,1
			rcall	WaitMiliseconds
			sbi		GLCD_CTRL_PORT,GLCD_RESET	; LCD RESET HI

			#if GLCD_FONT_WIDTH == 8
			cbi		GLCD_CTRL_PORT,GLCD_FS
			#endif
			
			ldi		r18,low(GLCD_GRAPHIC_HOME)
			rcall	T6963C_WriteData
			ldi		r18,high(GLCD_GRAPHIC_HOME)
			rcall	T6963C_WriteData
			ldi		r18,T6963_SET_GRAPHIC_HOME_ADDRESS
			rcall	T6963C_WriteCommand
			
			ldi		r18,GLCD_GRAPHIC_AREA
			rcall	T6963C_WriteData
			ldi		r18,0x00
			rcall	T6963C_WriteData
			ldi		r18,T6963_SET_GRAPHIC_AREA
			rcall	T6963C_WriteCommand
			
			ldi		r18,low(GLCD_TEXT_HOME)
			rcall	T6963C_WriteData
			ldi		r18,high(GLCD_TEXT_HOME)
			rcall	T6963C_WriteData
			ldi		r18,T6963_SET_TEXT_HOME_ADDRESS
			rcall	T6963C_WriteCommand
			
			ldi		r18,GLCD_TEXT_AREA
			rcall	T6963C_WriteData
			ldi		r18,0x00
			rcall	T6963C_WriteData
			ldi		r18,T6963_SET_TEXT_AREA
			rcall	T6963C_WriteCommand
			
			ldi		r18,GLCD_OFFSET_REGISTER
			rcall	T6963C_WriteData
			ldi		r18,0x00
			rcall	T6963C_WriteData
			ldi		r18,T6963_SET_OFFSET_REGISTER
			rcall	T6963C_WriteCommand
			
			ldi		r18,T6963_DISPLAY_MODE | T6963_GRAPHIC_DISPLAY_ON | T6963_TEXT_DISPLAY_ON
			rcall	T6963C_WriteCommand
			
			#if CG_ROM_MODE == 1
			ldi		r18,T6963_MODE_SET | T6963_OR_MODE | T6963_CG_ROM_MODE
			#else
			ldi		r18,T6963_MODE_SET | T6963_OR_MODE | T6963_CG_RAM_MODE
			#endif
			rcall	T6963C_WriteCommand
			
			ret


;------------------------------------------------------------------------------
; Chceck Status GLCD
;
; USED: __tmp_reg__*, r17*
; CALL: T6963C_delay
; IN: -
; OUT: r17
;------------------------------------------------------------------------------
T6963C_CheckStatus:
			out		GLCD_DATA_DDR,__zero_reg__	; GLCD_DATA_DDR input
			cbi		GLCD_CTRL_PORT,GLCD_RD		; RD=0
			cbi		GLCD_CTRL_PORT,GLCD_CE		; CE=0
			rcall	T6963C_delay
			in		r17,GLCD_DATA_PIN			; r17 = Status byte
			ser		__tmp_reg__
			out		GLCD_DATA_DDR,__tmp_reg__	; GLCD_DATA_DDR output
			sbi		GLCD_CTRL_PORT,GLCD_RD		; RD=1
			sbi		GLCD_CTRL_PORT,GLCD_CE		; CE=1
			ret


;------------------------------------------------------------------------------
; Wait for ready
; 
; T6963C_BusyWait spins its wheels until the controller returns that it's ready to
; accept a new data or command byte. We want to wait for a nonzero value to
; appear there.
;
; USED: __tmp_reg__*, r17, T flag*
; CALL: T6963C_delay
; IN: r17 - wait code
; OUT: -
; 
; TODO: add timeout to prevent the program freeze
;------------------------------------------------------------------------------
T6963C_BusyWait:
			clt
T6963C_BusyWait_0:
			out		GLCD_DATA_DDR,__zero_reg__	; GLCD_DATA_DDR input
			cbi		GLCD_CTRL_PORT,GLCD_RD		; RD=0
			cbi		GLCD_CTRL_PORT,GLCD_CE		; CE=0
			rcall	T6963C_delay
			in		__tmp_reg__,GLCD_DATA_PIN			; r17 = Status byte
			and		__tmp_reg__,r17
			breq	T6963C_BusyWait_1
			set
T6963C_BusyWait_1:
			ser		__tmp_reg__
			out		GLCD_DATA_DDR,__tmp_reg__	; GLCD_DATA_DDR output
			sbi		GLCD_CTRL_PORT,GLCD_RD		; RD=1
			sbi		GLCD_CTRL_PORT,GLCD_CE		; CE=1
			brtc	T6963C_BusyWait_0
			;rcall	T6963C_CheckStatus
			;and		r17,r19
			;breq	T6963C_BusyWait
			ret


;------------------------------------------------------------------------------
; Write Command to GLCD
;
; USED: r17*, r18
; CALL: T6963C_BusyWait, T6963C_delay
; IN: r18
; OUT: -
;------------------------------------------------------------------------------
T6963C_WriteCommand:
			ldi		r17,(STATUS_CMD_EXEC|STATUS_DATA_RW)
			rcall	T6963C_BusyWait
			out		GLCD_DATA_PORT,r18
			cbi		GLCD_CTRL_PORT,GLCD_WR
			cbi		GLCD_CTRL_PORT,GLCD_CE
			rcall	T6963C_delay
			sbi		GLCD_CTRL_PORT,GLCD_WR
			sbi		GLCD_CTRL_PORT,GLCD_CE
			ret


;------------------------------------------------------------------------------
; Write Data to GLCD
;
; USED: __tmp_reg__*, r17*, r18
; CALL: T6963C_BusyWait, T6963C_delay
; IN: r18
; OUT: -
;------------------------------------------------------------------------------
T6963C_WriteData:
			ldi		r17,(STATUS_CMD_EXEC|STATUS_DATA_RW)
			rcall	T6963C_BusyWait
T6963C_WriteData_:
			out		GLCD_DATA_PORT,r18
			in		__tmp_reg__,GLCD_CTRL_PORT
			andi	__tmp_reg__,~((1 << GLCD_WR)|(1 << GLCD_CE)|(1 << GLCD_CD))
			out		GLCD_CTRL_PORT,__tmp_reg__
			rcall	T6963C_delay
			in		__tmp_reg__,GLCD_CTRL_PORT
			ori		__tmp_reg__,(1 << GLCD_WR)|(1 << GLCD_CE)|(1 << GLCD_CD)
			out		GLCD_CTRL_PORT,__tmp_reg__
			ret


;------------------------------------------------------------------------------
; Reads data
;
; USED: __tmp_reg__*, r17*, r18*
; CALL: T6963C_BusyWait, T6963C_delay
; IN: -
; OUT: r18
;------------------------------------------------------------------------------
T6963C_ReadData:
			ldi		r17,(STATUS_CMD_EXEC|STATUS_DATA_RW)
			rcall	T6963C_BusyWait
T6963C_ReadData_:
			out		GLCD_DATA_DDR,__zero_reg__ ; GLCD_DATA_DDR as input
			in		__tmp_reg__,GLCD_CTRL_PORT
			andi	__tmp_reg__,~((1 << GLCD_RD)|(1 << GLCD_CE)|(1 << GLCD_CD))
			out		GLCD_CTRL_PORT,__tmp_reg__
			rcall	T6963C_delay
			in		r18,GLCD_DATA_PIN			; r18 contain read byte
			in		__tmp_reg__,GLCD_CTRL_PORT
			ori		__tmp_reg__,(1 << GLCD_RD)|(1 << GLCD_CE)|(1 << GLCD_CD)
			out		GLCD_CTRL_PORT,__tmp_reg__
			ser		__tmp_reg__
			out		GLCD_DATA_DDR,__tmp_reg__ ; GLCD_DATA_DDR as output
			ret


;------------------------------------------------------------------------------
; Sets address pointer for display RAM memory
;
; USED: r18*, r19
; CALL: T6963C_WriteData, T6963C_WriteCommand
; IN: r19:r18 - address
; OUT: -
;------------------------------------------------------------------------------
T6963C_SetAddressPointer:
			rcall	T6963C_WriteData
			mov		r18,r19
			rcall	T6963C_WriteData
			ldi		r18,T6963_SET_ADDRESS_POINTER
			rjmp	T6963C_WriteCommand


;------------------------------------------------------------------------------
; Sets display coordinates
;
; USED: __tmp_reg__*, r18*, r19*, r0*, r1*
; CALL: 
; IN: r18 (x), r19 (y)
; OUT: -
;------------------------------------------------------------------------------
T6963C_TextGoTo:
;RAM address = GLCD_TEXT_HOME +  x + (GLCD_TEXT_AREA * y)
			ldi		__tmp_reg__, GLCD_TEXT_AREA		; 30 for 8x8 font
			mul		r19, __tmp_reg__	; GLCD_TEXT_AREA * y
			clr		r19
			add		r18,r0
			adc		r19,r1
			rjmp	T6963C_SetAddressPointer


;------------------------------------------------------------------------------
; Sets graphics coordinates
;
; USED: __tmp_reg__, r18*, r19*, r0*, r1*
; CALL: 
; IN: r18 (x), r19 (y)
; OUT: -
; 
; TODO: for font width not equal to 8
;------------------------------------------------------------------------------
T6963C_GraphicGoTo:
; RAM address = GLCD_GRAPHIC_HOME + (x / GLCD_FONT_WIDTH) + (GLCD_GRAPHIC_AREA * y)
			#if (GLCD_FONT_WIDTH == 8)
			lsr		r18
			lsr		r18
			lsr		r18
			#elif (GLCD_FONT_WIDTH == 6)	; incorrect!!!
			;lsr		r18
			;lsr		r18
			#error "Unsupported font width: " GLCD_FONT_WIDTH
			#else
			#error "Unsupported font width: " GLCD_FONT_WIDTH
			#endif
			ldi		__tmp_reg__, GLCD_GRAPHIC_AREA	; 30 for 8x8 font
			mul		r19, __tmp_reg__	; GLCD_GRAPHIC_AREA * y
			clr		r19
			subi	r18,low(-GLCD_GRAPHIC_HOME)
			sbci	r19,high(-GLCD_GRAPHIC_HOME)
			add		r18,r0
			adc		r19,r1
			rjmp	T6963C_SetAddressPointer


;------------------------------------------------------------------------------
; Writes display data and increment address pointer
;
; USED: r18*
; CALL: T6963C_WriteData
; IN: r18
; OUT: -
;------------------------------------------------------------------------------
T6963C_WriteDisplayData:
			rcall	T6963C_WriteData
			ldi		r18,T6963_DATA_WRITE_AND_INCREMENT
			rjmp	T6963C_WriteCommand


;------------------------------------------------------------------------------
; Writes a single character (ASCII code) to display RAM memory
;
; USED: r18*
; CALL: 
; IN: r18
; OUT: -
;------------------------------------------------------------------------------
T6963C_WriteChar:
			#if CG_ROM_MODE == 1
			subi	r18,0x20	; 32
			#endif
			rjmp	T6963C_WriteDisplayData


;------------------------------------------------------------------------------
; Writes null-terminated string to display RAM memory (fast version)
;
; USED: r17*, r18*, X*
; CALL: T6963C_WriteCommand, T6963C_BusyWait, T6963C_WriteData_
; IN: X - pointer to null-terminated string
; OUT: -
;------------------------------------------------------------------------------
T6963C_WriteString:
			ldi		r18,T6963_SET_DATA_AUTO_WRITE
			rcall	T6963C_WriteCommand
T6963C_WriteString_WR:
			; Chceck Status STATUS_AUTO_WR
			ldi		r17,STATUS_AUTO_WR		; Check STA3=1?
			rcall	T6963C_BusyWait
			; Load symbol
			ld		r18,X+				; get char
			tst		r18					; end of string?
			breq	T6963C_WriteString_END	; end of string
			; Send data
			rcall	T6963C_WriteData_	; r18 - input
			rjmp	T6963C_WriteString_WR
T6963C_WriteString_END:
			; Chceck Status STATUS_AUTO_WR
			ldi		r17,STATUS_AUTO_WR		; Check STA3=1?
			rcall	T6963C_BusyWait
			; Command T6963_AUTO_RESET
			ldi		r18,T6963_AUTO_RESET
			rcall	T6963C_WriteCommand
			ret


;------------------------------------------------------------------------------
; Writes null-terminated string from program memory to display RAM memory
;
; USED: r18*, Z*
; CALL: 
; IN: Z - pointer to null-terminated string
; OUT: -
;------------------------------------------------------------------------------
T6963C_WriteStringPgm:
			lpm		r18,Z+				; get char
			tst		r18					; end of string?
			breq	T6963C_WriteStringPgm_END	; end of string
			rcall	T6963C_WriteChar
			rjmp	T6963C_WriteStringPgm
T6963C_WriteStringPgm_END:
			ret	


;------------------------------------------------------------------------------
; Clears text area of display RAM memory (fast version)
;
; USED: r17*,r18*,r19*, Y*
; CALL: T6963C_BusyWait, T6963C_SetAddressPointer, T6963C_WriteCommand, T6963C_WriteData_
; IN: -
; OUT: -
;------------------------------------------------------------------------------
T6963C_ClearText:
			; Set Address Pointer to GLCD_TEXT_HOME
			ldi		r19,high(GLCD_TEXT_HOME) ; 0
			ldi		r18,low(GLCD_TEXT_HOME) ; 0
			rcall	T6963C_SetAddressPointer
			; Command T6963_SET_DATA_AUTO_WRITE
			ldi		r18,T6963_SET_DATA_AUTO_WRITE
			rcall	T6963C_WriteCommand
			; Count of bytes to zeroing
			ldi		YH,high(GLCD_TEXT_SIZE) ; 0x01
			ldi		YL,low(GLCD_TEXT_SIZE) ; 0xE0
			clr		r18
			; Subroutine of zeroing
T6963C_Clear_AUTO_WR:
			; Chceck Status STATUS_AUTO_WR
			ldi		r17,STATUS_AUTO_WR		; Check STA3=1?
			rcall	T6963C_BusyWait
			; Send data
			rcall	T6963C_WriteData_	; r18 - input
			; Decrement counter
			sbiw	YL, 0x01
			brne	T6963C_Clear_AUTO_WR
			; Chceck Status STATUS_AUTO_WR
			ldi		r17,STATUS_AUTO_WR		; Check STA3=1?
			rcall	T6963C_BusyWait
			; Command T6963_AUTO_RESET
			ldi		r18,T6963_AUTO_RESET
			rcall	T6963C_WriteCommand
			ret


;------------------------------------------------------------------------------
; Clears graphics area of display RAM memory (fast version)
;
; USED: r17*,r18*,r19*, Y*
; CALL: T6963C_SetAddressPointer, T6963C_WriteCommand
; IN: -
; OUT: -
;------------------------------------------------------------------------------
T6963C_ClearGraphic:
			; Set Address Pointer to GLCD_GRAPHIC_HOME
			ldi		r19,high(GLCD_GRAPHIC_HOME) ; 0x01
			ldi		r18,low(GLCD_GRAPHIC_HOME) ; 0xE0
			rcall	T6963C_SetAddressPointer
			; Command T6963_SET_DATA_AUTO_WRITE
			ldi		r18,T6963_SET_DATA_AUTO_WRITE
			rcall	T6963C_WriteCommand
			; Count of bytes to zeroing
			ldi		YH,high(GLCD_GRAPHIC_SIZE) ; 0x0F
			ldi		YL,low(GLCD_GRAPHIC_SIZE) ; 0x00
			clr		r18
			; Subroutine of zeroing
			rjmp	T6963C_Clear_AUTO_WR


;------------------------------------------------------------------------------
; Clears characters generator area of display RAM memory (fast version)
;
; USED: r17*,r18*,r19*, Y*
; CALL: T6963C_SetAddressPointer, T6963C_WriteCommand
; IN: -
; OUT: -
;------------------------------------------------------------------------------
T6963C_ClearCG:
			; Set Address Pointer to GLCD_EXTERNAL_CG_HOME
			ldi		r19,high(GLCD_EXTERNAL_CG_HOME) ; 0x10
			ldi		r18,low(GLCD_EXTERNAL_CG_HOME) ; 0x00
			rcall	T6963C_SetAddressPointer
			; Command T6963_SET_DATA_AUTO_WRITE
			ldi		r18,T6963_SET_DATA_AUTO_WRITE
			rcall	T6963C_WriteCommand
			; Count of bytes to zeroing
			ldi		YH,high(256*8) ; 0x08
			ldi		YL,low(256*8) ; 0x00
			clr		r18
			; Subroutine of zeroing
			rjmp	T6963C_Clear_AUTO_WR


;------------------------------------------------------------------------------
; Set pixel on screen (fast version)
; only for GLCD_FONT_WIDTH = 8
;
; USED: __tmp_reg__, r18*, r19*
; CALL: T6963C_GraphicGoTo
; IN: r19 (y), r18 (x)
; OUT: -
; 
; TODO: for font width not equal to 8
;------------------------------------------------------------------------------
T6963C_SetPixel:
			push	r18 ; remember x
			rcall	T6963C_GraphicGoTo ; (IN: r18 - x; r19 - y)
			pop		__tmp_reg__ ; restore x
			#if (GLCD_FONT_WIDTH == 8)
			andi	__tmp_reg__,7 ; x%8
			#elif (GLCD_FONT_WIDTH == 6)
			#error "Unsupported font width: " GLCD_FONT_WIDTH
			#else
			#error "Unsupported font width: " GLCD_FONT_WIDTH
			#endif
			ldi		r18,7
			sub		r18,__tmp_reg__ ; 7-(x%8)
			ori		r18,T6963_BIT_SET
			rjmp	T6963C_WriteCommand


;------------------------------------------------------------------------------
; Reset (clear) pixel on screen (fast version)
;
; USED: __tmp_reg__, r18*, r19*
; CALL: T6963C_GraphicGoTo
; IN: r19 (y), r18 (x)
; OUT: -
;------------------------------------------------------------------------------
T6963C_ResetPixel:
			push	r18 ; remember x
			rcall	T6963C_GraphicGoTo
			pop		__tmp_reg__ ; restore x
			#if (GLCD_FONT_WIDTH == 8)
			andi	__tmp_reg__,7 ; x%8
			#elif (GLCD_FONT_WIDTH == 6)
			#error "Unsupported font width: " GLCD_FONT_WIDTH
			#else
			#error "Unsupported font width: " GLCD_FONT_WIDTH
			#endif
			ldi		r18,7
			sub		r18,__tmp_reg__ ; 7-(x%8)
			ori		r18,T6963_BIT_RESET
			rjmp	T6963C_WriteCommand


;------------------------------------------------------------------------------
; Displays bitmap from program memory
;
; USED: 
; CALL: -
; IN: Z - pointer to bitmap in flash, r18 - x, r19 - y, r20 - width, r21 - height
; OUT: -
;------------------------------------------------------------------------------
T6963C_Bitmap:
			; TODO
			ret


;------------------------------------------------------------------------------
; Delay function
;
; USED: __tmp_reg__*
; CALL: -
; IN: -
; OUT: -
;------------------------------------------------------------------------------
T6963C_delay:
			ldi		__tmp_reg__,(F_CPU/1000000)
T6963C_delay_loop:
			nop
			nop
			nop
			nop
			dec		__tmp_reg__
			brne	T6963C_delay_loop
			ret


;------------------------------------------------------------------------------
; Writes font table to character generator area of display RAM memory
;
; USED: r17*, r18*, r19*, Y*, Z*
; CALL: T6963C_SetAddressPointer, T6963C_BusyWait, T6963C_WriteCommand, T6963C_WriteData_
; IN: -
; OUT: -
;------------------------------------------------------------------------------
T6963C_FillCG:
			; Set Address Pointer to GLCD_EXTERNAL_CG_HOME
			ldi		r19,high(GLCD_EXTERNAL_CG_HOME) ; 
			ldi		r18,low(GLCD_EXTERNAL_CG_HOME) ; 
			rcall	T6963C_SetAddressPointer
			; Command T6963_SET_DATA_AUTO_WRITE
			ldi		r18,T6963_SET_DATA_AUTO_WRITE
			rcall	T6963C_WriteCommand
			; Count of bytes
			ldi		YH,high(2048) ; 
			ldi		YL,low(2048) ; 
			; Pointer to font table
			ldi		ZH,high(font_8x8_rus*2) ; 
			ldi		ZL,low(font_8x8_rus*2) ; 
T6963C_FillCG_AUTO_WR:
			; Chceck Status STATUS_AUTO_WR
			ldi		r17,STATUS_AUTO_WR		; Check STA3=1?
			rcall	T6963C_BusyWait
			lpm		r18,Z+				; get byte
			; Send data
			rcall	T6963C_WriteData_	; r18 - input
			; Decrement counter
			sbiw	YL, 0x01
			brne	T6963C_FillCG_AUTO_WR
			; Check Status STATUS_AUTO_WR
			ldi		r17,STATUS_AUTO_WR		; Check STA3=1?
			rcall	T6963C_BusyWait
			; Command T6963_AUTO_RESET
			ldi		r18,T6963_AUTO_RESET
			rcall	T6963C_WriteCommand
			ret


;------------------------------------------------------------------------------
; Shift a block by 1 pixel to the left
; (useful for moving charts)
; ATTENTION!!! X and width must be a multiple of 8
; RAM buffer used (DataBlock) to processing a single line
; 1. One line is read into the buffer
; 2. The shift of all bits of the string by 1 is performed
; 3. The string is written back to the display
; The operation is repeated for all rows
; 
; USED: r16*, r17*, r18*, r19*, Y*
; CALL: T6963C_GraphicGoTo, T6963C_WriteCommand, T6963C_BusyWait, T6963C_ReadData_, T6963C_WriteData_
; IN: r20 - X, r21 - Y, r22 - width, r23 - height
; OUT: -
; 
; TODO: make a shift for arbitrary coordinates
;------------------------------------------------------------------------------
T6963C_ShiftLeftDataBlock:
			; STEP 1. Get byte array from display
			; cycle by rows Y_var [56..86]
			mov		r18,r20 ;       ; 96
			mov		r19,r21 ; Y_var ; 56..86
			rcall	T6963C_GraphicGoTo
			ldi		r18,T6963_SET_DATA_AUTO_READ
			rcall	T6963C_WriteCommand
			; cycle by bytes per line i_var [0..16]
			mov		r19,r22 ; i_var ; 17
			ldi		YL,low(DataBlock)
			ldi		YH,high(DataBlock)
T6963C_ShiftLeftDataBlock_CheckStatus_RD:
			ldi		r17,STATUS_AUTO_RD
			rcall	T6963C_BusyWait
			rcall	T6963C_ReadData_ ; (OUT: r18)
			st		Y+,r18	; save received byte to array
			dec		r19 ; i_var
			brne	T6963C_ShiftLeftDataBlock_CheckStatus_RD
			; Check status
			ldi		r17,STATUS_AUTO_RD
			rcall	T6963C_BusyWait
			ldi		r18,T6963_AUTO_RESET
			rcall	T6963C_WriteCommand
			; STEP 2. Byte-shift array by 1 bit left
			; need to shift left 1 bit in all 16 bytes 
			; transferring the high bit from the current byte 
			; to the low bit of the previous byte
			mov		r19,r22 ; i_var
			ldi		YL,low(DataBlock)
			ldi		YH,high(DataBlock)
			; Starting from the end
			add		YL,r22
			adc		YH,__zero_reg__
			clc		; clear carry flag
T6963C_ShiftLeftDataBlock_Move:
			ld		r16,-Y ; get byte
			rol		r16  ; shift byte. in LSB insert the carry bit
			; after operation MSB is written to the carry bit
			st		Y,r16 ; save byte
			dec		r19 ; i_var
			brne	T6963C_ShiftLeftDataBlock_Move
			; STEP 3. Write array back to the display
			mov		r18,r20 ;       ; 96
			mov		r19,r21 ; Y_var ; 56..86
			rcall	T6963C_GraphicGoTo
			ldi		r18,T6963_SET_DATA_AUTO_WRITE
			rcall	T6963C_WriteCommand
			; cycle by bytes per line i_var [0..16]
			mov		r19,r22 ; i_var
			ldi		YL,low(DataBlock)
			ldi		YH,high(DataBlock)
T6963C_ShiftLeftDataBlock_CheckStatus_WR:
			; Chceck Status STATUS_AUTO_WR
			ldi		r17,STATUS_AUTO_WR		; Check STA3=1?
			rcall	T6963C_BusyWait
			ld		r18,Y+
			rcall	T6963C_WriteData_ ; (IN: r18)
			dec		r19 ; i_var
			brne	T6963C_ShiftLeftDataBlock_CheckStatus_WR
			; Chceck Status STATUS_AUTO_WR
			ldi		r17,STATUS_AUTO_WR		; Check STA3=1?
			rcall	T6963C_BusyWait
			ldi		r18,T6963_AUTO_RESET
			rcall	T6963C_WriteCommand
			inc		r21 ; Y_var
			dec		r23
			brne	T6963C_ShiftLeftDataBlock
			ret



;==============================================================================
;
;           Graphical primitives
;
;==============================================================================

;------------------------------------------------------------------------------
; Horizontal line from (x,y) to right
;
; USED: r18*, r19*, r20*, r21*
; CALL: T6963C_SetPixel
; IN: r18 - x, r19 - y, r20 - width
; OUT: -
; 
; TODO: test for (x + width) < GLCD_PIXELS_PER_LINE
;------------------------------------------------------------------------------
T6963C_HorizLine:
			cpi		r18,GLCD_PIXELS_PER_LINE
			brsh	T6963C_HorizLine_Exit
			cpi		r19,GLCD_NUMBER_OF_LINES
			brsh	T6963C_HorizLine_Exit
			cpi		r20,GLCD_PIXELS_PER_LINE
			brsh	T6963C_HorizLine_Exit
			tst		r20 ; otherwise there will be bugs
			breq	T6963C_HorizLine_Exit
			mov		r21,r18 ; x
			mov		r22,r19 ; y
			add		r20,r18 ; end x
T6963C_HorizLine_loop:
			mov		r18,r21 ; x
			mov		r19,r22 ; y
			rcall	T6963C_SetPixel
			inc		r21
			cp		r21,r20
			brne	T6963C_HorizLine_loop
T6963C_HorizLine_Exit:
			ret


;------------------------------------------------------------------------------
; Vertical line from (x,y) to down
;
; USED: r18*, r19*, r20*, r21*
; CALL: T6963C_SetPixel
; IN: r18 - x, r19 - y, r20 - height
; OUT: -
; 
; TODO: test for (y + height) < GLCD_NUMBER_OF_LINES
;------------------------------------------------------------------------------
T6963C_VertLine:
			cpi		r18,GLCD_PIXELS_PER_LINE
			brsh	T6963C_VertLine_Exit
			cpi		r19,GLCD_NUMBER_OF_LINES
			brsh	T6963C_VertLine_Exit
			cpi		r20,GLCD_NUMBER_OF_LINES
			brsh	T6963C_VertLine_Exit
			tst		r20 ; otherwise there will be bugs
			breq	T6963C_VertLine_Exit
			mov		r21,r18 ; x
			mov		r22,r19 ; y
			add		r20,r19 ; end y
T6963C_VertLine_loop:
			mov		r18,r21 ; x
			mov		r19,r22 ; y
			rcall	T6963C_SetPixel
			inc		r22
			cp		r22,r20
			brne	T6963C_VertLine_loop
T6963C_VertLine_Exit:
			ret


;------------------------------------------------------------------------------
; Rectangle
;
; USED: r18*, r19*, r20*, r21*, r23, r24, r25
; CALL: T6963C_SetPixel
; IN: r18 - x, r19 - y, r20 - width, r21 - height
; OUT: -
;------------------------------------------------------------------------------
T6963C_Rectangle:
			push	r23
			push	r24
			push	r25
			; Draw horizontal sides
			mov		r23,r19 ; y1
			mov		r24,r21
			add		r24,r19
			subi	r24,1   ; y2
			mov		r25,r18 ; x start
			mov		r21,r20
			add		r21,r18 ; x end
			mov		r20, r18
T6963C_Rectangle_H_loop:
			mov		r18,r25 ; x
			mov		r19,r23 ; y1
			rcall	T6963C_SetPixel
			mov		r18,r25 ; x
			mov		r19,r24 ; y2
			rcall	T6963C_SetPixel
			inc		r25
			cp		r25,r21
			brne	T6963C_Rectangle_H_loop
			; Draw vertical sides
			subi	r25,1
T6963C_Rectangle_V_loop:
			mov		r18,r20 ; x1
			mov		r19,r23 ; y
			rcall	T6963C_SetPixel
			mov		r18,r25 ; x2
			mov		r19,r23 ; y
			rcall	T6963C_SetPixel
			inc		r23
			cp		r23,r24
			brne	T6963C_Rectangle_V_loop
			pop		r23
			pop		r24
			pop		r25
			ret


;------------------------------------------------------------------------------
; Filled Rectangle
;
; USED: r18*, r19*, r20*, r21*, r23, r24, r25
; CALL: T6963C_SetPixel
; IN: r18 - x, r19 - y, r20 - width, r21 - height
; OUT: -
;------------------------------------------------------------------------------
T6963C_FillRectangle:
			push	r23
			push	r24
			push	r25
			mov		r23,r19 ; y index
			mov		r24,r21
			add		r24,r19 ; y end
			mov		r25,r18 ; x start
			mov		r21,r20
			add		r21,r18 ; x end
			mov		r20,r25 ; x index
T6963C_FillRectangle_loop:
			mov		r18,r20 ; x
			mov		r19,r23 ; y
			rcall	T6963C_SetPixel
			inc		r20
			cp		r20,r21
			brne	T6963C_FillRectangle_loop
			; set start x again
			mov		r20,r25
			; increment y
			inc		r23
			cp		r23,r24
			brne	T6963C_FillRectangle_loop
			pop		r23
			pop		r24
			pop		r25
			ret


;------------------------------------------------------------------------------
; Cleared Rectangle
;
; USED: r18*, r19*, r20*, r21*, r23, r24, r25
; CALL: T6963C_SetPixel
; IN: r18 - x, r19 - y, r20 - width, r21 - height
; OUT: -
;------------------------------------------------------------------------------
T6963C_ClrRectangle:
			push	r23
			push	r24
			push	r25
			mov		r23,r19 ; y index
			mov		r24,r21
			add		r24,r19 ; y end
			mov		r25,r18 ; x start
			mov		r21,r20
			add		r21,r18 ; x end
			mov		r20,r25 ; x index
T6963C_ClrRectangle_loop:
			mov		r18,r20 ; x
			mov		r19,r23 ; y
			rcall	T6963C_ResetPixel
			inc		r20
			cp		r20,r21
			brne	T6963C_ClrRectangle_loop
			; set start x again
			mov		r20,r25
			; increment y
			inc		r23
			cp		r23,r24
			brne	T6963C_ClrRectangle_loop
			pop		r23
			pop		r24
			pop		r25
			ret




#if defined (T6963C_LEGACY)

;------------------------------------------------------------------------------
; Writes null-terminated string to display RAM memory (preserved for legacy)
;
; USED: r18, X
; CALL: 
; IN: X - pointer to null-terminated string
; OUT: -
;------------------------------------------------------------------------------
T6963C_WriteString2:
			ld		r18,X+				; get char
			tst		r18					; end of string?
			breq	T6963C_WriteString2_END	; end of string
			rcall	T6963C_WriteChar
			rjmp	T6963C_WriteString2
T6963C_WriteString2_END:
			ret


;------------------------------------------------------------------------------
; Set pixel on screen (preserved for legacy)
;
; USED: __tmp_reg__, r17*, r18*, r19*
; CALL: T6963C_GraphicGoTo
; IN: r19 (y), r18 (x)
; OUT: -
;------------------------------------------------------------------------------
T6963C_SetPixel2:
			push	r18 ; remember x
			rcall	T6963C_GraphicGoTo
			ldi		r18,T6963_DATA_READ_AND_NONVARIABLE
			rcall	T6963C_WriteCommand
			rcall	T6963C_ReadData ; (OUT: r18)
			; (1 <<  (GLCD_FONT_WIDTH - 1 - (x % GLCD_FONT_WIDTH)))
			pop		__tmp_reg__ ; restore x
			com		__tmp_reg__
			andi	__tmp_reg__, 0x07	; 7
			ldi		r17,0x01	; 1
			rjmp	T6963C_SetPixel2_l2
T6963C_SetPixel2_l1:
			add		r17,r17
T6963C_SetPixel2_l2:
			dec		__tmp_reg__
			brpl	T6963C_SetPixel2_l1
			or		r18,r17
			rjmp	T6963C_WriteDisplayData


;------------------------------------------------------------------------------
; Reset (clear) pixel on screen (preserved for legacy)
;
; USED: __tmp_reg__, r17*, r18*, r19*
; CALL: T6963C_GraphicGoTo
; IN: r19 (y), r18 (x)
; OUT: -
;------------------------------------------------------------------------------
T6963C_ResetPixel2:
			push	r18 ; remember x
			rcall	T6963C_GraphicGoTo
			ldi		r18,T6963_DATA_READ_AND_NONVARIABLE
			rcall	T6963C_WriteCommand
			rcall	T6963C_ReadData ; (OUT: r18)
			; (1 <<  (GLCD_FONT_WIDTH - 1 - (x % GLCD_FONT_WIDTH)))
			pop		__tmp_reg__ ; restore x
			com		__tmp_reg__
			andi	__tmp_reg__, 0x07	; 7
			ldi		r17,0x01	; 1
			rjmp	T6963C_ResetPixel2_l2
T6963C_ResetPixel2_l1:
			add		r17,r17
T6963C_ResetPixel2_l2:
			dec		__tmp_reg__
			brpl	T6963C_ResetPixel2_l1
			com		r17
			and		r18,r17
			rjmp	T6963C_WriteDisplayData
#endif

.include "font_8x8_rus.inc"

;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
