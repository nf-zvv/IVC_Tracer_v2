;------------------------------------------------------------------------------
; Очень примитивная реализация меню
; Для каждого экрана есть свой обработчик событий и набор подпрограмм обработки этих стбытий
;
;
; (C) 2019-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; History
; =======
; 
;------------------------------------------------------------------------------




;------------------------------------------------------------------------------
; Заглушка
;------------------------------------------------------------------------------
void:
ret

;==============================================================================
;
;                    #                              
;                    #         ####    ####   #   ####  
;                    #        #    #  #    #  #  #    # 
;                    #        #    #  #       #  #      
;                    #        #    #  #  ###  #  #      
;                    #        #    #  #    #  #  #    # 
;                    #######   ####    ####   #   ####  
; 
;==============================================================================




;------------------------------------------------------------------------------
; Обработчик событий
; 
; 
;------------------------------------------------------------------------------
MENU_EVENT_HANDLER:
			lds		r16,Flags
			sbrs	r16,enc_left_spin
			rjmp	menu_event_handler_enc_right_spin
			; сработало событие enc_left_spin
			; сбросим флаг
			andi	r16,~(1 << enc_left_spin)
			sts		Flags,r16
			; выбираем действие в зависимости от текущего экрана
			lds		r16,screen_ID
			; Главный экран
			cpi		r16,MAIN_SCREEN_ID
			breq	main_scr_left_spin_action
			; Экран калибровки
			cpi		r16,CALIBRATION_SCREEN_ID
			breq	calib_scr_left_spin_action
			; Экран автоматического снятия ВАХ
			cpi		r16,IVC_TRACE_SCREEN_ID
			breq	ivc_trace_scr_left_spin_action
			; Некорректное значение screen_ID
			rjmp	menu_event_handler_enc_right_spin
main_scr_left_spin_action:
			rcall	main_scr_encoder_left
			rjmp	menu_event_handler_enc_right_spin
calib_scr_left_spin_action:
			rcall	calib_scr_encoder_left
			rjmp	menu_event_handler_enc_right_spin
ivc_trace_scr_left_spin_action:
			rcall	ivc_trace_scr_encoder_left
			;rjmp	menu_event_handler_enc_right_spin
;------------------------------------------------------------------------------
menu_event_handler_enc_right_spin:
			lds		r16,Flags
			sbrs	r16,enc_right_spin
			rjmp	menu_event_handler_btn_press
			; сработало событие enc_right_spin
			; сбросим флаг
			andi	r16,~(1 << enc_right_spin)
			sts		Flags,r16
			; выбираем действие в зависимости от текущего экрана
			lds		r16,screen_ID
			; Главный экран
			cpi		r16,MAIN_SCREEN_ID
			breq	main_scr_right_spin_action
			; Экран калибровки
			cpi		r16,CALIBRATION_SCREEN_ID
			breq	calib_scr_right_spin_action
			; Экран автоматического снятия ВАХ
			cpi		r16,IVC_TRACE_SCREEN_ID
			breq	ivc_trace_scr_right_spin_action
			; Некорректное значение screen_ID
			rjmp	menu_event_handler_btn_press
main_scr_right_spin_action:
			rcall	main_scr_encoder_right
			rjmp	menu_event_handler_btn_press
calib_scr_right_spin_action:
			rcall	calib_scr_encoder_right
			rjmp	menu_event_handler_btn_press
ivc_trace_scr_right_spin_action:
			rcall	ivc_trace_scr_encoder_right
			;rjmp	menu_event_handler_btn_press
;------------------------------------------------------------------------------
menu_event_handler_btn_press:
			lds		r16,Flags
			sbrs	r16,btn_press
			rjmp	menu_event_handler_btn_long_press
			; сработало событие btn_press
			; сбросим флаг
			andi	r16,~(1 << btn_press)
			sts		Flags,r16
			; выбираем действие в зависимости от текущего экрана
			lds		r16,screen_ID
			; Главный экран
			cpi		r16,MAIN_SCREEN_ID
			breq	main_scr_btn_press_action
			; Экран калибровки
			cpi		r16,CALIBRATION_SCREEN_ID
			breq	calib_scr_btn_press_action
			; Экран автоматического снятия ВАХ
			cpi		r16,IVC_TRACE_SCREEN_ID
			breq	ivc_trace_scr_btn_press_action
			; Некорректное значение screen_ID
			rjmp	menu_event_handler_btn_long_press
main_scr_btn_press_action:
			rcall	main_scr_btn_press
			rjmp	menu_event_handler_btn_long_press
calib_scr_btn_press_action:
			rcall	calib_scr_btn_press
			rjmp	menu_event_handler_btn_long_press
ivc_trace_scr_btn_press_action:
			rcall	ivc_trace_scr_btn_press
			;rjmp	menu_event_handler_btn_long_press
;------------------------------------------------------------------------------
menu_event_handler_btn_long_press:
			lds		r16,Flags
			sbrs	r16,btn_long_press
			rjmp	menu_event_handler_update
			; сработало событие btn_long_press
			; сбросим флаг
			andi	r16,~(1 << btn_long_press)
			sts		Flags,r16
			; выбираем действие в зависимости от текущего экрана
			lds		r16,screen_ID
			; Главный экран
			cpi		r16,MAIN_SCREEN_ID
			breq	main_scr_btn_long_press_action
			; Экран калибровки
			cpi		r16,CALIBRATION_SCREEN_ID
			breq	calib_scr_btn_long_press_action
			; Экран автоматического снятия ВАХ
			cpi		r16,IVC_TRACE_SCREEN_ID
			breq	ivc_trace_scr_btn_long_press_action
			; Некорректное значение screen_ID
			rjmp	menu_event_handler_update
main_scr_btn_long_press_action:
			rcall	void
			rjmp	menu_event_handler_update
calib_scr_btn_long_press_action:
			rcall	void
			rjmp	menu_event_handler_update
ivc_trace_scr_btn_long_press_action:
			rcall	void
			;rjmp	menu_event_handler_update
;------------------------------------------------------------------------------
menu_event_handler_update:
			lds		r16,Flags
			sbrs	r16,update
			rjmp	menu_event_handler_change_screen
			; сработало событие update
			; сбросим флаг
			andi	r16,~(1 << update)
			sts		Flags,r16
			; выбираем действие в зависимости от текущего экрана
			lds		r16,screen_ID
			; Главный экран
			cpi		r16,MAIN_SCREEN_ID
			breq	main_scr_update_action
			; Экран калибровки
			cpi		r16,CALIBRATION_SCREEN_ID
			breq	calib_scr_update_action
			; Экран автоматического снятия ВАХ
			cpi		r16,IVC_TRACE_SCREEN_ID
			breq	ivc_trace_scr_update_action
			; Некорректное значение screen_ID
			rjmp	menu_event_handler_change_screen
main_scr_update_action:
			rcall	main_scr_update
			rjmp	menu_event_handler_change_screen
calib_scr_update_action:
			rcall	calib_scr_update
			rjmp	menu_event_handler_change_screen
ivc_trace_scr_update_action:
			rcall	void
			;rjmp	menu_event_handler_change_screen
;------------------------------------------------------------------------------
menu_event_handler_change_screen:
			lds		r16,Flags
			sbrs	r16,change_screen
			rjmp	menu_event_handler_uart_rx_parse
			; сработало событие change_screen
			; сбросим флаг
			andi	r16,~(1 << change_screen)
			sts		Flags,r16
			; выбираем действие в зависимости от текущего экрана
			lds		r16,screen_ID
			; Главный экран
			cpi		r16,MAIN_SCREEN_ID
			breq	main_scr_change_screen_action
			; Экран калибровки
			cpi		r16,CALIBRATION_SCREEN_ID
			breq	calib_scr_change_screen_action
			; Экран автоматического снятия ВАХ
			cpi		r16,IVC_TRACE_SCREEN_ID
			breq	ivc_trace_scr_change_screen_action
			; Некорректное значение screen_ID
			rjmp	menu_event_handler_uart_rx_parse
main_scr_change_screen_action:
			rcall	MAIN_SCREEN
			rjmp	menu_event_handler_uart_rx_parse
calib_scr_change_screen_action:
			rcall	CALIBRATION_SCREEN
			rjmp	menu_event_handler_uart_rx_parse
ivc_trace_scr_change_screen_action:
			rcall	IVC_TRACE_SCREEN
			;rjmp	menu_event_handler_uart_rx_parse

;------------------------------------------------------------------------------
menu_event_handler_uart_rx_parse:
			lds		r16,UART_Flags
			sbrs	r16,UART_STR_RCV
			rjmp	menu_event_handler_end
			; сработало событие uart_rx_parse
			; сбросим флаг
			;andi	r16,~(1 << UART_STR_RCV)
			;sts		UART_Flags,r16
			; Сброс флага выполняется в начале подпрограммы UART_RX_PARSE
			call	UART_RX_PARSE
menu_event_handler_end:
			rjmp	MENU_EVENT_HANDLER






;------------------------------------------------------------------------------
; Главный экран
; Ожидание событий в цикле
; Обработка событий энкодера
;  - сброс флагов
;  - переход на подпрограмму-обработчик
; Обработка обновления параметров (update)
; 
; TODO: сделать регулировку "точно/грубо" вместо "значение+шаг"
; TODO: долгое нажатие на кнопку энкодера - сброс значения на дефолтное
;------------------------------------------------------------------------------
MAIN_SCREEN:
			rcall	PRINT_MAIN_SCREEN
			rcall	PRINT_MAIN_DEFAULT
			; Обнуляем указаель текущего пункта меню
			sts		menu_ID,__zero_reg__
			; Деактивируем пункт
			lds		r16,Flags
			andi	r16,~(1<<menu_edit)
			sts		Flags,r16
			; Курсор на первую строчку меню
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			ret


