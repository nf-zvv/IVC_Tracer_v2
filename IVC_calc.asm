;------------------------------------------------------------------------------
; Обработка результатов измерений
; 
; (C) 2017-2021 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
; 
; History
; =======
; 07.10.2021 Подпрограммы Calculate_current и Calculate_voltage 
;            из главного файла IVC_Tracer_v2.asm перемещены сюда
; 07.10.2021 Добавлены Calculate_power, Calculate_resistance
; 
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; Преобразование кода АЦП в миллиамперы
;
; Current_mA = (((ADC_code * ADC_V_REF / 4096) - CH0_DELTA) * 1000) / ACS712_KI
; 
; Умножение на 1000 здесь необходимо из-за того, что коэффициент ACS712_KI 
; переводит значение из мВ в А, а нам нужны мА.
;
; MCP3204 - 12-битный АЦП. Максимальное значение ADC_code = 4095
; Опорное напряжение АЦП ADC_V_REF = 5000 мВ

; TODO: сделать округление (ADC_code * ADC_V_REF / 4096)

; IN: r17:r16 - ADC_code
; OUT: CURRENT_MA, r19:r18 - mA
;------------------------------------------------------------------------------
Calculate_current:
			; Преобразование кода АЦП в милливольты
			; Умножить на значение опорного напряжения в мВ
			lds		r18,ADC_V_REF+0
			lds		r19,ADC_V_REF+1
			rcall	mul16u   ; (IN: r17:r16, r19:r18, OUT: r25:r24:r23:r22)
			; Поделить на разрядность АЦП
			rcall	DIV_4096 ; (IN, OUT: r25:r24:r23:r22)
			; Вычесть смещение
			mov		r20,r22
			mov		r21,r23
			lds		r24,CH0_DELTA+0
			lds		r25,CH0_DELTA+1
			sub		r20,r24
			sbc		r21,r25
			; Умножение на 1000
			; IN: r21:r20, r19:r18
			; OUT: r25:r24:r23:r22
			ldi		r18,low(1000)
			ldi		r19,high(1000)
			rcall	muls16x16_32
			; Деление
			lds		r18,ACS712_KI
			ldi		r19,0x00	; 0
			ldi		r20,0x00	; 0
			ldi		r21,0x00	; 0
			rcall	__divmodsi4 ; (OUT: r21:r20:r19:r18)
			; save current
			sts		CURRENT_MA+1,r19
			sts		CURRENT_MA+0,r18
			ret


;------------------------------------------------------------------------------
; Преобразование кода АЦП в милливольты
; 
; Voltage_mV = (CH1_DELTA - (ADC_code * ADC_V_REF / 4096) ) * RESDIV_KU
; 
; IN: r17:r16 - ADC_code
; OUT: VOLTAGE_MV, r23:r22 - mV
;------------------------------------------------------------------------------
Calculate_voltage:
			; Преобразование кода АЦП в милливольты
			; Умножить на значение опорного напряжения в мВ

			lds		r18,ADC_V_REF+0
			lds		r19,ADC_V_REF+1
			rcall	mul16u   ; (IN: r17:r16, r19:r18, OUT: r25:r24:r23:r22)
			; Поделить на разрядность АЦП
			rcall	DIV_4096 ; (IN, OUT: r25:r24:r23:r22)
			; Вычесть смещение
			; r21:r20 = r21:r20 - r25:r24
			lds		r20,CH1_DELTA+0
			lds		r21,CH1_DELTA+1
			mov		r24,r22
			mov		r25,r23
			;mov		r20,r22
			;mov		r21,r23
			;lds		r24,CH1_DELTA+0
			;lds		r25,CH1_DELTA+1
			sub		r20,r24
			sbc		r21,r25
			; Умножить на коэффициент делителя напряжения
			; IN: r21:r20, r19:r18
			; OUT: r25:r24:r23:r22
			lds		r18,RESDIV_KU
			ldi		r19,0
			rcall	muls16x16_32
			; save voltage
			sts		VOLTAGE_MV+1,r23
			sts		VOLTAGE_MV+0,r22
			ret


;------------------------------------------------------------------------------
; Calculate power
; 
; Power_mW = Voltage_mV * Current_mA / 1000
; 
; IN:  VOLTAGE_MV, CURRENT_MA
; OUT: POWER_MW
;------------------------------------------------------------------------------
Calculate_power:
			
			; IN: r21:r20, r19:r18
			; OUT: r25:r24:r23:r22
			lds		r21,VOLTAGE_MV+1
			lds		r20,VOLTAGE_MV+0
			lds		r19,CURRENT_MA+1
			lds		r18,CURRENT_MA+0
			call	muls16x16_32

			; IN: r25:r24:r23:r22 - Dividend
			; IN: r21:r20:r19:r18 - Divisor
			; OUT: r21:r20:r19:r18 - Result
			ldi		r21,0x00
			ldi		r20,0x00
			ldi		r19,high(1000)
			ldi		r18,high(1000)
			call	__divmodsi4

			sts		POWER_MW+1,r19
			sts		POWER_MW+0,r18

			ret



