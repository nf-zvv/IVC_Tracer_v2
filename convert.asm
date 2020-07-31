;=============================================================================
; Подпрограммы для преобразования чисел в строки и обратно
;
; (C) 2017-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; History
; =======
; 27.08.2017 добавлена STR_TO_UINT16
; 24.07.2020 добавлена ATOI
; 28.07.2020 добавлена ITOA_FAST_DIV
;
;=============================================================================
#ifndef _CONVERT_ASM_
#define _CONVERT_ASM_


;=============================================================================
;
; Преобразование числа в строку
;
;=============================================================================



;------------------------------------------------------------------------------
; Преобразование 16-битного числа в строку
; Метод: деление на 10 сдвигами и сложениями
;
; ITOA_FAST_DIV - с учётом знака
; UTOA_FAST_DIV - без учёта знака
;
; Необходим буфер длиной не менее 7 байт для строки (знак, 5 байт числа, символ \0)
;
; http://we.easyelectronics.ru/Soft/preobrazuem-v-stroku-chast-1-celye-chisla.html
;
; Используются: r18*, r19*, r20*, r21*, r23*, r26*, r27*, r28*, r29*
; Вход: X (r27:r26) - число
;       Y (r29:r28) - указатель на буфер
; Выход: буфер
;------------------------------------------------------------------------------
ITOA_FAST_DIV:
			clt
			; определяем знак числа
			and		r27,r27
			brpl	UTOA_FAST_DIV
			set		; установить флаг T как флаг отрицательного числа
			; Изменить знак числа
			com		r27
			neg		r26
			sbci	r27,0xFF
UTOA_FAST_DIV:
			; заполняем буфер пробелами
			ldi		r18,7
			ldi		r19,' '
UTOA_FAST_DIV_ZEROING:
			st		Y+,r19
			dec		r18
			brne	UTOA_FAST_DIV_ZEROING
			st		-Y,__zero_reg__		; помещаем ноль в конец строки
UTOA_FAST_DIV_1:
			; res.quot = n >> 1;
			movw	r20,r26
			lsr		r21
			ror		r20
			; res.quot += res.quot >> 1;
			movw	r18,r26
			lsr		r19
			ror		r18
			lsr		r19
			ror		r18
			add		r20,r18
			adc		r21,r19
			; res.quot += res.quot >> 4;
			movw	r18,r20
			ldi		r23,0x04	; 4 сдвига
UTOA_FAST_DIV_2:
			lsr		r19
			ror		r18
			dec		r23
			brne	UTOA_FAST_DIV_2
			add		r20,r18
			adc		r21,r19
			; res.quot += res.quot >> 8;
			mov		r18,r21
			eor		r19,r19
			add		r18,r20
			adc		r19,r21
			; res.quot >>= 3;
			movw	r20,r18
			ldi		r23,0x03	; 3 сдвига
UTOA_FAST_DIV_3:
			lsr		r21
			ror		r20
			dec		r23
			brne	UTOA_FAST_DIV_3
			; res.rem = (uint8_t)(n - ((res.quot << 1) + (qq & ~7ul)));
			andi	r18,0xF8	; 248
			mov		r27,r26
			sub		r27,r18
			mov		r26,r20
			add		r26,r26
			sub		r27,r26
			; if(res.rem > 9)
			cpi		r27,0x0A	; 10
			brcs	UTOA_FAST_DIV_4
			; res.rem -= 10;
			subi	r27,0x0A	; 10
			; res.quot++;
			subi	r20,0xFF	; 255
			sbci	r21,0xFF	; 255
			; do
			; {
			; divmod10_t res = divmodu10(value);
			; *--buffer = res.rem + '0';
UTOA_FAST_DIV_4:
			subi	r27,0xD0	; 208
			st		-Y,r27
			; value = res.quot;
			movw	r26,r20
			; }
			; while (value != 0);
			sbiw	r26,0x00	; 0
			brne	UTOA_FAST_DIV_1
			; return buffer;
			; }
			; Проверить знак числа
			brtc	UTOA_FAST_DIV_EXIT
			ldi		r23,'-'
			st		-Y,r23
			clt
UTOA_FAST_DIV_EXIT:
			ret


;--------------------------------------------------------------
; Преобразование двоичного однобайтового числа в строку
; 
; Используются: r16*, r17*
; Вход: r16 - число [0 - 255]
;       Y - pointer to null-terminating string
; Выход: Y - pointer to null-terminating string
;--------------------------------------------------------------
DEC_TO_STR4:
			LDI		r17, -1