;------------------------------------------------------------------------------
; Главный экран
; Событие: поворот энкодера влево
; 
;------------------------------------------------------------------------------
main_scr_encoder_left:
			; сначала проверяем флаг редактирования
			lds		r16,Flags
			sbrs	r16,menu_edit
			rjmp	main_scr_encoder_left_noedit
;..............................................................................
			; пункт в режиме редактирования
			lds		r16,menu_ID
			cpi		r16,0
			breq	main_scr_encoder_left_dec_dac
			cpi		r16,1
			breq	main_scr_encoder_left_dec_dac_step
			rjmp	main_scr_encoder_left_exit
main_scr_encoder_left_dec_dac:
			rcall	Encoder_left
			rjmp	main_scr_encoder_left_exit
main_scr_encoder_left_dec_dac_step:
			rcall	main_scr_dec_dac_step
			rjmp	main_scr_encoder_left_exit
;..............................................................................
			; пункт не в режиме редактирования
main_scr_encoder_left_noedit:
			lds		r16,menu_ID
			; Загружаем в Z адрес таблицы переходов
			ldi		ZH,high(main_scr_encoder_left_TABLE)
			ldi		ZL,low(main_scr_encoder_left_TABLE)
			; добавляем смещение адреса
			add		ZL,r16
			adc		ZH,__zero_reg__
			ijmp
main_scr_encoder_left_TABLE:
			rjmp	main_scr_encoder_left_0
			rjmp	main_scr_encoder_left_1
			rjmp	main_scr_encoder_left_2
			rjmp	main_scr_encoder_left_3
main_scr_encoder_left_0:
			ldi		r16,3
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	main_scr_encoder_left_exit
main_scr_encoder_left_1:
			ldi		r16,0
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	main_scr_encoder_left_exit
main_scr_encoder_left_2:
			ldi		r16,1
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	main_scr_encoder_left_exit
main_scr_encoder_left_3:
			ldi		r16,2
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	main_scr_encoder_left_exit

main_scr_encoder_left_exit:
			ret

;------------------------------------------------------------------------------
; Главный экран
; Событие: поворот энкодера вправо
; 
;------------------------------------------------------------------------------
main_scr_encoder_right:
			; сначала проверяем флаг редактирования
			lds		r16,Flags
			sbrs	r16,menu_edit
			rjmp	main_scr_encoder_right_noedit
;..............................................................................
			; пункт в режиме редактирования
			lds		r16,menu_ID
			cpi		r16,0
			breq	main_scr_encoder_right_inc_dac
			cpi		r16,1
			breq	main_scr_encoder_right_inc_dac_step
			rjmp	main_scr_encoder_right_exit
main_scr_encoder_right_inc_dac:
			rcall	Encoder_right
			rjmp	main_scr_encoder_right_exit
main_scr_encoder_right_inc_dac_step:
			rcall	main_scr_inc_dac_step
			rjmp	main_scr_encoder_right_exit
;..............................................................................
			; пункт не в режиме редактирования
main_scr_encoder_right_noedit:
			lds		r16,menu_ID
			; Загружаем в Z адрес таблицы переходов
			ldi		ZH,high(main_scr_encoder_right_TABLE)
			ldi		ZL,low(main_scr_encoder_right_TABLE)
			; добавляем смещение адреса
			add		ZL,r16
			adc		ZH,__zero_reg__
			ijmp
main_scr_encoder_right_TABLE:
			rjmp	main_scr_encoder_right_0
			rjmp	main_scr_encoder_right_1
			rjmp	main_scr_encoder_right_2
			rjmp	main_scr_encoder_right_3
main_scr_encoder_right_0:
			ldi		r16,1
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	main_scr_encoder_right_exit
main_scr_encoder_right_1:
			ldi		r16,2
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	main_scr_encoder_right_exit
main_scr_encoder_right_2:
			ldi		r16,3
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	main_scr_encoder_right_exit
main_scr_encoder_right_3:
			ldi		r16,0
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	main_scr_encoder_right_exit
main_scr_encoder_right_exit:
			ret


;------------------------------------------------------------------------------
; 
; 
; 
; 
;------------------------------------------------------------------------------
main_scr_dec_dac_step:
			lds		r24,DAC_STEP+0
			lds		r25,DAC_STEP+1
			ldi		r26,1
			ldi		r27,0
			rcall	DECREMENT
			sts		DAC_STEP+0,r24
			sts		DAC_STEP+1,r25
			; Выводим значение DAC_STEP на дисплей
			; Преобразовать число в строку
			mov		XL,r24
			mov		XH,r25
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Установить координаты вывода
			ldi		r18,11
			ldi		r19,3
			call	T6963C_TextGoTo
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret



;------------------------------------------------------------------------------
; 
; 
; 
; 
;------------------------------------------------------------------------------
main_scr_inc_dac_step:
			lds		r24,DAC_STEP+0
			lds		r25,DAC_STEP+1
			ldi		r26,1
			ldi		r27,0
			rcall	INCREMENT
			sts		DAC_STEP+0,r24
			sts		DAC_STEP+1,r25
			; Выводим значение DAC_STEP на дисплей
			; Преобразовать число в строку
			mov		XL,r24
			mov		XH,r25
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Установить координаты вывода
			ldi		r18,11
			ldi		r19,3
			call	T6963C_TextGoTo
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret



;------------------------------------------------------------------------------
; Главный экран
; Событие: нажатие кнопки энкодера
;
; 
;------------------------------------------------------------------------------
main_scr_btn_press:
			; обработчик для пунктов "IVC Trace" и "Calibration"
			lds		r16,menu_ID
			cpi		r16,2 ;  пункт "IVC Trace"
			brne	main_scr_btn_press_3
			ldi		r16,IVC_TRACE_SCREEN_ID
			rjmp	main_scr_btn_press_change_screen
main_scr_btn_press_3:
			cpi		r16,3 ;  пункт "Calibration"
			brne	main_scr_btn_press_act
			ldi		r16,CALIBRATION_SCREEN_ID
main_scr_btn_press_change_screen:
			sts		screen_ID,r16
			lds		r16,Flags
			ori		r16,(1<<change_screen) ; установка флага смены меню
			sts		Flags,r16
			ret
;..............................................................................
main_scr_btn_press_act:
			; проверяем флаг редактирования
			lds		r16,Flags
			sbrs	r16,menu_edit
			rjmp	main_scr_btn_press_noedit
			; пункт в режиме редактирования (активирован)
			; тогда деактивируем пункт:
			andi	r16,~(1<<menu_edit)
			rjmp	main_scr_btn_press_exit
main_scr_btn_press_noedit:
			; пункт не в режиме редактирования (деактивирован)
			; тогда активируем пункт:
			ori		r16,(1<<menu_edit) ; установка флага
main_scr_btn_press_exit:
			sts		Flags,r16
			ret


;------------------------------------------------------------------------------
;
;
;
;------------------------------------------------------------------------------
main_scr_update:
			rcall	Event_update
			ret




;==============================================================================
; Экран калибровки
; 
; Поворотом ручки энкодера выбирается пункт меню,
; нажатием кнопки энкодера этот пункт активируется,
; поворотом ручки энкодера регулируется значение пункта меню,
; нажатием кнопки энкодера пункт деактивируется.


; Обработчик событий энкодера
; В зависимости от того, активирован пункт меню или нет:
; Поворот влево:
;  - переход на предыдущий пункт меню
;  - уменьшение текущего значения
; Поворот вправо:
;  - переход на следующий пункт меню
;  - увеличение текущего значения
;==============================================================================

;------------------------------------------------------------------------------
; Экран калибровки
; Ожидание событий в цикле
; Обработка событий энкодера
;  - сброс флагов
;  - переход на подпрограмму-обработчик
; Обработка события выхода из меню
;
;
;------------------------------------------------------------------------------
CALIBRATION_SCREEN:
			; Выводим содержимое меню
			rcall	PRINT_CALIBRATION_SCREEN
			; Вывести текущие значения
			rcall	PRINT_CALIBRATION_DEFAULT
			; Обнуляем указаель текущего пункта меню
			sts		menu_ID,__zero_reg__
			; Деактивируем пункт
			lds		r16,Flags
			andi	r16,~(1<<menu_edit)
			sts		Flags,r16
			; Курсор на первую строчку меню
			ldi		r18,0
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			ret


;------------------------------------------------------------------------------
; Экран калибровки
; Событие: поворот энкодера влево
; 
; 
;------------------------------------------------------------------------------
calib_scr_encoder_left:
			; сначала проверяем флаг редактирования
			lds		r16,Flags
			sbrs	r16,menu_edit
			rjmp	calib_scr_encoder_left_noedit
;..............................................................................
			; пункт в режиме редактирования
			lds		r16,menu_ID
			; Загружаем в Z адрес таблицы переходов
			ldi		ZH,high(calib_scr_encoder_left_ed_TABLE)
			ldi		ZL,low(calib_scr_encoder_left_ed_TABLE)
			; добавляем смещение адреса
			add		ZL,r16
			adc		ZH,__zero_reg__
			ijmp
