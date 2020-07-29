;------------------------------------------------------------------------------
; ���������� ������
; 
; ������ ������:
;   clear  - ������� ������
;   reboot - ������������
;   pwm    - ��������� � ���������� �������� ���
;   adc    - ���������� �������� ������ ���
;   cal    - ����������
;
; (C) 2017-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; History
; =======
; 19.02.2018 ������������ fill_cmd_list ������������� � init_cmd_list
; 12.03.2018 � ������������ init_cmd_list ��������� ��������� ������� UART
;            ������������ init_cmd_list ������������� � UART_PARSER_INIT
; 10.03.2020 ADD: SET � GET �������
; 11.03.2020 CMD_TABLE. ������������� Flash ������ RAM
;------------------------------------------------------------------------------
#ifndef _CMD_FUNC_ASM_
#define _CMD_FUNC_ASM_

.equ	VAR_COUNT     = 15			; ���-�� ���������� (��� ������ SET � GET)

.dseg
VAR_ID:		.byte 1


.cseg
;------------------------------------------------------------------------------
; ���������� ������� ������-�������
; ������: -
; ������������: X*, Z*
; ����: -
; �����: CMD_LIST
;------------------------------------------------------------------------------
UART_PARSER_INIT:
			; ������������ ������� UART
			; �������� ���������
			sts		IN_PTR_S,__zero_reg__
			sts		IN_PTR_E,__zero_reg__
			;sts		OUT_PTR_S,__zero_reg__
			;sts		OUT_PTR_E,__zero_reg__

			; ������ ��� ����������� ������������

			; �� ������ ��������� ���-�� ������ � ���������� CMD_COUNT � ����� cmd.asm
			ret


