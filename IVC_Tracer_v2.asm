;------------------------------------------------------------------------------
; Автоматическое снятие ВАХ солнечного модуля
; Вторая версия прибора
; Для снятия полной ветви ВАХ
; 
; (C) 2019-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; Fuses:
; Low Fuse 0xF7
; High Fuse 0xD4
; Extended Fuse 0xFD
; avrdude -U lfuse:w:0xF7:m -U hfuse:w:0xD4:m -U efuse:w:0xFD:m
; 
; Bootloader:
; optiboot_flash_atmega1284p_UART0_115200_18432000L_B7_BIGBOOT
; LED on PB7 (two blinks)
; https://github.com/MCUdude/optiboot_flash
; https://github.com/Optiboot/optiboot/wiki/HowOptibootWorks
;
; Burn flash via UART:
; avrdude -c arduino -b 115200 -P COM9 -p m1284p -U flash:w:IVC_Tracer_v2.hex:i
; 
; Burn flash via ISP:
; avrdude -c usbasp -p m1284p -B10 -U flash:w:IVC_Tracer_v2.hex
;
; History
; =======

;------------------------------------------------------------------------------

#define F_CPU (18432000)

;.device ATmega1284P
.nolist
.include "m1284Pdef.inc"
.include "macro.asm"
.include "eeprom_macro.asm"
.include "uart_macro.asm"
.list

.LISTMAC ; Включить разворачивание макросов


; Нулевой регистр
.ifndef __zero_reg__
.def __zero_reg__ = r2
.endif

; Используется энкодером
.def __enc_reg__ = r7

; Флаги
.equ enc_left_spin  = 0
.equ enc_right_spin = 1
.equ btn_press      = 2
.equ btn_long_press = 3
.equ update         = 4
.equ enc_channel    = 5
.equ menu_edit      = 6
.equ change_screen  = 7
;-------------------------------------------
.equ UART_IN_FULL   = 0		; Приемный буфер UART полон
;.equ UART_OUT_FULL  = 1		; Буфер отправки UART полон
.equ UART_STR_RCV   = 2		; Получена строка по UART
.equ UART_CR        = 3		; Флаг получения кода CR (0x0D) возврат каретки
;-------------------------------------------

; Размер приёмного буфера UART (255 max)
.equ MAXBUFF_IN	 =	64		; Размер входящего буфера

.equ IVC_MAX_RECORDS = 150

;-------------------------------------------
;                 Таймер T0                 |
;-------------------------------------------|
; время до переполнения таймера в милисекундах
#define period_T0 1
#define T0_Clock_Select (1<<CS02)|(0<<CS01)|(0<<CS00)
; вычисление начального значения
#define start_count_T0 (0x100-(period_T0*F_CPU/(256*1000)))

;-------------------------------------------
;                 Таймер T1                 |
;-------------------------------------------|
; время до переполнения таймера в милисекундах
#define period_T1 300
; вычисление начального значения
#define start_count_T1 (0x10000-(period_T1*F_CPU/(1024*1000)))

;-------------------------------------------
;                  HW SPI                   |
;-------------------------------------------|
.equ SPI_PORT     = PORTB
.equ SPI_DDR      = DDRB
.equ SPI_PIN      = PINB
.equ SPI_SS       = PB4
.equ SPI_MOSI     = PB5
.equ SPI_MISO     = PB6
.equ SPI_SCK      = PB7

;-------------------------------------------
;                 Encoder                   |
;-------------------------------------------|
.equ ENC_A        = PB0
.equ ENC_B        = PB1
.equ ENC_Btn      = PB2
.equ ENC_PORT     = PORTB
.equ ENC_DDR      = DDRB
.equ ENC_PIN      = PINB

