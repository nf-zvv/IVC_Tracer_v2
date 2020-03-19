;------------------------------------------------------------------------------
;
;
; (C) 2017-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; History
; =======
;
;------------------------------------------------------------------------------




;-----------------------------------------------------------------------------
; RTC Code
;-----------------------------------------------------------------------------
RTC_READ:	RCALL	IIC_START		; Отослали старт
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x08
			BRNE	IIC_RErr
 
			LDI		r16,0b10100000	; Отослали адрес часов на запись
			RCALL	IIC_BYTE
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x18
			BRNE	IIC_RErr
 
			LDI		r16,RTCAddr		; Отослали адрес ячейки откуда будем читать
			RCALL	IIC_BYTE
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x28
			BRNE	IIC_RErr
 
			RCALL	IIC_START		; Повторный старт
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x10
			BRNE	IIC_RErr
 
			LDI		r16,0b10100001	; Адрес часов снова, но уже на чтение
			RCALL	IIC_BYTE
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x40
			BRNE	IIC_RErr
 
			RCALL	IIC_RCV			; Считали первый байт - секунды
			IN		r16,TWDR		; Забрали из регистра TWIDR
			IN		r17,TWSR		; Проверка статуса
			ANDI	r17,0xF8
			CPI		r17, 0x50
			BRNE	IIC_RErr
			STS		Sec_o,r16		; Сохранили в память
 
			RCALL	IIC_RCV			; Второй байт - Минуты, с ним также
			IN		r16,TWDR
			IN		r17,TWSR		; Проверка статуса
			ANDI	r17,0xF8
			CPI		r17, 0x50
			BRNE	IIC_RErr
			STS		Min_o,r16
 
			RCALL	IIC_RCV			; Третий байт - Часы
			IN		r16,TWDR
			IN		r17,TWSR		; Проверка статуса
			ANDI	r17,0xF8
			CPI		r17, 0x50
			BRNE	IIC_RErr
			STS		Hour_o,r16
 
			RCALL	IIC_RCV			; Четвертый - число
			IN		r16,TWDR
			IN		r17,TWSR		; Проверка статуса
			ANDI	r17,0xF8
			CPI		r17, 0x50
			BRNE	IIC_RErr
			STS		Date_o,r16
 
			RCALL	IIC_RCV2		; Ну и напоследок - месяц. Внимание! 
			IN		r16,TWDR		; тут процедура послденго байта! RCV2!!!
			IN		r17,TWSR		; Проверка статуса
			ANDI	r17,0xF8
			CPI		r17, 0x58
			BRNE	IIC_RErr
			STS		Mth_o,r16
 
IIC_RErr:	RCALL	IIC_STOP		; Дали STOP и освободили линию.
 
			RET				; Вышли из задачи

;-----------------------------------------------------------------------------
; Записть новых значений даты-времени в RTC
;-----------------------------------------------------------------------------
RTC_WRITE:
			RCALL	IIC_START		; Старт 
			LDI		r16,0b10100000	; Загрузили Адрес часов на запись
			RCALL	IIC_BYTE		; Отослали адрес часов на запись
			LDI		r16,RTCAddr		; Загрузили адрес ячейки памяти часов
			RCALL	IIC_BYTE		; Отослали адрес ячейки
			LDS		r16,Sec_i	;Sec	; Загрузили секунды
			RCALL	IIC_Byte		; Отослали секунды
 
			LDS		r16,Min_i	;Min	; Загрузили минуты
			RCALL	IIC_Byte		; Отослали минуты
 
			LDS		r16,Hour_i	;Hr	; Загрузили часы
			RCALL	IIC_Byte		; Отослали часы
 
			LDS		r16,Date_i	;Date	; Загрузили число
			RCALL	IIC_Byte		; Отослали число
 
			LDS		r16,Mth_i	;Mth	; Загрузили Месяц
			RCALL	IIC_Byte		; Отослали месяц
 