DEC_TO_STR4_1:
			INC		r17
			SUBI	r16, 100
			BRSH	DEC_TO_STR4_1
			SUBI	r16, -100
			SUBI	r17,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r17
			LDI		r17, -1
DEC_TO_STR4_2:
			INC		r17
			SUBI	r16, 10
			BRSH	DEC_TO_STR4_2
			SUBI	r17,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r17
			SUBI	r16, -10
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16
			CLR		r16
			ST		Y+,r16		; \0 - null-terminating string
			RET


;------------------------------------------------------------------------------
; Convert unsigned number to string
; 
; USED: r16*, r26*, r27*, r28*, r29*
; CALL: 
; IN: X - число [0 - 9999], [0x0000 - 0x270F]
;     Y - pointer to null-terminating string
; OUT: Y - pointer to null-terminating string
;------------------------------------------------------------------------------
DEC_TO_STR5:
			LDI		r16, -1
DEC_TO_STR5_1:
			INC		r16
			SUBI	r26, Low(1000)
			SBCI	r27, High(1000)
			BRSH	DEC_TO_STR5_1
			SUBI	r26, Low(-1000)
			SBCI	r27, High(-1000)
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			LDI		r16, -1
DEC_TO_STR5_2:
			INC		r16
			SUBI	r26, Low(100)
			SBCI	r27, High(100)
			BRSH	DEC_TO_STR5_2
			SUBI	r26, -100
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			LDI		r16, -1
DEC_TO_STR5_3:
			INC		r16
			SUBI	r26, 10
			BRSH	DEC_TO_STR5_3
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			SUBI	r26,-10
			SUBI	r26,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r26		; сохранить код цифры
			CLR		r16
			ST		Y+,r16		; \0 - null-terminating string
			ret


;------------------------------------------------------------------------------
; Convert signed number to string
; 
; USED: r16*, r26*, r27*, r28*, r29*
; CALL: 
; IN: X - число [0..65535], [0x0000..0xFFFF]
;     Y - pointer to null-terminating string
; OUT: Y - pointer to null-terminating string
;------------------------------------------------------------------------------
DEC_TO_STR7:
			; определить знак
			SBRC	r27,7
			RJMP	DEC_TO_STR7_SIGN
			LDI		r16,' '
			ST		Y+,r16
			RJMP	DEC_TO_STR7_START
DEC_TO_STR7_SIGN:
			ldi		r16,'-'
			st		Y+,r16
			; смена знака
			com		r26
			com		r27
			subi	r26,low(-1)
			sbci	r27,high(-1)
DEC_TO_STR7_START:
			LDI		r16, -1
DEC_TO_STR7_0:
			INC		r16
			SUBI	r26, Low(10000)
			SBCI	r27, High(10000)
			BRSH	DEC_TO_STR7_0
			SUBI	r26, Low(-10000)
			SBCI	r27, High(-10000)
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			LDI		r16, -1
DEC_TO_STR7_1:
			INC		r16
			SUBI	r26, Low(1000)
			SBCI	r27, High(1000)
			BRSH	DEC_TO_STR7_1
			SUBI	r26, Low(-1000)
			SBCI	r27, High(-1000)
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			LDI		r16, -1
DEC_TO_STR7_2:
			INC		r16
			SUBI	r26, Low(100)
			SBCI	r27, High(100)
			BRSH	DEC_TO_STR7_2
			SUBI	r26, -100
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			LDI		r16, -1
DEC_TO_STR7_3:
			INC		r16
			SUBI	r26, 10
			BRSH	DEC_TO_STR7_3
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			SUBI	r26,-10
			SUBI	r26,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r26		; сохранить код цифры
			CLR		r16
			ST		Y+,r16		; \0 - null-terminating string
			RET



;=============================================================================
;
; Преобразование строки в число
;
;=============================================================================



;-----------------------------------------------------------------------------
; Преобразование строки в число
; Работает как с положительными (0...65535), 
; так и с отрицательными числами (-32767...32767)
; Как только встречается не число, преобразование завершается

; 
; Используются: r16*, r24*, r25*, r28*, r29*
; Вход: Y (0-ended строка)
; Выход: r25:r24
;-----------------------------------------------------------------------------
ATOI:
			clr		r24		; Очистить r24
			clr		r25		; Очистить r25
			clt
ATOI_1:
			ld		r16,Y+
			cpi		r16,0x20	; пробел
			breq	ATOI_1
			cpi		r16,0x09
			brcs	atoi_2
			cpi		r16,0x0E
			brcs	ATOI_1