calib_scr_encoder_left_ed_TABLE:
			rjmp	ZERO_DAC_DEC
			rjmp	VREF_DAC_DEC
			rjmp	CH0_DELTA_DEC
			rjmp	CH1_DELTA_DEC
			rjmp	ADC_V_REF_DEC
			rjmp	ACS712_KI_DEC
			rjmp	RESDIV_KU_DEC
			;rjmp	calib_scr_encoder_left_exit
ZERO_DAC_DEC:
			lds		r25,ZERO_DAC+1
			lds		r24,ZERO_DAC+0
			ldi		r27,0
			ldi		r26,1
			rcall	DECREMENT
			sts		ZERO_DAC+1,r25
			sts		ZERO_DAC+0,r24
			rjmp	calib_scr_encoder_left_exit
VREF_DAC_DEC:
			lds		r25,VREF_DAC+1
			lds		r24,VREF_DAC+0
			ldi		r27,0
			ldi		r26,1
			rcall	DECREMENT
			sts		VREF_DAC+1,r25
			sts		VREF_DAC+0,r24
			sts		DAC_CH_A+1,r25
			sts		DAC_CH_A+0,r24
			rcall	DAC_SET_A
			rjmp	calib_scr_encoder_left_exit
CH0_DELTA_DEC:
			lds		r25,CH0_DELTA+1
			lds		r24,CH0_DELTA+0
			ldi		r27,0
			ldi		r26,1
			rcall	DECREMENT
			sts		CH0_DELTA+1,r25
			sts		CH0_DELTA+0,r24
			rjmp	calib_scr_encoder_left_exit
CH1_DELTA_DEC:
			lds		r25,CH1_DELTA+1
			lds		r24,CH1_DELTA+0
			ldi		r27,0
			ldi		r26,1
			rcall	DECREMENT
			sts		CH1_DELTA+1,r25
			sts		CH1_DELTA+0,r24
			rjmp	calib_scr_encoder_left_exit
ADC_V_REF_DEC:
			lds		r25,ADC_V_REF+1
			lds		r24,ADC_V_REF+0
			ldi		r27,0
			ldi		r26,1
			rcall	DECREMENT
			sts		ADC_V_REF+1,r25
			sts		ADC_V_REF+0,r24
			rjmp	calib_scr_encoder_left_exit
ACS712_KI_DEC:
			lds		r24,ACS712_KI
			dec		r24
			sts		ACS712_KI,r24
			rjmp	calib_scr_encoder_left_exit
RESDIV_KU_DEC:
			lds		r24,RESDIV_KU
			dec		r24
			sts		RESDIV_KU,r24
			rjmp	calib_scr_encoder_left_exit
;..............................................................................
calib_scr_encoder_left_noedit:
			; пункт не в режиме редактирования
			lds		r16,menu_ID

			; Загружаем в Z адрес таблицы переходов
			ldi		ZH,high(calib_scr_encoder_left_TABLE)
			ldi		ZL,low(calib_scr_encoder_left_TABLE)
			; добавляем смещение адреса
			add		ZL,r16
			adc		ZH,__zero_reg__
			ijmp
calib_scr_encoder_left_TABLE:
			rjmp	calib_scr_encoder_left_0
			rjmp	calib_scr_encoder_left_1
			rjmp	calib_scr_encoder_left_2
			rjmp	calib_scr_encoder_left_3
			rjmp	calib_scr_encoder_left_4
			rjmp	calib_scr_encoder_left_5
			rjmp	calib_scr_encoder_left_6
			rjmp	calib_scr_encoder_left_7
			rjmp	calib_scr_encoder_left_8
calib_scr_encoder_left_0:
			ldi		r16,8
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,14
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_left_exit
calib_scr_encoder_left_1:
			ldi		r16,0
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,7
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_left_exit
calib_scr_encoder_left_2:
			ldi		r16,1
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,8
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,7
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_left_exit
calib_scr_encoder_left_3:
			ldi		r16,2
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,9
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,8
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_left_exit
calib_scr_encoder_left_4:
			ldi		r16,3
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,10
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,9
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_left_exit
calib_scr_encoder_left_5:
			ldi		r16,4
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,11
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,10
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_left_exit
calib_scr_encoder_left_6:
			ldi		r16,5
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,12
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,11
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_left_exit
calib_scr_encoder_left_7:
			ldi		r16,6
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,13
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,12
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_left_exit
calib_scr_encoder_left_8:
			ldi		r16,7
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,14
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,13
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
calib_scr_encoder_left_exit:
			ret

;------------------------------------------------------------------------------
; Экран калибровки
; Событие: поворот энкодера вправо
;
;
;------------------------------------------------------------------------------
calib_scr_encoder_right:
			; сначала проверяем флаг редактирования
			lds		r16,Flags
			sbrs	r16,menu_edit
			rjmp	calib_scr_encoder_right_noedit
;..............................................................................
			; пункт в режиме редактирования
			lds		r16,menu_ID
			; Загружаем в Z адрес таблицы переходов
			ldi		ZH,high(calib_scr_encoder_right_ed_TABLE)
			ldi		ZL,low(calib_scr_encoder_right_ed_TABLE)
			; добавляем смещение адреса
			add		ZL,r16
			adc		ZH,__zero_reg__
			ijmp
calib_scr_encoder_right_ed_TABLE:
			rjmp	ZERO_DAC_INC
			rjmp	VREF_DAC_INC
			rjmp	CH0_DELTA_INC
			rjmp	CH1_DELTA_INC
			rjmp	ADC_V_REF_INC
			rjmp	ACS712_KI_INC
			rjmp	RESDIV_KU_INC
ZERO_DAC_INC:
			lds		r25,ZERO_DAC+1
			lds		r24,ZERO_DAC+0
			ldi		r27,0
			ldi		r26,1
			rcall	INCREMENT
			sts		ZERO_DAC+1,r25
			sts		ZERO_DAC+0,r24
			rjmp	calib_scr_encoder_right_exit
VREF_DAC_INC:
			lds		r25,VREF_DAC+1
			lds		r24,VREF_DAC+0
			ldi		r27,0
			ldi		r26,1
			rcall	INCREMENT
			sts		VREF_DAC+1,r25
			sts		VREF_DAC+0,r24
			sts		DAC_CH_A+1,r25
			sts		DAC_CH_A+0,r24
			rcall	DAC_SET_A
			rjmp	calib_scr_encoder_right_exit
CH0_DELTA_INC:
			lds		r25,CH0_DELTA+1
			lds		r24,CH0_DELTA+0
			ldi		r27,0
			ldi		r26,1
			rcall	INCREMENT
			sts		CH0_DELTA+1,r25
			sts		CH0_DELTA+0,r24
			rjmp	calib_scr_encoder_right_exit
CH1_DELTA_INC:
			lds		r25,CH1_DELTA+1
			lds		r24,CH1_DELTA+0
			ldi		r27,0
			ldi		r26,1
			rcall	INCREMENT
			sts		CH1_DELTA+1,r25
			sts		CH1_DELTA+0,r24
			rjmp	calib_scr_encoder_right_exit
ADC_V_REF_INC:
			lds		r25,ADC_V_REF+1
			lds		r24,ADC_V_REF+0
			ldi		r27,0
			ldi		r26,1
			rcall	INCREMENT
			sts		ADC_V_REF+1,r25
			sts		ADC_V_REF+0,r24
			rjmp	calib_scr_encoder_right_exit
ACS712_KI_INC:
			lds		r24,ACS712_KI
			inc		r24
			sts		ACS712_KI,r24
			rjmp	calib_scr_encoder_right_exit
RESDIV_KU_INC:
			lds		r24,RESDIV_KU
			inc		r24
			sts		RESDIV_KU,r24
			rjmp	calib_scr_encoder_right_exit
;..............................................................................
calib_scr_encoder_right_noedit:
			; пункт не в режиме редактирования
			lds		r16,menu_ID
			; Загружаем в Z адрес таблицы переходов
			ldi		ZH,high(calib_scr_encoder_right_TABLE)
			ldi		ZL,low(calib_scr_encoder_right_TABLE)
			; добавляем смещение адреса
			add		ZL,r16
			adc		ZH,__zero_reg__
			ijmp
calib_scr_encoder_right_TABLE:
			rjmp	calib_scr_encoder_right_0
			rjmp	calib_scr_encoder_right_1
			rjmp	calib_scr_encoder_right_2
			rjmp	calib_scr_encoder_right_3
			rjmp	calib_scr_encoder_right_4
			rjmp	calib_scr_encoder_right_5
			rjmp	calib_scr_encoder_right_6
			rjmp	calib_scr_encoder_right_7
			rjmp	calib_scr_encoder_right_8
calib_scr_encoder_right_0:
			ldi		r16,1
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,7
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_right_exit
calib_scr_encoder_right_1:
			ldi		r16,2
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,7
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,8
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_right_exit
calib_scr_encoder_right_2:
			ldi		r16,3
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,8
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,9
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_right_exit
calib_scr_encoder_right_3:
			ldi		r16,4
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,9
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,10
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_right_exit
calib_scr_encoder_right_4:
			ldi		r16,5
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,10
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,11
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_right_exit
calib_scr_encoder_right_5:
			ldi		r16,6
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,11
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,12
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_right_exit
calib_scr_encoder_right_6:
			ldi		r16,7
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,12
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,13
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_right_exit
calib_scr_encoder_right_7:
			ldi		r16,8
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,13
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,14
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	calib_scr_encoder_right_exit
calib_scr_encoder_right_8:
			ldi		r16,0
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,14
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
calib_scr_encoder_right_exit:
			ret

