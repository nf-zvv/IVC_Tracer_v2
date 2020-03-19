;------------------------------------------------------------------------------
; Graphic LCD with Toshiba T6963 controller
; 
; Display connections
;
; (C) 2019-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; History
; =======
; 22.05.2019 initial
; 
;------------------------------------------------------------------------------

#ifndef _T6963C_CONFIG_INC_
#define _T6963C_CONFIG_INC_

; data port
#define GLCD_DATA_PORT 	PORTA
#define GLCD_DATA_PIN		PINA
#define GLCD_DATA_DDR		DDRA
; control port
#define GLCD_CTRL_PORT		PORTC
#define GLCD_CTRL_PIN		PINC
#define GLCD_CTRL_DDR		DDRC
; control signals
#define GLCD_WR			PC7
#define GLCD_RD			PC6
#define GLCD_CE			PC5
#define GLCD_CD			PC4
#define GLCD_RESET		PC3
#define GLCD_FS			PC2
; display properties
#define GLCD_NUMBER_OF_LINES		128
#define GLCD_PIXELS_PER_LINE		240
#define GLCD_FONT_WIDTH			8

;
#define GLCD_GRAPHIC_AREA			(GLCD_PIXELS_PER_LINE / GLCD_FONT_WIDTH)
#define GLCD_TEXT_AREA				(GLCD_PIXELS_PER_LINE / GLCD_FONT_WIDTH)
#define GLCD_GRAPHIC_SIZE			(GLCD_GRAPHIC_AREA * GLCD_NUMBER_OF_LINES)
#define GLCD_TEXT_SIZE				(GLCD_TEXT_AREA * (GLCD_NUMBER_OF_LINES/8))

#define GLCD_TEXT_HOME				0
#define GLCD_GRAPHIC_HOME			(GLCD_TEXT_HOME + GLCD_TEXT_SIZE)
#define GLCD_OFFSET_REGISTER		3
#define GLCD_EXTERNAL_CG_HOME		(GLCD_OFFSET_REGISTER << 11)

#endif  /* _T6963C_CONFIG_INC_ */

;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