;------------------------------------------------------------------------------
; Calculate resistance
; 
; Resistance_Ohm = (Voltage_mV << 16) / Current_mA
; 
; IN: VOLTAGE_MV, CURRENT_MA
; OUT: RES_OHM_INT, RES_OHM_FRAC
;------------------------------------------------------------------------------
Calculate_resistance:
			; IN: r21:r20, r19:r18
			; OUT: r25:r24:r23:r22
			lds		r21,VOLTAGE_MV+1
			lds		r20,VOLTAGE_MV+0
			lds		r19,CURRENT_MA+1
			lds		r18,CURRENT_MA+0

			; Проверить ток на ноль!!!
			; (деление на ноль)
			ldi		r17,0
			ldi		r16,0
			cp		r18,r16
			cpc		r19,r17
			breq	ZERO_DIVISION
			
			; First of all need to drop the sign
			; of voltage and current
			; signed -> unsigned

			; r25:r24:r23:r22 - Dividend
			; r21:r20:r19:r18 - Divisor
			lds		r25,VOLTAGE_MV+1
			lds		r24,VOLTAGE_MV+0
			ldi		r23,0x00
			ldi		r22,0x00
			; check for sign
			bst		r25, 7
			brtc	Calculate_resistance_1
			; убираем знак
			com		r25
			neg		r24
			sbci	r25,0xFF
Calculate_resistance_1:
			ldi		r21,0x00
			ldi		r20,0x00
			lds		r19,CURRENT_MA+1
			lds		r18,CURRENT_MA+0
			; check for sign
			bst		r19, 7
			brtc	Calculate_resistance_2
			; убираем знак
			com		r19
			neg		r18
			sbci	r19,0xFF
Calculate_resistance_2:
			call	__udivmodsi4 ; (OUT: r21:r20:r19:r18)
			; r21:r20 - integer part of number
			; r19:r18 - fractional part of number

			; convert fractional part to number
			; IN: r19:r18
			; OUT: r23:r22
			rcall	fract_part_10bit

			sts		RES_OHM_INT+1,r21
			sts		RES_OHM_INT+0,r20
			sts		RES_OHM_FRAC+1,r23
			sts		RES_OHM_FRAC+0,r22

			ret
ZERO_DIVISION:
			ldi		r21,high(9999)
			ldi		r20,low(9999)
			sts		RES_OHM_INT+1,r21
			sts		RES_OHM_INT+0,r20
			ret


;------------------------------------------------------------------------------
; input: r19:r18 - fractional part of number
; output: r23:r22
; used: r23:r22,r25:r24
;------------------------------------------------------------------------------
fract_part_10bit:
			clr		r22
			clr		r23
			lsl		r19
			brcc	fp10b_next_bit_1
			ldi		r22,low(5000)
			ldi		r23,high(5000)
fp10b_next_bit_1:
			lsl		r19
			brcc	fp10b_next_bit_2
			ldi		r24,low(2500)
			ldi		r25,high(2500)
			add		r22,r24
			adc		r23,r25
fp10b_next_bit_2:
			lsl		r19
			brcc	fp10b_next_bit_3
			ldi		r24,low(1250)
			ldi		r25,high(1250)
			add		r22,r24
			adc		r23,r25
fp10b_next_bit_3:
			lsl		r19
			brcc	fp10b_next_bit_4
			ldi		r24,low(625)
			ldi		r25,high(625)
			add		r22,r24
			adc		r23,r25
fp10b_next_bit_4:
			lsl		r19
			brcc	fp10b_next_bit_5
			ldi		r24,low(313)
			ldi		r25,high(313)
			add		r22,r24
			adc		r23,r25
fp10b_next_bit_5:
			lsl		r19
			brcc	fp10b_next_bit_6
			ldi		r24,156
			ldi		r25,0
			add		r22,r24
			adc		r23,r25
fp10b_next_bit_6:
			lsl		r19
			brcc	fp10b_next_bit_7
			ldi		r24,78
			ldi		r25,0
			add		r22,r24
			adc		r23,r25
fp10b_next_bit_7:
			lsl		r19
			brcc	fp10b_next_bit_8
			ldi		r24,39
			ldi		r25,0
			add		r22,r24
			adc		r23,r25
