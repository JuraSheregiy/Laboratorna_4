.data                             ; директива початку сегменту даних
	sLN db 13,10,'$'
	sSlash db '\$'	
;-//- Змінні для роботи з ФАЙЛАМИ
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
;-//- Повідомлення для введення/виведення даних про телефон
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
;-//- СТРУКТУРА каталогу ТЕЛЕФОНІВ
  mName 	db 20 dup(32),13,10,'$'
  mModel 	db 20 dup(32),13,10,'$'
  mYear		db 4 dup(32),13,10,'$'
  mCamera	db 2 dup(32),13,10,'$'
  mPrice 	db 5 dup(32),13,10,'$'
  vStructSize dw 57
  vAllStruct  db 57 dup(?)
;-//- Змінні 
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
; Очищення вікна
   	MOV  AL, 3		; AL - код режима 80*25 (16 кольори)
	 MOV  AH, 0		; Встановлюємо відеорежим (Очищення екану)
   	 INT  10H 		
; Прокрутка вниз, для зміни байтів атрибут
	mov  al,0    
	xor CX,CX    
	mov  dh,24
	mov  dl,79   
	mov  bh,0F3h		; атрибути
	 mov AH, 07h 	; прокручує вниз
	 INT 10h	 
; Вивід ЗАГОЛОВКА прогрпми	 
	lea DX, sProgramTitle
	call write
; відкритя файла
	call OpenFiles
	mov vPhoneInd,0
;визначення розміру бази данних
	mov AL, 2	; зсув щодо кінця файла
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
; закриття файла
	call CloseFiles
ret
Destr ENDP
;---***///***------***///***------***///***---
About PROC NEAR
; Процедура
	lea DX, sAbout
	call write
ret
About ENDP
;---***///***------***///***------***///***---
PrintStat PROC NEAR
; Процедура
	lea DX, sStat
	call writeln
;вивід к-сті телефонів
	lea DX, sPhonesCnt
	call write
	mov AX, vPhonesCNT
	call WriteInt
	
	call Satistic ; виклик процедури яка знаходить дані
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
; --//--Процедура виводу на екран першого телефону в каталозі
	lea DX, sPrintPhones
	call writeln
	
	mov vPhoneInd,0
	call ShowPhone
ret
PrintPhones ENDP
;---***///***------***///***------***///***---
PrevPhone PROC NEAR
;-//- Процедура виводу на екран характеристик телефону
	lea DX, sPrintPhones
	call writeln
	
	DEC vPhoneInd       ; декремент
	call ShowPhone
	cmp AX, 0FFFh
	je FirstPh
ret
FirstPh: ; якщо це вже був перший телефон то виводимо його
	INC vPhoneInd           ; інкремент
	call ShowPhone
ret
PrevPhone ENDP
;---***///***------***///***------***///***---
ViewPhone PROC NEAR
;-//- Процедура виводу на екран характеристик телефону
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
;-//- Процедура виводу на екран характеристик телефону
	lea DX, sPrintPhones
	call writeln
	
	INC vPhoneInd
	call ShowPhone
	cmp AX, 0FFFh
	je LastPh
ret
LastPh:	; якщо це вже був останный телефон то виводимо його
	DEC vPhoneInd
	call ShowPhone
ret
NextPhone ENDP
;---***///***------***///***------***///***---
AddPhone PROC NEAR
;-//- добавлення нового телефону
; в кінець файлу
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
;-//- Процедура для видалення телефону під індексом
; копіюємо в темп файл все крім того що потрібно було видалити
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

	cmp SI, vPhoneInd		;якщо запис є той який потрібн овидалити
	je nextPh				;то не записуємо в темп файл
	
	mov CX, AX
	mov BX, vFileHandleTMP
	lea DX, vAllStruct
	 mov AH, 40h
	 INT 21h	

	nextPh:
	INC SI
	pop CX
loop CopyCycle1
; У темп файлі наші дані, тепер необхідно закрити обидва файли, 
; видалити файл, темп файл переіменувати, і відкрити файли
	call CloseFiles
	; видаляємо файл з телефонами
	lea DX, vFileName
	 mov AH,41h 
	 INT 21h
	; переіменовуємо темп файл
	lea DX, vFileNameTMP
	lea DI, vFileName
	 mov AH, 56h
	 INT 21h
	call OpenFiles
	DEC vPhonesCNT
; ВИвід відповідного повідомлення
	lea DX, sDone
	call write	
ret
RemovePhone ENDP 
;---***///***------***///***------***///***---
EditPhone PROC NEAR
; Процедура для редагування телефону	
	lea DX, sEditExistsPhone
	call writeln
	
	call AddEditPhone
	DEC vPhonesCNT
