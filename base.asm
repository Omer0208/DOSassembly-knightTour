IDEAL
MODEL small
STACK 100h
MAX_BMP_WIDTH  = 320
MAX_BMP_HEIGHT = 200
SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH  = 40
DATASEG
; --------------------------
;320 200



;----------- board
siz db -1 ;amount of square : get this value in fixsiz
bigsiz dw -1 ;siz in dw : get this value in finpix
bigbrdsiz dw -1 ;size of square in dw : get this value in finpix
brdsiz db 200 ;size of square 


;------ finding algorithem and play
wor db 225 dup(-1);array of where the knight has been

color db 1 ;wat color pixel

colorrandomizer db 0 ;wat color pixel
changeorno db 0 ; doesit need to skip or not
;------knight position
kplacex dw 0 ; where clicked in squares
kplacey dw 0

mousex dw 0; pysical position of mouse
mousey dw 0
; --------------------make cube
temp dw ? ; tmp
temptwo dw ? ; tmp2

; make board
increone dw 0 ; square making loop
incretwo dw 0; square making loop

whichone dw 0 ; square making loop
whichtwo dw 0; square making loop

;----------------------knight movement
knightplacex dw 0  ;place of knight
knightplacey dw 0

temparradderone dw 2
temparraddertwo dw 2

allowedmove dw 0
loopermove dw 0

anymovepossible dw 0

randommovx dw 0
randommovy dw 0
;--------------------solving
movesinsolve db 225 dup(0) ;(amount of moves)
solvingloop db 0

wheremovtox dw 0
wheremovtoy dw 0

;File Data : pictures
OneBmpLine 	    db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
ScreenLineMax 	db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
FileHandle	 dw ?
Header 	            db 54 dup(0)
Palette 	        db 400h dup (0)
StartImage        db 'start.bmp',0 ; file name
BmpFileErrorMsg    	db 'Error At Opening Bmp File .', 0dh, 0ah,'$'
ErrorFile           db 0
BB                  db "BB..",'$'	 
BmpLeft             dw 0 ;x
BmpTop              dw 0 ;y
BmpColSize          dw 16 ;columns number
BmpRowSize          dw 16 ;rows number
;- picture
horse db 'horsie.bmp',0
button db 'buttont.bmp' ,0
restart db 'restart.bmp' ,0
CODESEG
include 'openFile.inc'
;------------------sound

proc Beep ; כמה טיקים, צליל
    push bp
    mov bp, sp

    mov al, 0B6h
    out 43h, al

    mov ax, [bp+4]
    out 42h, al 
    mov al, ah
    out 42h, al

    mov cx, [bp+6]
    sounding:
        push cx
        call oneTick
        pop cx
        loop sounding

    pop bp
    ret 4
endp Beep
proc playSound ;----------- make the sound move
    in al, 61h
    or al, 00000011b
    out 61h, al

    push 2
    push 1000h 
    call Beep

    in al, 61h
    and al, 11111100b
    out 61h, al
    ret
endp playSound
proc oneTick
    mov ah, 0 
    int 1ah
    mov bx, dx

    waitInside:
        mov ah, 0
        int 1ah

        sub dx, bx 
        cmp dx, 1 
        jb waitInside
    ret
endp oneTick

proc generaterandomone;------------generate random
   
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

   mov  ax, dx
   xor  dx, dx
   mov  cx, 16
   div  cx  ;found in dx
   mov [colorrandomizer], dl
endp generaterandomone



proc Upload_Image;----------upload image
	push bp
	mov bp,sp
	;BmpColSize[bp+4] 
	;BmpRowSize[bp+6]
	;BmpTop[bp+8]
	;BmpLeft[bp+10]
	mov si,[bp+10]
	mov [BmpLeft],si
	mov si,[bp+8]
	mov [BmpTop],si
	mov si,[bp+6]
	mov [BmpRowSize],si
	mov si,[bp+4]
	mov [BmpColSize],si
	call OpenShowBmp 
	cmp [ErrorFile],1
	jne exitErrorImage
	exitErrorImage:
	mov dx, offset BmpFileErrorMsg
	pop bp
	ret 8