fp10b_next_bit_8:
			lsl		r18
			brcc	fp10b_next_bit_9
			ldi		r24,20
			ldi		r25,0
			add		r22,r24
			adc		r23,r25
fp10b_next_bit_9:
			lsl		r18
			brcc	fp10b_exit
			ldi		r24,10
			ldi		r25,0
			add		r22,r24
			adc		r23,r25
fp10b_exit:
			ret


;------------------------------------------------------------------------------
; Convert resistance to string
; IN: RES_OHM_INT, RES_OHM_FRAC
; OUT: Y - pointer to null-terminating string
;------------------------------------------------------------------------------
RES_TO_STR:
			


			; Сначала разбираемся в целой частью
			lds		r27,RES_OHM_INT+1
			lds		r26,RES_OHM_INT+0
			; Проверяем случай, когда ток равен нулю
			ldi		r17,high(9999)
			ldi		r16,low(9999)
			cp		r26,r16
			cpc		r27,r17
			brne	RES_TO_STR_OK
			rjmp	RES_TO_STR_DASH
RES_TO_STR_OK:
			; Надо проверить, что вычисленное значение не больше 1000
			ldi		r17,high(1000)
			ldi		r16,low(1000)
			cp		r26,r16
			cpc		r27,r17
			brsh	RES_TO_STR_BIG

			; начинаем преобразовывать
			; Сотни
			LDI		r16, -1
RES_TO_STR_1:
			INC		r16
			SUBI	r26, Low(100)
			SBCI	r27, High(100)
			BRSH	RES_TO_STR_1
			SUBI	r26, -100
			TST		r16		; проверка на 0
			BRNE	RES_TO_STR_1_NONZERO
			LDI		r16,' '
			CLT
			RJMP	RES_TO_STR_1_SAVE
RES_TO_STR_1_NONZERO:
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			SET
RES_TO_STR_1_SAVE:
			ST		Y+,r16		; сохранить код цифры
			; Десятки
			LDI		r16, -1
RES_TO_STR_2:
			INC		r16
			SUBI	r26, 10
			BRSH	RES_TO_STR_2
			SUBI	r26,-10
			BRTS	RES_TO_STR_2_NONZERO	; если флаг Т установлен, значит пропускаем
			TST		r16		; проверка на 0
			BRNE	RES_TO_STR_2_NONZERO
			LDI		r16,' '
			RJMP	RES_TO_STR_2_SAVE
RES_TO_STR_2_NONZERO:
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
RES_TO_STR_2_SAVE:
			CLT
			ST		Y+,r16		; сохранить код цифры
			; Единицы
			SUBI	r26,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r26		; сохранить код цифры
			
			ldi		r16,'.'
			ST		Y+,r16

			; Переходим к дробной части
			lds		r26,RES_OHM_FRAC+0
			lds		r27,RES_OHM_FRAC+1


			LDI		r16, -1
RES_TO_STR_3:
			INC		r16
			SUBI	r26, Low(1000)
			SBCI	r27, High(1000)
			BRSH	RES_TO_STR_3
			SUBI	r26, Low(-1000)
			SBCI	r27, High(-1000)
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			LDI		r16, -1
RES_TO_STR_4:
			INC		r16
			SUBI	r26, Low(100)
			SBCI	r27, High(100)
			BRSH	RES_TO_STR_4
			SUBI	r26, -100
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			LDI		r16, -1
RES_TO_STR_5:
			INC		r16
			SUBI	r26, 10
			BRSH	RES_TO_STR_5
			SUBI	r16,-0x30	; преобразовать цифру в ASCII код
			ST		Y+,r16		; сохранить код цифры
			CLR		r16
			ST		Y+,r16		; \0 - null-terminating string
			ret

RES_TO_STR_BIG:
			; Поместить в буфер строку "999.999"
			ldi		ZH,high(2*OVER_RESISTANCE_str)
			ldi		ZL,low(2*OVER_RESISTANCE_str)
RES_TO_STR_BIG_LOOP:
			lpm		r16,Z+
			ST		Y+,r16
			tst		r16
			brne	RES_TO_STR_BIG_LOOP
			ret

RES_TO_STR_DASH:
		; Поместить в буфер строку "---.---"
			ldi		ZH,high(2*ZERO_CURRENT_str)
			ldi		ZL,low(2*ZERO_CURRENT_str)
RES_TO_STR_DASH_LOOP:
			lpm		r16,Z+
			ST		Y+,r16
			tst		r16
			brne	RES_TO_STR_DASH_LOOP
			ret


			


OVER_RESISTANCE_str:	.db "999.999",0
ZERO_CURRENT_str:		.db "---.---",0

;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