ret
EditPhone ENDP
;---***///***------***///***------***///***---
;==============================================================================
ShowPhone PROC NEAR
;-//- Процедура виводу на екран характеристик телефону
	call ReadPhone		;Читаємо з файлу дані
	cmp AX, 5			;якщо немає запису під таким індексом
	je	PrtPh
mov AX, 0FFFh
ret
PrtPh:
;-//- виводимо із структури на екран		
	lea DX, sPhoneInd
	 call write
	mov AX, vPhoneInd
	INC AX		; щоб індексація була з "1"
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
; Процедура добавлення нового телефону

;-//- Зчитування НАЗВИ телефону
	lea DX, sEnterName
	call write

	call ReadString20
	cmp ax,0;якщо користувач ввів пусту строку то виходимо
	jne NotCanceled
	
	lea DX, sCanceled
	call write	
ret
NotCanceled:

; копіювання в нашу строку
	xor SI, SI
	mov CX,20	
To_mName:	
	mov AL,vString20[SI]
	mov mName[SI],AL
	INC SI
loop To_mName

;-//- Зчитування МОДЕЛІ телефону
	lea DX, sLN
	call write
	lea DX, sEnterModel
	 call write
	 
	 call ReadString20
; копіювання в нашу строку	 
	xor SI, SI
	mov CX,20
To_mModel:	
	mov AL,vString20[SI]
	mov mModel[SI],AL
	INC SI
loop To_mModel

;-//- Зчитування Року випуску телефону
	lea DX, sLN
	call write
	lea DX, sEnterYear
	 call write
	 
	 mov AX,4
	 call ReadInt10
; копіювання в нашу строку	 
	xor SI, SI
	mov CX,4
To_mYear:	
	mov AL,vInt10[SI]
	mov mYear[SI],AL
	INC SI
loop To_mYear

;-//- Зчитування КАМЕРИ телефону
	lea DX, sLN
	call write
	lea DX, sEnterCamera
	 call write
	 
	 mov AX,2
	 call ReadInt10
; копіювання в нашу строку	 
	xor SI, SI
	mov CX,2
To_mCamera:	
	mov AL,vInt10[SI]
	mov mCamera[SI],AL
	INC SI
loop To_mCamera

;-//- Зчитування ЦІНИ телефону
	lea DX, sLN
	call write
	lea DX, sEnterPrice
	 call write
	 
	 mov AX,5
	 call ReadInt10
; копіювання в нашу строку	 
	xor SI, SI
	mov CX,5
To_mPrice:	
	mov AL,vInt10[SI]
	mov mPrice[SI],AL
	INC SI
loop To_mPrice
; безпосередньо запис у файл
	
	call WritePhone
	
	INC vPhonesCNT
	lea DX, sDone
	call write
ret
AddEditPhone ENDP 
;===============================
;__________ Процедура для пошуку
SearchPhoneProc PROC NEAR
	mov AH,9
	mov dx,offset sEnterModel
	int 21h
;_____ вводимо дані 
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
;_____ видаляємо останні два введені символи(13,10)
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

; якщо не знайдено
msNotFound:
mov ax, 0
ret
; якщо знайдено
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
		fndMax: ;знаходження максимального
		cmp  AX,vMaxYear
		 jle fndMin
		mov vMaxYear,AX
		fndMin: ;знаходження мінімалдьного
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
; Процедура для читання 20 символів
	xor SI, SI
	mov CX,20
zanulStr20:	
	mov vString20[SI],' '
	INC SI
loop zanulStr20
	xor SI, SI
readChar:
	call ReadKeyProc	; Читаємо символ
	 
	cmp AL, 8
	je BackSlash
	cmp AL, 13				; Чи не натиснуто ЕНТЕР
	je returnStr20
	cmp AL, 32				; Якщо заборонений то читаємо другий
	jl readChar
	cmp AL, 122
	jg readChar
	 
	cmp SI, 20				; Якщо 20 символ	
	jge readChar			; то продовжуємо читати до натиснення ЕНТЕРа
	
	mov DL, AL
	mov AH,2h
	INT 21h
	
	;call Write1Symb
	mov vString20[SI], AL	; Зберігаємо в змінну
	INC SI	
	jmp readChar
returnStr20:
	mov AX, SI
ret
BackSlash:; <- потрібно зменшити індекс, видалити символ
	cmp SI,0
	je readChar
	
	mov vString20[SI],32
	dec SI	
	mov   bh, 0    ;Відеосторінка 0
	 mov   ah, 3
	 int   10h
dec DL
	mov   bh, 0    ;Відеосторінка 0
	 mov   ah, 2
	 int   10h
	 
mov  al, ' '     ;   ASCII-код  символу 
mov  bh,0        ;   Відеосторінка 0 
mov  cx,1        ;   Лічильник  повторення 
	  mov  ah, 0Ah
	  int  10h