endp Upload_Image

;--------------------------------------------------------------------------get values

proc fixsiz ;--- gets num for size v

	mov ah, 1h
	int 21h
	
	mov bl, 10h
	xor ah,ah
	div bl
	
	cmp al, 3
	je first
	
	cmp al, 4
	je second
	
	cmp al, 6
	je second
	
	jmp exit
	
	first:
		mov [siz], ah
	jmp retfixsiz
	second:
		cmp ah, 6
		ja ender
		mov [siz], ah 
		add [siz], 9 ; to get them to be 10 - 15
	retfixsiz:
	ret 

endp fixsiz

proc finpix ;--- checks what size a square should be v

	mov al,[brdsiz]
	xor ah,ah
	div [siz]
	
	mov [brdsiz], al
	
	xor ax,ax
    mov al,[siz]
    mov [bigsiz], ax

	xor ax,ax
    mov al,[brdsiz]
    mov [bigbrdsiz], ax

	ret 
endp finpix
;--------------------------------------------------------------------------make board

;----------------------make dot v
proc one_dot;x y
	push bp
	mov bp, sp
	y equ [bp+4]
	x equ [bp+6]
	
	mov bh, 0h
	mov cx, x
	mov dx, y
	mov al, [color]
	mov ah, 0ch
	int 10h
	
	pop bp
	ret 4
endp one_dot

ender:
	JMP exit

;-----------------------make square v  
PROC draw_cube ;   gets x the y
	mov [temp] , 0
	mov [temptwo] , 0

    PUSH BP
    MOV BP, SP
    
    MOV AX, [BP+6]    ; Get the X-coordinate parameter
    MOV BX, [BP+4]    ; Get the Y-coordinate parameter
    

	add [temp] ,BX
	mov DX,[bigbrdsiz]
	add [temp],DX

	add [temptwo],AX
	mov CX,[bigbrdsiz]
	add [temptwo],CX

    ; Loop to draw the square cube
    MOV CX, AX
    MOV DX, BX
draw_loop:
    PUSH CX
    PUSH DX
    CALL one_dot
    
    ADD DX, 1       ; Move down one pixel
    
    CMP DX, [temp]   ; Check if we reached the end of a row
    JB draw_loop
    
    ADD CX, 1       ; Move to the next row
    MOV DX, BX
    
    CMP CX, [temptwo]   ; Check if we reached the end of the cube
    JB draw_loop
    
    POP BP
    RET 4
ENDP draw_cube

;-----------------------make board squares v
proc makeboard
    mov [increone], 60
	mov [incretwo],  0

	mov al,[siz]
	xor ah,ah
	mov bl, 2
	div bl

	cmp ah,0
		je duos
	mov [changeorno] ,1h



	duos:
boardmakeloopbig:
	boardmakeloopsmall:
		push [increone]
		push [incretwo]
		call colorc
		call draw_cube
		mov ax, [bigbrdsiz]
		add [increone],ax
		inc [whichone]
		mov ax, [whichone]
		cmp ax,[bigsiz]
		jb boardmakeloopsmall

	cmp [changeorno] ,1h
		je nochange
	call colorc
	nochange:


	inc [whichtwo]
	mov [increone], 60
	mov [whichone], 0
	mov ax, [bigbrdsiz]
	add [incretwo],ax
	mov ax, [whichtwo]
	cmp ax,[bigsiz]
	jb boardmakeloopbig

    RET
endp makeboard

;-----------------------change var color  v
proc colorc
	mov al, [colorrandomizer]
	mov bl,al
	inc bl
	cmp [color], al
	je changeone;
	mov [color] , al
	jmp colorchangeend
	
	changeone:
		mov [color] , bl
	colorchangeend:
	ret
