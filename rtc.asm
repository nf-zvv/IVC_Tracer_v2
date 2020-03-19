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
RTC_READ:	RCALL	IIC_START		; �������� �����
			IN		r16,TWSR		; �������� �������
			ANDI	r16,0xF8
			CPI		r16, 0x08
			BRNE	IIC_RErr
 
			LDI		r16,0b10100000	; �������� ����� ����� �� ������
			RCALL	IIC_BYTE
			IN		r16,TWSR		; �������� �������
			ANDI	r16,0xF8
			CPI		r16, 0x18
			BRNE	IIC_RErr
 
			LDI		r16,RTCAddr		; �������� ����� ������ ������ ����� ������
			RCALL	IIC_BYTE
			IN		r16,TWSR		; �������� �������
			ANDI	r16,0xF8
			CPI		r16, 0x28
			BRNE	IIC_RErr
 
			RCALL	IIC_START		; ��������� �����
			IN		r16,TWSR		; �������� �������
			ANDI	r16,0xF8
			CPI		r16, 0x10
			BRNE	IIC_RErr
 
			LDI		r16,0b10100001	; ����� ����� �����, �� ��� �� ������
			RCALL	IIC_BYTE
			IN		r16,TWSR		; �������� �������
			ANDI	r16,0xF8
			CPI		r16, 0x40
			BRNE	IIC_RErr
 
			RCALL	IIC_RCV			; ������� ������ ���� - �������
			IN		r16,TWDR		; ������� �� �������� TWIDR
			IN		r17,TWSR		; �������� �������
			ANDI	r17,0xF8
			CPI		r17, 0x50
			BRNE	IIC_RErr
			STS		Sec_o,r16		; ��������� � ������
 
			RCALL	IIC_RCV			; ������ ���� - ������, � ��� �����
			IN		r16,TWDR
			IN		r17,TWSR		; �������� �������
			ANDI	r17,0xF8
			CPI		r17, 0x50
			BRNE	IIC_RErr
			STS		Min_o,r16
 
			RCALL	IIC_RCV			; ������ ���� - ����
			IN		r16,TWDR
			IN		r17,TWSR		; �������� �������
			ANDI	r17,0xF8
			CPI		r17, 0x50
			BRNE	IIC_RErr
			STS		Hour_o,r16
 
			RCALL	IIC_RCV			; ��������� - �����
			IN		r16,TWDR
			IN		r17,TWSR		; �������� �������
			ANDI	r17,0xF8
			CPI		r17, 0x50
			BRNE	IIC_RErr
			STS		Date_o,r16
 
			RCALL	IIC_RCV2		; �� � ���������� - �����. ��������! 
			IN		r16,TWDR		; ��� ��������� ��������� �����! RCV2!!!
			IN		r17,TWSR		; �������� �������
			ANDI	r17,0xF8
			CPI		r17, 0x58
			BRNE	IIC_RErr
			STS		Mth_o,r16
 
IIC_RErr:	RCALL	IIC_STOP		; ���� STOP � ���������� �����.
 
			RET				; ����� �� ������

;-----------------------------------------------------------------------------
; ������� ����� �������� ����-������� � RTC
;-----------------------------------------------------------------------------
RTC_WRITE:
			RCALL	IIC_START		; ����� 
			LDI		r16,0b10100000	; ��������� ����� ����� �� ������
			RCALL	IIC_BYTE		; �������� ����� ����� �� ������
			LDI		r16,RTCAddr		; ��������� ����� ������ ������ �����
			RCALL	IIC_BYTE		; �������� ����� ������
			LDS		r16,Sec_i	;Sec	; ��������� �������
			RCALL	IIC_Byte		; �������� �������
 
			LDS		r16,Min_i	;Min	; ��������� ������
			RCALL	IIC_Byte		; �������� ������
 
			LDS		r16,Hour_i	;Hr	; ��������� ����
			RCALL	IIC_Byte		; �������� ����
 
			LDS		r16,Date_i	;Date	; ��������� �����
			RCALL	IIC_Byte		; �������� �����
 
			LDS		r16,Mth_i	;Mth	; ��������� �����
			RCALL	IIC_Byte		; �������� �����
 
IIC_WErr:	RCALL	IIC_STOP		; ����
			RET