jmp readChar
ReadString20 ENDP 
;===============================
ReadInt10 PROC NEAR;(out vString20)
; Процедура для читання 10-цфрового числа
	xor SI, SI
	push AX 	; зберігаємо макс к-сть цифр
	mov CX, 10
zanulInt10:	
	mov vInt10[SI],' '
	INC SI
loop zanulInt10
	xor SI, SI
mReadInt:
	call ReadKeyProc	; Читаємо символ
	 
	cmp AL, 8
	je BackSlashI
	cmp AL, 13				; Чи не натиснуто ЕНТЕР
	je returnInt10
	cmp AL, 30h				; Якщо заборонений то читаємо другий
	jl mReadInt
	cmp AL, 39h
	jg mReadInt
	 
	pop BX
	push BX
	cmp SI, BX				; Якщо 20 символ		
	jge mReadInt			; то продовжуємо читати до натиснення ЕНТЕРа
	
	mov DL, AL
	mov AH,2h
	INT 21h
	
	mov vInt10[SI], AL	; Зберігаємо в змінну
	INC SI	
	jmp mReadInt
returnInt10:
	mov AX, SI
	pop SI
ret
BackSlashI:; <- потрібно зменшити індекс, видалити символ
	cmp SI,0
	je mReadInt
	
	mov vInt10[SI],32
	dec SI	
;Змінюємо положення каретки на один вліво
	mov   bh, 0    ;Відеосторінка 0
	 mov   ah, 3	
	 int   10h
dec DL
	mov   bh, 0    ;Відеосторінка 0
	 mov   ah, 2
	 int   10h
	 
mov  al, ' '     ;   ASCII-код  символу 
mov  bh,0        ;   Відеосторінка 0 
mov  cx,1        ;   Лічильник  повторення 
	  mov  ah, 0Ah
	  int  10h

jmp mReadInt
ReadInt10 ENDP 
;--//--FILE--//----//--FILE--//----//--FILE--//----//--FILE--//----//--FILE--//
OpenFiles PROC NEAR
; Процедура для відкривання файла
	lea SI, vFileName
	mov BX, 2			; Читаємо/Запис
	mov CX, 0			; Звичайний файл
	mov DX, 1			; Відкрити існуючий файл
	 mov AX, 716Ch	 	 
	 INT 21h
	jc createFile		; якщо неможливо відкрити то створюємо
mov vFileHandle, AX
jmp createTMPfile
createFile: ; Створення новго файла
	lea SI, vFileName
	mov BX, 2			; Читаємо/Запис
	mov CX, 0			; Звичайний файл
	mov DX, 10h			; Створення новго
	 mov AX, 716Ch	 	 
	 INT 21h
	mov vFileHandle, AX
	
createTMPfile:
	lea DX, vFileNameTMP
	 mov AH,41h 
	 INT 21h

; Створення новго файла
	lea SI, vFileNameTMP
	mov BX, 2			; Читаємо/Запис
	mov CX, 0			; Звичайний файл
	mov DX, 10h			; Створення новго
	 mov AX, 716Ch	 	 
	 INT 21h
	mov vFileHandleTMP, AX
	
ret
OpenFiles ENDP
;===============================
CloseFiles PROC NEAR
; Процедура для закривання файла
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
 ; Процедура 
mov BX, vPhoneInd
mov AX, vStructSize
mul BX
mov DX, AX

mov BX, vFileHandle
mov CX, 0
mov AL, 0
 mov AH,42h
 INT 21h
 
 ; ЧИтаємо двадцять символів
	mov CX, 20
	mov BX, vFileHandle
	lea DX, mName
	 mov AH, 3fh
	 INT 21h
	; зсуваємо на 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ЧИтаємо двадцять символів
	mov CX, 20
	mov BX, vFileHandle
	lea DX, mModel
	 mov AH, 3fh
	 INT 21h
	; зсуваємо на 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ЧИтаємо 4 символів
	mov CX, 4
	mov BX, vFileHandle
	lea DX, mYear
	 mov AH, 3fh
	 INT 21h
	; зсуваємо на 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
; ЧИтаємо 2 символів
	mov CX, 2
	mov BX, vFileHandle
	lea DX, mCamera
	 mov AH, 3fh
	 INT 21h
	; зсуваємо на 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ЧИтаємо 5 символів
	mov CX, 5
	mov BX, vFileHandle
	lea DX, mPrice
	 mov AH, 3fh
	 INT 21h 	 
	push AX
	
	; зсуваємо на 2 (13,10)
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
; Процедура для збереження даних в файл
	mov AX, vStructSize
	mul vPhoneInd
	mov DX, AX
	
	mov AL, 0	; зсув щодо початку файла	
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
