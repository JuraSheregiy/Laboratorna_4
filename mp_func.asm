.data                             ; ��������� ������� �������� �����
	sLN db 13,10,'$'
	sSlash db '\$'	
;-//- ���� ��� ������ � �������
	vFileHandle DW ?
	vFileName db "mp.txt",0
	vFileHandleTMP DW ?
	vFileNameTMP db "mp_tmp.txt",0	
	vString20 db 20 dup (' ')
	vInt10	db 10 dup(' ')	
	vPhoneInd dw 0
	vPhonesCNT	dw 0
	vMinYear dw 3000
	vMaxYear dw 0
	vMaxPxls dw 0
;-//- ����������� ��� ��������/��������� ����� ��� �������
	sEnterName		db 5 dup(32),'Name: $'
	sEnterModel		db 5 dup(32),'Model: $'
	sEnterYear		db 5 dup(32),'Year: $'
	sEnterCamera	db 5 dup(32),'Camera: $'
	sEnterPrice		db 5 dup(32),'Price: $'	
	sPhoneInd 		db 5 dup(32),'Index: $'	
	sPhonesCnt 		db 5 dup(32),'Phones count: $'
	sMaxPxls db 13,10,5 dup(32),'Max Pixels: $'
	sMinYear db 13,10,5 dup(32),'Min year: $'
	sMaxYear db 13,10,5 dup(32),'Max year: $'
;-//- ��������� �������� ������Ͳ�
  mName 	db 20 dup(32),13,10,'$'
  mModel 	db 20 dup(32),13,10,'$'
  mYear		db 4 dup(32),13,10,'$'
  mCamera	db 2 dup(32),13,10,'$'
  mPrice 	db 5 dup(32),13,10,'$'
  vStructSize dw 57
  vAllStruct  db 57 dup(?)
;-//- ���� 
	srchPhoneModel db 20 dup(32),13,10,'$'
	sStat		 db 25 dup(32),"<<<  Some statistics... >>>$"
	sPrintPhones db 14 dup(32),"<<< Catalog of phones! 4/6 to change phone.. >>>$"
	sAddNewPhone db 12 dup(32),"<<<  Add New Phone! Type the parameters, please.. >>>$"	
	sEditExistsPhone db 12 dup(32),"<<<  Edit exists Phone! Type the parameters, please.. >>>$"		
	sDone	 db 13,10,"Done!$"
	sCanceled		 db 13,10,"Canceled!$"
	PhoneNotFound db 13,10,"Phone not found!$"
	sEMopen db '***Error! Cannt open file!**',13,10,'$'
	sEMaxCNT DB	'***Error! Cannt add phone! There are to many phones!**',13,10,'$'
	sAbout  db 20 dup(32),'This program created by Jura Sheregiy',13,10
			db 20 dup(32),'Student of Engineering faculty UzhNU$'  
;=====================================================================
.code
Init PROC NEAR
	mov AX, @data
	mov DS, AX
	mov ES, AX
; �������� ����
   	MOV  AL, 3		; AL - ��� ������ 80*25 (16 �������)
	 MOV  AH, 0		; ������������ ��������� (�������� �����)
   	 INT  10H 		
; ��������� ����, ��� ���� ����� �������
	mov  al,0    
	xor CX,CX    
	mov  dh,24
	mov  dl,79   
	mov  bh,0F3h		; ��������
	 mov AH, 07h 	; �������� ����
	 INT 10h	 
; ���� ��������� ��������	 
	lea DX, sProgramTitle
	call write
; ������� �����
	call OpenFiles
	mov vPhoneInd,0
;���������� ������ ���� ������
	mov AL, 2	; ���� ���� ���� �����
	mov CX, 0
	mov DX, 0
	mov BX, vFileHandle
	 mov AH, 42h
	 INT 21h	
	div vStructSize
	mov vPhonesCNT, AX
ret
Init ENDP
;---***///***------***///***------***///***---
Destr PROC NEAR
; �������� �����
	call CloseFiles
ret
Destr ENDP
;---***///***------***///***------***///***---
About PROC NEAR
; ���������
	lea DX, sAbout
	call write
ret
About ENDP
;---***///***------***///***------***///***---
PrintStat PROC NEAR
; ���������
	lea DX, sStat
	call writeln