;------------------------------------------------------------------------------
; Экран калибровки
; Событие: нажатие кнопки энкодера
;  - если находимся на пункте "Отмена" или "Сохранить и Выйти", 
;      то выполнить соответствующее действие
;  - иначе активируем или деактивируем пункт меню
;
; Для универсальности: сделать действие для каждого пункта меню
;  - нет действия вызов void
;  - активация/деактивация пункта меню
;  - вызов назначенной подпрограммы
;  - если подпрограмма не назначена (void), тогда активация/деактивация этого пункта
; Сделать таблицу переходов?
;------------------------------------------------------------------------------
calib_scr_btn_press:
			; обработчик для пунктов "Отмена" и "Сохранить и Выйти"
			lds		r16,menu_ID
			cpi		r16,7 ;  пункт "Сохранить и Выйти"
			brne	calib_scr_btn_press_8
			rcall	EEPROM_SAVE_CALIBRATIONS
			rjmp	calib_scr_btn_press_menu_exit
calib_scr_btn_press_8:
			cpi		r16,8 ;  пункт "Отмена"
			brne	calib_scr_btn_press_act
			call	EEPROM_RESTORE_VAR
calib_scr_btn_press_menu_exit:
			lds		r16,Flags
			ori		r16,(1<<change_screen) ; установка флага выхода из меню Калибровки
			sts		Flags,r16
			ldi		r16,MAIN_SCREEN_ID
			sts		screen_ID,r16
			ret
;..............................................................................
calib_scr_btn_press_act:
			; проверяем флаг редактирования
			lds		r16,Flags
			sbrs	r16,menu_edit
			rjmp	calib_scr_btn_press_noedit
			; пункт в режиме редактирования (активирован)
			; тогда деактивируем пункт:
			andi	r16,~(1<<menu_edit)
			rjmp	calib_scr_btn_press_exit
calib_scr_btn_press_noedit:
			; пункт не в режиме редактирования (деактивирован)
			; тогда активируем пункт:
			ori		r16,(1<<menu_edit) ; установка флага
calib_scr_btn_press_exit:
			sts		Flags,r16
			ret


;------------------------------------------------------------------------------
; 
; 
; С целью экономии числа перезаписей EEPROM добавлена проверка перед записью
;------------------------------------------------------------------------------
EEPROM_SAVE_CALIBRATIONS:
			; ZERO_DAC
			ldi		r16,low(E_ZERO_DAC+0)
			ldi		r17,high(E_ZERO_DAC+0)
			call	EERead
			lds		r19,ZERO_DAC+0
			cp		r18,r19
			breq	test_next_byte_1
			mov		r18,r19
			call	EEWrite
test_next_byte_1:
			ldi		r16,low(E_ZERO_DAC+1)
			ldi		r17,high(E_ZERO_DAC+1)
			call	EERead
			lds		r19,ZERO_DAC+1
			cp		r18,r19
			breq	test_next_byte_2
			mov		r18,r19
			call	EEWrite
test_next_byte_2:
			; VREF_DAC
			ldi		r16,low(E_VREF_DAC+0)
			ldi		r17,high(E_VREF_DAC+0)
			call	EERead
			lds		r19,VREF_DAC+0
			cp		r18,r19
			breq	test_next_byte_3
			mov		r18,r19
			call	EEWrite
test_next_byte_3:
			ldi		r16,low(E_VREF_DAC+1)
			ldi		r17,high(E_VREF_DAC+1)
			call	EERead
			lds		r19,VREF_DAC+1
			cp		r18,r19
			breq	test_next_byte_4
			mov		r18,r19
			call	EEWrite
test_next_byte_4:
			; CH0_DELTA
			ldi		r16,low(E_CH0_DELTA+0)
			ldi		r17,high(E_CH0_DELTA+0)
			call	EERead
			lds		r19,CH0_DELTA+0
			cp		r18,r19
			breq	test_next_byte_5
			mov		r18,r19
			call	EEWrite
test_next_byte_5:
			ldi		r16,low(E_CH0_DELTA+1)
			ldi		r17,high(E_CH0_DELTA+1)
			call	EERead
			lds		r19,CH0_DELTA+1
			cp		r18,r19
			breq	test_next_byte_6
			mov		r18,r19
			call	EEWrite
test_next_byte_6:
			; CH1_DELTA
			ldi		r16,low(E_CH1_DELTA+0)
			ldi		r17,high(E_CH1_DELTA+0)
			call	EERead
			lds		r19,CH1_DELTA+0
			cp		r18,r19
			breq	test_next_byte_7
			mov		r18,r19
			call	EEWrite
test_next_byte_7:
			ldi		r16,low(E_CH1_DELTA+1)
			ldi		r17,high(E_CH1_DELTA+1)
			call	EERead
			lds		r19,CH1_DELTA+1
			cp		r18,r19
			breq	test_next_byte_8
			mov		r18,r19
			call	EEWrite
test_next_byte_8:
			; ADC_V_REF
			ldi		r16,low(E_ADC_V_REF+0)
			ldi		r17,high(E_ADC_V_REF+0)
			call	EERead
			lds		r19,ADC_V_REF+0
			cp		r18,r19
			breq	test_next_byte_9
			mov		r18,r19
			call	EEWrite
test_next_byte_9:
			ldi		r16,low(E_ADC_V_REF+1)
			ldi		r17,high(E_ADC_V_REF+1)
			call	EERead
			lds		r19,ADC_V_REF+1
			cp		r18,r19
			breq	test_next_byte_10
			mov		r18,r19
			call	EEWrite
test_next_byte_10:
			; ACS712_KI
			ldi		r16,low(E_ACS712_KI)
			ldi		r17,high(E_ACS712_KI)
			call	EERead
			lds		r19,ACS712_KI
			cp		r18,r19
			breq	test_next_byte_11
			mov		r18,r19
			call	EEWrite
test_next_byte_11:
			; RESDIV_KU
			ldi		r16,low(E_RESDIV_KU)
			ldi		r17,high(E_RESDIV_KU)
			call	EERead
			lds		r19,RESDIV_KU
			cp		r18,r19
			breq	test_next_byte_12
			mov		r18,r19
			call	EEWrite
test_next_byte_12:
			ret


;------------------------------------------------------------------------------
; 
; 
; 
;------------------------------------------------------------------------------
calib_scr_update:
			rcall	ADC_RUN
			;..................................................................
			; Выводим "сырые" значения тока и напряжения
			; ........... Ток ...........
			; Установить координаты вывода
			ldi		r18,6
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,ADC_CH0+0
			lds		XH,ADC_CH0+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			; ........ Напряжение ........
			; Установить координаты вывода
			ldi		r18,18
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,ADC_CH1+0
			lds		XH,ADC_CH1+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			;..................................................................
			; Вывести реальные значение тока и напряжения
			; ........... Ток ...........
			rcall	Calculate_current ; ADC_code -> mA
			; convert digit to string
			mov		XL,r18
			mov		XH,r19
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR7
			; Установить координаты вывода
			ldi		r18,4
			ldi		r19,4
			call	T6963C_TextGoTo
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			; ........ Напряжение ........
			rcall	Calculate_voltage ; ADC_code -> mV
			; Установить координаты вывода
			ldi		r18,16
			ldi		r19,4
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			mov		XL,r22
			mov		XH,r23
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR7
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString

			rcall	PRINT_CALIBRATION_DEFAULT
			ret


;------------------------------------------------------------------------------
; Экран автоматического снятия ВАХ
; Обработка событий
;
;------------------------------------------------------------------------------
IVC_TRACE_SCREEN:
			rcall	PRINT_IVC_TRACE_SCREEN
			rcall	PRINT_IVC_TRACE_SCREEN_DEFAULT
			; Обнуляем указаель текущего пункта меню
			sts		menu_ID,__zero_reg__
			; Деактивируем пункт
			lds		r16,Flags
			andi	r16,~(1<<menu_edit)
			sts		Flags,r16
			; Курсор на первую строчку меню
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			ret


;------------------------------------------------------------------------------
; Экран автоматического снятия ВАХ
; Событие: поворот энкодера влево
; 
;------------------------------------------------------------------------------
ivc_trace_scr_encoder_left:
			; сначала проверяем флаг редактирования
			lds		r16,Flags
			sbrs	r16,menu_edit
			rjmp	ivc_trace_scr_encoder_left_noedit
;..............................................................................
			; пункт в режиме редактирования
			lds		r16,menu_ID
			cpi		r16,1
			breq	ivc_trace_scr_encoder_left_dec_dac_start
			cpi		r16,2
			breq	ivc_trace_scr_encoder_left_dec_dac_end
			cpi		r16,3
			breq	ivc_trace_scr_encoder_left_dec_dac_step
			rjmp	ivc_trace_scr_encoder_left_exit
ivc_trace_scr_encoder_left_dec_dac_start:
			rcall	IVC_TRACE_DAC_START_DEC
			rjmp	ivc_trace_scr_encoder_left_exit
ivc_trace_scr_encoder_left_dec_dac_end:
			rcall	IVC_TRACE_DAC_END_DEC
			rjmp	ivc_trace_scr_encoder_left_exit
ivc_trace_scr_encoder_left_dec_dac_step:
			rcall	IVC_TRACE_DAC_STEP_DEC
			rjmp	ivc_trace_scr_encoder_left_exit
