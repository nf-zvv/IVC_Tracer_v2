;------------------------------------------------------------------------------
; Подпрограммы для работы с аппаратным SPI
; 
; 
; (C) 2017-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; History
; =======
;
;------------------------------------------------------------------------------
#ifndef _SPI_ASM_
#define _SPI_ASM_

;------------------------------------------------------------------------------
; Инициализация SPI
; Используются: r16*
; Вход: -
; Выход: -
;------------------------------------------------------------------------------
SPI_INIT:
			; настройка линий ввода/вывода
			sbi		SPI_PORT,SPI_MOSI	; MOSI = 0
			sbi		SPI_DDR,SPI_MOSI	; MOSI output
			sbi		SPI_PORT,SPI_MISO	; MISO pull up
			cbi		SPI_DDR,SPI_MISO	; MISO input
			cbi		SPI_PORT,SPI_SCK	; SCK = 0
			sbi		SPI_DDR,SPI_SCK		; SCK output
			sbi		SPI_DDR,SPI_SS
			cbi		SPI_PORT,SPI_SS
			; настройка скорости SPI
			; Enable SPI, Master, set clock rate fck/32
			; FCPU/32 i.e. 0.576 MHz
			ldi		r16,(1<<SPE)|(1<<MSTR)|(0<<SPR0)|(1<<SPR1)
			out		SPCR,r16
			ldi		r16,(1<<SPI2X)
			out		SPSR,r16
			ret

;------------------------------------------------------------------------------
; Запись по SPI
; Используются: r16*
; Вход: r16
; Выход: r16
;------------------------------------------------------------------------------
SPI_RW:
			out		SPDR,r16
Wait_Transmit:
			; Wait for transmission complete
			in		r16, SPSR
			sbrs	r16, SPIF
			rjmp	Wait_Transmit
			in		r16,SPDR
			ret

#endif  /* _SPI_ASM_ */

;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