#define Default_DAC_STEP       0x0005 ; 5
#define Default_IVC_DAC_START  0x03e8 ; 1000
#define Default_IVC_DAC_END    0x0708 ; 1800
#define Default_IVC_DAC_STEP   0x0064 ; 100
#define Default_CH0_DELTA      0x09C4 ; 2500
#define Default_CH1_DELTA      0x09C4 ; 2500
#define Default_ADC_V_REF      0x1388 ; 5000
#define Default_ACS712_KI      185
#define Default_RESDIV_KU      6  ; 
#define Default_ZERO_DAC       2048
#define Default_VREF_DAC       2048
#define Default_LIM_VOLT_NEG   0xA628 ; -23000 mV
#define Default_LIM_VOLT_POS   0x59D8 ;  23000 mV
#define Default_LIM_CURR_NEG   0xD8F0 ; -10000 mA
#define Default_LIM_CURR_POS   0x2710 ;  10000 mA

; Menu
.equ MAIN_SCREEN_ID        = 0
.equ CALIBRATION_SCREEN_ID = 1
.equ IVC_TRACE_SCREEN_ID   = 2

;===================================EEPROM=====================================
.eseg
.org 0x100
EEPROM_TEST:		.db 0 ; для проверки, если равно 0xFF, то EEPROM чиста и надо проинициализировать
E_DAC_STEP: 		.dw Default_DAC_STEP
E_IVC_DAC_START:	.dw Default_IVC_DAC_START
E_IVC_DAC_END:		.dw Default_IVC_DAC_END
E_IVC_DAC_STEP:		.dw Default_IVC_DAC_STEP
E_CH0_DELTA:		.dw Default_CH0_DELTA
E_CH1_DELTA:		.dw Default_CH1_DELTA
E_ADC_V_REF:		.dw Default_ADC_V_REF
E_ACS712_KI:        .dw Default_ACS712_KI
E_RESDIV_KU:        .dw Default_RESDIV_KU
E_ZERO_DAC:         .dw Default_ZERO_DAC
E_VREF_DAC:         .dw Default_VREF_DAC
E_LIM_VOLT_NEG:		.dw Default_LIM_VOLT_NEG
E_LIM_VOLT_POS:		.dw Default_LIM_VOLT_POS
E_LIM_CURR_NEG:		.dw Default_LIM_CURR_NEG
E_LIM_CURR_POS:		.dw Default_LIM_CURR_POS

;====================================DATA======================================
.dseg
ButtonCounter:	.byte	2	; количество тиков при нажатой кнопке энкодера
Flags:			.byte	1	; 
UART_Flags:		.byte	1	; флаги для UART
; Блок данных для операций с дисплеем
DataBlock:		.byte	17	; 
; Буферы для преобразования DEC2STR
STRING:			.byte	30
;------------------------
DAC_STEP:		.byte	2
IVC_DAC_START:	.byte	2
IVC_DAC_END:	.byte	2
IVC_DAC_STEP:	.byte	2
; Калибровка
CH0_DELTA:		.byte	2
CH1_DELTA:		.byte	2
ADC_V_REF:		.byte	2
ACS712_KI:		.byte	2
RESDIV_KU:		.byte	2
ZERO_DAC:		.byte	2
VREF_DAC:		.byte	2
; Лимиты
LIM_VOLT_NEG:	.byte	2
LIM_VOLT_POS:	.byte	2
LIM_CURR_NEG:	.byte	2
LIM_CURR_POS:	.byte	2
; Menu
menu_ID:    	.byte	1 ; идентификатор текущего пункта меню
screen_ID:  	.byte	1 ; идентификатор текущего экрана
;------------------------
IVC_ARRAY:		.byte	2*2*IVC_MAX_RECORDS
;------------------------
;====================================CODE======================================
.cseg
.org 0000
rjmp	RESET
.include "vectors_m1284p.inc"
;==============================================================================
;                           Обработчики прерываний
;                             Interrupt Handlers
;==============================================================================

;------------------------------------------------------------------------------
; Обработчик UART
;------------------------------------------------------------------------------
.include "uart_irq.asm"

