section .data                      ; sección de datos inicializados
    indicacion      db  "Ingrese una cadena (max 50): ", 10
                                    ; mensaje de petición + salto de línea
    indicacion_len  equ $-indicacion
                                    ; longitud del mensaje anterior

    out_msg         db  "Cantidad de vocales: "
                                    ; prefijo del resultado (sin LF)
    out_len         equ $-out_msg
                                    ; longitud del prefijo

    newline         db  10          ; salto de línea para final de salida

section .bss                       ; sección de datos no inicializados
    buffer          resb    51      ; espacio para hasta 50 caracteres + '\n'
    digit_buf       resb    20      ; buffer para conversión a ASCII de número

section .text                      ; sección de código ejecutable
    global _start                  ; punto de entrada para el linker

_start:
    ; 1) write(1, indicacion, indicacion_len)
    mov     rax, 1                  ; RAX = 1 en syscall número 1 = write
    mov     rdi, 1                  ; RDI = 1 en file descriptor stdout
    mov     rsi, indicacion         ; RSI = &indicacion en puntero al mensaje
    mov     rdx, indicacion_len     ; RDX = longitud del mensaje
    syscall                         ; invoca write(stdout, indicacion, len)

    ; 2) read(0, buffer, 50)
    mov     rax, 0                  ; RAX = 0 en syscall número 0 = read
    mov     rdi, 0                  ; RDI = 0 en fd = stdin
    mov     rsi, buffer             ; RSI = &buffer en dónde guardar bytes
    mov     rdx, 50                 ; RDX = 50 en máxima lectura de 50 bytes
    syscall                         ; invoca read(stdin, buffer, 50)
    mov     rbx, rax                ; RBX = número de bytes leídos

    ; 3) Contar vocales en buffer
    xor     rcx, rcx                ; RCX = 0 → contador de vocales
    mov     rsi, buffer             ; RSI = &buffer en puntero de lectura

count_loop:
    cmp     rbx, 0                  ; ¿quedan bytes por procesar?
    je      done_count              ; si RBX==0, fin del bucle

    mov     al, [rsi]               ; AL = *RSI en carácter actual
    mov     dl, al                  ; DL = AL en copia para normalizar
    cmp     al, 'A'                 ; si AL < 'A'
    jl      skip_upper             ; saltar si no es mayúscula
    cmp     al, 'Z'                 ; si AL > 'Z'
    jg      skip_upper             ; saltar si no es mayúscula
    add     dl, 32                  ; DL += 32 convierte 'A'..'Z' → 'a'..'z'

skip_upper:
    cmp     dl, 'a'                 ; comparar con 'a'
    je      is_vowel                ; si igual, es vocal
    cmp     dl, 'e'                 ; comparar con 'e'
    je      is_vowel
    cmp     dl, 'i'                 ; comparar con 'i'
    je      is_vowel
    cmp     dl, 'o'                 ; comparar con 'o'
    je      is_vowel
    cmp     dl, 'u'                 ; comparar con 'u'
    jne     next_char               ; si no es ninguna, siguiente

is_vowel:
    inc     rcx                      ; RCX++ en contamos una vocal

next_char:
    inc     rsi                      ; RSI++ en siguiente carácter
    dec     rbx                      ; RBX-- en un byte menos por procesar
    jmp     count_loop               ; repetir bucle

done_count:
    ; 4) write(1, out_msg, out_len)
    mov     rax, 1                  ; syscall write
    mov     rdi, 1                  ; fd = stdout
    mov     rsi, out_msg            ; puntero al prefijo
    mov     rdx, out_len            ; longitud del prefijo
    syscall                         ; invoca write()

    ; 5) Convertir RCX (contador) a ASCII decimal en digit_buf
    mov     rax, rcx                 ; RAX = contador de vocales
    lea     rdi, [digit_buf + 19]    ; RDI apunta al final del buffer
    mov     byte [rdi], 0            ; colocar terminador NUL

    cmp     rax, 0                   ; si contador == 0
    jne     conv_loop                ; saltar a conversión normal
    ; caso especial contador=0 → imprimir '0'
    mov     byte [rdi-1], '0'        ; escribir '0' antes del NUL
    lea     rsi, [rdi-1]             ; RSI = &"0"
    mov     rdx, 1                   ; longitud = 1 dígito
    jmp     print_number             ; ir a impresión

conv_loop:
    xor     rdx, rdx                 ; RDX=0 antes de DIV
    mov     rbx, 10                  ; divisor = 10
    div     rbx                      ; RAX = cociente, RDX = resto
    add     dl, '0'                  ; resto en ASCII '0'..'9'
    dec     rdi                      ; mover puntero un byte atrás
    mov     [rdi], dl                ; guardar dígito en buffer
    cmp     rax, 0
    jne     conv_loop                ; repetir mientras cociente > 0

    ; preparar parámetros para write()
    lea     rsi, [rdi]               ; RSI = inicio de la cadena dígitos
    lea     rdx, [digit_buf + 19]    ; RDX = fin teórico
    sub     rdx, rsi                 ; RDX = longitud = fin – inicio

print_number:
    ; 6) write(1, rsi, rdx)
    mov     rax, 1                  ; syscall write
    mov     rdi, 1                  ; fd = stdout
    syscall                         ; invoca write(rsi, rdx)

    ; 7) Salto de línea final
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, newline            ; puntero a '\n'
    mov     rdx, 1                  ; longitud = 1
    syscall                         ; invoca write()

    ; 8) exit(0)
    mov     rax, 60                 ; syscall número 60 = exit
    xor     rdi, rdi                ; RDI = 0 en código de salida
    syscall                         ; invoca exit(0)