;..............................................................................
			; пункт не в режиме редактирования
ivc_trace_scr_encoder_left_noedit:
			lds		r16,menu_ID
			; Загружаем в Z адрес таблицы переходов
			ldi		ZH,high(ivc_trace_scr_encoder_left_TABLE)
			ldi		ZL,low(ivc_trace_scr_encoder_left_TABLE)
			; добавляем смещение адреса
			add		ZL,r16
			adc		ZH,__zero_reg__
			ijmp
ivc_trace_scr_encoder_left_TABLE:
			rjmp	ivc_trace_scr_encoder_left_0
			rjmp	ivc_trace_scr_encoder_left_1
			rjmp	ivc_trace_scr_encoder_left_2
			rjmp	ivc_trace_scr_encoder_left_3
			rjmp	ivc_trace_scr_encoder_left_4
ivc_trace_scr_encoder_left_0:
			ldi		r16,4
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_left_exit
ivc_trace_scr_encoder_left_1:
			ldi		r16,0
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_left_exit
ivc_trace_scr_encoder_left_2:
			ldi		r16,1
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_left_exit
ivc_trace_scr_encoder_left_3:
			ldi		r16,2
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_left_exit
ivc_trace_scr_encoder_left_4:
			ldi		r16,3
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_left_exit
ivc_trace_scr_encoder_left_exit:
			ret

;------------------------------------------------------------------------------
; Экран автоматического снятия ВАХ
; Событие: поворот энкодера вправо
; 
;------------------------------------------------------------------------------
ivc_trace_scr_encoder_right:
			; сначала проверяем флаг редактирования
			lds		r16,Flags
			sbrs	r16,menu_edit
			rjmp	ivc_trace_scr_encoder_right_noedit
;..............................................................................
			; пункт в режиме редактирования
			lds		r16,menu_ID
			cpi		r16,1
			breq	ivc_trace_scr_encoder_right_inc_dac_start
			cpi		r16,2
			breq	ivc_trace_scr_encoder_right_inc_dac_end
			cpi		r16,3
			breq	ivc_trace_scr_encoder_right_inc_dac_step
			rjmp	ivc_trace_scr_encoder_right_exit
ivc_trace_scr_encoder_right_inc_dac_start:
			rcall	IVC_TRACE_DAC_START_INC
			rjmp	ivc_trace_scr_encoder_right_exit
ivc_trace_scr_encoder_right_inc_dac_end:
			rcall	IVC_TRACE_DAC_END_INC
			rjmp	ivc_trace_scr_encoder_right_exit
ivc_trace_scr_encoder_right_inc_dac_step:
			rcall	IVC_TRACE_DAC_STEP_INC
			rjmp	ivc_trace_scr_encoder_right_exit
;..............................................................................
			; пункт не в режиме редактирования
ivc_trace_scr_encoder_right_noedit:
			lds		r16,menu_ID
			; Загружаем в Z адрес таблицы переходов
			ldi		ZH,high(ivc_trace_scr_encoder_right_TABLE)
			ldi		ZL,low(ivc_trace_scr_encoder_right_TABLE)
			; добавляем смещение адреса
			add		ZL,r16
			adc		ZH,__zero_reg__
			ijmp
ivc_trace_scr_encoder_right_TABLE:
			rjmp	ivc_trace_scr_encoder_right_0
			rjmp	ivc_trace_scr_encoder_right_1
			rjmp	ivc_trace_scr_encoder_right_2
			rjmp	ivc_trace_scr_encoder_right_3
			rjmp	ivc_trace_scr_encoder_right_4
ivc_trace_scr_encoder_right_0:
			ldi		r16,1
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_right_exit
ivc_trace_scr_encoder_right_1:
			ldi		r16,2
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_right_exit
ivc_trace_scr_encoder_right_2:
			ldi		r16,3
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_right_exit
ivc_trace_scr_encoder_right_3:
			ldi		r16,4
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_right_exit
ivc_trace_scr_encoder_right_4:
			ldi		r16,0
			sts		menu_ID,r16
			ldi		r18,0
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		r18,' '
			call	T6963C_WriteChar
			ldi		r18,0
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		r18,'>'
			call	T6963C_WriteChar
			rjmp	ivc_trace_scr_encoder_right_exit
ivc_trace_scr_encoder_right_exit:
			ret


;------------------------------------------------------------------------------
; Экран автоматического снятия ВАХ
; Событие: нажатие кнопки энкодера
;
; 
;------------------------------------------------------------------------------
ivc_trace_scr_btn_press:
			; обработчик для пунктов "START" и "EXIT"
			lds		r16,menu_ID
			cpi		r16,0 ;  пункт "START"
			brne	ivc_trace_scr_btn_press_4
			rjmp	IVC_TRACE_BTN_START_PRESS
ivc_trace_scr_btn_press_4:
			cpi		r16,4 ;  пункт "EXIT"
			brne	ivc_trace_scr_btn_press_act
			; TODO: проверить изменены ли переменные и сохранить их при необходимости
			rcall	EEPROM_SAVE_IVC_VARS
			ldi		r16,MAIN_SCREEN_ID
			sts		screen_ID,r16
			lds		r16,Flags
			ori		r16,(1<<change_screen) ; установка флага смены меню
			sts		Flags,r16
			ret
;..............................................................................
ivc_trace_scr_btn_press_act:
			; проверяем флаг редактирования
			lds		r16,Flags
			sbrs	r16,menu_edit
			rjmp	ivc_trace_scr_btn_press_noedit
			; пункт в режиме редактирования (активирован)
			; тогда деактивируем пункт:
			andi	r16,~(1<<menu_edit)
			rjmp	ivc_trace_scr_btn_press_exit
ivc_trace_scr_btn_press_noedit:
			; пункт не в режиме редактирования (деактивирован)
			; тогда активируем пункт:
			ori		r16,(1<<menu_edit) ; установка флага
ivc_trace_scr_btn_press_exit:
			sts		Flags,r16
			ret


;------------------------------------------------------------------------------
; Сохранить переменные АВАХ в EEPROM, если они были изменены
;
; IVC_DAC_START, IVC_DAC_END, IVC_DAC_STEP, VAH_DELAY
;
;------------------------------------------------------------------------------
EEPROM_SAVE_IVC_VARS:
			; IVC_DAC_START
			ldi		r16,low(E_IVC_DAC_START+0)
			ldi		r17,high(E_IVC_DAC_START+0)
			call	EERead
			lds		r19,IVC_DAC_START+0
			cp		r18,r19
			breq	IVC_DAC_START_byte_1
			mov		r18,r19
			call	EEWrite
IVC_DAC_START_byte_1:
			ldi		r16,low(E_IVC_DAC_START+1)
			ldi		r17,high(E_IVC_DAC_START+1)
			call	EERead
			lds		r19,IVC_DAC_START+1
			cp		r18,r19
			breq	IVC_DAC_END_byte_0
			mov		r18,r19
			call	EEWrite
IVC_DAC_END_byte_0:
			; IVC_DAC_END
			ldi		r16,low(E_IVC_DAC_END+0)
			ldi		r17,high(E_IVC_DAC_END+0)
			call	EERead
			lds		r19,IVC_DAC_END+0
			cp		r18,r19
			breq	IVC_DAC_END_byte_1
			mov		r18,r19
			call	EEWrite
IVC_DAC_END_byte_1:
			ldi		r16,low(E_IVC_DAC_END+1)
			ldi		r17,high(E_IVC_DAC_END+1)
			call	EERead
			lds		r19,IVC_DAC_END+1
			cp		r18,r19
			breq	IVC_DAC_STEP_byte_0
			mov		r18,r19
			call	EEWrite
IVC_DAC_STEP_byte_0:
			; IVC_DAC_STEP
			ldi		r16,low(E_IVC_DAC_STEP+0)
			ldi		r17,high(E_IVC_DAC_STEP+0)
			call	EERead
			lds		r19,IVC_DAC_STEP+0
			cp		r18,r19
			breq	IVC_DAC_STEP_byte_1
			mov		r18,r19
			call	EEWrite
IVC_DAC_STEP_byte_1:
			ldi		r16,low(E_IVC_DAC_STEP+1)
			ldi		r17,high(E_IVC_DAC_STEP+1)
			call	EERead
			lds		r19,IVC_DAC_STEP+1
			cp		r18,r19
			breq	VAH_DELAY_byte_0
			mov		r18,r19
			call	EEWrite
VAH_DELAY_byte_0:
			; VAH_DELAY
			ldi		r16,low(E_VAH_DELAY+0)
			ldi		r17,high(E_VAH_DELAY+0)
			call	EERead
			lds		r19,VAH_DELAY+0
			cp		r18,r19
			breq	VAH_DELAY_byte_1
			mov		r18,r19
			call	EEWrite
VAH_DELAY_byte_1:
			ldi		r16,low(E_VAH_DELAY+1)
			ldi		r17,high(E_VAH_DELAY+1)
			call	EERead
			lds		r19,VAH_DELAY+1
			cp		r18,r19
			breq	SAVE_IVC_VARS_EXIT
			mov		r18,r19
			call	EEWrite
SAVE_IVC_VARS_EXIT:
			ret