;------------------------------------------------------------------------------
;           Прерывание таймера T0 по переполнению
;              Обслуживание энкодера и кнопки
;             Переполнение таймера каждую 1 мс
;------------------------------------------------------------------------------
OVF0_IRQ:
			push	r16 
			in		r16,SREG
			push	r16
			push	r17
			push	r24
			push	r25

			; переинициализация таймера
			ldi		r16,0x100-72  ;start_count_T0
			OutReg	TCNT0,r16

			;sbi		PORTB,1		; тестовый СД вкл.

			; поучение текущего состояния энкодера
			in		r16,ENC_PIN
			andi	r16,(1<<ENC_A)|(1<<ENC_B)
			;andi	r16,0b11000000
			;swap	r16
			;lsr 	r16
			;lsr 	r16

			; если предыдущее состояние равно текущему - выходим
			mov		r17,__enc_reg__	; загружаем последовательность состояний
			andi	r17,0b00000011	; отделяем только последнее
			cp		r17,r16 		; сравниваем
			breq	OVF0_IRQ_EXIT	; не изменилось - выходим

			; если же состояние изменилось
			lsl		__enc_reg__		; два раза
			lsl		__enc_reg__		;   сдвигаем
			or		__enc_reg__,r16	; добавляем новое состояние на освободившееся место

			; сравниваем получившуюся последовательность
			mov		r17,__enc_reg__
			cpi		r17,0b11100001
			brne	next_spin
			;sbr 	Flags_2,(1<<enc_left_spin)		; установка флага
			lds		r16,Flags
			ori		r16,(1<<enc_left_spin)
			sts		Flags,r16
			clr		__enc_reg__
			rjmp	OVF0_IRQ_EXIT
next_spin:
			cpi		r17,0b11010010
			brne	OVF0_IRQ_EXIT
			;sbr 	Flags_2,(1<<enc_right_spin)		; установка флага
			lds		r16,Flags
			ori		r16,(1<<enc_right_spin)
			sts		Flags,r16
			clr		__enc_reg__
			
OVF0_IRQ_EXIT:
			;cbi		PORTB,1		; тестовый СД выкл.

;--------------------------- Обработка нажатия на кнопку ---------------------------
			;sbis	BUTTON_PIN,BUTTON	; считываем состояние кнопки
			sbis	ENC_PIN,ENC_Btn
			rjmp	int1_low	; если кнопка нажата, переходим на int1_low
			; если кнопка не нажата (или уже отпущена?)
			lds		r24,ButtonCounter+0
			lds		r25,ButtonCounter+1
			;ldi		r16,0
			;ldi		r17,0
			;cp		r24,r16
			;cpc		r25,r17
			;breq	ovf0_exit
			ldi		r16,120
			ldi		r17,0
			cp		r24,r16
			cpc		r25,r17
			brlo	too_little_ticks	; мало удерживали кнопку
			; итак, набралось достаточно тиков
			; считаем это коротким нажатием
			; устанавливаем флаг короткого нажатия
			;sbr		Flags_2,(1<<btn_press) ; возведение флага
			lds		r16,Flags
			ori		r16,(1<<btn_press)
			sts		Flags,r16
			; и обнуляем ButtonCounter:
too_little_ticks:
			; если набралось до 164 тиков:
			; недостаточно долго держали, 
			; либо ложное срабатывание
			; обнуляем ButtonCounter
			;clr		r16
			sts		ButtonCounter+0,__zero_reg__
			sts		ButtonCounter+1,__zero_reg__
			rjmp	ovf0_exit
int1_low:
			; если кнопка нажата (INT1=0), то ButtonCounter++
			lds		r24,ButtonCounter+0
			lds		r25,ButtonCounter+1
			ldi		r16,low(1000)
			ldi		r17,high(1000)
			cp		r24,r16
			cpc		r25,r17
			brsh	long_button_press	; набралось много тиков (длинное нажатие)
			; если недостаточно, просто увеличиваем счетчик и выходим
			adiw	r24,1
			sts		ButtonCounter+0,r24
			sts		ButtonCounter+1,r25
			rjmp	ovf0_exit
long_button_press:
			; устанавливаем флаг длинного нажатия 
			; (удержание кнопки нажатой)
			;sbr		Flags_2,(1<<btn_long_press) ; возведение флага
			lds		r16,Flags
			ori		r16,(1<<btn_long_press)
			sts		Flags,r16
			; обнуляем ButtonCounter
			sts		ButtonCounter+0,__zero_reg__
			sts		ButtonCounter+1,__zero_reg__
