.model small   ; ��������� ����� ����� ���'��, ��� ����� 1 �������, ��� ��'����� � 1 �����,�����. ��� ������� �����. ����
.stack 100h    ; ��������� ������� ������� �����, 100 ��� ����� �����
.code          ; ������� �������� ����, ���� �����. �����
START:		
	call Init 			; �����������
	call ShowMainMenu	; ���� ��������		
ReadUserAction:
	mov al, 25              ; ���������
	call CursorToLine		; ������� ������ � 25 �����(���� �����)
	call ReadKeyProc		; ������ ������
	  
	sub AL, 30h              ; ��������
;�������� ��������� ������
	cmp AL,0                  ;��������� ����� ������� ���� �������� ������
	jl ReadUserAction         ; ������� ���� �����
	cmp AL,9
	jg ReadUserAction         ;������� ���� �����
	
	call ClrPartScr            ;������
;-//- � ��������� �� ������ ������������ �������:::
	cmp AL, 1	
	 je ACTION_about	; 1- ���� �� ����� "��� ��������" ������� ���� ����

	cmp AL, 2
	 je ACTION_stat		; 2- ���� ����������
	 
	cmp AL, 3
	 je ACTION_print	; 3- �������� �� ����� ������ ��������
	 
	cmp AL, 4
	 je ACTION_prev		; 4- ��������� �����
	 
	cmp AL, 5
	 je ACTION_view		; 4- ����� �� ��������
	 
	cmp AL, 6
	 je ACTION_next		; 6- ��������� �����
	 
	cmp AL, 7	
	 je ACTION_add		; 2- ����� ���������� ������ ��������
	 
	cmp AL, 8		 
	 je ACTION_remove	; 3- ��������� ��������
	 
	cmp AL, 9	 
	 je ACTION_edit		; 4- ����������� ����� ��� ��������
	 
	cmp AL, 0	
	 je EXIT			; 0- �������� � ��������	 
	 
jmp ReadUserAction        ; ���������� �������
;-//- ������� ������
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
	
;-//-��ղ� �� ��������
EXIT:
	call Destr			; ����������

	mov AX, 4C00h
	INT 21h

include mp_if.asm		; ��������� ��������
include mp_func.asm		; ������ �������
end start