endp colorc


proc pictureee
	mov [BmpLeft], 0
	mov [BmpTop], 0
	mov [BmpColSize], 16
	mov [BmpRowSize], 16
    mov dx, offset horse
	call OpenShowBmp
	cmp [ErrorFile],1
	jne cont12
	jmp exitError1
	cont12:
	jmp exit12
	exitError1:
    mov dx, offset BmpFileErrorMsg
	mov ah,9
	int 21h	
	exit12:
	ret
endp pictureee

proc getmouseclick ;------------------ wait til clicked and gets position v
	mov [allowedmove],1
	unclickloop:
		mov ax,3h
		int 33h
		shr CX,1
		cmp BX, 01b
		jne unclickloop
	ret
endp getmouseclick


proc getkplace;------------------ wait til clicked and gets which square v
	mov [allowedmove],1
	call getmouseclick

	cmp CX,60
	jb solution

	cmp CX,260
	ja restarter

	sub CX, 60

	mov ax,CX
	div [brdsiz]


	
	mov bl, al
	xor bh,bh

	mov bl, al
	xor bh,bh

	mov [kplacex] ,BX
	;------------
	mov ax,DX
	div [brdsiz]
	
	mov bl, al
	xor bh,bh

	mov bl, al
	xor bh,bh

	mov [kplacey] ,BX
	ret
endp getkplace

restarter:
call restarting

solution:
call solutionpressed

proc colorsquare;---------------- make a specific square a specific color v

    PUSH BP
    MOV BP, SP

    MOV AX, [BP+6]    ; Get the X-coordinate parameter

	mul [bigbrdsiz]
	add ax, 60

	push ax


	MOV AX, [BP+4] 

	mul [bigbrdsiz]

	push ax

	mov ax,2h
	int 33h	
	call draw_cube
	mov ax,1h
	int 33h	

	call setnuminarray
	mov [wor + bx ], 1

	pop bp	
	ret 4
endp colorsquare

proc checkmovementk ;checks everything by hand v

	mov [allowedmove],0

	PUSH BP
    MOV BP, SP

	MOV AX, [BP+6]
	MOV BX, [BP+4]

	mov DX, [knightplacex] 
	sub DX, 2
	mov CX, [knightplacey] 
	add CX, 1

	cmp dx, ax
	jne incorrectone
	cmp cx, bx
	jne incorrectone

	mov [allowedmove],1
	jmp correctone
	incorrectone:

	mov DX, [knightplacex] 
	sub DX, 2
	mov CX, [knightplacey] 
	sub CX, 1

	cmp dx, ax
	jne incorrecttwo
	cmp cx, bx
	jne incorrecttwo

	mov [allowedmove],1
	correctone:
	jmp correcttwo
	incorrecttwo:

	mov DX, [knightplacex] 
	sub DX, 1
	mov CX, [knightplacey] 
	add CX, 2

	cmp dx, ax
	jne incorrecthree
	cmp cx, bx
	jne incorrecthree

	mov [allowedmove],1
	correcttwo:
	jmp correctthree
	incorrecthree:

	mov DX, [knightplacex] 
	sub DX, 1
	mov CX, [knightplacey] 
	sub CX, 2

	cmp dx, ax
	jne incorrecfour
	cmp cx, bx
	jne incorrecfour

	mov [allowedmove],1
	correctthree:
	jmp correctfour
	incorrecfour:

	mov DX, [knightplacex] 
	add DX, 1
	mov CX, [knightplacey] 
	add CX, 2

	cmp dx, ax
	jne incorrecfive
	cmp cx, bx
	jne incorrecfive

	mov [allowedmove],1
	correctfour:
	jmp correctfive
	incorrecfive:

	mov DX, [knightplacex] 
	add DX, 1
	mov CX, [knightplacey] 
	sub CX, 2

	cmp dx, ax
	jne incorrecsix
	cmp cx, bx
	jne incorrecsix

	mov [allowedmove],1
	correctfive:
	jmp correctsix
	incorrecsix:

	mov DX, [knightplacex] 
	add DX, 2
	mov CX, [knightplacey] 
	add CX, 1


	cmp dx, ax
	jne incorrecseven
	cmp cx, bx
	jne incorrecseven

	mov [allowedmove],1
	correctsix:
	jmp incorreceight
	incorrecseven:

	mov DX, [knightplacex] 
	add DX, 2
	mov CX, [knightplacey] 
	sub CX, 1

	cmp dx, ax
	jne incorreceight
	cmp cx, bx
	jne incorreceight
	
	cmp ax,0
	jb incorreceight
	cmp bx,0
	jb incorreceight

	cmp ax,[bigsiz]
	ja incorreceight
	cmp bx,[bigsiz]
	ja incorreceight
	
	mov [allowedmove],1

	incorreceight:

	checktotalend:
	pop bp
	ret 4