ATOI_2:
			cpi		r16,'+'
			breq	ATOI_3
			cpi		r16,'-'
			brne	ATOI_4
			set
			rjmp	ATOI_3
ATOI_5:
			rcall	MULHI_CONST_10
			add		r24,r16
			adc		r25,__zero_reg__
ATOI_3:
			ld		r16,Y+
ATOI_4:
			subi	r16,'0'	; переводим ASCII код цифры в число
			cpi		r16,0x0A	; 10
			brcs	ATOI_5
			brtc	ATOI_EXIT
			; если число отрицательное
			com		r25
			neg		r24
			sbci	r25,0xFF
ATOI_EXIT:
			ret


;-----------------------------------------------------------------------------
; Умножение на 10
; 
; Используются: r0*, r1*, r23*, r24*, r25*
; Вход: r25:r24
; Выход: r25:r24
;-----------------------------------------------------------------------------
MULHI_CONST_10:
			ldi	r23,10
			mul	r25,r23
			mov	r25,r0
			mul	r24,r23
			mov	r24,r0
			add	r25,r1
			ret


;-----------------------------------------------------------------------------
; Преобразование строки в число
; 0...65535
; Используются: r16*, r24*, r25*, r28*, r29*
; Вход: Y (0-ended строка)
; Выход: r25:r24, r13
;        r13 = 0 успешно
;        r13 = 1 не число
;        r13 = 2 слишком большое
;-----------------------------------------------------------------------------
.def tmpL = r22
.def tmpH = r23
.def WL   = r24
.def WH   = r25
STR_TO_UINT16:
			clr		r24			; Обнуляем результат
			clr		r25
			rcall	STR_LEN		; Определяем длину строки
			cpi		r16,1
			breq	STR_TO_UINT16_1DIGIT
			cpi		r16,2
			breq	STR_TO_UINT16_2DIGIT
			cpi		r16,3
			breq	STR_TO_UINT16_3DIGIT
			cpi		r16,4
			breq	STR_TO_UINT16_4DIGIT
			cpi		r16,5
			breq	STR_TO_UINT16_5DIGIT
			rjmp	STR_TO_UINT16_TOOBIG
;--------------------
STR_TO_UINT16_5DIGIT:
			ld		r17,Y+
			rcall	IS_DIGIT	; проверяем - цифра ли это
			tst		r16
			breq	STR_TO_UINT16_NONDIGIT
			subi	r17,'0'	; переводим ASCII код цифры в число
			ldi		tmpL,low(10000)
			ldi		tmpH,high(10000)
STR_TO_UINT16_LOOP5:
			tst		r17
			breq	STR_TO_UINT16_4DIGIT
			add		WL,tmpL
			adc		WH,tmpH
			dec		r17
			rjmp	STR_TO_UINT16_LOOP5
;--------------------
STR_TO_UINT16_4DIGIT:
			ld		r17,Y+
			rcall	IS_DIGIT	; проверяем - цифра ли это
			tst		r16		
			breq	STR_TO_UINT16_NONDIGIT
			subi	r17,'0'	; переводим ASCII код цифры в число
			ldi		tmpL,low(1000)
			ldi		tmpH,high(1000)
STR_TO_UINT16_LOOP4:
			tst		r17
			breq	STR_TO_UINT16_3DIGIT
			add		WL,tmpL
			adc		WH,tmpH
			dec		r17
			rjmp	STR_TO_UINT16_LOOP4
;--------------------
STR_TO_UINT16_3DIGIT:
			ld		r17,Y+
			rcall	IS_DIGIT	; проверяем - цифра ли это
			tst		r16		
			breq	STR_TO_UINT16_NONDIGIT
			subi	r17,'0'	; переводим ASCII код цифры в число
			ldi		tmpL,100
			mul		r17,tmpL
			add		WL,r0
			adc		WH,r1
;--------------------
STR_TO_UINT16_2DIGIT:
			ld		r17,Y+
			rcall	IS_DIGIT	; проверяем - цифра ли это
			tst		r16		
			breq	STR_TO_UINT16_NONDIGIT
			subi	r17,'0'	; переводим ASCII код цифры в число
			ldi		tmpL,10
			mul		r17,tmpL
			add		WL,r0
			adc		WH,r1
;--------------------
STR_TO_UINT16_1DIGIT:
			ld		r17,Y+
			rcall	IS_DIGIT	; проверяем - цифра ли это
			tst		r16		
			breq	STR_TO_UINT16_NONDIGIT
			subi	r17,'0'	; переводим ASCII код цифры в число
			clr		tmpL
			add		WL,r17
			adc		WH,tmpL
			clr		r13		; статус - успех
			ret