;���� �-�� ��������
	lea DX, sPhonesCnt
	call write
	mov AX, vPhonesCNT
	call WriteInt
	
	call Satistic ; ������ ��������� ��� ��������� ���
	lea DX, sMinYear
	call write	
	mov AX,vMinYear
	 call WriteInt
	lea DX, sMaxYear
	call write	 
	mov AX,vMaxYear
	 call WriteInt
	lea DX, sMaxPxls
	call write	 
	mov AX,vMaxPxls
	 call WriteInt
ret
PrintStat ENDP
;---***///***------***///***------***///***---
PrintPhones PROC NEAR
; --//--��������� ������ �� ����� ������� �������� � �������
	lea DX, sPrintPhones
	call writeln
	
	mov vPhoneInd,0
	call ShowPhone
ret
PrintPhones ENDP
;---***///***------***///***------***///***---
PrevPhone PROC NEAR
;-//- ��������� ������ �� ����� ������������� ��������
	lea DX, sPrintPhones
	call writeln
	
	DEC vPhoneInd       ; ���������
	call ShowPhone
	cmp AX, 0FFFh
	je FirstPh
ret
FirstPh: ; ���� �� ��� ��� ������ ������� �� �������� ����
	INC vPhoneInd           ; ���������
	call ShowPhone
ret
PrevPhone ENDP
;---***///***------***///***------***///***---
ViewPhone PROC NEAR
;-//- ��������� ������ �� ����� ������������� ��������
	lea DX, sPrintPhones
	call writeln
	
	call SearchPhoneProc
	cmp ax,0
	je mNotFoundPhone
	
	call ShowPhone
ret
mNotFoundPhone:
	lea dx, PhoneNotFound
	call write
ret
ViewPhone ENDP
;---***///***------***///***------***///***---
NextPhone PROC NEAR
;-//- ��������� ������ �� ����� ������������� ��������
	lea DX, sPrintPhones
	call writeln
	
	INC vPhoneInd
	call ShowPhone
	cmp AX, 0FFFh
	je LastPh
ret
LastPh:	; ���� �� ��� ��� �������� ������� �� �������� ����
	DEC vPhoneInd
	call ShowPhone
ret
NextPhone ENDP
;---***///***------***///***------***///***---
AddPhone PROC NEAR
;-//- ���������� ������ ��������
; � ����� �����
	lea DX, sAddNewPhone
	call writeln
	
	cmp vPhonesCNT,1100
	jg MaxCNT
	mov AX, vPhonesCNT
	mov vPhoneIND, AX
	call AddEditPhone
ret
MaxCNT:
	lea DX, sEMaxCNT
	call writeln
ret
AddPhone ENDP
;---***///***------***///***------***///***---
RemovePhone PROC NEAR
;-//- ��������� ��� ��������� �������� �� ��������
; ������� � ���� ���� ��� ��� ���� �� ������� ���� ��������
	mov BX, vFileHandle
	mov AL, 0
	xor DX,DX
	xor CX,CX
	 mov AH, 42h
	 INT 21h

xor SI, SI
mov CX, vPhonesCNT
CopyCycle1:
	push CX
	;COPY
	mov CX, vStructSize
	mov BX, vFileHandle
	lea DX, vAllStruct
	 mov AH, 3fh
	 INT 21h

	cmp SI, vPhoneInd		;���� ����� � ��� ���� ������ ���������
	je nextPh				;�� �� �������� � ���� ����
	
	mov CX, AX
	mov BX, vFileHandleTMP
	lea DX, vAllStruct
	 mov AH, 40h
	 INT 21h	

	nextPh:
	INC SI
	pop CX
loop CopyCycle1
; � ���� ���� ���� ���, ����� ��������� ������� ������ �����, 
; �������� ����, ���� ���� ������������, � ������� �����
	call CloseFiles
	; ��������� ���� � ����������
	lea DX, vFileName
	 mov AH,41h 
	 INT 21h
	; ������������ ���� ����
	lea DX, vFileNameTMP
	lea DI, vFileName
	 mov AH, 56h
	 INT 21h
	call OpenFiles
	DEC vPhonesCNT
; ���� ���������� �����������
	lea DX, sDone
	call write	
ret
RemovePhone ENDP 
;---***///***------***///***------***///***---
EditPhone PROC NEAR
; ��������� ��� ����������� ��������	
	lea DX, sEditExistsPhone
	call writeln
	
	call AddEditPhone
	DEC vPhonesCNT
ret
EditPhone ENDP
;---***///***------***///***------***///***---
;==============================================================================
ShowPhone PROC NEAR
;-//- ��������� ������ �� ����� ������������� ��������
	call ReadPhone		;������ � ����� ���
	cmp AX, 5			;���� ���� ������ �� ����� ��������
	je	PrtPh