endp checkmovementk



proc fullboardmake ;----------- makes the whole board v
	mov [brdsiz] ,200
	mov [knightplacex] , 0
	mov [knightplacey] , 0
	mov [increone],0
	mov [incretwo],0
	mov [whichtwo],0


	
	call fixsiz ; --- get board values (works)
	call finpix ; compute values (works)

	mov ax,2h;mouse disappear
	int 33h	
	call makeboard ; make game board with values (works)
	mov ax,1h;mouse appear
	int 33h	

	mov [color],4 ;---- make first square red
	push 0
	push 0
	call colorsquare

	call sethasbeen
	ret
endp fullboardmake

proc checkoutbound
	PUSH BP
    MOV BP, SP

	MOV AX, [BP+6]
	MOV BX, [BP+4]

	;mov dl, al
	;add dl, '0'
	;mov ah, 2h   ; call interrupt to display a value in DL
   	;int 21h 

	;mov dl, bl
	;add dl, '0'
	;mov ah, 2h   ; call interrupt to display a value in DL
   	;int 21h 

	mov [allowedmove],0

	cmp ax,0
	jb outbound
	cmp bx,0
	jb outbound

	cmp ax,[bigsiz]
	jae outbound
	cmp bx,[bigsiz]
	jae outbound

	mov [allowedmove],1
	outbound:
	pop bp
	ret 4
endp checkoutbound

proc gameloop ;----------------- full gameloop check

	loppps:
	call getkplace ;get mouse tile
	mov [wor],1
	call setnuminarray
	cmp [wor + bx],1
	je wrongpalce

	push [kplacex] ; check if posiion allowed with movement
	push [kplacey]
	call checkmovementk
	cmp [allowedmove],0
	je wrongpalce

	call playSound ; sound

	mov ax,[kplacex] ; move knight
	mov [knightplacex] ,ax
	mov ax,[kplacey]
	mov [knightplacey] ,ax

	push [kplacex] ; change square
	push [kplacey]
	call colorsquare

	wrongpalce:
	jmp loppps ; loop til solve
	ret
endp gameloop

notpossible:
call restarting

proc sethasbeen
	mov al, [siz]
	mul [siz]
	mov bx,ax
	sethasloop:
		dec bx
		mov [wor+bx],0
		cmp bx,0
		ja sethasloop

	ret
endp sethasbeen

proc resetsolutionmoves
	mov al, [siz]
	mul [siz]
	mov bx,ax
	sethaslooptwo:
		dec bx
		mov [wor+bx],0
		cmp bx,0
		ja sethaslooptwo

	ret
endp resetsolutionmoves

proc setnuminarray
	;[kplacex] [kplacey]
	xor ax,ax
	mov CX,[kplacex]
	mov DX,[kplacey]
	mov al,[siz]
	mul cl

	add al, dl
	mov bx,ax
	ret	
endp setnuminarray


