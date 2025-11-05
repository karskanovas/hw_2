global _start

_start:
    
    mov rax, 1                  
    mov rdi, 1                  
    lea rsi, [rel msg_in]       ; Адрес сообщения msg_in
    mov rdx, msg_in_len         ; Длина сообщения
    syscall 
    
    sub rsp, 128        ; резервируем место в стеке
    mov rax, 0          ; вводим строку
    mov rdi, 0
    mov rsi, rsp
    mov rdx, 100        ;максимум 100 символов
    syscall
    mov rcx, rax        ;сохраняем длину введённой строки
    dec rcx             ;убираем \n, чтобы не печатать его

    lea rsi, [rsp]
    mov rdx, rcx        ; rdx = длина строки
    mov r8, rcx         ;чтобы не выводилло лишнее
    call reverse       ;Вызов функции reverse(rsi=строка, rdx=длина)

    mov byte [rsi+r8], 10       ; '\n'
    mov byte [rsi+r8+1], 0      ; конец строки

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg_out]      ; Адрес текста "Reversed:"
    mov rdx, msg_out_len        ; Его длина
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, rsp        ;Указатель на перевёрнутую строку
    mov rdx, r8
    add rdx, 1        ;Количество символов для вывода
    syscall

    add rsp, 128        ;Восстанавливаем стек
    mov rax, 60
    xor rdi, rdi
    syscall

reverse:        ;аргументы: rsi — указатель на строку, rdx — длина строки
    push rbx        ;будем использовать как счётчик
    xor rbx, rbx        ;счётчик с начала строки
.loop:
    cmp rbx, rdx
    jge .done       ; Если rbx >= rdx — выходим из цикла
    mov al, [rsi+rbx]       ;символ слева
    mov ah, [rsi+rdx-1]     ; ah = символ справа
    mov [rsi+rbx], ah        ; записываем правый символ на место левого
    mov [rsi+rdx-1], al     ; записываем левый символ на место правого
    inc rbx     ; сдвигаемся с начала строки вперёд
    dec rdx     ; сдвигаемся с конца строки назад
    jmp .loop       ; повторяем, пока не дойдём до середины
.done:
    pop rbx
    ret

msg_in:     db "Enter your string: ",0
msg_in_len  equ $ - msg_in
msg_out:    db 10,"Reversed: ",0
msg_out_len equ $ - msg_out
