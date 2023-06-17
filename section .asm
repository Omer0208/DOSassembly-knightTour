section .data
    n db 0
    board db 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0, 0, 0, 0, 0, 0, 0, 0, 0
    dx db -2, -2, -1, -1, 1, 1, 2, 2
    dy db 1, -1, 2, -2, 2, -2, 1, -1
    row db 0
    col db 0

section .text
    global _start

_start:
    ; Prompt the user for the size of the board
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_size_of_board
    mov edx, prompt_size_of_board_len
    int 0x80

    ; Read the user's input into n
    mov eax, 3
    mov ebx, 0
    mov ecx, n
    mov edx, 2
    int 0x80

    ; Calculate the size of the board and allocate memory
    add al, '0'
    sub al, 48
    inc eax
    movzx eax, al
    mov edi, eax
    add edi, 1
    shl edi, 2
    push edi
    push edi
    call malloc
    add esp, 8
    mov [board], eax

    ; Initialize row and col variables
    mov [row], al
    mov [col], 1

    ; Find the knight's tour
    push 1
    push dword [col]
    push dword [row]
    call findTour
    add esp, 12

    ; Check if a solution was found
    cmp eax, 0
    jne solution_found

    ; Print "No solution found."
    mov eax, 4
    mov ebx, 1
    mov ecx, no_solution_found
    mov edx, no_solution_found_len
    int 0x80

    ; Exit the program
    mov eax, 1
    xor ebx, ebx
    int 0x80

solution_found:
    ; Print the board
    call printBoard

    ; Exit the program
    mov eax, 1
    xor ebx, ebx
    int 0x80

findTour:
    ; Prologue
    push ebp
    mov ebp, esp

    ; Save the register values
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Initialize board[row][col] to count
    movzx eax, byte [ebp + 8] ; row
    imul eax, dword [n + 1]
    add eax, byte [ebp + 12] ; col
    mov edi, eax
    add edi, edi
    shl edi, 2
    add edi, [board]
    movzx eax, byte [ebp + 16] ; count
    mov [edi], eax

    ; Check if count == n * n
    mov eax, byte [ebp + 16]
    movzx ecx, byte [n]
    mul ecx
    cmp eax, ecx
    jne check_moves

    ; Set the return value to true (1)
    mov eax, 1
    jmp findTour_epilogue

check_moves:
    ; Generate knight's moves
    movzx ecx, byte [ebp + 8] ; row
    movzx edx, byte [ebp + 12] ; col
    push edx
    push ecx
    call generateMoves
    add esp, 8

    ; Sort the moves
    push eax
    push eax
    push edx
    push ecx
    call sortMoves
    add esp, 16

    ; Iterate over the moves
    mov eax, dword [n + 1]
    mul ecx ; Multiply n by row
    add eax, edx ; Add col
    mov ebx, eax ; Store the result in ebx
    mov esi, eax
    add esi, esi
    shl esi, 2
    add esi, [board]
    xor ecx, ecx ; Initialize the loop counter

iterate_moves:
    ; Get the next move
    mov edx, ecx
    shl edx, 2
    add edx, eax
    add edx, edx
    shl edx, 2
    add edx, [eax + 4] ; Get the pointer to the move
    movzx eax, byte [edx] ; Get the row
    movzx edx, byte [edx + 1] ; Get the col

    ; Check if board[nextRow][nextCol] == 0
    movzx edi, byte [n]
    mov ebx, eax
    imul ebx, dword [n + 1]
    add ebx, edx
    add ebx, ebx
    shl ebx, 2
    add ebx, [board]
    mov edx, [ebx]
    cmp edx, 0
    jne next_move

    ; Call findTour recursively
    push ecx
    push edx
    push eax
    inc byte [ebp + 16] ; Increment count
    call findTour
    add esp, 12

    ; Check if a solution was found
    cmp eax, 1
    jne next_move

    ; Set the return value to true (1)
    mov eax, 1
    jmp findTour_epilogue

next_move:
    ; Increment the loop counter
    inc ecx
    cmp ecx, 8
    jl iterate_moves

    ; Clean up and return false (0)
    xor eax, eax

findTour_epilogue:
    ; Restore the register values
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx

    ; Epilogue
    mov esp, ebp
    pop ebp
    ret

generateMoves:
    ; Prologue
    push ebp
    mov ebp, esp

    ; Save the register values
    push ebx
    push ecx
    push edx

    ; Get the row and col arguments
    movzx ecx, byte [ebp + 8] ; row
    movzx edx, byte [ebp + 12] ; col

    ; Allocate memory for moves
    mov eax, 32
    push eax
    call malloc
    add esp, 4
    mov edi, eax ; Store the address in edi

    ; Generate the moves
    xor ecx, ecx ; Initialize the loop counter

generate_moves_loop:
    ; Get the next dx and dy values
    movzx eax, byte [dx + ecx]
    movzx ebx, byte [dy + ecx]

    ; Calculate the nextRow and nextCol
    add eax, ecx
    add edx, ebx

    ; Check if nextRow and nextCol are within the board bounds
    movzx ebx, byte [n]
    cmp eax, 1
    jl next_move_iteration
    cmp eax, ebx
    jg next_move_iteration
    cmp edx, 1
    jl next_move_iteration
    cmp edx, ebx
    jg next_move_iteration

    ; Add the move to the moves array
    mov byte [edi], al
    mov byte [edi + 1], dl
    add edi, 2