ovf0_exit:
			pop		r25
			pop		r24
			pop		r17
			pop		r16
			out		SREG,r16
			pop		r16
			reti


;------------------------------------------------------------------------------
; Обработчик переполнения таймера T1
;------------------------------------------------------------------------------
OVF1_IRQ:
			push	r16
			in		r16,SREG
			push	r16
			;----------------
			; Усанавливаем флаг
			lds		r16,Flags
			ori		r16,(1<<update)
			sts		Flags,r16
			; переинициализация таймера
			ldi		r16,high(start_count_T1)
			OutReg	TCNT1H,r16
			ldi		r16,low(start_count_T1)
			OutReg	TCNT1L,r16
			;----------------
			pop		r16
			out		SREG,r16
			pop		r16
			reti

;==============================================================================
; EEPROM code
;==============================================================================

;------------------------------------------------------------------------------
; Инициализация EEPROM
;------------------------------------------------------------------------------
EEPROM_PRELOAD:
			ldi 	r16,low(EEPROM_TEST)	; Загружаем адрес ячейки EEPROM
			ldi 	r17,high(EEPROM_TEST)	; из которой хотим прочитать байт
			rcall 	EERead 					; (OUT: r18)
			cpi		r18,0xFF
			breq	EEPROM_INIT		; если равно 0xFF - память пуста, надо инициализировать
			ret 					; иначе - выходим
EEPROM_INIT:
			ldi		r16,low(EEPROM_TEST)
			ldi		r17,high(EEPROM_TEST)
			clr		r18
			rcall	EEWrite
			EEPROM_WRITE_WORD E_DAC_STEP,Default_DAC_STEP
			EEPROM_WRITE_WORD E_IVC_DAC_START,Default_IVC_DAC_START
			EEPROM_WRITE_WORD E_IVC_DAC_END,Default_IVC_DAC_END
			EEPROM_WRITE_WORD E_IVC_DAC_STEP,Default_IVC_DAC_STEP
			EEPROM_WRITE_WORD E_CH0_DELTA,Default_CH0_DELTA
			EEPROM_WRITE_WORD E_CH1_DELTA,Default_CH1_DELTA
			EEPROM_WRITE_WORD E_ADC_V_REF,Default_ADC_V_REF
			EEPROM_WRITE_WORD E_ACS712_KI,Default_ACS712_KI
			EEPROM_WRITE_WORD E_RESDIV_KU,Default_RESDIV_KU
			EEPROM_WRITE_WORD E_ZERO_DAC,Default_ZERO_DAC
			EEPROM_WRITE_WORD E_VREF_DAC,Default_VREF_DAC
			EEPROM_WRITE_WORD E_LIM_VOLT_NEG,Default_LIM_VOLT_NEG
			EEPROM_WRITE_WORD E_LIM_VOLT_POS,Default_LIM_VOLT_POS
			EEPROM_WRITE_WORD E_LIM_CURR_NEG,Default_LIM_CURR_NEG
			EEPROM_WRITE_WORD E_LIM_CURR_POS,Default_LIM_CURR_POS
			ret

;------------------------------------------------------------------------------
; Восстановление переменных из EEPROM в RAM
;------------------------------------------------------------------------------
EEPROM_RESTORE_VAR:
			EEPROM_READ_WORD E_DAC_STEP,DAC_STEP
			EEPROM_READ_WORD E_IVC_DAC_START,IVC_DAC_START
			EEPROM_READ_WORD E_IVC_DAC_END,IVC_DAC_END
			EEPROM_READ_WORD E_IVC_DAC_STEP,IVC_DAC_STEP
			EEPROM_READ_WORD E_CH0_DELTA,CH0_DELTA
			EEPROM_READ_WORD E_CH1_DELTA,CH1_DELTA
			EEPROM_READ_WORD E_ADC_V_REF,ADC_V_REF
			EEPROM_READ_WORD E_ACS712_KI,ACS712_KI
			EEPROM_READ_WORD E_RESDIV_KU,RESDIV_KU
			EEPROM_READ_WORD E_ZERO_DAC,ZERO_DAC
			EEPROM_READ_WORD E_VREF_DAC,VREF_DAC
			EEPROM_READ_WORD E_LIM_VOLT_NEG,LIM_VOLT_NEG
			EEPROM_READ_WORD E_LIM_VOLT_POS,LIM_VOLT_POS
			EEPROM_READ_WORD E_LIM_CURR_NEG,LIM_CURR_NEG
			EEPROM_READ_WORD E_LIM_CURR_POS,LIM_CURR_POS
			ret