IIC_WErr:	RCALL	IIC_STOP		; Стоп
			RET


;-----------------------------------------------------------------------------
; Считывание байта из RAM RTC
; Адрес читаемой ячейки RAM - в регистре r6
; Результат - в регистре r7
; Изменяются: r16
;-----------------------------------------------------------------------------
RTC_READ_RAM:
			push	r16
			push	r17
			RCALL	IIC_START		; Отослали старт
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x08
			BRNE	IIC_RRErr
 
			LDI		r16,0b10100000	; Отослали адрес часов на запись
			RCALL	IIC_BYTE
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x18
			BRNE	IIC_RRErr
 
			MOV		r16,r6			; Отослали адрес ячейки откуда будем читать
			RCALL	IIC_BYTE
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x28
			BRNE	IIC_RRErr
 
			RCALL	IIC_START		; Повторный старт
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x10
			BRNE	IIC_RRErr
 
			LDI		r16,0b10100001	; Адрес часов снова, но уже на чтение
			RCALL	IIC_BYTE
			IN		r16,TWSR		; Проверка статуса
			ANDI	r16,0xF8
			CPI		r16, 0x40
			BRNE	IIC_RRErr

			RCALL	IIC_RCV2
			IN		r16,TWDR
			IN		r17,TWSR
			ANDI	r17,0xF8
			CPI		r17, 0x58
			BRNE	IIC_RRErr
			MOV		r7,r16
 
IIC_RRErr:	RCALL	IIC_STOP		; Дали STOP и освободили линию.
 			pop		r17
			pop		r16
		RET				; Вышли из задачи

;-----------------------------------------------------------------------------
; Записть новых значений даты-времени в RTC
; Адрес записываемой ячейки RAM - в регистре r6
; Записываемый байт - в регистре r7
; Изменяются: r16
;-----------------------------------------------------------------------------
RTC_WRITE_RAM:
			push	r16
			RCALL	IIC_START		; Старт 
			LDI		r16,0b10100000	; Загрузили Адрес часов на запись
			RCALL	IIC_BYTE		; Отослали адрес часов на запись
			MOV		r16,r6		; Загрузили адрес ячейки памяти часов
			RCALL	IIC_BYTE		; Отослали адрес ячейки
			MOV		r16,r7			; Загрузили отправляемый байт
			RCALL	IIC_Byte		; Отправили

IIC_WRErr:	RCALL	IIC_STOP		; Стоп
			pop		r16
			RET

;-----------------------------------------------------------------------------
; Детальная обработка входных данных
; Результат - в регистре r16
;-----------------------------------------------------------------------------
GET_SEC0:
			LDS		R16,Sec_o
			ANDI	R16,0x0F
			RET
GET_SEC1:
			LDS		R16,Sec_o
			ANDI	R16,0x70
			SWAP	R16
			RET
GET_MIN0:
			LDS		R16,Min_o
			ANDI	R16,0x0F
			RET
GET_MIN1:
			LDS		R16,Min_o
			ANDI	R16,0x70
			SWAP	R16
			RET
GET_HOUR0:
			LDS		R16,Hour_o
			ANDI	R16,0x0F
			RET
GET_HOUR1:
			LDS		R16,Hour_o
			ANDI	R16,0x30
			SWAP	R16
			RET
; 0 - AM
; 1 - PM
GET_AM_PM:
			LDS		R16,Hour_o
			ANDI	R16,0x40
			SWAP	R16
			LSR		R16
			LSR		R16
			RET
; 0 - 24h (AM/PM флаг не изменяется)
; 1 - 12h (AM/PM флаг обновляется)
GET_12_24:
			LDS		R16,Hour_o
			ANDI	R16,0x80
			SWAP	R16
			LSR		R16
			LSR		R16
			LSR		R16
			RET
GET_DAY0:
			LDS		R16,Date_o
			ANDI	R16,0x0F
			RET
