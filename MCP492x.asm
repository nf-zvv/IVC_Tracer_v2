;------------------------------------------------------------------------------
; ������������ ��� ������ � MCP4921, MCP4922
; 12-������ ���
; SPI ���������
; � ������������ ��������� ������������ �������� ��������� ������
; ���� ��� �������� ��������� �������� ���������� VREF
;
; ������ ���������� �������:
; bit 15   = 0 - ������ � ������� ��� ����� A
;          = 1 - ������ � ������� ��� ����� B
; bit 14   = 1 - �������������� ���� Vref
;          = 0 - ���������������� ���� Vref
; bit 13   = 1 - 1x(Vout = Vref*D/4096)
;          = 0 - 2x(Vout = 2*Vref*D/4096)
; bit 12   = 1 - �������� �����
;          = 0 - ���������� ���������. Vout ����������� � ��������� 500 ���
; bit 11-0  D11:D0  ���� ������ ���
; 
; ��� MCP4921 bit 15 = 0
; 
; ����� �������������� ���������� ������������������� SPI
; 
; ������ DAC_CS_PORT, DAC_CS_DDR, DAC_CS
;
; (C) 2017-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; History
; =======
;
;------------------------------------------------------------------------------
#ifndef _MCP492X_ASM_
#define _MCP492X_ASM_

.ifndef __zero_reg__
.def __zero_reg__ = r2
.endif

.equ	DAC_CS_PORT	= PORTD
.equ	DAC_CS_DDR	= DDRD
.equ	DAC_CS		= PD6

.equ	DAC_A       = 0x00
.equ	DAC_B       = 0x80

.equ	Buffer_on   = 0x40
.equ	Buffer_off  = 0x00

.equ	Gain_1X	    = 0x20
.equ	Gain_2X	    = 0x00

.equ	Active      = 0x10
.equ	Shutdown    = 0x00


.dseg
DAC_CH_A:		.byte	2
DAC_CH_B:		.byte	2
.cseg

;------------------------------------------------------------------------------
; ������������� ��� MCP4921
; 
; ������: DAC_SET
; ������������: r16*, r17*
; ����: -
; �����: -
;------------------------------------------------------------------------------
DAC_INIT:
			; ��������� ����� �����/������
			sbi		DAC_CS_DDR,DAC_CS	; DAC CS output
			sbi		DAC_CS_PORT,DAC_CS	; CS=1
			; ������������� ��������� �������� ���
			sts		DAC_CH_A+0,__zero_reg__
			sts		DAC_CH_A+1,__zero_reg__
			rcall	DAC_SET_A
			sts		DAC_CH_B+0,__zero_reg__
			sts		DAC_CH_B+1,__zero_reg__
			rcall	DAC_SET_B
			ret


;------------------------------------------------------------------------------
; ��������� �������� ��� MCP4921/MCP4921
; ����� A
; 
; ������: SPI_RW
; ������������: r16*
; ����: DAC_A
; �����: -
;------------------------------------------------------------------------------
DAC_SET_A:
			cbi		DAC_CS_PORT,DAC_CS	; CS=0
			lds		r16,DAC_CH_A+1			; ������� ����
			andi	r16,0b00001111			; ������ �� ���������� �������� 4095
			ori		r16,(DAC_A|Buffer_on|Gain_1X|Active)	; �������������� ���� Vref + GAIN 1x
			rcall	SPI_RW
			lds		r16,DAC_CH_A+0			; ������� ����
			rcall	SPI_RW
			sbi		DAC_CS_PORT,DAC_CS	; CS=1
			ret

;------------------------------------------------------------------------------
; ��������� �������� ��� MCP4922
; ����� B
; 
; ������: SPI_RW
; ������������: r16*
; ����: DAC_A
; �����: -
;------------------------------------------------------------------------------
DAC_SET_B:
			cbi		DAC_CS_PORT,DAC_CS	; CS=0
			lds		r16,DAC_CH_B+1			; ������� ����
			andi	r16,0b00001111			; ������ �� ���������� �������� 4095
			ori		r16,(DAC_B|Buffer_on|Gain_1X|Active)	; �������������� ���� Vref + GAIN 1x
			rcall	SPI_RW
			lds		r16,DAC_CH_B+0			; ������� ����
			rcall	SPI_RW
			sbi		DAC_CS_PORT,DAC_CS	; CS=1
			ret

#endif  /* _MCP492X_ASM_ */

;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