;-----------------------------------------------------------------------------
; ���������� ����� �� RAM RTC
; ����� �������� ������ RAM - � �������� r6
; ��������� - � �������� r7
; ����������: r16
;-----------------------------------------------------------------------------
RTC_READ_RAM:
			push	r16
			push	r17
			RCALL	IIC_START		; �������� �����
			IN		r16,TWSR		; �������� �������
			ANDI	r16,0xF8
			CPI		r16, 0x08
			BRNE	IIC_RRErr
 
			LDI		r16,0b10100000	; �������� ����� ����� �� ������
			RCALL	IIC_BYTE
			IN		r16,TWSR		; �������� �������
			ANDI	r16,0xF8
			CPI		r16, 0x18
			BRNE	IIC_RRErr
 
			MOV		r16,r6			; �������� ����� ������ ������ ����� ������
			RCALL	IIC_BYTE
			IN		r16,TWSR		; �������� �������
			ANDI	r16,0xF8
			CPI		r16, 0x28
			BRNE	IIC_RRErr
 
			RCALL	IIC_START		; ��������� �����
			IN		r16,TWSR		; �������� �������
			ANDI	r16,0xF8
			CPI		r16, 0x10
			BRNE	IIC_RRErr
 
			LDI		r16,0b10100001	; ����� ����� �����, �� ��� �� ������
			RCALL	IIC_BYTE
			IN		r16,TWSR		; �������� �������
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
 
IIC_RRErr:	RCALL	IIC_STOP		; ���� STOP � ���������� �����.
 			pop		r17
			pop		r16
		RET				; ����� �� ������

;-----------------------------------------------------------------------------
; ������� ����� �������� ����-������� � RTC
; ����� ������������ ������ RAM - � �������� r6
; ������������ ���� - � �������� r7
; ����������: r16
;-----------------------------------------------------------------------------
RTC_WRITE_RAM:
			push	r16
			RCALL	IIC_START		; ����� 
			LDI		r16,0b10100000	; ��������� ����� ����� �� ������
			RCALL	IIC_BYTE		; �������� ����� ����� �� ������
			MOV		r16,r6		; ��������� ����� ������ ������ �����
			RCALL	IIC_BYTE		; �������� ����� ������
			MOV		r16,r7			; ��������� ������������ ����
			RCALL	IIC_Byte		; ���������

IIC_WRErr:	RCALL	IIC_STOP		; ����
			pop		r16
			RET

;-----------------------------------------------------------------------------
; ��������� ��������� ������� ������
; ��������� - � �������� r16
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
; 0 - 24h (AM/PM ���� �� ����������)
; 1 - 12h (AM/PM ���� �����������)
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
			LSR		R16				; ������ � r16 �������� ���� (������� �� �������)
			ldi		r19,0x10
			mov		r6,r19 
			rcall	RTC_READ_RAM	; � ������� r7 ������� ���������� ���
			add		r16,r7			; � �������� r16 ��������� �������� ����
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
; ������������� ������ ����� ������� �� � RTC
; � ������� FullDateTime ��������� 12 ���� ����-�������
; � ������� DDMMYYhhmmss
;
; ����� ������������� ���������� ����� ��������� � �������:
; Date_i, Hour_i, Min_i, Sec_i, Mth_i
; ������������: r16, r17, ZH
;
; ����������� ����������� �������� �� ������������ ��������� ����
; � ������ ������������ �� ������ r16=1
; ��� ������� ������ �� ������ r16=0
;-----------------------------------------------------------------------------
PREPROC_DATETIME:
			ldi		ZL,low(FullDateTime)
			ldi		ZH,high(FullDateTime)
			
			; ���������� ���
			ld		r16,Z+			; �������� ���������� ������ ��� (0,1,2,3)
			ld		r17,Z+			; �������� ��������� ������ ��� (0-9)
			rcall	DATE_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Date_i,r16		; ������ � ������ ��������������� �������� ����
			
			; ���������� ������
			ld		r16,Z+			; �������� ���������� ������ ������ (0,1)
			ld		r17,Z+			; �������� ��������� ������ ������ (0-9)
			rcall	MONTH_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Mth_i,r16		; ������ � ������ ��������������� �������� ������
			
			; ���������� ����
			ld		r16,Z+			; ����������� 1 ������ ����
			ld		r17,Z+			; ����������� 2 ������ ����
			rcall	YEAR_TEST
			
			; ���������� ����
			ld		r16,Z+			; �������� ���������� ������ ���� (0-5)
			ld		r17,Z+			; �������� ��������� ������ ���� (0-9)
			rcall	HOUR_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Hour_i,r16		; ������ � ������ ��������������� �������� ����
			
			; ���������� �����
			ld		r16,Z+			; �������� ���������� ������ ����� (0-5)
			ld		r17,Z+			; �������� ��������� ������ ����� (0-9)
			rcall	TIME_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Min_i,r16		; ������ � ������ ��������������� �������� �����

			; ���������� ������
			ld		r16,Z+			; �������� ���������� ������ ������ (0-5)
			ld		r17,Z			; �������� ��������� ������ ������ (0-9)
			rcall	TIME_TEST
			tst		r17
			breq	PREPROC_ERROR
			sts		Sec_i,r16		; ������ � ������ ��������������� �������� ������
			
			ldi		r16,1				; ��� ���������. �������.
			rjmp	PREPROC_EXIT