mov AX, 0FFFh
ret
PrtPh:
;-//- �������� �� ��������� �� �����		
	lea DX, sPhoneInd
	 call write
	mov AX, vPhoneInd
	INC AX		; ��� ���������� ���� � "1"
	 call WriteInt
	lea DX,sLN
	 call Write
;	
	lea DX, sEnterName
	 call write
	lea DX, mName	
	 call write
;	 
	lea DX, sEnterModel
	 call write
	lea DX, mModel
	 call write	
;	 
	lea DX, sEnterYear
	 call write
	lea DX, mYear
	 call write		 
;	 
	lea DX, sEnterCamera
	 call write
	lea DX, mCamera
	 call write	
;	 
	lea DX, sEnterPrice
	 call write
	lea DX, mPrice
	 call write		 
ret
ShowPhone ENDP
;===============================
AddEditPhone PROC NEAR
; ��������� ���������� ������ ��������

;-//- ���������� ����� ��������
	lea DX, sEnterName
	call write

	call ReadString20
	cmp ax,0;���� ���������� ��� ����� ������ �� ��������
	jne NotCanceled
	
	lea DX, sCanceled
	call write	
ret
NotCanceled:

; ��������� � ���� ������
	xor SI, SI
	mov CX,20	
To_mName:	
	mov AL,vString20[SI]
	mov mName[SI],AL
	INC SI
loop To_mName

;-//- ���������� ����˲ ��������
	lea DX, sLN
	call write
	lea DX, sEnterModel
	 call write
	 
	 call ReadString20
; ��������� � ���� ������	 
	xor SI, SI
	mov CX,20
To_mModel:	
	mov AL,vString20[SI]
	mov mModel[SI],AL
	INC SI
loop To_mModel

;-//- ���������� ���� ������� ��������
	lea DX, sLN
	call write
	lea DX, sEnterYear
	 call write
	 
	 mov AX,4
	 call ReadInt10
; ��������� � ���� ������	 
	xor SI, SI
	mov CX,4
To_mYear:	
	mov AL,vInt10[SI]
	mov mYear[SI],AL
	INC SI
loop To_mYear

;-//- ���������� ������ ��������
	lea DX, sLN
	call write
	lea DX, sEnterCamera
	 call write
	 
	 mov AX,2
	 call ReadInt10
; ��������� � ���� ������	 
	xor SI, SI
	mov CX,2
To_mCamera:	
	mov AL,vInt10[SI]
	mov mCamera[SI],AL
	INC SI
loop To_mCamera

;-//- ���������� ֲ�� ��������
	lea DX, sLN
	call write
	lea DX, sEnterPrice
	 call write
	 
	 mov AX,5
	 call ReadInt10
; ��������� � ���� ������	 
	xor SI, SI
	mov CX,5
To_mPrice:	
	mov AL,vInt10[SI]
	mov mPrice[SI],AL
	INC SI
loop To_mPrice
; ������������� ����� � ����
	
	call WritePhone
	
	INC vPhonesCNT
	lea DX, sDone
	call write
ret
AddEditPhone ENDP 
;===============================
;__________ ��������� ��� ������
SearchPhoneProc PROC NEAR
	mov AH,9
	mov dx,offset sEnterModel
	int 21h
;_____ ������� ��� 
	mov cx,20
	xor si,si
cycle_zanul:
	mov srchPhoneModel[si],' '
	inc si
loop cycle_zanul
	xor si,si
	xor AX,AX
	xor BX,BX
	
	mov AH,3fh
	mov dx,offset srchPhoneModel
	mov cx, 25
	int 21h
;_____ ��������� ������ ��� ������ �������(13,10)
mov SI,ax
mov srchPhoneModel[si-2],32
mov srchPhoneModel[si-1],32
	
	cmp vPhoneSCNT,0
	je msNotFound
	
	mov vPhoneInd,0
	mov cx, vPhoneSCNT
	
SearchCycle:
push CX
		call ReadPhone
		xor si,si
	cmpPhone:	
		mov al,srchPhoneModel[si]
		mov ah, mModel[si]
		cmp ah,al
		 jne nextSearchPhone
		inc si
		cmp si,20
		je msFound
	jmp cmpPhone
nextSearchPhone:
	inc VPhoneInd
pop CX	
loop SearchCycle