STR_TO_UINT16_NONDIGIT:
			ldi		r16,1
			mov		r13,r16
			ret
STR_TO_UINT16_TOOBIG:
			ldi		r16,2
			mov		r13,r16
			ret
.undef tmpL
.undef tmpH


;-----------------------------------------------------------------------------
; Преобразование строки в число
; 0...255
; Используются: r13*, r16*, r17*, r24* Y*
; Вход: Y (0-ended строка)
; Выход: r24, r13
;        r13 = 0 успешно
;        r13 = 1 не число
;        r13 = 2 слишком большое
; ЗАМЕЧАНИЕ! Примитивный код. Надо улучшить.
;-----------------------------------------------------------------------------
STR_TO_UINT8:
			ld		r17,Y+
			tst		r17
			breq	str_end
			rcall	IS_DIGIT	; проверяем - цифра ли это
			tst		r16		
			breq	str_to_uint8_nondigit
			inc		r16			; подсчет длины числа
			rjmp	STR_TO_UINT8
str_end:
			; оказались здесь, значит длина числа подсчитана
			ld		r17,-Y	; считали /0 - символ конца строки

			ld		r17,-Y	; считали первую цифру - единицы
			subi	r17,'0'	; переводим ASCII код цифры в число
			mov		WL,r17	; результат - единицы
			dec		r16		; уменьшаем счетчик цифр
			tst		r16		; не кончились ли цифры?
			breq	str_to_uint8_finish

			ld		r17,-Y	; считали вторую цифру - десятки
			subi	r17,'0'	; переводим ASCII код цифры в число
			ldi		r18,10
			mul		r17,r18	; выполняем умножение на 10
			add		WL,r0	; прибавляем к результату десятки
			dec		r16		; уменьшаем счетчик цифр
			tst		r16		; не кончились ли цифры?
			breq	str_to_uint8_finish

			ld		r17,-Y	; считали третью цифру - сотни
			cpi		r17,3	; если три и больше - слишком много
			brsh	str_to_uint8_too_big
str_to_uint8_next:
			subi	r17,'0'	; переводим ASCII код цифры в число
			ldi		r18,100
			mul		r17,r18	; выполняем умножение на 100
			add		WL,r0	; прибавляем к результату сотни
			brcs	str_to_uint8_too_big
			dec		r16		; уменьшаем счетчик цифр
			tst		r16		; не кончились ли цифры?
			breq	str_to_uint8_finish
			; если оказались тут, значит
			; цифры так и не кончились - статус too big
str_to_uint8_too_big:
			ldi		r16,2
			mov		r13,r16
			ret
str_to_uint8_nondigit:
			ldi		r16,1
			mov		r13,r16
			ret
str_to_uint8_finish:
			clr		r13		; статус - успех
			ret
.undef WL
.undef WH


;=============================================================================
;
; Преобразование числа в BCD формат
;
;=============================================================================



;--------------------------------------------------------------
; Преобразование двоичного однобайтового числа в BCD формат
; Вход: r16
; Выход: r8-r10 (BCD_1 - BCD_3)
;--------------------------------------------------------------
.def BCD_1 = r4
.def BCD_2 = r5
.def BCD_3 = r6
Bin1ToBCD3:
			LDIL	BCD_1, -1
Bin1ToBCD3_1:
			INC		BCD_1
			SUBI	r16, 100
			BRSH	Bin1ToBCD3_1
			SUBI	r16, -100
			LDIL	BCD_2, -1
Bin1ToBCD3_2:
			INC		BCD_2
			SUBI	r16, 10
			BRSH	Bin1ToBCD3_2
			SUBI	r16, -10
			MOV		BCD_3,r16
			RET


;------------------------------------------------------------------------------
; Преобразование двоичного двухбайтового числа в BCD формат
; Вход: X(r27:r26)
; Выход: r11-r14 (BCD_4 - BCD_7)
;------------------------------------------------------------------------------
.def BCD_4 = r22
.def BCD_5 = r23
.def BCD_6 = r24
.def BCD_7 = r25
Bin2ToBCD4:
			LDIL	BCD_4, -1
Bin2ToBCD4_1:
			INC		BCD_4
			SUBI	r26, Low(1000)
			SBCI	r27, High(1000)
			BRSH	Bin2ToBCD4_1
			SUBI	r26, Low(-1000)
			SBCI	r27, High(-1000)
			LDIL	BCD_5, -1
