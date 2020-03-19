;------------------------------------------------------------------------------
; Graphic LCD with Toshiba T6963 controller
; 
; Function codes
;
; (C) 2019-2020 Vitaliy Zinoviev
; https://github.com/nf-zvv/IVC_Tracer_v2
;
; History
; =======
; 22.05.2019 initial
; 
;------------------------------------------------------------------------------

#ifndef _T6963C_CODES_INC_
#define _T6963C_CODES_INC_

; function codes
#define T6963_SET_CURSOR_POINTER			0x21
#define T6963_SET_OFFSET_REGISTER			0x22
#define T6963_SET_ADDRESS_POINTER			0x24

#define T6963_SET_TEXT_HOME_ADDRESS			0x40
#define T6963_SET_TEXT_AREA					0x41
#define T6963_SET_GRAPHIC_HOME_ADDRESS		0x42
#define T6963_SET_GRAPHIC_AREA				0x43

#define T6963_MODE_SET						0x80
#define T6963_CG_ROM_MODE					0x00
#define T6963_CG_RAM_MODE					0x08
#define T6963_OR_MODE						0x00
#define T6963_EXOR_MODE						0x01
#define T6963_AND_MODE						0x03
#define T6963_TEXT_ONLY_MODE				0x04

#define T6963_DISPLAY_MODE					0x90
	#define T6963_CURSOR_BLINK_ON			0x01
	#define T6963_CURSOR_DISPLAY_ON			0x02
	#define T6963_TEXT_DISPLAY_ON			0x04
	#define T6963_GRAPHIC_DISPLAY_ON		0x08				

#define T6963_CURSOR_PATTERN_SELECT			0xA0
	#define T6963_CURSOR_1_LINE				0x00
	#define T6963_CURSOR_2_LINE				0x01
	#define T6963_CURSOR_3_LINE				0x02
	#define T6963_CURSOR_4_LINE				0x03
	#define T6963_CURSOR_5_LINE				0x04
	#define T6963_CURSOR_6_LINE				0x05
	#define T6963_CURSOR_7_LINE				0x06
	#define T6963_CURSOR_8_LINE				0x07

#define T6963_SET_DATA_AUTO_WRITE			0xB0
#define T6963_SET_DATA_AUTO_READ			0xB1
#define T6963_AUTO_RESET					0xB2

#define T6963_DATA_WRITE_AND_INCREMENT		0xC0
#define T6963_DATA_READ_AND_INCREMENT		0xC1
#define T6963_DATA_WRITE_AND_DECREMENT		0xC2
#define T6963_DATA_READ_AND_DECREMENT		0xC3
#define T6963_DATA_WRITE_AND_NONVARIALBE	0xC4
#define T6963_DATA_READ_AND_NONVARIABLE		0xC5

#define T6963_SCREEN_PEEK					0xE0
#define T6963_SCREEN_COPY					0xE8

#define T6963_BIT_RESET						0xF0
#define T6963_BIT_SET						0xF8

#define STATUS_CMD_EXEC						0x01
#define STATUS_DATA_RW						0x02
#define STATUS_AUTO_RD						0x04
#define STATUS_AUTO_WR						0x08

#endif  /* _T6963C_CODES_INC_ */

;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