;------------------------------------------------------------------------------
; Нажтие на кнопку запуска
; 
; Запуск процедуры автоматического снятия ВАХ
;
;------------------------------------------------------------------------------
IVC_TRACE_BTN_START_PRESS:
			; очистить область для вывода данных
			rcall	IVC_TRACE_START
			ret		; возвращает управление в IVC_TRACE_SCREEN 
			        ; в цикл IVC_TRACE_SCREEN_WAIT_EVENT


;------------------------------------------------------------------------------
; Запуск автоматического снятия ВАХ солнечного элемента/модуля
; Дополнение от 29.02.2020:
;   Если начальное значение ЦАП будет больше конечного, тогда 
;   вычитать шаг из начального пока не будет достигнуто конечное.
;   Это сделано с оой целью, чтобы идти от точки КЗ к точке ХХ
; 03.03.2020 Проведены некоторые оптимизации после вышеуказанного дополнения
;
; Вызовы: FLASH_CONST_TO_LCD, DAC_SET, ADC_RUN, PRINT_IVC_DATA_TO_UART,
;         WaitMiliseconds, подпрограммя для работы с дисплеем
; Используются: r3*, r4*, r12*, r13*, r16*, r17*, r22*, r23*, r24*, r25*, X*, Y*, Z*
; Вход: -
; Выход: IVC_ARRAY
;------------------------------------------------------------------------------
IVC_TRACE_START:
			; Отключаем таймер энкодера и кнопки
			clr		r16
			OutReg	TCCR0B,r16
			; наверное надо еще отключить таймер T1
			cli
			; сброс флага
			;lds		r16,Flags
			;andi	r16,~((1 << btn_long_press) | (1 << btn_press))
			;sts		Flags,r16
			; Сохраняем текущее значение ЦАП
			lds		r16,DAC_CH_B+0
			push	r16
			lds		r16,DAC_CH_B+1
			push	r16
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Текущее действие на дисплее
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Подготовка, инициализация переменных
; Измерения сохраняются в массив IVC_ARRAY
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			; Загружаем начальные значения
			lds		r22,IVC_DAC_START+0
			lds		r23,IVC_DAC_START+1
			lds		r24,IVC_DAC_STEP+0
			lds		r25,IVC_DAC_STEP+1
			lds		r12,IVC_DAC_END+0
			lds		r13,IVC_DAC_END+1
			; Массив, куда сохраняем результаты
			ldi		YL,low(IVC_ARRAY)
			ldi		YH,high(IVC_ARRAY)
			clr		r3	; счетчик измерений
			; Сравниваем начальное и конечное значение ЦАП
			cp		r22,r12
			cpc		r23,r13
			brlo	VAH_LOOP_FORWARD
			mov		r4,__zero_reg__ ; если IVC_DAC_START > IVC_DAC_END
			rjmp	VAH_LOOP
VAH_LOOP_FORWARD:
			ldi		r16,1           ; если IVC_DAC_START < IVC_DAC_END
			mov		r4,r16
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Цикл измерений
; Устанавливаем значение ЦАП и считываем показания тока и напряжения
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VAH_LOOP:
			; 1. устанавливаем новое значение ЦАП
			sts		DAC_CH_B+0,r22
			sts		DAC_CH_B+1,r23
			rcall	DAC_SET_B
			; 2. задержка после смены значения (для завершения перех. процессов)
			lds		r16,VAH_DELAY
			call	WaitMiliseconds		; [использует регистры r16 и X]
			; 3. считываем значение каналов АЦП
			call	ADC_RUN
			; 4. схораняем результат в память
			lds		r16,ADC_CH0+1
			st		Y+,r16
			lds		r16,ADC_CH0+0
			st		Y+,r16
			; 6. схораняем результат в IVC_ARRAY
			lds		r16,ADC_CH2+1
			st		Y+,r16
			lds		r16,ADC_CH2+0
			st		Y+,r16
			; Увеличиваем счетчик числа измерений
			inc		r3
			; Определяем направление изменения ЦАП
			tst		r4
			brne	VAH_LOOP_INC
			breq	VAH_LOOP_DEC
VAH_LOOP_INC:
			; Берём следующее значение
			; r23:r22 = r23:r22 + r25:r24
			add		r22,r24
			adc		r23,r25
			; Проверка (не дошли ли до конца?)
			cp		r22,r12		; не подошли ли к IVC_DAC_END
			cpc		r23,r13
			brlo	VAH_LOOP
			rjmp	VAH_LOOP_END
VAH_LOOP_DEC:
			; Берём следующее значение
			; r23:r22 = r23:r22 - r25:r24
			sub		r22,r24
			sbc		r23,r25
			; Проверка (не дошли ли до конца?)
			cp		r22,r12		; не подошли ли к IVC_DAC_END
			cpc		r23,r13
			brsh	VAH_LOOP
VAH_LOOP_END:
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Вывести на дисплей количество снятых точек
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			mov		r16,r3
			rcall	Bin1ToBCD3
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Отправка результатов на компьютер по UART
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			rcall	PRINT_IVC_DATA_TO_UART
			; Восстанавливаем значение ЦАП до экспримента
			pop		r16
			sts		DAC_CH_B+1,r16
			pop		r16
			sts		DAC_CH_B+0,r16
			rcall	DAC_SET_B
			; Небольшая задержка
			ldi		r16,250
			call	WaitMiliseconds		; использует регистры r16 и X
			ldi		r16,250
			call	WaitMiliseconds		; использует регистры r16 и X
			sei
			; Включаем таймер T1
			; .....
			; Включаем таймер энкодера и кнопки
			ldi		r16,T0_Clock_Select
			OutReg	TCCR0B,r16
			ret


;------------------------------------------------------------------------------
; Отправка результатов на компьютер по UART
; 
; Вызовы: DEC_TO_STR5, DEC_TO_STR7, Calculate_current, Calculate_voltage, 
;         STRING_TO_UART
; Используются:
; Вход: IVC_ARRAY
; Выход: <UART>
;------------------------------------------------------------------------------
PRINT_IVC_DATA_TO_UART:
			; Загружаем начальные значения
			lds		r22,IVC_DAC_START+0
			lds		r23,IVC_DAC_START+1
			lds		r24,IVC_DAC_STEP+0
			lds		r25,IVC_DAC_STEP+1
			lds		r12,IVC_DAC_END+0
			lds		r13,IVC_DAC_END+1
			; Массив с данными
			ldi		ZL,low(IVC_ARRAY)
			ldi		ZH,high(IVC_ARRAY)
			; Сравниваем начальное и конечное значение ЦАП
			cp		r22,r12
			cpc		r23,r13
			brlo	PRINT_IVC_DATA_TO_UART_FORWARD
			ldi		r16,0
			mov		r4,r16     ; если IVC_DAC_START > IVC_DAC_END
			rjmp	PRINT_IVC_DATA_TO_UART_LOOP
PRINT_IVC_DATA_TO_UART_FORWARD:
			ldi		r16,1
			mov		r4,r16     ; если IVC_DAC_START < IVC_DAC_END
PRINT_IVC_DATA_TO_UART_LOOP:
			; Подготавливаем для вывода DAC
			mov		XL,r22
			mov		XH,r23
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR5
			; Надо удалить последний символ в строке! Там 0 стоит
			ld		r16,-Y
			; Разделитель - табуляция
			ldi		r16,9
			st		Y+,r16
			; Подготавливаем для вывода ток
			ld		r16,Z+ ; Извлекаем младший байт АЦП
			ld		r17,Z+ ; Извлекаем старший байт АЦП
			call	Calculate_current ; (IN: r17:r16, OUT: r19:r18)
			; Преобразовать в строку
			mov		XL,r18
			mov		XH,r19
			;ldi		YL,low(STRING)
			;ldi		YH,high(STRING)
			rcall	DEC_TO_STR7
			; Надо удалить последний символ в строке! Там 0 стоит
			ld		r16,-Y
			; Разделитель - табуляция
			ldi		r16,9
			st		Y+,r16
			; Подготавливаем для вывода напряжение
			ld		r16,Z+	; младший байт АЦП
			ld		r17,Z+	; старший байт АЦП
			call	Calculate_voltage ; (IN: r17:r16, OUT: r19:r18)
			; Преобразовать в строку
			mov		XL,r18
			mov		XH,r19
			;ldi		YL,low(STRING)
			;ldi		YH,high(STRING)
			rcall	DEC_TO_STR5
			; Надо удалить последний символ в строке! Там 0 стоит
			ld		r16,-Y
			; Конец строки
			ldi		r16,13
			st		Y+,r16
			ldi		r16,10
			st		Y+,r16
			clr		r16
			st		Y+,r16
			; Отправить число по UART
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			rcall	STRING_TO_UART
			; Теперь нужно увеличить или уменьшить r23:r22
			; Проверить не превысило ли, или наоборот, не стало ли ниже конечного значения
			; И при необходимости вернуться на исходную метку
			tst		r4
			brne	PRINT_IVC_DATA_TO_UART_INC
			breq	PRINT_IVC_DATA_TO_UART_DEC
PRINT_IVC_DATA_TO_UART_INC:
			; Либо это:
			; r23:r22 = r23:r22 + r25:r24
			add		r22,r24
			adc		r23,r25
			; Сравниваем начальное и конечное значение ЦАП
			cp		r22,r12
			cpc		r23,r13
			brlo	PRINT_IVC_DATA_TO_UART_LOOP
			rjmp	PRINT_IVC_DATA_TO_UART_EXIT