;==============================================================================
; Main code
;==============================================================================
RESET:
			; Stack init
			ldi		r16, low(RAMEND)
			out		SPL, r16
			ldi		r16, high(RAMEND)
			out		SPH, r16

			; Обнуление памяти и регистров (объем кода: 80 байт прошивки)
			.include "coreinit.inc"

			; Нулевой регистр
			clr		__zero_reg__

			; Аналоговый компаратор выключен
			ldi		r16,1<<ACD
			out		ACSR,r16

			; Port A Init
			ldi		r16,0b00000000
			out		DDRA,r16
			ldi		r16,0b00000000
			out		PORTA,r16

			; Port B Init
			ldi		r16,0b10110000
			out		DDRB,r16
			ldi		r16,0b01001111
			out		PORTB,r16

			; Port C Init
			ldi		r16,0b00000000
			out		DDRC,r16
			ldi		r16,0b00000000
			out		PORTC,r16

			; Port D Init
			ldi 	r16,0b01100010
			out 	DDRD,r16
			ldi 	r16,0b01100011
			out 	PORTD,r16

			sts		Flags,__zero_reg__
			sts		UART_Flags,__zero_reg__

			;---------------------
			; Инициализация UART
			;---------------------
			USART_INIT
			;---------------------

			; Инициализация SPI
			rcall	SPI_INIT
			
			; Инициализация АЦП
			rcall	ADC_INIT

			; Инициализация ЦАП
			rcall	DAC_INIT

			; Восстановить переменные из EEPROM
			rcall	EEPROM_PRELOAD
			rcall	EEPROM_RESTORE_VAR

			; Инициализация интерпретатора команд UART
			call	UART_PARSER_INIT


			;------------------------------------------------------------------
			; Инициализация таймера Т0
			;------------------------------------------------------------------
			; Переполнение таймера каждую 1 мс
			; инициализация начального значения таймера
			ldi		r16,0x100-72  ;start_count_T0
			OutReg	TCNT0,r16
			#if defined (__ATmega328P__) || defined(__ATmega1284P__)
					; разрешение прерывания таймера T0 по переполнению
					InReg	r16,TIMSK0
					ori		r16,(1<<TOIE0)
					OutReg	TIMSK0,r16
					; Настройка предделителя 64
					ldi		r16,(1<<CS02)|(0<<CS01)|(0<<CS00)
					OutReg	TCCR0B,r16
			#elif defined (__ATmega16A__) || defined(__ATmega16__)
					; разрешение прерывания таймера T0 по переполнению
					InReg	r16,TIMSK
					ori		r16,(1<<TOIE0)
					OutReg	TIMSK,r16
					; Настройка предделителя 64
					ldi		r16,(1<<CS02)|(0<<CS01)|(0<<CS00)
					OutReg	TCCR0,r16
			#else
			#error "Unsupported part:" __PART_NAME__
			#endif // part specific code
			;------------------------------------------------------------------


			;------------------------------------------------------------------
			; Инициализация таймера Т1
			;------------------------------------------------------------------
			; инициализация начального значения таймера
			; от этого значения таймер будет считать до переполнения
			ldi		r16,high(start_count_T1)
			OutReg	TCNT1H,r16
			ldi		r16,low(start_count_T1)
			OutReg	TCNT1L,r16
			#if defined (__ATmega328P__) || defined(__ATmega1284P__)
					; разрешение прерывания таймера по переполнению
					InReg	r16,TIMSK1
					ori		r16,(1<<TOIE1)
					OutReg	TIMSK1,r16
					; Включить таймер Т1
					ldi		r16,5		; Установка предделителя 1024
					OutReg	TCCR1B,r16
			#elif defined (__ATmega16A__) || defined(__ATmega16__)
					; разрешение прерывания таймера по переполнению
					InReg	r16,TIMSK
					ori		r16,(1<<TOIE1)
					OutReg	TIMSK,r16
					; Включить таймер Т1
					ldi		r16,5		; Установка предделителя 1024
					OutReg	TCCR1B,r16
			#else
			#error "Unsupported part:" __PART_NAME__
			#endif // part specific code
			;------------------------------------------------------------------

			; Инициализация дисплея
			call	T6963C_Initalize
			call	T6963C_ClearText
			call	T6963C_ClearGraphic
			call	T6963C_ClearCG
			call	T6963C_FillCG