proc imageknight
	mov [BmpLeft], 0
	mov [BmpTop], 0
	mov [BmpColSize], 48
	mov [BmpRowSize], 192
    mov dx, offset button
	call OpenShowBmp
	cmp [ErrorFile],1
	jne cont123
	jmp exitError2
	cont123:
	jmp exit12
	exitError2:
    mov dx, offset BmpFileErrorMsg
	ret
endp imageknight


proc imagerestart
	mov [BmpLeft], 260
	mov [BmpTop], 0
	mov [BmpColSize], 48
	mov [BmpRowSize], 192
    mov dx, offset restart
	call OpenShowBmp
	cmp [ErrorFile],1
	jne cont1234
	jmp exitError21
	cont1234:
	jmp exit12
	exitError21:
    mov dx, offset BmpFileErrorMsg
	ret
endp imagerestart

proc solutionpressed ; when left side clicked

	call solutionmainloop
	
	ret
endp solutionpressed

proc solutionmainloop
	mov [movesinsolve], 1

	mainsolutionlooping:


		mov si, 0
		mov [knightplacex],0
		mov [knightplacey],0
		mov [kplacex],0
		mov [kplacey],0
		call sethasbeen ; been to the first square
		mov [wor], 1
		

		runningsolutionmaking:

			;mov dl, [movesinsolve + 1]
			;add dl, '0'
			;mov ah, 2h   ; call interrupt to display a value in DL
   			;int 21h 

			;check if reached solution
			mov al, [siz]
			mul [siz]
			dec ax
			dec ax

			cmp si,ax
			ja totalendsolution

			cmp [movesinsolve],0
			je totalendsolution

			cmp [movesinsolve+si],0
			je checkingrightolution

			xor ah,ah
			mov al,[movesinsolve+si]
			push ax

			call numtomuvementcheck

			; check if possible move
			push [kplacex]
			push [kplacey]
			call checkoutbound

			cmp [allowedmove],0
			je checkingwrongsolution
		
			;check if exist in data base
			call setnuminarray
			cmp [wor + bx],1
			je checkingwrongsolution

			mov ax,[kplacex] ; move knight
			mov [knightplacex] ,ax
			mov ax,[kplacey]
			mov [knightplacey] ,ax

			call setnuminarray
			mov [wor + bx ], 1

			
			inc si

			jmp runningsolutionmaking


	checkingwrongsolution:
	
	call addoneandremove

	;mov dl, 9
	;add dl, '0'
	;mov ah, 2h   ; call interrupt to display a value in DL
   	;int 21h 

	jmp mainsolutionlooping


	checkingrightolution:

	;mov dl, 2
	;add dl, '0'
	;mov ah, 2h   ; call interrupt to display a value in DL
   	;int 21h 

	call addonecuzright
	jmp mainsolutionlooping



	totalendsolution:
	call showsolution
	ret
endp solutionmainloop

proc showsolution

	;------------- show in numbers
	;mov si, 0
	;looptosee:

	;mov dl, [movesinsolve + si ]
	;add dl, '0'
	;mov ah, 2h   ; call interrupt to display a value in DL
   	;int 21h 

	;inc si

	;mov al, [siz]
	;mul [siz]
	;dec ax

	;cmp si, ax
	;jne looptosee
	
	;cmp [movesinsolve],0
	;je impossibletryagain
	;------------- show in numbers


;-------------------------
	mov [kplacex], 0
	mov [kplacey], 0

	mov si, 0
	looptoseeTWO:

	mov al, [movesinsolve + si ]
	xor ah,ah
	push ax
	;----------------------------wait 1 sec
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	call oneTick
	;----------------------------wait 1 sec
	call numtomuvementcheck

	push [kplacex]
	push [kplacey]
	mov [color] , 4
	call colorsquare
	call playSound
	
	inc si

	mov al, [siz]
	mul [siz]
	dec ax

	cmp si, ax
	jne looptoseeTWO


	mov si, 0

	jmp impossibletryagain

	ret