; ���� �� ��������
msNotFound:
mov ax, 0
ret
; ���� ��������
msFound:
pop cx
mov ax, 1
ret
SearchPhoneProc ENDP
;===============================
Satistic PROC NEAR
	mov vPhoneInd,0
	mov cx, vPhoneSCNT
	
CycleStat:
push CX
		call ReadPhone
		
		call ConvertYear
		fndMax: ;����������� �������������
		cmp  AX,vMaxYear
		 jle fndMin
		mov vMaxYear,AX
		fndMin: ;����������� �����������
		cmp  AX,vMinYear
		 jge fndMaxPxls
		mov vMinYear,AX
		fndMaxPxls:
		call ConvertCamera
		cmp  AX,vMaxPxls
		 jle stNext
		mov vMaxPxls,AX

	stNext:
	inc VPhoneInd
pop CX	
loop CycleStat
	mov VPhoneInd,0
ret
Satistic ENDP

;===============================
ReadString20 PROC NEAR;(out vString20)
; ��������� ��� ������� 20 �������
	xor SI, SI
	mov CX,20
zanulStr20:	
	mov vString20[SI],' '
	INC SI
loop zanulStr20
	xor SI, SI
readChar:
	call ReadKeyProc	; ������ ������
	 
	cmp AL, 8
	je BackSlash
	cmp AL, 13				; �� �� ��������� �����
	je returnStr20
	cmp AL, 32				; ���� ����������� �� ������ ������
	jl readChar
	cmp AL, 122
	jg readChar
	 
	cmp SI, 20				; ���� 20 ������	
	jge readChar			; �� ���������� ������ �� ���������� ������
	
	mov DL, AL
	mov AH,2h
	INT 21h
	
	;call Write1Symb
	mov vString20[SI], AL	; �������� � �����
	INC SI	
	jmp readChar
returnStr20:
	mov AX, SI
ret
BackSlash:; <- ������� �������� ������, �������� ������
	cmp SI,0
	je readChar
	
	mov vString20[SI],32
	dec SI	
	mov   bh, 0    ;³���������� 0
	 mov   ah, 3
	 int   10h
dec DL
	mov   bh, 0    ;³���������� 0
	 mov   ah, 2
	 int   10h
	 
mov  al, ' '     ;   ASCII-���  ������� 
mov  bh,0        ;   ³���������� 0 
mov  cx,1        ;   ˳�������  ���������� 
	  mov  ah, 0Ah
	  int  10h

jmp readChar
ReadString20 ENDP 
;===============================
ReadInt10 PROC NEAR;(out vString20)
; ��������� ��� ������� 10-�������� �����
	xor SI, SI
	push AX 	; �������� ���� �-��� ����
	mov CX, 10
zanulInt10:	
	mov vInt10[SI],' '
	INC SI
loop zanulInt10
	xor SI, SI
mReadInt:
	call ReadKeyProc	; ������ ������
	 
	cmp AL, 8
	je BackSlashI
	cmp AL, 13				; �� �� ��������� �����
	je returnInt10
	cmp AL, 30h				; ���� ����������� �� ������ ������
	jl mReadInt
	cmp AL, 39h
	jg mReadInt
	 
	pop BX
	push BX
	cmp SI, BX				; ���� 20 ������		
	jge mReadInt			; �� ���������� ������ �� ���������� ������
	
	mov DL, AL
	mov AH,2h
	INT 21h
	
	mov vInt10[SI], AL	; �������� � �����
	INC SI	
	jmp mReadInt
returnInt10:
	mov AX, SI
	pop SI
ret
BackSlashI:; <- ������� �������� ������, �������� ������
	cmp SI,0
	je mReadInt
	
	mov vInt10[SI],32
	dec SI	
;������� ��������� ������� �� ���� ����
	mov   bh, 0    ;³���������� 0
	 mov   ah, 3	
	 int   10h
dec DL
	mov   bh, 0    ;³���������� 0
	 mov   ah, 2
	 int   10h
	 
mov  al, ' '     ;   ASCII-���  ������� 
mov  bh,0        ;   ³���������� 0 
mov  cx,1        ;   ˳�������  ���������� 
	  mov  ah, 0Ah
	  int  10h

jmp mReadInt
ReadInt10 ENDP 
;--//--FILE--//----//--FILE--//----//--FILE--//----//--FILE--//----//--FILE--//
OpenFiles PROC NEAR
; ��������� ��� ���������� �����
	lea SI, vFileName
	mov BX, 2			; ������/�����
	mov CX, 0			; ��������� ����
	mov DX, 1			; ³������ �������� ����
	 mov AX, 716Ch	 	 
	 INT 21h
	jc createFile		; ���� ��������� ������� �� ���������
mov vFileHandle, AX
jmp createTMPfile
createFile: ; ��������� ����� �����
	lea SI, vFileName
	mov BX, 2			; ������/�����
	mov CX, 0			; ��������� ����
	mov DX, 10h			; ��������� �����
	 mov AX, 716Ch	 	 
	 INT 21h
	mov vFileHandle, AX
	
createTMPfile:
	lea DX, vFileNameTMP
	 mov AH,41h 
	 INT 21h

; ��������� ����� �����
	lea SI, vFileNameTMP
	mov BX, 2			; ������/�����
	mov CX, 0			; ��������� ����
	mov DX, 10h			; ��������� �����
	 mov AX, 716Ch	 	 
	 INT 21h
	mov vFileHandleTMP, AX
	
ret
OpenFiles ENDP
;===============================
CloseFiles PROC NEAR
; ��������� ��� ���������� �����
	mov BX, vFileHandle
	 mov AH, 3eh
	 int 21h
	mov BX, vFileHandleTMP
	 mov AH, 3eh
	 int 21h	 
ret
CloseFiles ENDP
;===============================	 
ReadPhone PROC NEAR
 ; ��������� 
mov BX, vPhoneInd
mov AX, vStructSize
mul BX
mov DX, AX

mov BX, vFileHandle
mov CX, 0
mov AL, 0
 mov AH,42h
 INT 21h
 
 ; ������ �������� �������
	mov CX, 20
	mov BX, vFileHandle
	lea DX, mName
	 mov AH, 3fh
	 INT 21h
	; ������� �� 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ������ �������� �������
	mov CX, 20
	mov BX, vFileHandle
	lea DX, mModel
	 mov AH, 3fh
	 INT 21h
	; ������� �� 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ������ 4 �������
	mov CX, 4
	mov BX, vFileHandle
	lea DX, mYear
	 mov AH, 3fh
	 INT 21h
	; ������� �� 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
; ������ 2 �������
	mov CX, 2
	mov BX, vFileHandle
	lea DX, mCamera
	 mov AH, 3fh
	 INT 21h
	; ������� �� 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ������ 5 �������
	mov CX, 5
	mov BX, vFileHandle
	lea DX, mPrice
	 mov AH, 3fh
	 INT 21h 	 
	push AX
	
	; ������� �� 2 (13,10)
	mov AL, 1
	mov CX, 0	
	mov DX, 2	
	 mov AH, 42h
	 INT 21h		 
	 
	pop AX
ret
ReadPhone ENDP
;=============================== 
WritePhone PROC NEAR
; ��������� ��� ���������� ����� � ����
	mov AX, vStructSize
	mul vPhoneInd
	mov DX, AX
	
	mov AL, 0	; ���� ���� ������� �����	
	mov CX, 0
	mov BX, vFileHandle
	 mov AH, 42h
	 INT 21h	

	mov CX, 20
	mov BX, vFileHandle
	lea DX, mName
	 mov AH, 40h
	 INT 21h
	
	mov CX, 1		;///////////////////////////////////
	mov BX, vFileHandle
	lea DX, sSlash
	 mov AH, 40h
	 INT 21h
	
	mov CX, 20
	mov BX, vFileHandle
	lea DX, mModel
	 mov AH, 40h
	 INT 21h

	mov CX, 1		;///////////////////////////////////
	mov BX, vFileHandle
	lea DX, sSlash
	 mov AH, 40h
	 INT 21h
	
	mov CX, 4
	mov BX, vFileHandle
	lea DX, mYear
	 mov AH, 40h
	 INT 21h

	mov CX, 1		;///////////////////////////////////
	mov BX, vFileHandle
	lea DX, sSlash
	 mov AH, 40h
	 INT 21h
	 
	mov CX, 2
	mov BX, vFileHandle
	lea DX, mCamera
	 mov AH, 40h
	 INT 21h

	mov CX, 1		;///////////////////////////////////
	mov BX, vFileHandle
	lea DX, sSlash
	 mov AH, 40h
	 INT 21h
	
	mov CX, 5
	mov BX, vFileHandle
	lea DX, mPrice
	 mov AH, 40h
	 INT 21h
	 	 
	mov CX, 2		;(13,10) (13,10) (13,10) (13,10)
	mov BX, vFileHandle
	lea DX, sLN
	 mov AH, 40h
	 INT 21h	 
ret
WritePhone ENDP
