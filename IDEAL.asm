IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
CODESEG
start:
;----------------- protocols
	mov ax, @data
	mov ds, ax
	

	mov dl, 2
	add dl, '0'
	mov ah, 2h   ; call interrupt to display a value in DL
   	int 21h 


	
exit:
	mov ax, 4c00h
	int 21h
END start