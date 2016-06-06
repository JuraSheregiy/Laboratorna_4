.model small   ; директива опису моделі пам'яті, код займає 1 сегмент, дані об'єднані в 1 групу,викор. для більшості невел. прог
.stack 100h    ; директива початку задання стеку, 100 бітів розмір стеку
.code          ; початок сегменту коду, який викор. прога
START:		
	call Init 			; Ініціалізація
	call ShowMainMenu	; МЕНЮ ПРОГРАМИ		
ReadUserAction:
	mov al, 25              ; копіювання
	call CursorToLine		; Прячемо курсор в 25 рядку(який неіснує)
	call ReadKeyProc		; Читаємо клавішу
	  
	sub AL, 30h              ; віднімання
;перевірка натиснутої клавіші
	cmp AL,0                  ;порівняння чисел реально міняє значення флажків
	jl ReadUserAction         ; перейти якшо менше
	cmp AL,9
	jg ReadUserAction         ;перейти якшо більше
	
	call ClrPartScr            ;виклик
;-//- В залежності від вибору користувачем команди:::
	cmp AL, 1	
	 je ACTION_about	; 1- Вивід на екран "Про програму" перейти якшо рівно

	cmp AL, 2
	 je ACTION_stat		; 2- Вивід статистики
	 
	cmp AL, 3
	 je ACTION_print	; 3- Виводимо на екран список телефонів
	 
	cmp AL, 4
	 je ACTION_prev		; 4- Попередній запис
	 
	cmp AL, 5
	 je ACTION_view		; 4- Запис під індексом
	 
	cmp AL, 6
	 je ACTION_next		; 6- Наступний запис
	 
	cmp AL, 7	
	 je ACTION_add		; 2- Форма добавлення нового телефону
	 
	cmp AL, 8		 
	 je ACTION_remove	; 3- Видалення телефону
	 
	cmp AL, 9	 
	 je ACTION_edit		; 4- Редагування даних про телефону
	 
	cmp AL, 0	
	 je EXIT			; 0- Виходимо з програми	 
	 
jmp ReadUserAction        ; безумовний перехід
;-//- ОБРОБКА КОМАНД
ACTION_about:
	call About
	jmp ReadUserAction
	
ACTION_stat:
	call PrintStat
	jmp ReadUserAction

ACTION_print:
	call PrintPhones
	jmp ReadUserAction
	
ACTION_prev:
	call PrevPhone
	jmp ReadUserAction
	
ACTION_view:
	call ViewPhone
	jmp ReadUserAction
	
ACTION_next:
	call NextPhone
	jmp ReadUserAction
	
ACTION_add:
	call AddPhone
	jmp ReadUserAction
	
ACTION_remove:
	call RemovePhone
	jmp ReadUserAction
	
ACTION_edit:
	call EditPhone
	jmp ReadUserAction
	
;-//-ВИХІД ІЗ ПРОГРАМИ
EXIT:
	call Destr			; Деструктор

	mov AX, 4C00h
	INT 21h

include mp_if.asm		; Інтерфейс програми
include mp_func.asm		; Основні функції
end start