endp showsolution

impossibletryagain:
	call restarting

proc addonecuzright ; ---- works
	mov bx,0
	sethasloopfour:
		inc bx
		cmp [movesinsolve+bx],0
		ja sethasloopfour
	inc [movesinsolve+bx]

	ret
endp addonecuzright

proc addoneandremove  ;  works
 ;------ gets next move in a array of moves works but not teste

	mov bx,0
	sethasloopthree:

		inc bx

		cmp [movesinsolve+bx],9
		je foundanine
		

		cmp [movesinsolve+bx],0
		ja sethasloopthree


	dec bx
	inc [movesinsolve+bx]

	cmp [movesinsolve+bx],9
	je foundanine

	jmp addoneandremoveend

	foundanine:

	mov [movesinsolve+bx], 0

	dec bx
	inc [movesinsolve+bx]

	cmp [movesinsolve+bx],9
	je foundanine
	jmp addoneandremoveend

	impossible:
	call restarting

	addoneandremoveend:
	ret
endp addoneandremove

proc numtomuvementcheck ;--------- gets num 1 - 8 and returns where the knight would be in [wheremovtox],[wheremovtoy] (prob need reset before use)
	PUSH BP
    MOV BP, SP

	MOV BX, [BP+4]

	cmp BX, 1
	jne nexttrycheckm1
	add [kplacex], 1
	sub [kplacey], 2
	nexttrycheckm1:

	cmp BX, 2
	jne nexttrycheckm2
	add [kplacex], 2
	sub [kplacey], 1
	nexttrycheckm2:

	cmp BX, 3
	jne nexttrycheckm3
	add [kplacex], 2
	add [kplacey], 1
	nexttrycheckm3:

	cmp BX, 4
	jne nexttrycheckm4
	add [kplacex], 1
	add [kplacey], 2
	nexttrycheckm4:

	cmp BX, 5
	jne nexttrycheckm5
	sub [kplacex], 1
	add [kplacey], 2
	nexttrycheckm5:

	cmp BX, 6
	jne nexttrycheckm6
	sub [kplacex], 2
	add [kplacey], 1
	nexttrycheckm6:

	cmp BX, 7
	jne nexttrycheckm7
	sub [kplacex], 2
	sub [kplacey], 1
	nexttrycheckm7:

	cmp BX, 8
	jne nexttrycheckm8
	sub [kplacex], 1
	sub [kplacey], 2
	nexttrycheckm8:

	POP BP
	ret 2
endp numtomuvementcheck

proc restarting;-------------------------when restarting
	mov [changeorno] ,0h
	call imagerestart
	call imageknight
	call generaterandomone

	mov al, [colorrandomizer]
	mov [color],al

	call fullboardmake
	call gameloop
	ret
endp restarting
; -----------------------------------------------------------------start

start:
;----------------- protocols
	mov ax, @data
	mov ds, ax
	; Graphic mode
	mov ax, 13h
	int 10h
	;see mouse
	mov ax,1h
	int 33h	


; -------------------------- code
	call imagerestart
	call imageknight
	call generaterandomone
	call fullboardmake
	call gameloop
	;call pictureee
	 
	; Return to text mode  
	;mov ax, 2h
	;int 10h
	;push 3

	;call numtomuvementcheck

			; check if possible move
	;push [kplacex]
	;push [kplacey]
	;call checkoutbound


	;mov dx, [allowedmove]
	;add dl, '0'
	;mov ah, 2h   ; call interrupt to display a value in DL
   	;int 21h 

	;mov dl, [movesinsolve]
	;add dl, '0'
	;mov ah, 2h   ; call interrupt to display a value in DL
   	;int 21h 

	;mov dl, [movesinsolve + 1]
	;add dl, '0'
	;mov ah, 2h   ; call interrupt to display a value in DL
   	;int 21h 
	
exit:
	mov ax, 4c00h
	int 21h
END start