PREPROC_ERROR:
			clr		r16
PREPROC_EXIT:
			RET
;-----------------------------------------------------------------------------
; �������� ������������ ���������� �������
; ����: r16 (������� ������), r17 (��������� ������)
; �����: r16 (������� ��� ������ �����), r17=1 (�����), r17=0 (�������)
;-----------------------------------------------------------------------------
TIME_TEST:
			cpi		r16,6			; ���� ���� ������ ����� ����� 5
			brsh	TIME_TEST_ERROR
			swap	r16				; ��������� ����������� ������� ������
			or		r16,r17			; ��������� ���������� ������� ������
			ldi		r17,1
			rjmp	TIME_TEST_EXIT
TIME_TEST_ERROR:
			clr		r17
TIME_TEST_EXIT:
			ret

HOUR_TEST:
			cpi		r16,3			; ���� ���� ������ ����� ����� 2
			brsh	HOUR_TEST_ERROR
			cpi		r16,2
			brne	HOUR_TEST_OK
			cpi		r17,4			; ���� ���� ������ ����� ����� 3
			brsh	HOUR_TEST_ERROR
HOUR_TEST_OK:
			swap	r16				; ��������� ����������� ������� ���
			or		r16,r17			; ��������� ���������� ������� ���
			ldi		r17,1
			rjmp	HOUR_TEST_EXIT
HOUR_TEST_ERROR:
			clr		r17
HOUR_TEST_EXIT:
			ret

DATE_TEST:
			cpi		r16,4			; ���� ���� ������ ����� ����� 3
			brsh	DATE_TEST_ERROR
			cpi		r16,3
			brne	DATE_TEST_OK
			cpi		r17,1
			brne	DATE_TEST_ERROR
DATE_TEST_OK:
			swap	r16				; ��������� ����������� ������� ���
			or		r16,r17			; ��������� ���������� ������� ���
			ldi		r17,1
			rjmp	DATE_TEST_EXIT
DATE_TEST_ERROR:
			clr		r17
DATE_TEST_EXIT:
			ret

MONTH_TEST:
			cpi		r16,2			; ���� ���� ������ ����� ����� 1
			brsh	MONTH_TEST_ERROR
			cpi		r16,1
			brne	MONTH_TEST_OK
			cpi		r17,3			; ���� ���� ������ ����� ����� 2
			brsh	MONTH_TEST_ERROR
MONTH_TEST_OK:
			swap	r16				; ��������� ����������� ������� ���
			or		r16,r17			; ��������� ���������� ������� ���
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
			adc		r16,r17			; ������ � r16 ���������� �������� ����
			cpi		r16,4
			brlo	YEAR_TEST_1
			push	r16
YEAR_TEST_AGAIN:
			subi	r16,4
			cpi		r16,4
			brsh	YEAR_TEST_AGAIN
			mov		r17,r16			; ������� �� �������
			pop		r16				; �������� ���
			sub		r16,r17			; ��������� ��������� ���������� ���
			
			ldi		r19,0x10		; ����� ������ RAM � RTC
			mov		r6,r19			; ����� ������ RAM � RTC
			mov		r7,r16			; ������������ ���� (��������� ��������� ���������� ���)
			rcall	RTC_WRITE_RAM	; ������� ����������� ���� � ������ RAM RTC
			
			mov		r16,r17
			rjmp	YEAR_TEST_2
YEAR_TEST_1:
			ldi		r19,0x10		; ����� ������ RAM � RTC
			mov		r6,r19			; ����� ������ RAM � RTC
			clr		r19				; ������������ ����
			mov		r7,r19			; ������������ ���� (��������� ��������� ���������� ���)
			rcall	RTC_WRITE_RAM	; ������� ����������� ���� � ������ RAM RTC
YEAR_TEST_2:

			ldi		r19,0x11		; ����� ������ RAM � RTC
			mov		r6,r19			; ����� ������ RAM � RTC
			mov		r7,r16			; ������������ ���� (������� �� �������)
			rcall	RTC_WRITE_RAM	; ������� ������� �� ������� � ������ RAM RTC			

			swap	r16
			lsl		r16
			lsl		r16
			lds		r17,Date_i
			or		r16,r17
			sts		Date_i,r16
			ret

			