;------------------------------------------------------------------------------
; ������� ������
;
; ������������ � �������� �������:
;   <ESC>[H   - Cursor home
;   <ESC>[2J  - Erase screen
;
; ������: FLASH_CONST_TO_UART
; ������������: r13*, r16*
; ����: -
; �����: -
;------------------------------------------------------------------------------
cmd_clear:
			ldi		ZL,low(clear_seq_const*2)
			ldi		ZH,high(clear_seq_const*2)
			rcall	FLASH_CONST_TO_UART
			ldi		r16,255		; �� �������� ��������� '��'
			mov		r13,r16
			ret


;------------------------------------------------------------------------------
; ������������
; 
;------------------------------------------------------------------------------
cmd_reboot:
			jmp 0x0000


;------------------------------------------------------------------------------
; ������� Meow � ��������
; 
;------------------------------------------------------------------------------
cmd_meow:
			ldi		ZL,low(meow_const*2)
			ldi		ZH,high(meow_const*2)
			rcall	FLASH_CONST_TO_UART
			ldi		r16,255		; �� �������� ��������� '��'
			mov		r13,r16
			ret


;------------------------------------------------------------------------------
; ������� ���
; ������� � �������� �� ��, ��� � ����� � �� ������ ���������
; 
;------------------------------------------------------------------------------
cmd_echo:
			lds		r16,ARG_COUNT		; ���-�� ����������
			tst		r16
			brne	cmd_echo_max_arg_tst
			rjmp	cmd_no_args	; ��� ����������
cmd_echo_max_arg_tst:
			cpi		r16,1
			breq	cmd_echo_next
			rjmp	cmd_too_many_args
cmd_echo_next:
			ldi		r16,1			; ����� ������ ��������
			rcall	GET_ARGUMENT
			movw	X,Y
			rcall	STRING_TO_UART
			clr		r13				; �������� ���������
			ret

;------------------------------------------------------------------------------
; ����� ��� ���� �������� ��� ��������� ��������� �� �������
;------------------------------------------------------------------------------
cmd_invalid_arg_count:
			ldi		r16,3	; ��� ������: "������������ ����� ����������"
			mov		r13,r16
			ret
cmd_no_args:
			ldi		r16,6	; ��� ������: "����������� ���������"
			mov		r13,r16
			ret
cmd_too_many_args:
			ldi		r16,5	; ��� ������: "������� ����� ����������"
			mov		r13,r16
			ret



;------------------------------------------------------------------------------
; ��������� ������ �������� ����������
; 
; ������� ����� ��� ���������: ��� ���������� � ��������
;------------------------------------------------------------------------------
cmd_set:
			lds		r16,ARG_COUNT		; ���-�� ����������
			tst		r16
			brne	cmd_set_max_arg_tst
			rjmp	cmd_no_args	; ��� ����������
cmd_set_max_arg_tst:
			cpi		r16,2
			breq	cmd_set_next
			rjmp	cmd_invalid_arg_count
cmd_set_next:
			ldi		r16,1			; ����� ������ ��������
			rcall	GET_ARGUMENT	; (Y - pointer to zero ending argument string)
			movw	XL,YL
			ldi		ZL,low(VAR_TABLE*2)
			ldi		ZH,high(VAR_TABLE*2)
			ldi		r19,VAR_COUNT
			rcall	LOCATE_STR		; ������� ������ ����������
			cpi		r18,-1
			breq	cmd_set_error_arg
			; ���������� �������!
			sts		VAR_ID,r18		; ��������� ID ��������� ����������
			ldi		r16,2			; ����� ������ ��������
			rcall	GET_ARGUMENT	; (OUT: Y - pointer to zero-ended argument string)
			;rcall	STR_TO_UINT16	; (IN: Y; OUT: r25:r24)
			;tst		r13
			;brne	cmd_set_error_num
			rcall	atoi	; ������������� ������ � ����� (IN: Y; OUT: r25:r24)
			; ��������
			; TODO: ��� ���������� LIM_* - �������� ���� ������� ������
			;cp		r24,0
			;cpc		r25,0
			;brlt	cmd_dac_error_num
			;cp		r24,low(4096)
			;cpc		r25,high(4096)
			;brsh	cmd_dac_error_num
			; ��� ���������� � �������� �������� ����������,
			; ������ ����� �������� ������������
			; ��������� ����� �������
			ldi		ZL,low(VAR_TABLE*2)
			ldi		ZH,high(VAR_TABLE*2)
			lds		r0,VAR_ID			; ��������� ID ����������
			; ��������� ��������
			ldi		r16,4
			mul		r0,r16
			add		ZL,r0
			adc		ZH,r1
			adiw	ZL,2	; ��������������� �� ����� ���������� � RAM
			lpm		XL,Z+
			lpm		XH,Z	; ������ X ��������� �� �������� ���������� � RAM
			; ��������� ������ �������� �� ���������� ������
			st		X+,r24
			st		X,r25
			; ������� �������� � ��������
			rcall	GET_VAR_KEY_VAL ; (IN: VAR_ID)
			; ��������� � EEPROM
			call	EEPROM_SAVE_CALIBRATIONS
			clr		r13
			ret
cmd_set_error_arg:
			ldi		r16,4	; ��� ������: "������������ �������� ���������"
			mov		r13,r16
			ret
cmd_set_error_num:
			ldi		r16,8	; ��� ������: "������������ �����"
			mov		r13,r16
			ret


;------------------------------------------------------------------------------
; ��������� ����������
; ����� �������� ���������� � ��������
; 
; ������� ����� �����:
; ���� ����������                - ��������� ������ ���������� � �� ����������
; ���� �������� 'ALL'            - ��������� ������ ���������� � �� ����������
; ���� �������� '��� ����������' - ��������� ��� ���������� � ��������
;------------------------------------------------------------------------------
cmd_get:
			lds		r16,ARG_COUNT		; ���-�� ����������
			tst		r16
			brne	cmd_get_max_arg_tst
			rjmp	cmd_get_all	; ��� ���������� - ������ ��� ����������
cmd_get_max_arg_tst:
			cpi		r16,1
			breq	cmd_get_next
			rjmp	cmd_too_many_args
cmd_get_next:
			ldi		r16,1			; ����� ������ ��������
			rcall	GET_ARGUMENT	; (Y - pointer to zero ending argument string)
			; ������� ���������, �� ��������� �� ��� ���������� ������������
			movw	XL,YL
			ldi		ZL,low(ALL_const*2)		; �������� ALL
			ldi		ZH,high(ALL_const*2)
			rcall	STR_CMP
			tst		r16				; ��������� ��������
			brne	cmd_get_single_var
cmd_get_all:
			; ����� ��� ����������
			rcall	GET_ALL_VARS
			rjmp	cmd_get_success
cmd_get_single_var:
			movw	XL,YL
			ldi		ZL,low(VAR_TABLE*2)
			ldi		ZH,high(VAR_TABLE*2)
			ldi		r19,VAR_COUNT
			rcall	LOCATE_STR		; ������� ������ ����������
			cpi		r18,-1
			breq	cmd_get_VAR_NOT_FOUND
			; ���������� �������!
			sts		VAR_ID,r18		; ��������� ID ��������� ����������
			movw	XL,YL
			rcall	STRING_TO_UART ; (IN: X)
			ldi		r16,'='
			rcall	uart_snt
			; ��������� ����� �������
			ldi		ZL,low(VAR_TABLE*2)
			ldi		ZH,high(VAR_TABLE*2)
			lds		r0,VAR_ID			; ��������� ID ����������
			; ��������� ��������
			ldi		r16,4
			mul		r0,r16
			add		ZL,r0
			adc		ZH,r1
			adiw	ZL,2	; ��������������� �� ����� ���������� � RAM
			lpm		XL,Z+
			lpm		XH,Z	; ������ X ��������� �� �������� ���������� � RAM
			; ��������� ��������
			ld		r24,X+
			ld		r25,X
			movw	XL,r24
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			;call	DEC_TO_STR5 ; (IN: X; OUT: Y)
			call	ITOA_FAST_DIV
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			rcall	STRING_TO_UART ; (IN: X)
			rcall	UART_LF_CR
cmd_get_success:
			clr		r13
			ret
cmd_get_VAR_NOT_FOUND:
			ldi		r16,4	; ��� ������: "������������ �������� ���������"
			mov		r13,r16
			ret


;------------------------------------------------------------------------------
; ������ �������� ��������������� ������ ���
; ���������� �������� � ��������
;------------------------------------------------------------------------------
cmd_start:
			call	IVC_TRACE_START
			clr		r13
			ret


;------------------------------------------------------------------------------
; ��������� �������� ��� ��������� ������ �������� ���
; 
; ������� ����� �����:
; ���� ���������� - ��������� ��������� ������� �������� ���
; ���� ��������   - �������������� ����� ��������
;------------------------------------------------------------------------------
cmd_dac:
			lds		r16,ARG_COUNT		; ���-�� ����������
			tst		r16
			brne	cmd_dac_max_arg_tst
			rjmp	cmd_dac_show	; ��� ���������� - ������� ������� ��������
cmd_dac_max_arg_tst:
			cpi		r16,1
			breq	cmd_dac_next
			rjmp	cmd_too_many_args
cmd_dac_next:
			ldi		r16,1			; ����� ������ ��������
			rcall	GET_ARGUMENT	; (Y - pointer to zero ending argument string)
			rcall	atoi	; ������������� ������ � ����� (IN: Y; OUT: r25:r24)
			ldi		YL,0
			ldi		YH,0
			cp		r24,YL
			cpc		r25,YH
			brlt	cmd_dac_error_num
			ldi		YL,low(4096)
			ldi		YH,high(4096)
			cp		r24,YL
			cpc		r25,YH
			brsh	cmd_dac_error_num
			sts		DAC_CH_B+0,r24
			sts		DAC_CH_B+1,r25
			call	DAC_SET_B
			rjmp	cmd_dac_success
cmd_dac_show:
			ldi		ZL,low(DAC_const*2)
			ldi		ZH,high(DAC_const*2)
			rcall	FLASH_CONST_TO_UART ; (IN: Z)
			lds		XL,DAC_CH_B+0
			lds		XH,DAC_CH_B+1
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			;call	DEC_TO_STR5 ; (IN: X; OUT: Y)
			call	ITOA_FAST_DIV
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			rcall	STRING_TO_UART ; (IN: X)
			rcall	UART_LF_CR
			rjmp	cmd_dac_success
cmd_dac_error_num:
			ldi		r16,8	; ��� ������: "������������ �����"
			mov		r13,r16
			ret
cmd_dac_success:
			clr		r13
			ret


;------------------------------------------------------------------------------
; ��������� ���� ����������
; ����� �������� ���������� � ��������
;
; ������: FLASH_CONST_TO_UART, STRING_TO_UART, UART_LF_CR, uart_snt, DEC_TO_STR5
; ������������: r16*, r17*, r22*, r24*, r25*, X*, Y*, Z*
; ����: VAR_TABLE
;       r19 - ���������� ���������
; �����: 
;------------------------------------------------------------------------------
GET_ALL_VARS:
			ldi		r24,low(VAR_TABLE*2)
			ldi		r25,high(VAR_TABLE*2)
			ldi		r22,VAR_COUNT
GET_ALL_VARS_LOOP:
			movw	ZL,r24
			; ��������� ����� ����� ����������
			lpm		r16,Z+
			lpm		r17,Z+
			; ��������� ����� �������� ����������
			lpm		YL,Z+
			lpm		YH,Z
			; ������� ��� ����������
			movw	ZL,r16
			rcall	FLASH_CONST_TO_UART ; (IN: Z)
			ldi		r16,'='
			rcall	uart_snt
			; ��������� ��������
			ld		XL,Y+
			ld		XH,Y
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			;call	DEC_TO_STR5 ; (IN: X; OUT: Y)
			call	ITOA_FAST_DIV
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			rcall	STRING_TO_UART ; (IN: X)
			rcall	UART_LF_CR
			adiw	r24,4
			dec		r22
			brne	GET_ALL_VARS_LOOP
			ret


;------------------------------------------------------------------------------
; ����� ���� "���=��������" ���������� � UART
;
;
; ������: FLASH_CONST_TO_UART, STRING_TO_UART, UART_LF_CR, uart_snt, DEC_TO_STR5
; ������������: r0*, r1*, r16*, r17*, X*, Y*, Z*
; ����: VAR_ID
; �����: 
;------------------------------------------------------------------------------
GET_VAR_KEY_VAL:
			; ��������� ����� �������
			ldi		ZL,low(VAR_TABLE*2)
			ldi		ZH,high(VAR_TABLE*2)
			lds		r0,VAR_ID			; ��������� ID ����������
			; ��������� ��������
			ldi		r16,4
			mul		r0,r16
			add		ZL,r0
			adc		ZH,r1
			; ��������� ����� ����� ����������
			lpm		r16,Z+
			lpm		r17,Z+
			; ��������� ����� �������� ����������
			lpm		YL,Z+
			lpm		YH,Z
			movw	ZL,r16
			rcall	FLASH_CONST_TO_UART ; (IN: Z)
			ldi		r16,'='
			rcall	uart_snt
			; ��������� ��������
			ld		XL,Y+
			ld		XH,Y
			ldi		YL,low(STRING)
			ldi		YH,high(STRING)
			;call	DEC_TO_STR5 ; (IN: X; OUT: Y)
			call	ITOA_FAST_DIV
			ldi		XL,low(STRING)
			ldi		XH,high(STRING)
			rcall	STRING_TO_UART ; (IN: X)
			rcall	UART_LF_CR
			ret



; === ����� ===
; 16.03.2020
; ������� ��������� ������������:
; - ����� ���������� �� ����� (�� ������ VAR_ID)
; - ��������� ����� �� VAR_ID (�� ������ ��������� �� zero-ended ������)
; - ��������� �������� �� VAR_ID (�� ������ ������������ ��������)
; - ��������� ������ �������� �� VAR_ID
; - ��������� ���� "���=��������" �� VAR_ID (����� � ��������)
; �������� ������ EEPROM � ������� ����������,
; ����� ����� ���������/��������� ����� �� VAR_ID


;------------------------------------------------------------------------------
; 
; Includes
; 
;------------------------------------------------------------------------------



;------------------------------------------------------------------------------
; 
; Constants
; 
;------------------------------------------------------------------------------
cmd_clear_const:			.db "clear",0
cmd_reboot_const:			.db "reboot",0,0
cmd_echo_const:				.db "echo",0,0
cmd_meow_const:				.db "meow",0,0
cmd_set_const:				.db "set",0
cmd_get_const:				.db "get",0
;cmd_adc_const:				.db "adc",0
cmd_start_const:			.db "start",0
cmd_dac_const:				.db "dac",0
meow_const:					.db "Meow! ^_^",0
clear_seq_const:			.db 27, "[", "H", 27, "[", "2", "J",0

; ����� ����������
DAC_STEP_var_name:			.db "DAC_STEP",0,0
IVC_DAC_START_var_name:		.db "IVC_DAC_START",0
IVC_DAC_END_var_name:		.db "IVC_DAC_END",0
IVC_DAC_STEP_var_name:		.db "IVC_DAC_STEP",0,0
CH0_DELTA_var_name:			.db "CH0_DELTA",0
CH1_DELTA_var_name:			.db "CH1_DELTA",0
ADC_V_REF_var_name:			.db "ADC_V_REF",0
ACS712_KI_var_name:			.db "ACS712_KI",0
RESDIV_KU_var_name:			.db "RESDIV_KU",0
ZERO_DAC_var_name:			.db "ZERO_DAC",0,0
VREF_DAC_var_name:			.db "VREF_DAC",0,0
LIM_VOLT_NEG_var_name:		.db "LIM_VOLT_NEG",0,0
LIM_VOLT_POS_var_name:		.db "LIM_VOLT_POS",0,0
LIM_CURR_NEG_var_name:		.db "LIM_CURR_NEG",0,0
LIM_CURR_POS_var_name:		.db "LIM_CURR_POS",0,0

ALL_const:					.db "ALL",0
DAC_const:					.db "DAC=",0,0

; ������� ������� ���� ������ � ������� �����������
CMD_TABLE:
.db low(cmd_clear_const*2), high(cmd_clear_const*2), low(cmd_clear), high(cmd_clear)
.db low(cmd_reboot_const*2),high(cmd_reboot_const*2),low(cmd_reboot),high(cmd_reboot)
.db low(cmd_echo_const*2),  high(cmd_echo_const*2),  low(cmd_echo),  high(cmd_echo)
.db low(cmd_meow_const*2),  high(cmd_meow_const*2),  low(cmd_meow),  high(cmd_meow)
.db low(cmd_set_const*2),   high(cmd_set_const*2),   low(cmd_set),   high(cmd_set)
.db low(cmd_get_const*2),   high(cmd_get_const*2),   low(cmd_get),   high(cmd_get)
.db low(cmd_start_const*2), high(cmd_start_const*2), low(cmd_start), high(cmd_start)
.db low(cmd_dac_const*2),   high(cmd_dac_const*2),   low(cmd_dac),   high(cmd_dac)

; ������� ������� ���� ���������� �� Flash � ������� �������� � RAM
VAR_TABLE:
.db low(DAC_STEP_var_name*2),     high(DAC_STEP_var_name*2),     low(DAC_STEP),     high(DAC_STEP)
.db low(IVC_DAC_START_var_name*2),high(IVC_DAC_START_var_name*2),low(IVC_DAC_START),high(IVC_DAC_START)
.db low(IVC_DAC_END_var_name*2),  high(IVC_DAC_END_var_name*2),  low(IVC_DAC_END),  high(IVC_DAC_END)
.db low(IVC_DAC_STEP_var_name*2), high(IVC_DAC_STEP_var_name*2), low(IVC_DAC_STEP), high(IVC_DAC_STEP)
.db low(CH0_DELTA_var_name*2),    high(CH0_DELTA_var_name*2),    low(CH0_DELTA),    high(CH0_DELTA)
.db low(CH1_DELTA_var_name*2),    high(CH1_DELTA_var_name*2),    low(CH1_DELTA),    high(CH1_DELTA)
.db low(ADC_V_REF_var_name*2),    high(ADC_V_REF_var_name*2),    low(ADC_V_REF),    high(ADC_V_REF)
.db low(ACS712_KI_var_name*2),    high(ACS712_KI_var_name*2),    low(ACS712_KI),    high(ACS712_KI)
.db low(RESDIV_KU_var_name*2),    high(RESDIV_KU_var_name*2),    low(RESDIV_KU),    high(RESDIV_KU)
.db low(ZERO_DAC_var_name*2),     high(ZERO_DAC_var_name*2),     low(ZERO_DAC),     high(ZERO_DAC)
.db low(VREF_DAC_var_name*2),     high(VREF_DAC_var_name*2),     low(VREF_DAC),     high(VREF_DAC)
.db low(LIM_VOLT_NEG_var_name*2), high(LIM_VOLT_NEG_var_name*2), low(LIM_VOLT_NEG), high(LIM_VOLT_NEG)
.db low(LIM_VOLT_POS_var_name*2), high(LIM_VOLT_POS_var_name*2), low(LIM_VOLT_POS), high(LIM_VOLT_POS)
.db low(LIM_CURR_NEG_var_name*2), high(LIM_CURR_NEG_var_name*2), low(LIM_CURR_NEG), high(LIM_CURR_NEG)
.db low(LIM_CURR_POS_var_name*2), high(LIM_CURR_POS_var_name*2), low(LIM_CURR_POS), high(LIM_CURR_POS)


#endif  /* _CMD_FUNC_ASM_ */

;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
