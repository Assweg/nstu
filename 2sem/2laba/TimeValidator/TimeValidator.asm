section .data
        input db "0345", 0    ; Входная строка
msg_yes db "YES", 10, 0
msg_yes_len equ $ - msg_yes
        msg_no db "NO", 10, 0
msg_no_len equ $ - msg_no

        section .bss
        hours resb 2
minutes resb 2

section .text
        global _start

        _start:
; Преобразуем первые две цифры в число (часы)
movzx eax, byte [input + 0] ; первый символ
sub eax, '0'                ; конвертируем символ в число
movzx ebx, byte [input + 1] ; второй символ
sub ebx, '0'                ; конвертируем
        imul eax, 10                ; умножаем на 10
add eax, ebx                ; получаем часы

; Преобразуем последние две цифры в число (минуты)
movzx ecx, byte [input + 2] ; третий символ
sub ecx, '0'
movzx edx, byte [input + 3] ; четвертый символ
sub edx, '0'
imul ecx, 10                ; умножаем на 10
add ecx, edx                ; получаем минуты

; Сравниваем часы и минуты с диапазонами
cmp eax, 23
jg .no
        cmp ecx, 59
jg .no

; Если все верно, выводим "YES"
mov rax, 1          ; sys_write
        mov rdi, 1          ; stdout
        mov rsi, msg_yes    ; сообщение "YES"
mov rdx, msg_yes_len; длина сообщения
syscall
        jmp .exit

.no:
; Если неверно, выводим "NO"
mov rax, 1          ; sys_write
        mov rdi, 1          ; stdout
        mov rsi, msg_no     ; сообщение "NO"
mov rdx, msg_no_len ; длина сообщения
syscall

.exit:
; Завершаем программу
mov rax, 60         ; sys_exit
        xor rdi, rdi        ; код выхода 0
syscall
