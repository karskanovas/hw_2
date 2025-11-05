global _start

_start:
    mov rax, 1      ;ввод первого числа
    mov rdi, 1
    lea rsi, [rel tex1]
    mov rdx, tex1_len
    syscall

    sub rsp, 128
    mov rax, 0
    mov rdi, 0
    mov rsi, rsp
    mov rdx, 32
    syscall
    
    cmp rax, 1              ;если прочитан хотя бы один символ
    jl .skip_n_check_1
    dec rax                     ;длина строки без \n
    mov byte [rsp+rax], 0       ;заменяем \n на 0
.skip_n_check_1:
    lea rsi, [rsp]
    call str2num
    mov rbx, rax       ;первое число

    mov rax, 1      ;ввод вторго числа
    mov rdi, 1
    lea rsi, [rel tex2]
    mov rdx, tex2_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, rsp
    mov rdx, 32
    syscall
    
    mov r15, rax            ; сохраняем длину
    cmp r15, 1
    jl .skip_n_check_2
    dec r15                 ; R15 = Длина строки без \n
    mov byte [rsp+r15], 0   ; Заменяем \n на 0
.skip_n_check_2:
    lea rsi, [rsp]
    call str2num
    mov rcx, rax 

    mov rdi, rbx
    mov rsi, rcx
    call addnums
    mov rbx, rax 

    lea rdi, [rsp]      ;преобразовать результат в строку
    mov rax, rbx
    call num2str

    mov rax, 1      ;вывести результат
    mov rdi, 1
    lea rsi, [rel A]
    mov rdx, A_len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, r10
    syscall

    add rsp, 128
    mov rax, 60
    xor rdi, rdi
    syscall

str2num:        ;строка -> число 
    push rbx        ;сохраняем регистры, которые будут использоваться
    push rcx
    push rsi        ;сохраняем входной 
    xor rax, rax
    xor rcx, rcx        ; флаг знака
    
    movzx rbx, byte [rsi]
    cmp bl, '-'
    jne .loop_start
    inc rsi
    mov cl, 1
    
.loop_start:
    movzx rbx, byte [rsi]        ;читаем текущий символ
    cmp bl, 0           ;конец строки
    je .end

    sub bl, '0'         ;преобразовать в цифру
    imul rax, 10
    add rax, rbx
    inc rsi
    jmp .loop_start

.end:
    cmp cl, 1
    jne .ret
    neg rax

.ret:
    pop rsi     ;восстанавливаем сохраненные регистры
    pop rcx
    pop rbx
    ret

num2str:        ; число -> строка (вход RAX, вывод в RDI, длина в R10)
    push rbx      
    push rdx
    push r8
    push r9
    push rcx
    push r11
    mov rbx, rax    
    mov r11, rdi    
    mov r9, 0       ; R9 = Флаг знака
    cmp rbx, 0      ;обработка нуля
    jne .check_sign
    mov byte [rdi], '0'
    inc rdi
    jmp .calculate_length
.check_sign:        ;обработка отрицательного числа
    cmp rbx, 0
    jge .start_division
    mov r9, 1       
    neg rbx         
.start_division:
    xor rcx, rcx    
    mov rax, rbx    
.next_digit:
    xor rdx, rdx    
    mov r8, 10
    div r8          
    add dl, '0'     
    push rdx        
    inc rcx         
    test rax, rax   
    jnz .next_digit
    cmp r9, 1       ;вывод знака 
    jne .print_digits
    mov byte [rdi], '-'
    inc rdi
.print_digits:      ;ввод цифр со стека
.print_loop:
    pop rdx         
    mov [rdi], dl
    inc rdi
    dec rcx         
    jnz .print_loop
.calculate_length:      ;расчет и возврат длины
    mov r10, rdi    
    sub r10, r11
    pop r11         
    pop rcx
    pop r9
    pop r8
    pop rdx
    pop rbx
    ret
addnums:        ;сумма 
    mov rax, rdi
    add rax, rsi
    ret

tex1: db "Enter 1 number: ",0
tex1_len equ $ - tex1
tex2: db "Enter 2 number: ",0
tex2_len equ $ - tex2
A: db 10,"Answer: ",0
A_len equ $ - A