//			Проверочный вывод символов знакогенератора
//			clr		r20
//char_loop:
//			mov		r18,r20
//			rcall	T6963C_WriteDisplayData
//			inc		r20
//			cpi		r20,255
//			brne	char_loop
//			ldi		r18,255
//			rcall	T6963C_WriteDisplayData



			;ldi		r18,0
			;ldi		r19,100
			;ldi		r20,64
			;ldi		r21,8
			;rcall	T6963C_FillRectangle

			;ldi		r18,2
			;ldi		r19,102
			;ldi		r20,60
			;ldi		r21,4
			;rcall	T6963C_ClrRectangle

			; Шаг ЦАП
			ldi		r16,32
			sts		DAC_STEP+0,r16
			sts		DAC_STEP+1,__zero_reg__

			lds		r16,VREF_DAC+0
			sts		DAC_CH_A+0,r16
			lds		r16,VREF_DAC+1
			sts		DAC_CH_A+1,r16
			rcall	DAC_SET_A

			lds		r16,ZERO_DAC+0
			sts		DAC_CH_B+0,r16
			lds		r16,ZERO_DAC+1
			sts		DAC_CH_B+1,r16
			rcall	DAC_SET_B

			sei ; Разрешить прерывания

			lds		r16,Flags
			ori		r16,(1 << change_screen)
			sts		Flags,r16
			ldi		r16,MAIN_SCREEN_ID
			sts		screen_ID,r16
			rjmp	MENU_EVENT_HANDLER

;------------------------------------------------------------------------------
; Главный цикл. Проверяем флаги
;------------------------------------------------------------------------------
main:
			; На всякий случай. Вдруг сюда попадём
			rjmp	main


;------------------------------------------------------------------------------
;
;
;------------------------------------------------------------------------------
Encoder_left:
			lds		r24,DAC_CH_B+0		; уменьшаемое
			lds		r25,DAC_CH_B+1
			lds		r26,DAC_STEP+0	; вычитаемое
			lds		r27,DAC_STEP+1
			cp		r24,r26
			cpc		r25,r27
			brlo	DEC_DAC_TO_ZERO
			rcall	DECREMENT	; результат в r25:r24
			rjmp	DEC_DAC_SET
DEC_DAC_TO_ZERO:
			; если уменьшаемое меньше вычитаемого, то просто обнуляем уменьшаемое
			clr		r24
			clr		r25
DEC_DAC_SET:
			sts		DAC_CH_B+0,r24
			sts		DAC_CH_B+1,r25
			rcall	DAC_SET_B
			; Выводим значение на дисплей
			; Установить координаты вывода
			ldi		r18,11
			ldi		r19,2
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,DAC_CH_B+0
			lds		XH,DAC_CH_B+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret

;------------------------------------------------------------------------------
;
;
;------------------------------------------------------------------------------
Encoder_right:
			lds		r24,DAC_CH_B+0
			lds		r25,DAC_CH_B+1
			lds		r26,DAC_STEP+0
			lds		r27,DAC_STEP+1
			; Прибавляем шаг к текущему значению ЦАП
			rcall	INCREMENT	; результат в r25:r24
			; Проверяем, не превышает ли результат 4096
			ldi		r26,low(4096)
			ldi		r27,high(4096)
			cp		r24,r26
			cpc		r25,r27
			brlo	INC_DAC_SET
			; если превышает, то принудительно устанавливаем 4095
			ldi		r24,low(4095)
			ldi		r25,high(4095)