GET_DAY1:
			LDS		R16,Date_o
			ANDI	R16,0x30
			SWAP	R16
			RET
GET_YEAR:
			LDS		R16,Date_o
			ANDI	R16,0xC0
			SWAP	R16
			LSR		R16
			LSR		R16				; Сейчас в r16 смещение года (остаток от деления)
			ldi		r19,0x10
			mov		r6,r19 
			rcall	RTC_READ_RAM	; В регистр r7 считали високосный год
			add		r16,r7			; В регистре r16 находится значение года
			RET
GET_MONTH0:
			LDS		R16,Mth_o
			ANDI	R16,0x0F
			RET
GET_MONTH1:
			LDS		R16,Mth_o
			ANDI	R16,0x10
			SWAP	R16
			RET
GET_WEEK:
			LDS		R16,Mth_o
			ANDI	R16,0xE0
			SWAP	R16
			LSR		R16
			RET

;-----------------------------------------------------------------------------
; Предобработка данных перед записью их в RTC
; В массиве FullDateTime находятся 12 байт даты-времени
; в формате DDMMYYhhmmss
;
; После предобработки результаты будут находится в ячейках:
; Date_i, Hour_i, Min_i, Sec_i, Mth_i
; Используются: r16, r17, ZH
;
; Выполняется минимальная проверка на корректность введенных цифр
; В случае корректности на выходе r16=1
; При наличии ошибки на выходе r16=0
;-----------------------------------------------------------------------------
PREPROC_DATETIME:
			ldi		ZL,low(FullDateTime)
			ldi		ZH,high(FullDateTime)
			
			; Подготовка дня
			ld		r16,Z+			; Загружен десятичный разряд дня (0,1,2,3)
			ld		r17,Z+			; Загружен единичный разряд дня (0-9)
			rcall	DATE_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Date_i,r16		; Запись в память подготовленного значения даты
			
			; Подготовка месяца
			ld		r16,Z+			; Загружен десятичный разряд месяца (0,1)
			ld		r17,Z+			; Загружен единичный разряд месяца (0-9)
			rcall	MONTH_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Mth_i,r16		; Запись в память подготовленного значения месяца
			
			; Подготовка года
			ld		r16,Z+			; Считываются 1 разряд года
			ld		r17,Z+			; Считываются 2 разряд года
			rcall	YEAR_TEST
			
			; Подготовка часа
			ld		r16,Z+			; Загружен десятичный разряд часа (0-5)
			ld		r17,Z+			; Загружен единичный разряд часа (0-9)
			rcall	HOUR_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Hour_i,r16		; Запись в память подготовленного значения часа
			
			; Подготовка минут
			ld		r16,Z+			; Загружен десятичный разряд минут (0-5)
			ld		r17,Z+			; Загружен единичный разряд минут (0-9)
			rcall	TIME_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Min_i,r16		; Запись в память подготовленного значения минут

			; Подготовка секунд
			ld		r16,Z+			; Загружен десятичный разряд секунд (0-5)
			ld		r17,Z			; Загружен единичный разряд секунд (0-9)
			rcall	TIME_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Sec_i,r16		; Запись в память подготовленного значения секунд
			
			ldi		r16,1				; Все корректно. Выходим.
			rjmp	PREPROC_EXIT
PREPROC_ERROR:
			clr		r16
PREPROC_EXIT:
			RET
;-----------------------------------------------------------------------------
; Проверка корректности параметров времени
; Вход: r16 (десятый разряд), r17 (единичный разряд)
; Выход: r16 (готовое для записи число), r17=1 (успех), r17=0 (неудача)
;-----------------------------------------------------------------------------
TIME_TEST:
			cpi		r16,6			; Если этот символ после цифры 5
			brsh	TIME_TEST_ERROR
			swap	r16				; Установка десятичного разряда секунд
			or		r16,r17			; Установка единичного разряда секунд
			ldi		r17,1
			rjmp	TIME_TEST_EXIT