PRINT_IVC_DATA_TO_UART_DEC:
			; Либо вот это:
			; r23:r22 = r23:r22 - r25:r24
			sub		r22,r24
			sbc		r23,r25
			; Сравниваем начальное и конечное значение ЦАП
			cp		r22,r12
			cpc		r23,r13
			brsh	PRINT_IVC_DATA_TO_UART_LOOP
PRINT_IVC_DATA_TO_UART_EXIT:
			ret



;------------------------------------------------------------------------------
;
;
;
;------------------------------------------------------------------------------
IVC_TRACE_DAC_START_INC:
			lds		r24,IVC_DAC_START+0
			lds		r25,IVC_DAC_START+1
			ldi		r26,1
			ldi		r27,0
			; r25:r24 = r25:r24 + r27:r26
			rcall	INCREMENT	; результат в r25:r24
			sts		IVC_DAC_START+0,r24
			sts		IVC_DAC_START+1,r25
			; Установить координаты вывода
			ldi		r18,13
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,IVC_DAC_START+0
			lds		XH,IVC_DAC_START+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR5
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret

;------------------------------------------------------------------------------
;
;
;
;------------------------------------------------------------------------------
IVC_TRACE_DAC_END_INC:
			lds		r24,IVC_DAC_END+0
			lds		r25,IVC_DAC_END+1
			ldi		r26,1
			ldi		r27,0
			; r25:r24 = r25:r24 + r27:r26
			rcall	INCREMENT	; результат в r25:r24
			sts		IVC_DAC_END+0,r24
			sts		IVC_DAC_END+1,r25
			; Установить координаты вывода
			ldi		r18,13
			ldi		r19,4
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,IVC_DAC_END+0
			lds		XH,IVC_DAC_END+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR5
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret

;------------------------------------------------------------------------------
;
;
;
;------------------------------------------------------------------------------
IVC_TRACE_DAC_STEP_INC:
			lds		r24,IVC_DAC_STEP+0
			lds		r25,IVC_DAC_STEP+1
			ldi		r26,1
			ldi		r27,0
			; r25:r24 = r25:r24 + r27:r26
			rcall	INCREMENT	; результат в r25:r24
			sts		IVC_DAC_STEP+0,r24
			sts		IVC_DAC_STEP+1,r25
			; Установить координаты вывода
			ldi		r18,13
			ldi		r19,5
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,IVC_DAC_STEP+0
			lds		XH,IVC_DAC_STEP+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR5
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret


;------------------------------------------------------------------------------
;
;
;
;------------------------------------------------------------------------------
IVC_TRACE_DAC_START_DEC:
			lds		r24,IVC_DAC_START+0
			lds		r25,IVC_DAC_START+1
			ldi		r26,1
			ldi		r27,0
			; r25:r24 = r25:r24 - r27:r26
			;rcall	DECREMENT	; результат в r25:r24
			sub		r24,r26
			sbc		r25,r27
			sts		IVC_DAC_START+0,r24
			sts		IVC_DAC_START+1,r25
			; Установить координаты вывода
			ldi		r18,13
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,IVC_DAC_START+0
			lds		XH,IVC_DAC_START+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR5
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret


;------------------------------------------------------------------------------
;
;
;
;------------------------------------------------------------------------------
IVC_TRACE_DAC_END_DEC:
			lds		r24,IVC_DAC_END+0
			lds		r25,IVC_DAC_END+1
			ldi		r26,1
			ldi		r27,0
			; r25:r24 = r25:r24 - r27:r26
			;rcall	DECREMENT	; результат в r25:r24
			sub		r24,r26
			sbc		r25,r27
			sts		IVC_DAC_END+0,r24
			sts		IVC_DAC_END+1,r25
			; Установить координаты вывода
			ldi		r18,13
			ldi		r19,4
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,IVC_DAC_END+0
			lds		XH,IVC_DAC_END+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			rcall	DEC_TO_STR5
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret


;------------------------------------------------------------------------------
;
;
;
;------------------------------------------------------------------------------
IVC_TRACE_DAC_STEP_DEC:
			lds		r24,IVC_DAC_STEP+0
			lds		r25,IVC_DAC_STEP+1
			ldi		r26,1
			ldi		r27,0
			; r25:r24 = r25:r24 - r27:r26
			;rcall	DECREMENT	; результат в r25:r24
			sub		r24,r26
			sbc		r25,r27
			sts		IVC_DAC_STEP+0,r24
			sts		IVC_DAC_STEP+1,r25
			; Установить координаты вывода
			ldi		r18,13
			ldi		r19,5
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,IVC_DAC_STEP+0
			lds		XH,IVC_DAC_STEP+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret




;==============================================================================
;
;           #####                                              
;          #     #  #####     ##    #####   #    #  #   ####    ####  
;          #        #    #   #  #   #    #  #    #  #  #    #  #      
;          #  ####  #    #  #    #  #    #  ######  #  #        ####  
;          #     #  #####   ######  #####   #    #  #  #            # 
;          #     #  #   #   #    #  #       #    #  #  #    #  #    # 
;           #####   #    #  #    #  #       #    #  #   ####    ####  
;
;==============================================================================

;------------------------------------------------------------------------------
; Главный экран
;    ________________________________
;  0 |           Realtime           |
;  1 |                              |
;  2 | DAC:      xxxx               |
;  3 | DAC_STEP: xxxx               |
;  4 | IVC_TRACE                    |
;  5 | CALIBRATION                  |
;  6 |              _______________ |
;  7 | Ток         |              | |
;  8 | -xxxxxмА    |              | |
;  9 | xxxx        |              | |
; 10 |             |______________| |
; 11 |              _______________ |
; 12 | Напряжение  |              | |
; 13 | -xxxxxмВ    |              | |
; 14 | xxxx        |              | |
; 15 |_____________|______________|_|
;
; На главном экране разместить:
;  - Ручное регулирование ЦАП (DAC)
;  - Шаг ЦАП
;  - Запуск А.ВАХ
;  - Калибровка
;  - Значение (мА) и график изменения тока
;  - Значение (мВ) и график изменения напряжения
; Значения тока и напряжения показывать с учетом калибровки

;------------------------------------------------------------------------------
PRINT_MAIN_SCREEN:
			; очистка экрана
			call	T6963C_ClearText
			call	T6963C_ClearGraphic

			ldi		r18,11
			ldi		r19,0
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_REALTIME*2)
			ldi		ZH,high(STR_REALTIME*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_DAC*2)
			ldi		ZH,high(STR_DAC*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_DAC_STEP*2)
			ldi		ZH,high(STR_DAC_STEP*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_IVC_TRACE*2)
			ldi		ZH,high(STR_IVC_TRACE*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_CALIBRATION_EN*2)
			ldi		ZH,high(STR_CALIBRATION_EN*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,7
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_CURRENT*2)
			ldi		ZH,high(STR_CURRENT*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,12
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_VOLTAGE*2)
			ldi		ZH,high(STR_VOLTAGE*2)
			call	T6963C_WriteStringPgm

			ldi		r18,7
			ldi		r19,8
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_MA*2)
			ldi		ZH,high(STR_MA*2)
			call	T6963C_WriteStringPgm

			ldi		r18,7
			ldi		r19,13
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_MV*2)
			ldi		ZH,high(STR_MV*2)
			call	T6963C_WriteStringPgm

			ldi		r18,103
			ldi		r19,55
			ldi		r20,130
			ldi		r21,33
			call	T6963C_Rectangle

			ldi		r18,103
			ldi		r19,95
			ldi		r20,130
			ldi		r21,33
			call	T6963C_Rectangle

			ret


;------------------------------------------------------------------------------
; Экран калибровки
; Вывести текущие значения параметров
;
;------------------------------------------------------------------------------
PRINT_MAIN_DEFAULT:
			; Выводим значение DAC на дисплей
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
			; Выводим значение DAC_STEP на дисплей
			; Установить координаты вывода
			ldi		r18,11
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,DAC_STEP+0
			lds		XH,DAC_STEP+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести числа на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret


;------------------------------------------------------------------------------
; Экран калибровки
;    ________________________________
;  0 |          Калибровка          |
;  1 |                              |
;  2 |      Ток       Напряжение    |
;  3 |      xxxx        xxxx        |
;  4 |    -xxxxx мА   -xxxxx мВ     |
;  5 |                              |
;  6 |>ZERO_DAC        <xxxx>       |
;  7 | VREF_DAC         xxxx        |
;  8 | CH0_DELTA        xxxx        |
;  9 | CH1_DELTA        xxxx        |
; 10 | ADC_V_REF        xxxx        |
; 11 | ACS712_KI        xxxx        |
; 12 | RESDIV_KU        xxxx        |
; 13 | SAVE & EXIT                  |
; 14 | CANCEL                       |
; 15 |______________________________|
; 
;------------------------------------------------------------------------------
PRINT_CALIBRATION_SCREEN:
			; очистка экрана
			call	T6963C_ClearText
			call	T6963C_ClearGraphic
			; 
			ldi		r18,10
			ldi		r19,0
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_CALIBRATION*2)
			ldi		ZH,high(STR_CALIBRATION*2)
			call	T6963C_WriteStringPgm

			ldi		r18,6
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_CURRENT*2)
			ldi		ZH,high(STR_CURRENT*2)
			call	T6963C_WriteStringPgm

			ldi		r18,16
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_VOLTAGE*2)
			ldi		ZH,high(STR_VOLTAGE*2)
			call	T6963C_WriteStringPgm

			ldi		r18,11
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_MA*2)
			ldi		ZH,high(STR_MA*2)
			call	T6963C_WriteStringPgm

			ldi		r18,23
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_MV*2)
			ldi		ZH,high(STR_MV*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_ZERO_DAC*2)
			ldi		ZH,high(STR_ZERO_DAC*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,7
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_VREF_DAC*2)
			ldi		ZH,high(STR_VREF_DAC*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,8
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_CH0_DELTA*2)
			ldi		ZH,high(STR_CH0_DELTA*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,9
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_CH1_DELTA*2)
			ldi		ZH,high(STR_CH1_DELTA*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,10
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_ADC_V_REF*2)
			ldi		ZH,high(STR_ADC_V_REF*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,11
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_ACS712_KI*2)
			ldi		ZH,high(STR_ACS712_KI*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,12
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_RESDIV_KU*2)
			ldi		ZH,high(STR_RESDIV_KU*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,13
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_SAVE_EXIT*2)
			ldi		ZH,high(STR_SAVE_EXIT*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,14
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_CANCEL*2)
			ldi		ZH,high(STR_CANCEL*2)
			call	T6963C_WriteStringPgm
			ret
			
