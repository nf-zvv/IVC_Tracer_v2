;------------------------------------------------------------------------------
; Подпрограммы для работы с EEPROM микроконтроллеров AVR
;
;
;
;------------------------------------------------------------------------------

#if defined (__ATmega328P__) || defined(__ATmega1284P__)
EEWrite:	
	SBIC	EECR,EEPE
	RJMP	EEWrite
 
	CLI
	OUT 	EEARL,R16
	OUT 	EEARH,R17
	OUT 	EEDR,R18
 
	SBI 	EECR,EEMPE
	SBI 	EECR,EEPE
 
	SEI
	RET
EERead:	
	SBIC 	EECR,EEPE
	RJMP	EERead
	OUT 	EEARL, R16
	OUT  	EEARH, R17
	SBI 	EECR,EERE
	IN		R18, EEDR
	RET

#elif defined (__ATmega16A__) || defined(__ATmega16__)
EEWrite:	
	SBIC	EECR,EEWE
	RJMP	EEWrite
 
	CLI
	OUT 	EEARL,R16
	OUT 	EEARH,R17
	OUT 	EEDR,R18
 
	SBI 	EECR,EEMWE
	SBI 	EECR,EEWE
 
	SEI
	RET
EERead:	
	SBIC 	EECR,EEWE
	RJMP	EERead
	OUT 	EEARL, R16
	OUT  	EEARH, R17
	SBI 	EECR,EERE
	IN		R18, EEDR
	RET
#else
#error "Unsupported part:" __PART_NAME__
#endif // part specific code