Bin2ToBCD4_2:
			INC		BCD_5
			SUBI	r26, Low(100)
			SBCI	r27, High(100)
			BRSH	Bin2ToBCD4_2
			SUBI	r26, -100
			LDIL	BCD_6, -1
Bin2ToBCD4_3:
			INC		BCD_6
			SUBI	r26, 10
			BRSH	Bin2ToBCD4_3
			SUBI	r26, -10
			MOV		BCD_7,r26
			RET


;------------------------------------------------------------------------------
; 2BIN to 5BCD
; 16-bit binary to 5-digit packed BCD conversion (0..65535)
; "shift-plus-3" method
;
; Source: https://www.avrfreaks.net/forum/16bit-binary-bcd
;
; IN: r17:r16 = HEX value
; OUT: r20:r19:r18 = BCD value
;------------------------------------------------------------------------------
hexToBcd:
			push	r16
			push    r17
			push    r21
			push    r22
			push    xl
			push    xh
			clr     r18
			clr     r19
			clr     r20
			clr     xh
			ldi     r21, 16
hexToBcd1:
			ldi     xl, 20 + 1
hexToBcd2:
			ld      r22, -x
			subi    r22, -3
			sbrc    r22, 3
			st      x, r22
			ld      r22, x
			subi    r22, -0x30
			sbrc    r22, 7
			st      x, r22
			cpi     xl, 18
			brne    hexToBcd2
			lsl     r16
			rol     r17
			rol     r18
			rol     r19
			rol     r20
			dec     r21
			brne    hexToBcd1
			pop     xh
			pop     xl
			pop     r22
			pop     r21
			pop     r17
			pop     r16
			ret


;------------------------------------------------------------------------------
;*
;* Bin3BCD == 24-bit Binary to BCD conversion
;*
;* fbin0:fbin1:fbin2  >>>  tBCD0:tBCD1:tBCD2:tBCD3
;*	  hex			     dec
;*     r16r17r18      >>>	r20r21r22r23
;*
;------------------------------------------------------------------------------
.def	fbin0	=r22	; binary value byte 0 (LSB)
.def	fbin1	=r23	; binary value byte 1
.def	fbin2	=r24	; binary value byte 2 (MSB)
.def	tBCD0	=r25	; BCD value digits 0 and 1
.def	tBCD1	=r26	; BCD value digits 2 and 3
.def	tBCD2	=r27	; BCD value digits 4 and 5
.def	tBCD3	=r28	; BCD value digits 6 and 7 (MSD)

Bin3BCD16:
			ldi	tBCD3,0xfa		;initialize digits 7 and 6
binbcd_107:
			subi	tBCD3,-0x10		;
			subi	fbin0,byte1(10000*1000) ;subit fbin,10^7
			sbci	fbin1,byte2(10000*1000) ;
			sbci	fbin2,byte3(10000*1000) ;
			brcc	binbcd_107		;
binbcd_106:	dec		tBCD3			;
			subi	fbin0,byte1(-10000*100) ;addit fbin,10^6
			sbci	fbin1,byte2(-10000*100) ;
			sbci	fbin2,byte3(-10000*100) ;
			brcs	binbcd_106		;
			ldi		tBCD2,0xfa		;initialize digits 5 and 4
binbcd_105:	subi	tBCD2,-0x10		;
			subi	fbin0,byte1(10000*10)	;subit fbin,10^5
			sbci	fbin1,byte2(10000*10)	;
			sbci	fbin2,byte3(10000*10)	;
			brcc	binbcd_105		;
binbcd_104:	dec		tBCD2			;
			subi	fbin0,byte1(-10000)	;addit fbin,10^4
			sbci	fbin1,byte2(-10000)	;
			sbci	fbin2,byte3(-10000)	;
			brcs	binbcd_104		;
			ldi		tBCD1,0xfa		;initialize digits 3 and 2
binbcd_103:	subi	tBCD1,-0x10		;
			subi	fbin0,byte1(1000)	;subiw fbin,10^3
			sbci	fbin1,byte2(1000)	;
			brcc	binbcd_103		;
binbcd_102:	dec		tBCD1			;
			subi	fbin0,byte1(-100)	;addiw fbin,10^2
			sbci	fbin1,byte2(-100)	;
			brcs	binbcd_102		;
			ldi		tBCD0,0xfa		;initialize digits 1 and 0
binbcd_101:	subi	tBCD0,-0x10		;
			subi	fbin0,10		;subi fbin,10^1
			brcc	binbcd_101		;
			add		tBCD0,fbin0		;LSD
			ret				;



#endif  /* _CONVERT_ASM_ */

;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