;------------------------------------------------------------------------------
; Экран калибровки
; Вывести текущие значения параметров
;
;------------------------------------------------------------------------------
PRINT_CALIBRATION_DEFAULT:
			; Вывод текущих значений показателей
			;ZERO_DAC:		.byte	2
			;VREF_DAC:		.byte	2
			;CH0_DELTA:		.byte	2
			;CH1_DELTA:		.byte	2
			;ADC_V_REF:		.byte	2
			;ACS712_KI:		.byte	1
			;RES_DIV_KU:	.byte	1
			

			; Установить координаты вывода
			ldi		r18,14
			ldi		r19,6
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,ZERO_DAC+0
			lds		XH,ZERO_DAC+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString

			; Установить координаты вывода
			ldi		r18,14
			ldi		r19,7
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,VREF_DAC+0
			lds		XH,VREF_DAC+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString

			; Установить координаты вывода
			ldi		r18,14
			ldi		r19,8
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,CH0_DELTA+0
			lds		XH,CH0_DELTA+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString

			; Установить координаты вывода
			ldi		r18,14
			ldi		r19,9
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,CH1_DELTA+0
			lds		XH,CH1_DELTA+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString

			; Установить координаты вывода
			ldi		r18,14
			ldi		r19,10
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,ADC_V_REF+0
			lds		XH,ADC_V_REF+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString

			; Установить координаты вывода
			ldi		r18,14
			ldi		r19,11
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,ACS712_KI
			clr		XH
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString

			; Установить координаты вывода
			ldi		r18,14
			ldi		r19,12
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,RESDIV_KU
			clr		XH
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString


			ret



;------------------------------------------------------------------------------
; IVC Trace
;    ________________________________
;  0 |          IVC Trace           |
;  1 |                              |
;  2 | START                        |
;  3 | DAC_start   xxxx             |
;  4 | DAC_end     xxxx             |
;  5 | DAC_step    xxxx             |
;  6 | EXIT                         |
;  7 |                              |
;  8 |                              |
;  9 |                              |
; 10 |                              |
; 11 |                              |
; 12 |                              |
; 13 |                              |
; 14 |                              |
; 15 |______________________________|
; Может сделать такое расположение?
;    ________________________________
;  2 | DAC_start  DAC_end  DAC_step |
;  3 |  xxxx       xxxx     xxxx    |
;  4 |______________________________|
;
; Места меньше будет занимать 
; и будет больше места для графика ВАХ
;------------------------------------------------------------------------------
PRINT_IVC_TRACE_SCREEN:
			; очистка экрана
			call	T6963C_ClearText
			call	T6963C_ClearGraphic
			; 
			ldi		r18,10
			ldi		r19,0
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_IVC_TRACE_2*2)
			ldi		ZH,high(STR_IVC_TRACE_2*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_START*2)
			ldi		ZH,high(STR_START*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_DAC_START*2)
			ldi		ZH,high(STR_DAC_START*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_DAC_END*2)
			ldi		ZH,high(STR_DAC_END*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_DAC_STEP*2)
			ldi		ZH,high(STR_DAC_STEP*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_EXIT*2)
			ldi		ZH,high(STR_EXIT*2)
			call	T6963C_WriteStringPgm
			ret

PRINT_IVC_TRACE_SCREEN_DEFAULT:
			; Установить координаты вывода
			ldi		r18,13
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,IVC_DAC_START+0
			lds		XH,IVC_DAC_START+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			; Установить координаты вывода
			ldi		r18,13
			ldi		r19,4
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,IVC_DAC_END+0
			lds		XH,IVC_DAC_END+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			; Установить координаты вывода
			ldi		r18,13
			ldi		r19,5
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,IVC_DAC_STEP+0
			lds		XH,IVC_DAC_STEP+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString

			ret



;------------------------------------------------------------------------------
; Экран установки лимитов
;    ________________________________
;  0 |            Лимиты            |
;  1 |                              |
;  2 | LIM_VOLT_NEG     -xxxx       |
;  3 | LIM_VOLT_POS     +xxxx       |
;  4 | LIM_CURR_NEG     -xxxx       |
;  5 | LIM_CURR_POS     +xxxx       |
;  6 | SAVE & EXIT                  |
;  7 | CANCEL                       |
;  8 |                              |
;  9 |                              |
; 10 |                              |
; 11 |                              |
; 12 |                              |
; 13 |                              |
; 14 |                              |
; 15 |______________________________|
; 
;------------------------------------------------------------------------------
PRINT_LIMITS_SCREEN:
			; очистка экрана
			call	T6963C_ClearText
			call	T6963C_ClearGraphic
			; 
			ldi		r18,12
			ldi		r19,0
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_LIMITS*2)
			ldi		ZH,high(STR_LIMITS*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,2
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_LIM_VOLT_NEG*2)
			ldi		ZH,high(STR_LIM_VOLT_NEG*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,3
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_LIM_VOLT_POS*2)
			ldi		ZH,high(STR_LIM_VOLT_POS*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,4
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_LIM_CURR_NEG*2)
			ldi		ZH,high(STR_LIM_CURR_NEG*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,5
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_LIM_CURR_POS*2)
			ldi		ZH,high(STR_LIM_CURR_POS*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,6
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_SAVE_EXIT*2)
			ldi		ZH,high(STR_SAVE_EXIT*2)
			call	T6963C_WriteStringPgm

			ldi		r18,1
			ldi		r19,7
			call	T6963C_TextGoTo
			ldi		ZL,low(STR_CANCEL*2)
			ldi		ZH,high(STR_CANCEL*2)
			call	T6963C_WriteStringPgm
			ret

PRINT_LIMITS_SCREEN_DEFAULT:
			; Установить координаты вывода
			ldi		r18,18
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,LIM_VOLT_NEG+0
			lds		XH,LIM_VOLT_NEG+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			; Установить координаты вывода
			ldi		r18,18
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,LIM_VOLT_POS+0
			lds		XH,LIM_VOLT_POS+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			; Установить координаты вывода
			ldi		r18,18
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,LIM_CURR_NEG+0
			lds		XH,LIM_CURR_NEG+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			; Установить координаты вывода
			ldi		r18,18
			ldi		r19,3
			call	T6963C_TextGoTo
			; Преобразовать число в строку
			lds		XL,LIM_CURR_POS+0
			lds		XH,LIM_CURR_POS+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			call	DEC_TO_STR5
			; Вывести число на дисплей
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			call	T6963C_WriteString
			ret


;------------------------------------------------------------------------------
; 
; 
; 
; 
;------------------------------------------------------------------------------
STR_CALIBRATION:     .db "Калибровка",0,0
STR_CURRENT:         .db "Ток",0
STR_VOLTAGE:         .db "Напряжение",0,0
STR_MA:              .db "мА",0,0
STR_MV:              .db "мВ",0,0
STR_ZERO_DAC:        .db "ZERO_DAC",0,0
STR_VREF_DAC:        .db "VREF_DAC",0,0
STR_CH0_DELTA:       .db "CH0_DELTA",0
STR_CH1_DELTA:       .db "CH1_DELTA",0
STR_ADC_V_REF:       .db "ADC_V_REF",0
STR_ACS712_KI:       .db "ACS712_KI",0
STR_RESDIV_KU:       .db "RESDIV_KU",0
STR_SAVE_EXIT:       .db "SAVE & EXIT",0
STR_CANCEL:          .db "CANCEL",0,0

STR_REALTIME:        .db "Realtime",0,0
STR_DAC:             .db "DAC:",0,0
STR_DAC_STEP:        .db "DAC_STEP:",0
STR_IVC_TRACE:       .db "IVC_TRACE",0
STR_CALIBRATION_EN:  .db "CALIBRATION",0

STR_IVC_TRACE_2:     .db "IVC Trace",0
STR_START:           .db "START",0
STR_DAC_START:       .db "DAC_START:",0,0
STR_DAC_END:         .db "DAC_END:",0,0
STR_EXIT:            .db "EXIT",0,0

STR_LIMITS:          .db "Лимиты",0,0
STR_LIM_VOLT_NEG:    .db "LIM_VOLT_NEG",0,0
STR_LIM_VOLT_POS:    .db "LIM_VOLT_POS",0,0
STR_LIM_CURR_NEG:    .db "LIM_CURR_NEG",0,0
STR_LIM_CURR_POS:    .db "LIM_CURR_POS",0,0
