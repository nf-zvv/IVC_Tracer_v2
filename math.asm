;------------------------------------------------------------------------------
; ћатематические подпрограммы
; 
; (C) 2017-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
; 
; History
; =======
; 29.07.2020 Bin3BCD16, hexToBcd, Bin2ToBCD4, Bin1ToBCD3, DEC_TO_STR7, 
;            DEC_TO_STR5 перемещены в convert.asm
; 
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; Signed multiply of two 16bits numbers with 32bits result
; Cycles : 19 + ret
; Words  : 15 + ret
; Register usage: r0 to r2 and r16 to r23 (11 registers)
; Note: The routine is non-destructive to the operands.
; IN: r21:r20, r19:r18
; OUT: r25:r24:r23:r22
;------------------------------------------------------------------------------
muls16x16_32:
			clr		r2
			muls	r19, r21		; (signed)ah * (signed)bh
			movw	r25:r24, r1:r0
			mul		r18, r20		; al * bl
			movw	r23:r22, r1:r0
			mulsu	r19, r20		; (signed)ah * bl
			sbc		r25, r2
			add		r23, r0
			adc		r24, r1
			adc		r25, r2
			mulsu	r21, r18		; (signed)bh * al
			sbc		r25, r2
			add		r23, r0
			adc		r24, r1
			adc		r25, r2
			ret

;------------------------------------------------------------------------------
; Ѕеззнаковое умножение 16 бит
; 16bit * 16 bit = 32 bit
; ¬ход:
; r16 low  first
; r17 high first
; r18 low  second
; r19 high second
; ¬ыход:
; res0 - r22
; res1 - r23
; res2 - r24
; res3 - r25
; (17 тактов)
;------------------------------------------------------------------------------
.def res0 = r22
.def res1 = r23
.def res2 = r24
.def res3 = r25
mul16u:
			mul		r16,r18			;умножить мл. байт множимого на мл. байт множител€
			movw	res0,r0 		;скопировать r0:r1 в 1-й, 2-й байты результата
			mul		r17,r19 		;умножить ст. байт множимого на ст. байт множител€
			movw	res2,r0			;скопировать r0:r1 в 3-й, 4-й байты результата
			mul		r16,r19 		;умножить мл. байт множимого на ст. байт множител€
			clr		r16				;очистить ненужный регистр дл€ сложений с флагом "C"
			add		res1,r0			;сложить r0:r1:r16 с 2-м, 3-м, 4-м байтами результата
			adc		res2,r1			;...
			adc		res3,r16			;...
			mul		r17,r18 		;умножить ст. байт множимого на мл. байт множител€
			add		res1,r0			;сложить r0:r1:r16 с 2-м, 3-м, 4-м байтами результата
			adc		res2,r1			;...
			adc		res3,r16
			ret
.undef res0
.undef res1
.undef res2
.undef res3

;------------------------------------------------------------------------------
; Signed Division 32/32 = 32+32
;
; IN: r25:r24:r23:r22 - Dividend
;     r21:r20:r19:r18 - Divisor
; OUT: r21:r20:r19:r18 - Result
;      r25:r24:r23:r22 - Remainder
;------------------------------------------------------------------------------
__divmodsi4:
			mov		r0, r21
			bst		r25, 7
			brtc	__divmodsi4_1
			com		r0
			rcall	__negsi2
__divmodsi4_1:
			sbrc	r21, 7
			rcall	__divmodsi4_neg2
			rcall	__udivmodsi4
			sbrc	r0, 7
			rcall	__divmodsi4_neg2
			brtc	__divmodsi4_exit
			rjmp		__negsi2
__divmodsi4_neg2:
			com		r21
			com		r20
			com		r19
			neg		r18
			sbci	r19, 0xFF	; 255
			sbci	r20, 0xFF	; 255
			sbci	r21, 0xFF	; 255
__divmodsi4_exit:
			ret

;------------------------------------------------------------------------------
; Change sign 32 bit
; 
; IN: r25:r24:r23:r22
; OUT: r25:r24:r23:r22
;------------------------------------------------------------------------------
__negsi2:
			com		r25
			com		r24
			com		r23
			neg		r22
			sbci	r23, 0xFF	; 255
			sbci	r24, 0xFF	; 255
			sbci	r25, 0xFF	; 255
			ret