INC_DAC_SET:
			; Сохраняем результат
			sts		DAC_CH_B+0,r24
			sts		DAC_CH_B+1,r25
			; Передаем значение микросхеме
			rcall	DAC_SET_B
			; Выводим значение на дисплей
			; Установить координаты вывода
			ldi		r18,11
			ldi		r19,2
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,DAC_CH_B+0
			lds		XH,DAC_CH_B+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret



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

; IN: ADC_CH0
; OUT: r19:r18
;------------------------------------------------------------------------------
Calculate_current:
			; Преобразование кода АЦП в милливольты
			; Умножить на значение опорного напряжения в мВ
			lds		r16,ADC_CH0+0
			lds		r17,ADC_CH0+1
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
			ret


;------------------------------------------------------------------------------
; Преобразование кода АЦП в милливольты
; 
; Voltage_mV = (CH1_DELTA - (ADC_code * ADC_V_REF / 4096) ) * RESDIV_KU
; 
; IN: ADC_CH1
; OUT: r23:r22
;------------------------------------------------------------------------------
Calculate_voltage:
			; Преобразование кода АЦП в милливольты
			; Умножить на значение опорного напряжения в мВ
			lds		r16,ADC_CH1+0
			lds		r17,ADC_CH1+1
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
			ret


;------------------------------------------------------------------------------
;
;
;------------------------------------------------------------------------------
Event_update:
			;cli
			rcall	ADC_RUN
			;------------------------------------------------------
			; Установить координаты вывода
			ldi		r18,1
			ldi		r19,9
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,ADC_CH0+0
			lds		XH,ADC_CH0+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			
			rcall	Calculate_current

			; convert digit to string
			mov		XL,r18
			mov		XH,r19
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR7
			; Установить координаты вывода
			ldi		r18,1
			ldi		r19,8
			call	T6963C_TextGoTo
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			;.......................................................
			ldi		r20,104
			ldi		r21,56
			ldi		r22,16
			ldi		r23,31
			call	T6963C_ShiftLeftDataBlock
			; построить линию
			lds		r20,ADC_CH0+0
			lds		r21,ADC_CH0+1
			; поделить результат на 128
			add		r20,r20
			mov		r20,r21
			adc		r20,r20
			sbc		r21,r21
			neg		r21
			ldi		r18,231 ; x
			ldi		r19,87
			sub		r19,r20 ; y
			call	T6963C_VertLine ; (IN: r18 - x, r19 - y, r20 - height)
			;------------------------------------------------------
			; Установить координаты вывода
			ldi		r18,1
			ldi		r19,14
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,ADC_CH1+0
			lds		XH,ADC_CH1+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			
			rcall	Calculate_voltage

			; convert digit to string
			mov		XL,r22
			mov		XH,r23
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR7
			; Установить координаты вывода
			ldi		r18,1
			ldi		r19,13
			call	T6963C_TextGoTo
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			;.......................................................
			ldi		r20,104
			ldi		r21,96
			ldi		r22,16
			ldi		r23,31
			call	T6963C_ShiftLeftDataBlock
			; построить линию
			lds		r20,ADC_CH1+0
			lds		r21,ADC_CH1+1
			; поделить результат на 128
			add		r20,r20
			mov		r20,r21
			adc		r20,r20
			sbc		r21,r21
			neg		r21
			ldi		r18,231 ; x
			ldi		r19,127
			sub		r19,r20 ; y
			call	T6963C_VertLine ; (IN: r18 - x, r19 - y, r20 - height)
			;sei
			ret



.include "spi_hw.asm"
.include "MCP320x.asm"
.include "MCP492x.asm"
.include "eeprom.asm"
.include "math.asm"
.include "simple_menu.asm"

.include "convert.asm"

.include "uart_funcs.asm"
.include "strings.asm"
.include "cmd.asm"
.include "cmd_func.asm"

.include "wait.asm"
.include "t6963c.asm"

