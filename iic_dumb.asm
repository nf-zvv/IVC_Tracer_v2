;--------------------------------------------------------
; I2C Code
;--------------------------------------------------------
; ���� ����� �� ����� I2C
IIC_START:	OUTI	TWCR,1<<TWINT|1<<TWSTA|1<<TWEN|0<<TWIE

IIC_S:		IN		r16,TWCR
			ANDI	r16,1<<TWINT			
			BREQ	IIC_S		; ���� ���� ���������� IIC �������� �����
			RET
 
;-----------------------------------------------------------------------------
;�������� ���� �� IIC 
IIC_BYTE:  	OUT		TWDR,r16
			OUTI	TWCR,1<<TWINT|1<<TWEN|0<<TWIE
IIC_B:		IN		r16,TWCR
			ANDI	r16,1<<TWINT	; ���� ���� ���������� ������ ����			
			BREQ	IIC_B
			RET
 
;-----------------------------------------------------------------------------
; ������� ����. 
IIC_RCV:	OUTI	TWCR,1<<TWINT|1<<TWEN|1<<TWEA|0<<TWIE
IIC_R:		IN		r16,TWCR
			ANDI	r16,1<<TWINT			
			BREQ	IIC_R		; ���� ���� ���� ����� ������
			RET
 
;-----------------------------------------------------------------------------
; ������� ��������� ����. ������� � ����� � ������� ����� ������ ������ � ���������
; ������? � ��������� ����� �� ������������ ACK!!!
IIC_RCV2:	OUTI	TWCR,1<<TWINT|1<<TWEN|0<<TWEA|0<<TWIE
IIC_R2:		IN		r16,TWCR
			ANDI	r16,1<<TWINT	; ���� ���� ���� ����� ������		
			BREQ	IIC_R2
			RET
 
;-----------------------------------------------------------------------------
; ������������� STOP
IIC_STOP:	OUTI	TWCR,1<<TWINT|1<<TWSTO|1<<TWEN|0<<TWIE
 
;IIC_ST:		IN		r16,TWCR
;			ANDI	r16,1<<TWSTO			
;			BREQ	IIC_ST		; ���� ���� �� ����� ����� ����.
			RET
