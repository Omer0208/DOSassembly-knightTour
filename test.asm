.8086
.MODEL TINY

        CR      EQU     0dh
        LF      EQU     0ah
        SPACE   EQU     20H

.DATA?
        table           dw      81 DUP (?)      ; Worst case of 9x9 board.
        table_end       dw      ?               ; Offset of the last element in
                                                ; the table.
        jump            dw      8 DUP (?)

                        ;       (2*N+1)*2  - 0
                        ;       (N+2)*2    - 1      7 0      COLUMN 
                        ;       (-N+2)*2   - 2     6   1            R
                        ;       (-2*N+1)*2 - 3       x              O
                        ;       (-2*N-1)*2 - 4     5   2            W
                        ;       (-N-2)*2   - 5      4 3             
                        ;       (N-2)*2    - 6
                        ;       (2*N-1)*2  - 7
                        ; jump   --     Movement from the current position as
                        ;               a function of the move type.

        N               dw      ?       ; Table size.
        NN              dw      ?       ; N*N
        N2              dw      ?       ; 2*N
        N_char          db      ?       ; N as ASCII.

;       Register usage:
;       SI - current field.
;       DI - next field.
;       BX - movement type.
;       DX - info on the current field:
;               DH - allowed moves
;               DL - how many moves are tried from this field.
;       AX - info on the next field:
;               AH - allowed moves
;               AL - how many moves are tried from this field.


.DATA
                        db      'Author '
        author          db      'http://www.aleksa.org'
        table_size      db      CR, LF, 'Table size [3..9] > $'
        x_pos           db      CR, LF, 'row > $'
        y_pos           db      CR, LF, 'column  > $'
        analyzing_board db      CR, LF, 'Analyzing the board...',CR,LF,'$'
        nosolution      db      CR, LF, 'No solution.$'


.STACK 1024


.CODE
        .STARTUP
        mov     ah, 09h
        mov     dx, offset author
        int     21h             ; Display 'Table size [3..9] > '
        mov     ah, 01h
        int     21h             ; DOS call to read a char to AL.
        cmp     al, '3'
        jb      error           ; Exit if not in [3, 9] range.
        cmp     al, '9'
        jbe     ok_N
error:  jmp     finish
ok_N:   mov     N_char, al
        and     ax, 000fh       ; ASCII number -> bin number.
        mov     N, ax

        shl     ax, 1
        mov     N2, ax          ; N2 <- N*2
        mov     ax, N
        mul     al
        mov     NN, ax          ; NN <- N*N

        mov     table_end, offset table
        dec     ax              ; AX <- N*N-1
        shl     ax, 1           ; Every table element is 2 bytes.
        add     table_end, ax   ; table_end has the offset of the last element
                                ; in the table.

;---    Moves initialization.

        mov     di, offset jump

        mov     ax, N2
        inc     ax
        shl     ax, 1           ; (2*N+1)*2
        mov     [di], ax        ; Move 0.
        neg     ax
        mov     [di+8], ax      ; Move 4.
        add     di, 2           ; Point to the next element in the move list.

        mov     ax, N
        add     ax, 2
        shl     ax, 1           ; (N+2)*2
        mov     [di], ax        ; Move 1.
        neg     ax
        mov     [di+8], ax      ; Move 5.
        add     di, 2           ; Point to the next element in the move list.

        mov     ax, N
        neg     ax
        add     ax, 2
        shl     ax, 1           ; (-N+2)*2
        mov     [di], ax        ; Move 2.
        neg     ax
        mov     [di+8], ax      ; Move 6.
        add     di, 2           ; Point to the next element in the move list.

        mov     ax, N2
        neg     ax
        inc     ax
        shl     ax, 1           ; (-2*N+1)*2
        mov     [di], ax        ; Move 3.
        neg     ax
        mov     [di+8], ax      ; Move 7.

;---    Board initialization, mark illegal moves.

        mov     di, offset table; DI points to the table start.
        push    di
        xor     ax, ax
        mov     cx, NN
        cld
rep     stosw                   ; Fill the table with 0s.
        pop     di              ; Start from the beginning.
        mov     ax, 3c00h       ; Illegal moves 2,3,4 and 5 for the first
        mov     cx, N           ; column.
rep     stosw
        mov     ax, 1800h       ; Illegal moves 3 and 4 for the second column.
        mov     cx, N
rep     stosw
        mov     di, table_end
        mov     ax, 0c300h      ; Illegal moves 0,1,6 and 7 for the last
        mov     cx, N           ; row.
        std
rep     stosw
        mov     ax, 8100h       ; Illegal moves 0 and 7 for the next to last
        mov     cx, N           ; column.
rep     stosw
        mov     di, offset table
        mov     ax, 0f00h       ; Illegal moves 4, 5, 6 and 7 for the first
        mov     cx, N           ; row.
