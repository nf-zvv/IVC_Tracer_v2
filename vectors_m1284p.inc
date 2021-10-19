; ***** INTERRUPT VECTORS ************************************************
; ***** ATmega1284P ******************************************************
.org	INT0addr	; External Interrupt Request 0
reti
.org	INT1addr	; External Interrupt Request 1
reti
.org	INT2addr	; External Interrupt Request 2
reti
.org	PCI0addr	; Pin Change Interrupt Request 0
reti
.org	PCI1addr	; Pin Change Interrupt Request 1
reti
.org	PCI2addr	; Pin Change Interrupt Request 2
reti
.org	PCI3addr	; Pin Change Interrupt Request 3
reti
.org	WDTaddr		; Watchdog Time-out Interrupt
reti
.org	OC2Aaddr	; Timer/Counter2 Compare Match A
reti
.org	OC2Baddr	; Timer/Counter2 Compare Match B
reti
.org	OVF2addr	; Timer/Counter2 Overflow
reti
.org	ICP1addr	; Timer/Counter1 Capture Event
reti
.org	OC1Aaddr	; Timer/Counter1 Compare Match A
reti
.org	OC1Baddr	; Timer/Counter1 Compare Match B
reti
.org	OVF1addr	; Timer/Counter1 Overflow
rjmp	OVF1_IRQ
.org	OC0Aaddr	; Timer/Counter0 Compare Match A
rjmp	TIM0_OC0A_HANDLER
.org	OC0Baddr	; Timer/Counter0 Compare Match B
reti
.org	OVF0addr	; Timer/Counter0 Overflow
reti
.org	SPIaddr		; SPI Serial Transfer Complete
reti
.org	URXC0addr	; USART0, Rx Complete
rjmp	RX_OK
.org	UDRE0addr	; USART0 Data register Empty
reti
.org	UTXC0addr	; USART0, Tx Complete
reti
.org	ACIaddr		; Analog Comparator
reti
.org	ADCCaddr	; ADC Conversion Complete
reti
.org	ERDYaddr	; EEPROM Ready
reti
.org	TWIaddr		; 2-wire Serial Interface
reti
.org	SPMRaddr	; Store Program Memory Read
reti
.org	URXC1addr	; USART1 RX complete
reti
.org	UDRE1addr	; USART1 Data Register Empty
reti
.org	UTXC1addr	; USART1 TX complete
reti
.org	ICP3addr	; Timer/Counter3 Capture Event
reti
.org	OC3Aaddr	; Timer/Counter3 Compare Match A
reti
.org	OC3Baddr	; Timer/Counter3 Compare Match B
reti
.org	OVF3addr	; Timer/Counter3 Overflow
reti
; ***** INTERRUPT VECTORS ************************************************
