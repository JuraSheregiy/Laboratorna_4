.data
;-//- ���� ��� ���������� �������/���� ��������
	sProgramTitle db 22 dup(32),'     ..... MOBILE PHONES .....',13,10    ; �� ��������� ���� ��� ��������� ��������
	db 80 dup('_'),'$'
	WIbuff db 80 dup(?)
;-//- ���� ��� ����	                          
	sMenu 	 db 20 dup(32),'|   | -1-  About this program  |   |',13,10  ; ��� ��������
			 db 20 dup(32),'|   | -2-  Print statistic     |   |',13,10  ; ����������
			 db 20 dup(32),'|   | -3-  Print phones        |   |',13,10  ; ����������� �������
			 db 20 dup(32),'|   | -0-  Exit                |   |',13,10  ; �����	
			 db 20 dup(32),'| M |__________________________| M |',13,10		
			 db 20 dup(32),'| E | -4-  [<-] Prev phone     | E |',13,10  ; ��������� 
			 db 20 dup(32),'| N | -5-  Search by model     | N |',13,10  ; �����
			 db 20 dup(32),'| U | -6-  [->] Next phone     | U |',13,10  ; ��������� �������	
			 db 20 dup(32),'|   | -7-  Add new phone       |   |',13,10  ; ��������
			 db 20 dup(32),'|   | -8-  Remove phone        |   |',13,10  ; ��������
			 db 20 dup(32),'|   | -9-  Edit exists phone   |   |',13,10  ; ����������
			 db 20 dup(32),'|___|__________________________|___|',13,10,'$'	
.code
;=============================== 
ShowMainMenu PROC NEAR
;-//- ���� �� ����� ����Ҳ� ����
	lea DX, sMenu        ; ������������ ��������� ������
	 call write
ret                      ; ����������
ShowMainMenu ENDP
;====================================================
ClrPartScr PROC NEAR
; ������ ������� ����(� 14 �� 24 �����)
push AX                  ; �������� � ����
push BX 
push CX
	mov  al,0    
	mov  ch,15
	mov  cl,0     
	mov  dh,24   
	mov  dl,79   
	mov  bh,0F7h
	 mov AH, 07h ; �������� ����
	 INT 10h
	 
	mov al,15
	call CursorToLine	; ������� ������
pop CX                   ; ������� �� �����
pop BX 
pop AX
ret
ClrPartScr ENDP	 
;==================================================== 
CursorToLine PROC NEAR
push DX
	mov dL, 0		; �������� 0
	mov dH, al		; � �� �������� ����� �����
	mov bH, 0  		; �������
	 mov aH, 02h	; �̲�� ��������� �������
	 INT 10h 
pop DX
ret
CursorToLine ENDP
;====================================================	 
ReadKeyProc PROC NEAR
	 mov AH, 00h	; ������� ��������� ������������ �������
	 INT 16h
ret 
ReadKeyProc ENDP 
;=============================== 
 write PROC NEAR
; ��������� ��������� ����� �������
   push AX
	mov AH, 09h
	INT 21h
   pop AX
ret
write ENDP
;=============================== 
 writeln PROC NEAR
; ���������
   push AX
   push DX
	mov AH, 09h
	 INT 21h
	lea DX, sLN
	 INT 21h	
   pop DX
   pop AX
ret
writeln ENDP
;===============================
WriteInt PROC NEAR;(AX)
	mov si,0
	mov cx,25
zanul:
	mov WIbuff[si],0
	add si,1
	loop zanul           ; ����
	mov si,0
	mov cx,10
dill:
	cmp ax,10
	jl last
	xor dx,dx            ; �������� ���
	div cx 		; ĳ���� DX:AX �� CX (10),
	xchg ax,dx 	; ̳����� �� ������
	add al,'0' 	; �������� � AL ������ ��������� �����
	mov WIbuff[si],al
	add si,1
	xchg ax,dx
	cmp ax,10
	jge dill     ; ����� ����
last:
	add al,'0'
	mov WIbuff[si],al
	add si,1

	mov si,24
	mov cx,25
vuv:
	cmp WIbuff[si],0
	jne cifr          ; ������� ���� �� ����

	sub si,1
	loop vuv
cifr:
	mov dl,WIbuff[si]
	mov ah,02h
	int 21h
	sub si,1
	loop vuv
ret
WriteInt ENDP

ReadInt PROC NEAR
		
	xor AX, AX
	xor BX, BX
	xor CX, CX
	xor DX, DX
	
	call ReadString20
	
	StrToIntLoop:
			mov cx,ax ; � CX ������� ����
			mov si,0 ; ��������
			xor AX,AX ; � AX ����� ���������� �����

	cycle: ;���� ��������
		mov bL, vString20(si)
		sub bL,30h
		add AX,BX
		add si,1
		cmp cx,1
		jne mnoj ;���� CX<>1 (�� ������� �����)

			
	ret ; ���������� � ������� � ��������
	 mnoj:
			mov BL,10
			mul BL; Ax*10
	loop cycle
ReadInt ENDP

ConvertYear PROC NEAR
; int(mYear) -> AX
	push dx bx
	mov bl,10	
	
	mov al, mYear[3]
	sub al, 30h
	mov dx, ax

	xor ax,ax
	mov al, mYear[2]
	sub al, 30h
	mul bl
	add dx,ax
	
	xor ax,ax
	mov al, mYear[1]
	sub al, 30h
	mul bl
	mul bl
	add dx,ax
	
	xor ax,ax
	mov al, mYear[0]
	sub al, 30h
	mul bl
	mul bl
	mul bl
	add AX,dx
	
	pop bx dx
ret
ConvertYear ENDP

ConvertCamera PROC NEAR
; int(mCamera) -> AX
	push bx dx
	mov bl,10	
	
	xor ax,ax
	mov al, mCamera[1]
	sub al, 30h
	mov dx, ax

	xor ax,ax
	mov al, mCamera[0]
	sub al, 30h
	mul bl
	add AX,dx
	
	pop dx bx
ret
ConvertCamera ENDP