lab1:   or      [di], ax
        add     di, N2
        loop    lab1
        mov     di, offset table+2
        mov     ax, 0600h       ; Illegal moves 5 and 6 for the second row.
        mov     cx, N
lab2:   or      [di], ax
        add     di, N2
        loop    lab2
        mov     di, table_end
        mov     ax, 0f000h      ; Illegal moves 0,1,2 and 3 for the last row.
        mov     cx, N
lab3:   or      [di], ax
        sub     di, N2
        loop    lab3
        mov     di, table_end
        sub     di, 2
        mov     ax, 6000h       ; Illegal moves 1 and 2 for the last row.
        mov     cx, N
lab4:   or      [di], ax
        sub     di, N2
        loop    lab4

;---    Set starting position - first column, then row.

        mov     ah, 09h         ; DOS call to display the message.
        mov     dx, offset x_pos
        int     21h             ; 'column >'
        mov     ah, 01h         ; DOS call to read a character into AL.
        int     21h
        cmp     al, '1'
        jb      lab5            ; Exit if not within bounds.
        cmp     al, N_char      ; Exit if greater than table size.
        ja      lab5
        mov     cl, al
        mov     ah, 09h         ; DOS call to display the message.
        mov     dx, offset y_pos
        int     21h             ; 'row  >'
        mov     ah, 01h
        int     21h             ; DOS call to read a char to AL.
        cmp     al, '1'
        jb      lab5
        cmp     al, N_char      ; Exit if greater than table size.
        jbe     ok              ; Looks good.
lab5:   jmp     finish          ; As finish is more than 128 bytes away.
ok:     mov     ch, al          ; CH - row, CL - column.
        mov     ah, 09h
        mov     dx, offset analyzing_board
        int     21h             ; 'Analyzing the board...'
        and     cx, 0f0fh       ; Convert from ASCII to a number.
        dec     cl              ; Subtract 1 to mark the right field.
        dec     ch

;---    Set SI to point to the starting field.

        mov     ax, N
        mul     ch              ; AL <- row*N
        xor     ch, ch
        add     ax, cx          ; AL <- row*N + column
        shl     ax, 1           ; and multiply everything by 2.
        mov     si, offset table
        add     si, ax          ; SI - now pointing to the starting position.
        xor     bx, bx          ; BX <- 0
        mov     dx, [si]        ; Put the info on the current field.
        mov     dl, 1           ; Fields visited so far.

;---    Start filling the board.

        mov     cx, NN          ; !!!
search: rol     dh, 1           ; Rotate left, MSB is in CF.
        jc      nomove          ; Illegal move.
        mov     di, si
        add     di, jump[bx]    ; DI has the address of the next field.
        mov     ax, [di]        ; Load it.
        test    al, al          ; Is it taken?
        jnz     nomove          ; Yes.
        mov     [si], dx        ; No, store the old field,
        push    si              ; 
        push    bx              ; and what was the last move from that field.
        mov     si, di          ; Move the pointer to the new field.
        mov     dh, ah          ; Illegal moves go to DH.
        inc     dl              ; Increment the visited fields number.
        xor     bx, bx          ; Start with move 0.
        cmp     dl, cl          ; Did you fill the board?
        jne     search          ; No.
        jmp     short print     ; Yes, print it.
nomove: add     bx, 2           ; Try the next move.
        cmp     bx, 16          ; Have you tried all moves?
        jb      search          ; No.
        cmp     dl, 1           ; Are you back to the starting position?
        je      sorry           ; Yes, then there is no solution.
        xor     dl, dl
        mov     [si], dx        ; Unmark the field.
        pop     bx              ; What was the last move?
        pop     si              ; Go back by one field.
        mov     dx, [si]
        jmp     short nomove

;--- Print the solution, but convert to ASCII first.

print : mov     [si], dx
        mov     si, offset table
        ; CS already has N*N !!!
lab7:   mov     ax, [si]
        aam
        or      ax, 3030h       ; Convert to ASCII
        mov     [si], ax
        add     si, 2
        loop    lab7
        mov     ah, 02h
        mov     dl, CR
        int     21h
        mov     dl, LF
        int     21h
        mov     si, offset table
        mov     cx, N
crt:    mov     dl, [si+1]
        cmp     dl, '0'
        jne     good
        mov     dl, SPACE
good:   int     21h
        mov     dl, [si]
        int     21h
        mov     dl, SPACE
        int     21h
        add     si, 2
        loop    crt
        mov     dl, CR
        int     21h
        mov     dl, LF
        int     21h
        cmp     si, table_end
        jg      finish
        mov     cx, N
        jmp     short crt
sorry:  mov     ah, 09h         ; Print that there is no solution.
        mov     dx, offset nosolution
        int     21h
finish: .EXIT 0

END