next_move_iteration:
    ; Increment the loop counter
    inc ecx
    cmp ecx, 8
    jl generate_moves_loop

    ; Clean up and return the moves array
    mov eax, edi

    ; Restore the register values
    pop edx
    pop ecx
    pop ebx

    ; Epilogue
    mov esp, ebp
    pop ebp
    ret

sortMoves:
    ; Prologue
    push ebp
    mov ebp, esp

    ; Save the register values
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Get the moves and the number of moves
    mov edx, [ebp + 8]
    movzx ecx, byte [edx - 4] ; Get the number of moves

    ; Sort the moves using bubble sort
    xor esi, esi ; Initialize the outer loop counter

outer_loop:
    ; Initialize the inner loop counter
    xor edi, edi
    mov eax, edx ; Reset eax to the start of the moves array

inner_loop:
    ; Get the current and next moves
    movzx ebx, byte [eax]
    movzx esi, byte [eax + 2]
    movzx esi, byte [eax + 3]

    ; Generate moves for the current and next positions
    push esi
    push ebx
    call generateMoves
    add esp, 8
    movzx esi, byte [n]
    movzx edi, byte [n]
    mul esi ; Multiply n by n
    mov esi, eax ; Store the result in esi
    movzx edi, byte [n]
    mul edi ; Multiply n by n
    cmp esi, edi
    jb swap_moves

no_swap:
    ; Increment the inner loop counter
    inc edi
    cmp edi, ecx
    jl inner_loop

    ; Increment the outer loop counter
    inc esi
    cmp esi, ecx
    jl outer_loop

    ; Restore the register values
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx

    ; Epilogue
    mov esp, ebp
    pop ebp
    ret

swap_moves:
    ; Swap the current and next moves
    xchg al, [eax]
    xchg dl, [eax + 2]
    xchg dl, [eax + 3]

    ; Jump to no_swap
    jmp no_swap

printBoard:
    ; Prologue
    push ebp
    mov ebp, esp

    ; Save the register values
    push ebx
    push ecx
    push edx

    ; Initialize the loop counters
    xor ecx, ecx ; Outer loop counter (i)
    xor edx, edx ; Inner loop counter (j)

    ; Print the board
    mov eax, 1 ; File descriptor (stdout)
    mov ebx, 0 ; Buffer
    mov edx, 1 ; Number of characters to write

print_board_outer_loop:
    ; Print the current row
    mov esi, [ebp + 8] ; n
    inc esi ; Increment n by 1
    mul ecx ; Multiply n by i
    add esi, edx ; Add j
    movzx esi, byte [esi + ebp + 12] ; Get the value at board[i][j]

    ; Convert the value to a string
    push edx
    push ecx
    call itoa
    add esp, 8

    ; Print the string
    add eax, 4 ; Adjust eax to point to the string
    sub edx, 1 ; Subtract 1 from edx to exclude the null terminator
    int 0x80

    ; Print a tab character
    mov eax, 4 ; Write syscall
    mov ebx, 1 ; File descriptor (stdout)
    mov ecx, tab_char ; Address of the tab character
    mov edx, 1 ; Number of characters to write
    int 0x80

    ; Increment the inner loop counter
    inc edx
    cmp edx, esi
    jl print_board_outer_loop

    ; Print a newline character
    mov eax, 4 ; Write syscall
    mov ebx, 1 ; File descriptor (stdout)
    mov ecx, newline_char ; Address of the newline character
    mov edx, 1 ; Number of characters to write
    int 0x80

    ; Increment the outer loop counter
    inc ecx
    cmp ecx, esi
    jl print_board_outer_loop

    ; Clean up

    ; Restore the register values
    pop edx
    pop ecx
    pop ebx

    ; Epilogue
    mov esp, ebp
    pop ebp
    ret

itoa:
    ; Prologue
    push ebp
    mov ebp, esp

    ; Save the register values
    push ebx
    push edi

    ; Check if the value is zero
    mov eax, [ebp + 8]
    test eax, eax
    jnz nonzero

    ; Set the string to '0'
    mov eax, '0'
    mov byte [ebp + 12], al

    ; Jump to done
    jmp done

nonzero:
    ; Convert the value to a string
    xor ebx, ebx ; Initialize the counter
    cmp eax, 0
    jge positive
    neg eax ; Negate the value
    mov byte [ebp + 12], '-'
    inc ebx

positive:
    ; Convert the value to a string
    mov edi, 10 ; Divide by 10
    div edi
    add edx, '0' ; Convert the remainder to ASCII
    dec ebp ; Decrement ebp to exclude the null terminator
    mov [ebp + ebx + 12], dl ; Store the character in the string
    inc ebx
    test eax, eax
    jnz positive

    ; Reverse the string
    mov edi, 1 ; Start from the beginning of the string
    dec ebx ; Decrement ebx to exclude the null terminator
    mov ecx, ebx ; Set ecx to the string length
    shr ecx, 1 ; Divide the length by 2
    jz done_reverse

reverse_loop:
    mov al, [ebp + edi + 12]
    xchg al, [ebp + ebx + 12]
    mov [ebp + edi + 12], al
    inc edi
    dec ebx
    loop reverse_loop

done_reverse:
    ; Add the null terminator
    mov byte [ebp + edi + 12], 0

done:
    ; Clean up

    ; Restore the register values
    pop edi
    pop ebx

    ; Epilogue
    mov esp, ebp
    pop ebp
    ret

section .data
n db 0
board dd 0
dx db -2, -2, -1, -1, 1, 1, 2, 2
dy db 1, -1, 2, -2, 2, -2, 1, -1
tab_char db 9 ; ASCII code for tab
newline_char db 10 ; ASCII code for newline