;------------------------------------------------------------------------------
; Unsigned Division 32/32 = 32+32
;
; USED: r26,r27,
;
; IN: r25:r24:r23:r22 - Dividend
;     r21:r20:r19:r18 - Divisor
; OUT: r21:r20:r19:r18 - Result
;      r25:r24:r23:r22 - Remainder
;------------------------------------------------------------------------------
__udivmodsi4:
			ldi		r26, 0x21	; 33
			mov		r1, r26
			sub		r26, r26
			sub		r27, r27
			movw	r30, r26
			rjmp	__udivmodsi4_ep
__udivmodsi4_loop:
			adc		r26, r26
			adc		r27, r27
			adc		r30, r30
			adc		r31, r31
			cp		r26, r18
			cpc		r27, r19
			cpc		r30, r20
			cpc		r31, r21
			brcs	__udivmodsi4_ep
			sub		r26, r18
			sbc		r27, r19
			sbc		r30, r20
			sbc		r31, r21
__udivmodsi4_ep:
			adc		r22, r22
			adc		r23, r23
			adc		r24, r24
			adc		r25, r25
			dec		r1
			brne	__udivmodsi4_loop
			com		r22
			com		r23
			com		r24
			com		r25
			movw	r18, r22
			movw	r20, r24
			movw	r22, r26
			movw	r24, r30
			ret



;------------------------------------------------------------------------------
; input: r16 - fractional part (дробна€ часть)
; output: X(r27:r26)
; used: X(r27:r26),Y(r29:r28)
;------------------------------------------------------------------------------
fract_part:
			clr		r26
			clr		r27
			lsr		r16
			brcc	next_bit_1
			ldi		r26,low(625)
			ldi		r27,high(625)
next_bit_1:
			lsr		r16
			brcc	next_bit_2
			ldi		r28,low(1250)
			ldi		r29,high(1250)
			rcall	add16bit
next_bit_2:
			lsr		r16
			brcc	next_bit_3
			ldi		r28,low(2500)
			ldi		r29,high(2500)
			rcall	add16bit
next_bit_3:
			lsr		r16
			brcc	next_bit_4
			ldi		r28,low(5000)
			ldi		r29,high(5000)
			rcall	add16bit
next_bit_4:
			ret


;--------------------------------------------------------------
; 16bit adder
; input: r27:r26 and r29:r28
; output: r27:r26
;--------------------------------------------------------------
add16bit:
			add		r26,r28
			adc		r27,r29
			ret



;-----------------------------------------------------------------------------
; »нкремент двухбайтовой переменной на заданный шаг
; »спользуютс€: 
; ¬ход: 
;       r25:r24 - инкрементируемое число
;       r27:r26 - шаг инкремента
; ¬ыход: r25:r24
;-----------------------------------------------------------------------------
INCREMENT:
			add		r24,r26
			adc		r25,r27
			ret


;-----------------------------------------------------------------------------
; ƒекремент двухбайтовой переменной на заданный шаг
; »спользуютс€: 
; ¬ход: 
;       r25:r24 - декрементируемое число
;       r27:r26 - шаг декремента
; ¬ыход: r25:r24
;-----------------------------------------------------------------------------
DECREMENT:
;ѕреобразовываем вычитание в сложение:
;1. Ќайти дополнение вычитаемого R27:R26 до 1
;2. Ќайти дополнение вычитаемого R27:R26 до 2
;3. —ложить уменьшаемое R24:R25 и дополнение вычитаемого R27:R26 до 2
			com		r26
			com		r27
			adiw	r27:r26,1	; дополнение шестнадцатиричного числа R27:R26 до 2
			add		r24,r26
			adc		r25,r27
			ret

;------------------------------------------------------------------------------
; ƒеление 4-байтового числа на 4096 путем серии сдвигов вправо
;
; USED: r16*, r22*, r23*, r24*, r25*
; CALL: -
; IN: r25:r24:r23:r22
; OUT: r25:r24:r23:r22
;------------------------------------------------------------------------------
DIV_4096:
			ldi		r16,12
DIV_4096_LOOP:
			lsr		r25
			ror		r24
			ror		r23
			ror		r22
			dec		r16
			brne	DIV_4096_LOOP
			ret



;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