TIME_TEST_ERROR:
			clr		r17
TIME_TEST_EXIT:
			ret

HOUR_TEST:
			cpi		r16,3			; Если этот символ после цифры 2
			brsh	HOUR_TEST_ERROR
			cpi		r16,2
			brne	HOUR_TEST_OK
			cpi		r17,4			; Если этот символ после цифры 3
			brsh	HOUR_TEST_ERROR
HOUR_TEST_OK:
			swap	r16				; Установка десятичного разряда дня
			or		r16,r17			; Установка единичного разряда дня
			ldi		r17,1
			rjmp	HOUR_TEST_EXIT
HOUR_TEST_ERROR:
			clr		r17
HOUR_TEST_EXIT:
			ret

DATE_TEST:
			cpi		r16,4			; Если этот символ после цифры 3
			brsh	DATE_TEST_ERROR
			cpi		r16,3
			brne	DATE_TEST_OK
			cpi		r17,1
			brne	DATE_TEST_ERROR
DATE_TEST_OK:
			swap	r16				; Установка десятичного разряда дня
			or		r16,r17			; Установка единичного разряда дня
			ldi		r17,1
			rjmp	DATE_TEST_EXIT
DATE_TEST_ERROR:
			clr		r17
DATE_TEST_EXIT:
			ret

MONTH_TEST:
			cpi		r16,2			; Если этот символ после цифры 1
			brsh	MONTH_TEST_ERROR
			cpi		r16,1
			brne	MONTH_TEST_OK
			cpi		r17,3			; Если этот символ после цифры 2
			brsh	MONTH_TEST_ERROR
MONTH_TEST_OK:
			swap	r16				; Установка десятичного разряда дня
			or		r16,r17			; Установка единичного разряда дня
			ldi		r17,1
			rjmp	MONTH_TEST_EXIT
MONTH_TEST_ERROR:
			clr		r17
MONTH_TEST_EXIT:
			ret

YEAR_TEST:
			ldi		r19,10
			mul		r16,r19
			clc
			mov		r16,r0
			adc		r16,r17			; Теперь в r16 десятичное значение года
			cpi		r16,4
			brlo	YEAR_TEST_1
			push	r16
YEAR_TEST_AGAIN:
			subi	r16,4
			cpi		r16,4
			brsh	YEAR_TEST_AGAIN
			mov		r17,r16			; Остаток от деления
			pop		r16				; Исходный год
			sub		r16,r17			; Ближайший прошедший високосный год
			
			ldi		r19,0x10		; Адрес ячейки RAM в RTC
			mov		r6,r19			; Адрес ячейки RAM в RTC
			mov		r7,r16			; Записываемый байт (Ближайший прошедший високосный год)
			rcall	RTC_WRITE_RAM	; Записть високосного года в ячейку RAM RTC
			
			mov		r16,r17
			rjmp	YEAR_TEST_2
YEAR_TEST_1:
			ldi		r19,0x10		; Адрес ячейки RAM в RTC
			mov		r6,r19			; Адрес ячейки RAM в RTC
			clr		r19				; Записываемый байт
			mov		r7,r19			; Записываемый байт (Ближайший прошедший високосный год)
			rcall	RTC_WRITE_RAM	; Записть високосного года в ячейку RAM RTC
YEAR_TEST_2:

			ldi		r19,0x11		; Адрес ячейки RAM в RTC
			mov		r6,r19			; Адрес ячейки RAM в RTC
			mov		r7,r16			; Записываемый байт (Остаток от деления)
			rcall	RTC_WRITE_RAM	; Записть остаток от деления в ячейку RAM RTC			

			swap	r16
			lsl		r16
			lsl		r16
			lds		r17,Date_i
			or		r16,r17
			sts		Date_i,r16
			ret

			
